class Extruder
{
  Mesh planarMesh, floorMesh, extrudedMesh;
  float smoothAngle = (PI / 5) - 0.1;
  
  LoopManager loopManager;
  ArrayList<Integer[]> bridgeVertexPairs;
  ArrayList<Integer[]> extrudedBridgeVertexPairs;
  
  int numFloorCorners;
  int floorCornerIndex;
  
  int renderStartCornerIndex = 0;

  HashMap<Integer, Integer> oldToNew = new HashMap<Integer, Integer>();
  
  Extruder(Mesh m)
  {
    planarMesh = m;
  }
  
  void buildLoopManager(Mesh inputMesh)
  {
    
    ArrayList<Loop> loops = new ArrayList<Loop>();
    HashMap<Integer, Boolean> traversedVerts = new HashMap<Integer, Boolean>();
    for (int i = 0; i < inputMesh.G.size(); i++)
    {
      if (traversedVerts.containsKey(i))
        continue;
      
      ArrayList<Vertex> vertices = new ArrayList<Vertex>();
      ArrayList<Integer> vIndices = new ArrayList<Integer>();
      int vIndex = i;
      int cIndex = inputMesh.getCornerFromVertex(vIndex);
      int traceIndex = inputMesh.N.get(cIndex);
      traversedVerts.put(inputMesh.V.get(traceIndex), true);
      vertices.add(inputMesh.G.get(inputMesh.V.get(traceIndex)));
      vIndices.add(inputMesh.V.get(traceIndex));
      
      while(inputMesh.V.get(traceIndex) != inputMesh.V.get(cIndex))
      {
        traversedVerts.put(inputMesh.V.get(traceIndex), true);
        traceIndex = inputMesh.N.get(traceIndex);
        vertices.add(inputMesh.G.get(inputMesh.V.get(traceIndex)));
        vIndices.add(inputMesh.V.get(traceIndex));
      }
      loops.add(new Loop(vIndex, vIndices, vertices));
    }
    loopManager = new LoopManager(loops, inputMesh);
  }
  
  ArrayList<Vertex> getSubDivVertices(int cIndex)
  {
    Vertex origVertex = planarMesh.G.get(planarMesh.V.get(cIndex));
    float cornerOffset = planarMesh.getCornerOffset();
    int prevCorner = planarMesh.getPreviousCorner(cIndex);
    Vector3d cVec1 = planarMesh.getVectorFromCorner(prevCorner).normalize();
    Vector3d cVec2 = planarMesh.getVectorFromCorner(cIndex).normalize();
    float ang = getAngle(cVec1, cVec2);
    int numSegments = int(ang / smoothAngle);
    float segAngle = ang / float(numSegments);
    
    Vector2d traceVec = R(new Vector2d(cVec1.x, cVec1.y));
    ArrayList<Vertex> subDivVerts = new ArrayList<Vertex>();
    for (int i = 0; i <= numSegments; i++)
    {
      Vertex traceVert = new Vertex(int(origVertex.x + cornerOffset * traceVec.x), int(origVertex.y + cornerOffset * traceVec.y), 0);
      subDivVerts.add(traceVert);
      traceVec = R(traceVec, -segAngle);
    }
    return subDivVerts;
  }
  
  Mesh convertToFloor(Mesh inputMesh)
  {
    Mesh floorMesh = new Mesh();
    
    HashMap<Integer, Boolean> tracedCorners = new HashMap<Integer, Boolean>();
    HashMap<Integer, Integer> cornerVertexMap = new HashMap<Integer, Integer>();
    
    for (int i = 0; i < planarMesh.V.size(); i++)
    {
      //Create the floor loop by loop. 
      int traceCorner = i;
      if (tracedCorners.containsKey(traceCorner))
      {
        continue;
      }
        
      int vIndex1, vIndex2;
      do
      {
        int nextCorner = planarMesh.N.get(traceCorner); 
        Vertex origVertex = planarMesh.G.get(planarMesh.V.get(traceCorner));
        if (!tracedCorners.containsKey(traceCorner))
        {
          Vertex cornerPos = planarMesh.getCornerPos2d(traceCorner);
          vIndex1 = floorMesh.addVertex(cornerPos);
          tracedCorners.put(traceCorner, true);
          cornerVertexMap.put(traceCorner, vIndex1);
        }
        
        else
        {
          vIndex1 = cornerVertexMap.get(traceCorner);
        }
        
        if (!tracedCorners.containsKey(nextCorner))
        {
          Vertex cornerPos = planarMesh.getCornerPos2d(nextCorner);
          vIndex2 = floorMesh.addVertex(cornerPos);
          cornerVertexMap.put(nextCorner, vIndex2);
          tracedCorners.put(nextCorner, true);
        }
        else
        {
          vIndex2 = cornerVertexMap.get(nextCorner);
        }
        
        floorMesh.addCorners(vIndex1, vIndex2);
        
        if (planarMesh.isExternalCorner(traceCorner))
        {
          ArrayList<Vertex> subDivVertices = getSubDivVertices(traceCorner);
          Vertex v = subDivVertices.get(0);
          floorMesh.moveVertex(vIndex1, v.x, v.y, v.z);
          
          for (int j = 1; j < subDivVertices.size(); j++)
          {
            v = subDivVertices.get(j);
            vIndex1 = floorMesh.insertVertex(v, vIndex1, vIndex2);
          }
        }
        traceCorner = planarMesh.N.get(traceCorner);
      } while(traceCorner != i);
    }
    return floorMesh;
  }
  
  Mesh addWalls(Mesh inputMesh, int extrudeSection, int wallHeight)
  {
    extrudedBridgeVertexPairs = new ArrayList<Integer[]>();
    Mesh outputMesh = new Mesh(); 
    //Get starting point of floor
    //startCornerIndex is the index of a corner that is internal to the bridged floor. This ensures
    //that we extrude the inner section.
    int startCornerIndex = getStartCornerIndex(inputMesh, extrudeSection);
    
    floorCornerIndex = startCornerIndex;
    int cornerIndex = startCornerIndex;
    ArrayList<Integer> vIndices = new ArrayList<Integer>();
    do
    {
      int vIndex = floorMesh.V.get(cornerIndex);
      if (!vIndices.contains(vIndex))
        vIndices.add(vIndex);
      cornerIndex = floorMesh.N.get(cornerIndex);
    }while (cornerIndex != startCornerIndex);
   
    //Start from startCornerIndex and make new Mesh `extrudedMesh` by adding the walls
    ArrayList<Integer> floorCorners = new ArrayList<Integer>();
    do
    {
      floorCorners.add(cornerIndex);
      cornerIndex = inputMesh.N.get(cornerIndex);
    } while(cornerIndex != startCornerIndex);
    
    int vIndexOutput = 0;
    int cIndexOutput = 0;
    
    //Initialize the N and S tables so we can fill them in
    for (int i = 0; i < 6 * floorCorners.size(); i++)
    {
      outputMesh.N.add(-1);
      outputMesh.S.add(-1);
    }
    
    for (int i = 0; i < bridgeVertexPairs.size(); i++)
    {
      Integer[] pair = bridgeVertexPairs.get(i);
    }
    
    
    if (extrudeSection == 0)
    {
      for (int i = 0; i < floorCorners.size(); i++)
      {
        int vIndexInput = inputMesh.V.get(floorCorners.get(i));
        Vertex vertexFloor = inputMesh.G.get(vIndexInput);
        Vertex vertexRoof = new Vertex(vertexFloor.x, vertexFloor.y, wallHeight);
        
        //Add floor vertex
        vIndexOutput = outputMesh.addVertex(vertexFloor);
        
        oldToNew.put(vIndexInput, vIndexOutput);
        
        //Define root corner indices
        int cIndex = 3 * vIndexOutput;
        int cIndexNext = 3 * (vIndexOutput + 2);
        
        outputMesh.V.add(vIndexOutput);
        outputMesh.V.add(vIndexOutput);
        outputMesh.V.add(vIndexOutput);
        
        //Add roof vertex
        vIndexOutput = outputMesh.addVertex(vertexRoof);

        for (int k = 0; k < bridgeVertexPairs.size(); k++)
          print(" ( " + bridgeVertexPairs.get(k)[0] + ", " + bridgeVertexPairs.get(k)[1] + ")");
        if (pairInVertexPairs(new Integer[]{vIndexOutput, vIndexOutput - 1}))
          extrudedBridgeVertexPairs.add(new Integer[]{vIndexOutput, vIndexOutput - 1});
          
        
        outputMesh.V.add(vIndexOutput);
        outputMesh.V.add(vIndexOutput);
        outputMesh.V.add(vIndexOutput);
        
        //Bottom swings
        outputMesh.S.set(cIndex, cIndex + 2);
        outputMesh.S.set(cIndex + 2, cIndex + 1);
        outputMesh.S.set(cIndex + 1, cIndex);
        
        //Top swings
        outputMesh.S.set(cIndex + 3, cIndex + 4);
        outputMesh.S.set(cIndex + 4, cIndex + 5);
        outputMesh.S.set(cIndex + 5, cIndex + 3);
        
        if (i == floorCorners.size() - 1)
        {
          outputMesh.N.set(cIndex + 1, cIndex + 4);
          outputMesh.N.set(cIndex + 4, 5);
          outputMesh.N.set(5, 2);
          outputMesh.N.set(2, cIndex + 1);
          
          //Next table for floor. Make connection back to first corner
          outputMesh.N.set(cIndex, 0);
          
          //Next table for roof. Make connections back from fourth corner
          outputMesh.N.set(3, cIndex + 3);
        }
        else
        {
          //Next table for wall
          outputMesh.N.set(cIndex + 1, cIndex + 4);
          outputMesh.N.set(cIndex + 4, cIndex + 11);
          outputMesh.N.set(cIndex + 11, cIndex + 8);
          outputMesh.N.set(cIndex + 8, cIndex + 1);
          
          //Next table for floor
          outputMesh.N.set(cIndex, cIndex + 6);
          
          //Next table for roof
          outputMesh.N.set(cIndex + 9, cIndex + 3);
        }
      }
      
      
    }
    
    else if (extrudeSection == 1)
    {
      for (int i = 0; i < floorCorners.size(); i++)
      {
        int vIndexInput = inputMesh.V.get(floorCorners.get(i));
        Vertex vertexFloor = inputMesh.G.get(vIndexInput);
        Vertex vertexRoof = new Vertex(vertexFloor.x, vertexFloor.y, wallHeight);
        
        //Add floor vertex
        vIndexOutput = outputMesh.addVertex(vertexFloor);      
        
        oldToNew.put(vIndexInput, vIndexOutput);
        
        //Define root corner indices
        int cIndex = 3 * vIndexOutput;
        int cIndexNext = 3 * (vIndexOutput + 2);
        
        outputMesh.V.add(vIndexOutput);
        outputMesh.V.add(vIndexOutput);
        outputMesh.V.add(vIndexOutput);
        
        //Add roof vertex
        vIndexOutput = outputMesh.addVertex(vertexRoof);
        
        if (pairInVertexPairs(new Integer[]{vIndexInput, inputMesh.V.get(inputMesh.N.get(floorCorners.get(i)))}))
        {
          extrudedBridgeVertexPairs.add(new Integer[]{vIndexOutput - 1, vIndexOutput + 1}); 
        }
        
        outputMesh.V.add(vIndexOutput);
        outputMesh.V.add(vIndexOutput);
        outputMesh.V.add(vIndexOutput);
        
        //Bottom swings
        outputMesh.S.set(cIndex, cIndex + 2);
        outputMesh.S.set(cIndex + 2, cIndex + 1);
        outputMesh.S.set(cIndex + 1, cIndex);
        
        //Top swings
        outputMesh.S.set(cIndex + 3, cIndex + 4);
        outputMesh.S.set(cIndex + 4, cIndex + 5);
        outputMesh.S.set(cIndex + 5, cIndex + 3);
        
        if (i == floorCorners.size() - 1)
        {
          outputMesh.N.set(cIndex + 2, 1);
          outputMesh.N.set(1, 4);
          outputMesh.N.set(4, cIndex + 5);
          outputMesh.N.set(cIndex + 5, cIndex + 2);
          
          //Next table for floor. Make connection back to first corner
          outputMesh.N.set(0, cIndex);
          
          //Next table for roof. Make connections back from fourth corner
          outputMesh.N.set(cIndex + 3, 3);
        }
        else
        {
          //Next table for wall
          outputMesh.N.set(cIndex + 2, cIndex + 7);
          outputMesh.N.set(cIndex + 7, cIndex + 10);
          outputMesh.N.set(cIndex + 10, cIndex + 5);
          outputMesh.N.set(cIndex + 5, cIndex + 2);
          
          //Next table for floor
          outputMesh.N.set(cIndex + 6, cIndex);
          
          //Next table for roof
          outputMesh.N.set(cIndex + 3, cIndex + 9);
        }
      }
    }
    return outputMesh;
  }
  
  boolean pairInVertexPairs(Integer[] vPair)
  {
    for (int i = 0; i < bridgeVertexPairs.size(); i++)
    {
      Integer[] pair = bridgeVertexPairs.get(i);
      
      if (vPair[0] == pair[0] && vPair[1] == pair[1])
      {
        return true;
      }
      if (vPair[0] == pair[1] && vPair[1] == pair[0])
      {
        return true;
      }
    }
    return false;
  }
  
  boolean setInVertexPairs(Integer[] vSet)
  {
    for (int i = 0; i < bridgeVertexPairs.size(); i++)
    {
      Integer[] pair = bridgeVertexPairs.get(i);
      

      if (vSet[0] == oldToNew.get(pair[0]) && vSet[1] == oldToNew.get(pair[1]))
      {
        return true;
      }
      
      if (vSet[0] == oldToNew.get(pair[1]) && vSet[1] == oldToNew.get(pair[0]))
      {
        return true;
      }
      
      
      if (vSet[1] == oldToNew.get(pair[0]) && vSet[2] == oldToNew.get(pair[1]))
      {
        return true;
      }
      
      if (vSet[1] == oldToNew.get(pair[1]) && vSet[2] == oldToNew.get(pair[0]))
      {
        return true;
      }
      
      if (vSet[2] == oldToNew.get(pair[0]) && vSet[3] == oldToNew.get(pair[1]))
      {
        return true;
      }
      
      if (vSet[2] == oldToNew.get(pair[1]) && vSet[3] == oldToNew.get(pair[0]))
      {
        return true;
      }

      if (vSet[3] == oldToNew.get(pair[0]) && vSet[0] == oldToNew.get(pair[1]))
      {
        return true;
      }

      if (vSet[3] == oldToNew.get(pair[1]) && vSet[0] == oldToNew.get(pair[0]))
        return true;
    }
    return false;
  }
  
  Mesh getBridgedMesh(Mesh inputMesh, int extrudeSection)
  {
    
    buildLoopManager(inputMesh);
    if (loopManager.loops.size() == 1 && extrudeSection == 0)
      return inputMesh;
      
    bridgeVertexPairs = loopManager.getBridgeVertices(extrudeSection);
    for (int i = 0; i < bridgeVertexPairs.size(); i++)
    {
      Integer[] bridgeVertexPair = bridgeVertexPairs.get(i);
      inputMesh.addCorners(bridgeVertexPair[0], bridgeVertexPair[1]);
    }
    return inputMesh;
  }
  
  
  Mesh getExtrudedMesh(int extrudeSection, int wallHeight)
  { 
    if (planarMesh.G.size() == 0)
    {
      extrudedMesh = copyMesh(planarMesh);
      return extrudedMesh;
    }
    floorMesh = getBridgedMesh(convertToFloor(planarMesh), extrudeSection); 
    
    if (loopManager.loops.size() == 1 && extrudeSection == 0)
      return new Mesh();
    
    
    extrudedMesh = addWalls(floorMesh, extrudeSection, wallHeight);
    
    return extrudedMesh;
  }
  
  int getStartCornerIndex(Mesh floorMesh, int extrudeSection)
  {
    if (extrudeSection == 0)
    {
      return loopManager.getInnerLoopCorner();
    }
    return loopManager.getOuterLoopCorner();
  }
  
  //Render's the extruded mesh using different colors for wall, floor and roof
  void renderSpecial(Mesh inputMesh, int extrudeSection, boolean renderCorners2d, boolean renderCorners3d, int selectedCorner)
  {
    if (extrudedMesh == null)
      return;
      
    if (extrudedMesh.V.size() == 0)
      return;

    strokeWeight(1);
    color topFaceColor = blue_dark;
    color bottomFaceColor = blue_dark;
    color wallFaceColor = blue_light;
    
    //Render bottom face 
    floorCornerIndex = 0;
    int startCornerIndex = floorCornerIndex;
    int cornerIndex = startCornerIndex;
    fill(bottomFaceColor);
    beginShape();
    do
    {
      int vIndex = extrudedMesh.V.get(cornerIndex);
      Vertex v = extrudedMesh.G.get(vIndex);
      vertex(v.x, v.y, v.z);
      cornerIndex = extrudedMesh.N.get(cornerIndex);
    }while (cornerIndex != startCornerIndex);
    endShape();

    //Render top face
    startCornerIndex = floorCornerIndex + 3;

    cornerIndex = startCornerIndex;
    fill(topFaceColor);
    beginShape();
    do
    {
      int vIndex = extrudedMesh.V.get(cornerIndex);
      Vertex v = extrudedMesh.G.get(vIndex);
      vertex(v.x, v.y, v.z);
      cornerIndex = extrudedMesh.N.get(cornerIndex);
    } while (cornerIndex != startCornerIndex);
    endShape();
    
    //Render walls
    startCornerIndex = floorCornerIndex + 1;
    cornerIndex = startCornerIndex;
    
    
    fill(wallFaceColor);
    do
    {
      
      int vIndex1 = extrudedMesh.V.get(cornerIndex);
      
      Vertex v1 = extrudedMesh.G.get(vIndex1);
      
      cornerIndex = extrudedMesh.N.get(cornerIndex);
      int vIndex2 = extrudedMesh.V.get(cornerIndex);
      Vertex v2 = extrudedMesh.G.get(vIndex2);
      cornerIndex = extrudedMesh.N.get(cornerIndex);
      int vIndex3 = extrudedMesh.V.get(cornerIndex);
      Vertex v3 = extrudedMesh.G.get(vIndex3);
      
      cornerIndex = extrudedMesh.N.get(cornerIndex);
      int vIndex4 = extrudedMesh.V.get(cornerIndex);
      Vertex v4 = extrudedMesh.G.get(vIndex4);
      
      beginShape();
      vertex(v1.x, v1.y, v1.z);
      vertex(v2.x, v2.y, v2.z);
      vertex(v3.x, v3.y, v3.z);
      vertex(v4.x, v4.y, v4.z);
      endShape();   


      cornerIndex = extrudedMesh.S.get(cornerIndex);
      
    } while(cornerIndex != startCornerIndex);
    
    
    for (int i = 0; i < extrudedMesh.V.size(); i++)
    {
      int vIndex1 = extrudedMesh.V.get(i);
      int vIndex2 = extrudedMesh.V.get(extrudedMesh.N.get(i));
      
      Vertex v1 = extrudedMesh.G.get(vIndex1);
      Vertex v2 = extrudedMesh.G.get(vIndex2);
      stroke(dark_metal);
      
      line(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
    }

    for (int i = 0; i < extrudedMesh.G.size(); i++)
    {
      Vertex v = extrudedMesh.G.get(i);
      if (i == extrudedMesh.V.get(selectedCorner))
        v.render(yellow, 1);
      else
        v.render(blue, 1);
    }

    //Optionally render corners
    if (renderCorners2d || renderCorners3d)
    {
      for (int i = 0; i < extrudedMesh.V.size(); i++)
      //for (int i = 0; i < 1; i++)
      {
        if (renderCorners3d)
        {
          Vertex cornerPos = extrudedMesh.getCornerPos3d(i);
          if (i == selectedCorner)
            cornerPos.render(green, 2);
          else
            cornerPos.render(red, 2);
        }
      }
    }
  }
  
  Mesh copyMesh(Mesh m)
  {
    Mesh outputMesh = new Mesh();
    
    //Copy G, V, N, S
    for (int i = 0; i < m.G.size(); i++)
    {
      outputMesh.G.add(m.G.get(i));
    }
    
    for (int i = 0; i < m.V.size(); i++)
    {
      outputMesh.V.add(m.V.get(i));
      outputMesh.N.add(m.N.get(i));
      outputMesh.S.add(m.S.get(i));
    }
    return outputMesh;
  }
}

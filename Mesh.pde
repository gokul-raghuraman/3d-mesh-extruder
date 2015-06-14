class Vertex
{
  int x, y, z;
  Vertex(int p, int q, int r)
  {
    x = p;
    y = q;
    z = r;
  }
  
  void render()
  {
    stroke(blue_dark);
    strokeWeight(3);
    fill(blue_light);
    ellipse(x, y, 15, 15);
  }
  void render(color col, int radius)
  {
    renderSphere(col, radius);
  }
  
  void render(String s, color col, int radius)
  {
    renderSphere(col, radius);
    fill(red);
    stroke(black);
    textSize(12);
    text(s, x, y, z + 8);
  }
  
  void renderSphere(color col, int radius)
  {
    pushMatrix(); 
    translate(x, y, z);
    noStroke();
    fill(col, 200);
    scale(1, 1, 1); 
    sphere(radius); 
    popMatrix();
  }
  
  
}

class Mesh
{
  //Declare G, V, N, S tables
  ArrayList<Vertex> G;
  ArrayList<Integer> V;
  ArrayList<Integer> N;
  ArrayList<Integer> S;
  
  float cornerOffset = 20;
  
  Mesh()
  {
    G = new ArrayList<Vertex>();
    V = new ArrayList<Integer>();
    N = new ArrayList<Integer>();
    S = new ArrayList<Integer>();
  }
  
  float getCornerOffset()
  {
    return cornerOffset;
  }
  
  void setCornerOffset(float c)
  {
    cornerOffset = c;
  }
  
  void moveVertex(int vIndex, int x, int y, int z)
  {
    G.set(vIndex, new Vertex(x, y, z));
  }
  
  void addVertex(int x, int y, int z)
  {
    int vIndex = G.size();
    G.add(new Vertex(x, y, z));
  }
  
  int addVertex(Vertex v)
  {
    G.add(new Vertex(v.x, v.y, v.z));
    return (G.size() - 1);
  }
  
  int insertVertex(Vertex v, int vIndex1, int vIndex2)
  {
    int[] allCorners1 = getAllCorners(vIndex1);
    int[] allCorners2 = getAllCorners(vIndex2);
      
    int cIndex1 = -1;
    int cIndex2 = -1;
    for (int i = 0; i < allCorners1.length; i++)
    {
      if (V.get(N.get(allCorners1[i])) == vIndex2)
      {
        cIndex1 = allCorners1[i];
        break;
      }
    }
    
    
    for (int i = 0; i < allCorners2.length; i++)
    {
      if (V.get(N.get(allCorners2[i])) == vIndex1)
      {
        cIndex2 = allCorners2[i];
        break;
      }
    }
    
    int nextOfCorner1 = N.get(cIndex1);
    int nextOfCorner2 = N.get(cIndex2);
    int vIndex = addVertex(v);
    int cIndexNew1 = V.size();
    int cIndexNew2 = cIndexNew1 + 1;
    int swingOfCorner1 = cIndexNew2;
    int swingOfCorner2 = cIndexNew1;
    N.add(nextOfCorner1);
    N.add(nextOfCorner2);
    N.set(cIndex1, cIndexNew1);
    N.set(cIndex2, cIndexNew2);
    S.add(swingOfCorner1);
    S.add(swingOfCorner2);
    V.add(vIndex);
    V.add(vIndex);
    
    return vIndex;
  }
  
  void addCorners(int vIndex1, int vIndex2)
  {
    //Define corner indices
    int cIndex1 = V.size();
    int cIndex2 = cIndex1 + 1;

    //Get valency of v1
    int[] allCorners1 = getAllCorners(vIndex1);
    
    //Get valency of v2
    int[] allCorners2 = getAllCorners(vIndex2);
    
    if (allCorners1.length == 0)
    {
      //Both 0-valent. Happens only once
      if (allCorners2.length == 0)
      {
        int nextOfCorner1 = cIndex2;
        int nextOfCorner2 = cIndex1;
        
        int swingOfCorner1 = cIndex1;
        int swingOfCorner2 = cIndex2;
        
        N.add(nextOfCorner1);
        N.add(nextOfCorner2);
        S.add(swingOfCorner1);
        S.add(swingOfCorner2);
      }
      
    }
    
    else
    {
      if (allCorners2.length == 0)
      {
        int splitCorner = getCornerToSplit(vIndex1, vIndex2);
        
        int nextOfCorner1 = N.get(splitCorner);
        int nextOfCorner2 = cIndex1;
        int splitCornerUnswing = getUnswing(splitCorner);
        
        N.add(nextOfCorner1);
        N.add(nextOfCorner2);
        N.set(splitCorner, cIndex2);
        
        int swingOfCorner1 = splitCorner;
        int swingOfCorner2 = cIndex2;
        
        S.add(swingOfCorner1);
        S.add(swingOfCorner2);
        S.set(splitCornerUnswing, cIndex1);
      }
      
      else
      {
        int splitCorner1 = getCornerToSplit(vIndex1, vIndex2);
        int splitCorner2 = getCornerToSplit(vIndex2, vIndex1);        
        int splitCorner1Prev = getPreviousCorner(splitCorner1);
        int splitCorner2Next = N.get(splitCorner2);
        
        int nextOfCorner1 = cIndex2;
        int nextOfCorner2 = splitCorner2Next;
        
        N.add(nextOfCorner1);
        N.add(nextOfCorner2);
        N.set(splitCorner2, splitCorner1);
        N.set(splitCorner1Prev, cIndex1);
        
        int swingOfCorner1 = S.get(splitCorner1);
        int swingOfCorner2 = splitCorner2;
        int splitCorner2Unswing = getUnswing(splitCorner2);
        
        S.add(swingOfCorner1);
        S.add(swingOfCorner2);
        S.set(splitCorner1, cIndex1);
        S.set(splitCorner2Unswing, cIndex2);
      }
    }
    
    V.add(vIndex1);
    V.add(vIndex2);
    
  }
  
  int getCornerFromVertex(int vIndex)
  {
    for (int i = 0; i < V.size(); i++)
    {
      if (V.get(i) == vIndex)
        return i;
    }
    return -1;
  }
  
  int getPreviousCorner(int cIndex)
  {
    int traceIndex = N.get(cIndex);
    while(N.get(traceIndex) != cIndex)
    {
      traceIndex = N.get(traceIndex);
    }
    return traceIndex;
  }
  
  int getUnswing(int cIndex)
  {
    int traceIndex = S.get(cIndex);
    while(S.get(traceIndex) != cIndex)
    {
      traceIndex = S.get(traceIndex);
    }
    return traceIndex;
  }
  
  int[] getAllCorners(int vIndex)
  {
    //Get first corner
    int startCornerIndex = getCornerFromVertex(vIndex);
    
    if (startCornerIndex == -1)
    {
      return new int[]{};
    }
    ArrayList<Integer> allCorners = new ArrayList<Integer>();
    
    //Get all swings of this corner
    int swingCornerIndex = S.get(startCornerIndex);
    
    allCorners.add(startCornerIndex);
    while (swingCornerIndex != startCornerIndex)
    {
      allCorners.add(swingCornerIndex);
      swingCornerIndex = S.get(swingCornerIndex);
    }
    
    //Fill up the array with the swing corner indices
    int[] allCornersArray = new int[allCorners.size()];
    for (int i = 0; i < allCorners.size(); i++)
      allCornersArray[i] = allCorners.get(i);
      
    return allCornersArray;
  }
  
  int getCornerToSplit(int vIndex1, int vIndex2)
  {
    int[] allCorners = getAllCorners(vIndex1);
    
    if (allCorners.length == 1)
      return allCorners[0];
    
    Vertex vert = G.get(vIndex1);
    Vertex qvert = G.get(vIndex2);
    for (int i = 0; i < allCorners.length; i++)
    {
      int c = allCorners[i];
      int pc = getPreviousCorner(c);
      int nc = N.get(c);
      
      Vertex pvert = G.get(V.get(pc));
      Vertex nvert = G.get(V.get(nc));
      
      Vector3d vecP = (new Vector3d(pvert.x, pvert.y, pvert.z)).sub(new Vector3d(vert.x, vert.y, vert.z));
      Vector3d vecN = (new Vector3d(nvert.x, nvert.y, nvert.z)).sub(new Vector3d(vert.x, vert.y, vert.z));
      Vector3d vecQ = (new Vector3d(qvert.x, qvert.y, qvert.z)).sub(new Vector3d(vert.x, vert.y, vert.z));
      
      float ang1 = getAngle(vecP, vecQ);
      float ang2 = getAngle(vecQ, vecN);
      float ang = getAngle(vecP, vecN);
      
      if (abs(ang1 + ang2 - ang) < 1e-5)
      {
        return c;
      }
    } 
    return -1;
  }
   
  
  Vertex getVertex(int vIndex)
  {
    return G.get(vIndex);
  }
  
  boolean vertexExists(int x, int y, int z)
  {
    for (int i = 0; i < G.size(); i++)
    {
      if (sqrt(pow(G.get(i).x - x, 2) + pow(G.get(i).y - y, 2) + pow(G.get(i).z - z, 2)) <= 10)
        return true;
    }
    return false;
  }
  
  boolean verticesOverlap(Vertex v1, Vertex v2)
  {
    return (sqrt(pow(v1.x - v2.x, 2) + pow(v1.y - v2.y, 2) + pow(v1.z - v2.z, 2)) <= 10);
  }
  
  int getClosestVertex(int x, int y, int z)
  {
    for (int i = 0; i < G.size(); i++)
    {
      if (sqrt(pow(G.get(i).x - x, 2) + pow(G.get(i).y - y, 2) + pow(G.get(i).z - z, 2)) <= 15)
        return i;
    }
    return -1;
  }
  
  Vector3d getVectorFromCorner(int cIndex)
  {
    Vertex v1 = G.get(V.get(cIndex));
    Vertex v2 = G.get(V.get(N.get(cIndex)));
    Vector3d vec1 = new Vector3d(v1.x, v1.y, v1.z);
    Vector3d vec2 = new Vector3d(v2.x, v2.y, v2.z);
    return vec2.sub(vec1);  
  }
  
  int countLoops()
  {
    int numLoops = 0;
    HashMap<Integer, Boolean> cornerTraversed = new HashMap<Integer, Boolean>();
    for (int i = 0; i < V.size(); i++)
    {
      if (!cornerTraversed.containsKey(i))
      {
        numLoops += 1;
        int traceCorner = i;
        cornerTraversed.put(traceCorner, true);
        while (N.get(traceCorner) != i)
        {
          traceCorner = N.get(traceCorner);
          cornerTraversed.put(traceCorner, true);
        }
      }
    }
    return numLoops;
  }
  
  
  boolean isExternalCorner(int cIndex)
  {
    if (getAllCorners(V.get(cIndex)).length == 1)
      return true;
      
    Vector3d cVec1 = getVectorFromCorner(cIndex);
    Vector3d cVec2 = getVectorFromCorner(S.get(cIndex));
    return (det2(cVec1.normalize(), cVec2.normalize()) < 0);
  }
  
  Vector3d getFaceNormal(int cIndex)
  {
    //Applying Newell's to get face normal
    Vector3d normal = new Vector3d(0, 0, 0);
    
    int cornerIndex = cIndex;
    
    do
    {
      Vertex v1 = G.get(V.get(cornerIndex));
      Vertex v2 = G.get(V.get(N.get(cornerIndex)));
      
      normal.x += (v1.y - v2.y) * (v1.z + v1.z);
      normal.y += (v1.z - v2.z) * (v1.x + v1.x);
      normal.z += (v1.x - v2.x) * (v1.y + v1.y);
      cornerIndex = N.get(cornerIndex); 
    } while(cornerIndex != cIndex);
   
    normal.normalize();
    
    return normal;
  }
  
  
  Vertex getCornerPos3d(int cIndex)
  {
    Vector3d cVec1 = getVectorFromCorner(cIndex);
    Vector3d cVec2 = getVectorFromCorner(getPreviousCorner(cIndex));
    
    cVec1.normalize();
    cVec2.normalize();
    
    Vector3d outVec1 = getVectorFromCorner(cIndex);
    Vector3d outVec2 = getVectorFromCorner(getPreviousCorner(cIndex));
    outVec2.mul(-1);
    outVec1.normalize();
    outVec2.normalize();
    
    Vector3d faceNormal = getFaceNormal(cIndex);
    Vector3d N = N(cVec1, cVec2);
    
    float cornerConcave = -dot(faceNormal, N) / abs(dot(faceNormal, N));
    
    Vertex v1 = G.get(V.get(cIndex));
    float dir = det3(cVec1, cVec2) / (abs(det3(cVec1, cVec2)));
    cVec1 = getVectorFromCorner(cIndex);
    cVec2 = getVectorFromCorner(S.get(cIndex));
    float s = 5 * cornerConcave * dir;
    Vertex v = G.get(V.get(cIndex));
    Vector3d vec = new Vector3d(outVec1.x + outVec2.x, outVec1.y + outVec2.y, outVec1.z + outVec2.z); 
    vec.normalize();
    Vertex cornerPos = new Vertex(int(v.x + s * vec.x), int(v.y + s * vec.y), int(v.z + s * vec.z));
    cornerPos = new Vertex(int(v.x + s * vec.x), int(v.y + s * vec.y), int(v.z + s * vec.z));
    return cornerPos;
  }
  
  
  //Used for getting the position of the corner in 2D. 
  Vertex getCornerPos2d(int cIndex, float offset)
  {
    Vector3d cVec1 = getVectorFromCorner(cIndex);
    Vector3d cVec2 = getVectorFromCorner(S.get(cIndex));
    float s = offset / det2(cVec1.normalize(), cVec2.normalize());
    
    Vector2d cVec12d = new Vector2d(cVec1.x, cVec1.y);
    Vector2d cVec22d = new Vector2d(cVec2.x, cVec2.y);
    
    Vertex v = G.get(V.get(cIndex));
    Vector2d vec = cVec12d.normalize().add(cVec22d.normalize());
    
    Vertex cornerPos = new Vertex(int(v.x + s * vec.x), int(v.y + s * vec.y), 0);
    if (det2(cVec1.normalize(), cVec2.normalize()) != 0)
    {
      cornerPos = new Vertex(int(v.x + s * vec.x), int(v.y + s * vec.y), 0);
    }
    else
    {
      cornerPos = new Vertex(int(v.x - offset * vec.x), int(v.y - offset * vec.y), 0);
    }
    return cornerPos;
  }
  
  Vertex getCornerPos2d(int cIndex)
  {
    return getCornerPos2d(cIndex, cornerOffset);
  }
  
  void render(boolean renderFaces, boolean renderCorners2d, boolean renderCorners3d)
  {
    //Quick exit if no corners =)
    if (V.size() == 0)
      return;
      
    strokeWeight(1);
    color topFaceColor = metal;
    color wallFaceColor = yellow;
    
    stroke(black);
    strokeWeight(2);
    for (int i = 0; i < V.size(); i++)
    {
      Vertex v1 = G.get(V.get(i));  
      Vertex v2 = G.get(V.get(N.get(i)));
      line(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
    }
    
    for (int i = 0; i < G.size(); i++)
    {
      Vertex v = G.get(i);
      v.render();
    }
    
    //Optionally render corners
    if (renderCorners2d || renderCorners3d)
    {
      for (int i = 0; i < V.size(); i++)
      {
        if (renderCorners2d)
        {
          Vertex cornerPos = getCornerPos2d(i);
          cornerPos.render(Integer.toString(i), red, 2);
        }
        else if (renderCorners3d)
        {
          Vertex cornerPos = getCornerPos3d(i);
          cornerPos.render(Integer.toString(i), red, 2);
        }
      }
    }
  }
  
  void printData()
  {
    //Print Vertices
    print("\n======G Table=======");
    for (int i = 0; i < G.size(); i++)
    {
      Vertex v = G.get(i);
      print("\nG[" + i + "] = (" + v.x + ", " + v.y + ", " + v.z + ")");
    }
    
    print("\n\n======V Table=======");
    for (int i = 0; i < V.size(); i++)
    {
      int vIndex = V.get(i);
      print("\nV[" + i + "] = " + vIndex);
    }
    
    print("\n\n======N Table=======");
    for (int i = 0; i < N.size(); i++)
    {
      int cIndex = N.get(i);
      print("\nN[" + i + "] = " + cIndex);
    }
    
    print("\n\n======S Table=======");
    for (int i = 0; i < S.size(); i++)
    {
      int cIndex = S.get(i);
      print("\nS[" + i + "] = " + cIndex);
    } 
  }
}

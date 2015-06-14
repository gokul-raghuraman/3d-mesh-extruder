class GUIManager
{
  //(1) GUIManager is wired to build planarMesh in 2D with user input.
  //(2) extrudedMesh will build itself from planarMesh. GUIManager can 
  //    also perform read-only operations on extrudedMesh
  //(3) Both planarMesh and extrudedMesh use the same internal data structure.
  Mesh planarMesh, extrudedMesh;
  
  //Mode
  int mode;
  
  //Used for moving vertex
  int draggedVertex;
  
  //Used for drawing
  int startVertexIndex, endVertexIndex;
  Vertex startVertex, endVertex;
  boolean isDrawing;
  boolean addStartVertex;
  boolean addEndVertex;
  
  //For corner interactions
  int selectedCorner;
  
  //For viewing
  boolean view3D = false;
  
  //Used for rendering
  boolean renderMeshCorners = false;
  
  //Extrude section specifier
  int INNER_SECTION = 0;
  int OUTER_SECTION = 1;
  int extrudeSection = OUTER_SECTION;
  
  int wallHeight = 100;
  
  //Extrude operator
  Extruder extruder;
  
  GUIManager()
  {
    mode = 0;
    draggedVertex = -1;
    
    planarMesh = new Mesh();
    extrudedMesh = new Mesh();
    
    isDrawing = false;
    resetDrawVertices();
    
  }
  
  void view2D()
  {
    view3D = false;
  }
  
  void view3D()
  {
    view3D = true;
  }
  
  void setMode(int requestMode)
  {
    if (requestMode == 0 || requestMode == 1)
    {
      mode = requestMode;
    }
  }
  
  int getMode()
  {
    return mode;
  }
  
  int getDraggedVertex()
  {
    return draggedVertex;
  }
  
  void setDraggedVertex(int vIndex)
  {
    draggedVertex = vIndex;
  }
  
  void unsetDraggedVertex()
  {
    draggedVertex = -1;
  }
  
  void updateDraggedVertex(int x, int y)
  {
    planarMesh.moveVertex(draggedVertex, x, y, 0);
  }
  
  void addVertex(int x, int y)
  {
    planarMesh.addVertex(x, y, 0);
  }
  
  void resetDrawVertices()
  {
    startVertexIndex = -1;
    endVertexIndex = -1;
    startVertex = new Vertex(-1, -1, -1);
    endVertex = new Vertex(-1, -1, -1);
  }
  
  boolean isDrawing()
  {
    return isDrawing;
  }
  
  void startDraw(int x, int y)
  {
    isDrawing = true;
    if (vertexExistsPlanar(x, y))
    {
      addStartVertex = false;
      startVertexIndex = getClosestVertexPlanar(x, y);
      startVertex = planarMesh.getVertex(startVertexIndex);
    }
    else
    {
      addStartVertex = true;
      startVertex = new Vertex(x, y, 0);
    }
  }
  
  void finishDraw(int x, int y)
  {
    isDrawing = false;
    if (vertexExistsPlanar(x, y))
    {
      addEndVertex = false;
      endVertexIndex = getClosestVertexPlanar(x, y);
      endVertex = planarMesh.getVertex(endVertexIndex);
    }
    
    else
    {
      addEndVertex = true;
      endVertex = new Vertex(x, y, 0);
    }
    
    if (planarMesh.verticesOverlap(startVertex, endVertex))
      return;
      
    if (addStartVertex)
      startVertexIndex = planarMesh.addVertex(startVertex);
    
    if (addEndVertex)
      endVertexIndex = planarMesh.addVertex(endVertex);
    
    planarMesh.addCorners(startVertexIndex, endVertexIndex);
  }
  
  boolean vertexExistsPlanar(int x, int y)
  {
    return planarMesh.vertexExists(x, y, 0);
  } 
  
  int getClosestVertexPlanar(int x, int y)
  {
    return planarMesh.getClosestVertex(x, y, 0);
  } 
  
  boolean isMeshEmpty()
  {
    if (planarMesh.G.size() == 0)
      return true;
    return false;
  }
  
  void printMeshData(int meshID)
  {
    if (meshID == 1)
      planarMesh.printData();
    else if (meshID == 2)
      extrudedMesh.printData();
  }
  
  void toggleRenderCorners()
  {
    renderMeshCorners = !renderMeshCorners;
  }
  
  void updateCornerOffset(int meshID, float offsetDiff)
  {
    if (meshID == 1)
    {
      if (planarMesh.getCornerOffset() + offsetDiff > 10.5 && planarMesh.getCornerOffset() + offsetDiff < 30.5)
        planarMesh.setCornerOffset(planarMesh.getCornerOffset() + offsetDiff);
    }
    else if (meshID == 2)
    {
      if (planarMesh.getCornerOffset() + offsetDiff > 10 && planarMesh.getCornerOffset() + offsetDiff < 30)
        extrudedMesh.setCornerOffset(extrudedMesh.getCornerOffset() + offsetDiff);
    }
  }
  
  void updateWallHeight(float heightDiff)
  {
    wallHeight += heightDiff;
  }
  
  void extrudeMesh(int extrudeSection)
  {
    this.extrudeSection = extrudeSection;
    extruder = new Extruder(planarMesh);
    selectedCorner = 0;
    extrudedMesh = extruder.getExtrudedMesh(extrudeSection, wallHeight);
  }
  
  //Rendering functions
  void renderActive()
  {
    if (isDrawing)
    {
      stroke(black);
      strokeWeight(2);
      line(startVertex.x, startVertex.y, mouseX, mouseY);
      stroke(blue_dark);
      strokeWeight(3);
      fill(blue_light);
      ellipse(startVertex.x, startVertex.y, 15, 15);
      ellipse(mouseX, mouseY, 15, 15); 
    }
  }
  
  void renderMesh(int meshID)
  {
    if (meshID == 1)
    {
      planarMesh.render(false, renderMeshCorners, false);
    }
    else if (meshID == 2)
    {
      extruder.renderSpecial(extrudedMesh, extrudeSection, false, renderMeshCorners, selectedCorner);
    }
  }  
  
  void displayText()
  {
    //Display the selected corner ID
    if (view3D)
    {
      fill(dark_metal);
      
      if (extrudedMesh.V.size() > 0)
      {
        text("Selected Corner : " + selectedCorner, 20, 70);
        text("Selected Vertex : " + extrudedMesh.V.get(selectedCorner), 20, 90);
      }
      else
      {
        text("Selected Corner : -", 20, 70);
        text("Selected Vertex : -", 20, 90);
      }
    }
  }
  
  void displayGrid(int z)
  {
    float gridSpacing = 10;
    int numLines = int(width / gridSpacing);
    stroke(grey_light);
    strokeWeight(1);
    for (int i = 0; i <= numLines; i++)
    {
      line(0, i * gridSpacing, z, width, i * gridSpacing, z);
      line(i * gridSpacing, 0, z, i * gridSpacing, height, z);
    }
  }
  
  void getSelectedCorner(pt clickedPoint)
  {
    for (int i = 0; i < extrudedMesh.V.size(); i++)
    {
      Vertex cornerPos = extrudedMesh.getCornerPos3d(i); 
      if (sqrt(pow(cornerPos.x - clickedPoint.x, 2) + pow(cornerPos.y - clickedPoint.y, 2) + pow(cornerPos.z - clickedPoint.z, 2)) < 5)
      {
        selectedCorner = i;
        break;
      }
    }
  }
  
  void swingSelectedCorner()
  {
    selectedCorner = extrudedMesh.S.get(selectedCorner);
  }
  
  void unswingSelectedCorner()
  {
    selectedCorner = extrudedMesh.getUnswing(selectedCorner);
  }
  
  void advanceSelectedCorner()
  {
    selectedCorner = extrudedMesh.N.get(selectedCorner);
  }
  
  void recedeSelectedCorner()
  {
    selectedCorner = extrudedMesh.getPreviousCorner(selectedCorner);
  }
  
  public pt pick3D(int mX, int mY)
  {
    PGL pgl = beginPGL();
    FloatBuffer depthBuffer = ByteBuffer.allocateDirect(1 << 2).order(ByteOrder.nativeOrder()).asFloatBuffer();
    pgl.readPixels(mX, height - mY - 1, 1, 1, PGL.DEPTH_COMPONENT, PGL.FLOAT, depthBuffer);
    float depthValue = depthBuffer.get(0);
    depthBuffer.clear();
    endPGL();
    
    //get 3d matrices
    PGraphics3D p3d = (PGraphics3D)g;
    PMatrix3D proj = p3d.projection.get();
    PMatrix3D modelView = p3d.modelview.get();
    
    PMatrix3D modelViewProjInv = proj; 
    modelViewProjInv.apply( modelView ); 
    modelViewProjInv.invert();
    float[] viewport = {0, 0, p3d.width, p3d.height};
    float[] normalized = new float[4];
    normalized[0] = ((mX - viewport[0]) / viewport[2]) * 2.0f - 1.0f;
    normalized[1] = ((height - mY - viewport[1]) / viewport[3]) * 2.0f - 1.0f;
    normalized[2] = depthValue * 2.0f - 1.0f;
    normalized[3] = 1.0f;
    
    float[] unprojected = new float[4];
    modelViewProjInv.mult( normalized, unprojected );
    return P( unprojected[0]/unprojected[3], unprojected[1]/unprojected[3], unprojected[2]/unprojected[3]);
  }
  
}


void keyPressed()
{
  if (key == '1')
  {
    guiManager.view2D();
  }
  
  if (key == '2')
  {
    guiManager.extrudeMesh(1);
    guiManager.view3D();
  }
  
  if (key == '3')
  {
    guiManager.extrudeMesh(0);
    guiManager.view3D();
  }
  
  if (key == 's' || key == 'S')
  {
    if (guiManager.view3D)
      guiManager.swingSelectedCorner();
  }
  
  if (key == 'u' || key == 'U')
  {
    if (guiManager.view3D)
      guiManager.unswingSelectedCorner();
  }
  
  if (key == 'n' || key == 'N')
  {
    if (guiManager.view3D)
      guiManager.advanceSelectedCorner();
  }
  
  if (key == 'p' || key == 'P')
  {
    if (guiManager.view3D)
      guiManager.recedeSelectedCorner();
  }
  
  if (key == '`' || key == '~')
  {
    if (!guiManager.view3D)
      guiManager.printMeshData(1);
    else
      guiManager.printMeshData(2);
  }
  
  if (key == 'c' || key == 'C')
  {
    guiManager.toggleRenderCorners();
  }
  
  if (key == 'w' || key == 'W')
  {
    guiManager.setMode(MOV);
  }
  
  if (key == 'e' || key == 'E')
  {
    guiManager.setMode(DRAW);
  }
  
  if (key == '-' || key == '_')
  {
    if (guiManager.view3D)
    {
      guiManager.updateWallHeight(-10);
      guiManager.extrudeMesh(guiManager.extrudeSection);
    }
  }
  
  if (key == '+' || key == '=')
  {
    if (guiManager.view3D)
    {
      guiManager.updateWallHeight(10);
      guiManager.extrudeMesh(guiManager.extrudeSection);
    }
  }
  
  if (key == '[' || key == '{')
  {
    if (!guiManager.view3D)
    {
      guiManager.updateCornerOffset(1, -1);
    }
    else
    {
      guiManager.updateCornerOffset(1, -1);
      guiManager.extrudeMesh(guiManager.extrudeSection);
    }
  }
  
  if (key == ']' || key == '}')
  {
    if (!guiManager.view3D)
    {
      guiManager.updateCornerOffset(1, 1);
    }
    else
    {
      guiManager.updateCornerOffset(1, 1);
      guiManager.extrudeMesh(guiManager.extrudeSection);
    }
  }
  
  if (key == '?') 
    scribeText=!scribeText; 
}

void mouseWheel(MouseEvent event)
{
  dz -= event.getAmount(); 
}

void mouseDragged()
{
  if (!guiManager.view3D)
  {
    if (guiManager.getDraggedVertex() != -1)
    {
      guiManager.updateDraggedVertex(mouseX, mouseY);
    }
  }
  
  else
  { 
    if (mouseButton == LEFT && keyPressed && key==' ')
    {
      rx-=PI*(mouseY-pmouseY)/height;
      ry+=PI*(mouseX-pmouseX)/width;
    }
    if (mouseButton == RIGHT && keyPressed && key == ' ')
    {
      dz += mouseX - pmouseX + mouseY - pmouseY;
    }
    if (mouseButton == LEFT && keyPressed && key=='f') 
    {
      if(center) 
      {
        F.sub(ToIJ(V((float)(mouseX - pmouseX), (float)(mouseY - pmouseY),0)));
      } 
      else
      { 
        F.add(ToIJ(V((float)(mouseX - pmouseX), (float)(mouseY - pmouseY),0)));
      }
    }
  }
}

void mouseClicked()
{
  if (guiManager.view3D)
  { 
    guiManager.getSelectedCorner(pickedPoint3D);
    
  }
  
}

void mousePressed()
{
  if (!guiManager.view3D)
  {
    if (guiManager.getMode() == DRAW)
    {
      if (guiManager.isMeshEmpty() || guiManager.vertexExistsPlanar(mouseX, mouseY))
        guiManager.startDraw(mouseX, mouseY);
    }
    
    else if (guiManager.getMode() == MOV)
    {
      if (guiManager.vertexExistsPlanar(mouseX, mouseY))
      {
        int vIndex = guiManager.getClosestVertexPlanar(mouseX, mouseY);
        guiManager.setDraggedVertex(vIndex);
      }
      
    }
  }
}

void mouseReleased()
{
  if (!guiManager.view3D)
  {
    if (guiManager.getMode() == DRAW)
    {
      if (guiManager.isDrawing())
      {
        guiManager.finishDraw(mouseX, mouseY);
      }
    }
    else if (guiManager.getMode() == MOV)
    {
      guiManager.unsetDraggedVertex();
    }
  }
}


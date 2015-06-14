/**************************** HEADER ****************************
 Author: Gokul Raghuraman
 Class: CS6491 Fall 2014
 Project number: 5
 Project title: 3D Walls
 Date of submission: 11/04/2014
*****************************************************************/

import java.nio.*;

float dz = 0;                            
float rx = -0.06 * TWO_PI, ry = -0.04 * TWO_PI;
pt F = P(-width, -height, 0);                          
Boolean center = true;

pt pickedPoint3D = new pt(-1, -1, -1);

int DRAW = 0;
int MOV = 1;

//A GUI manager to handle user interaction 
GUIManager guiManager;

void drawCursor()
{
  stroke(red);
  strokeWeight(2);
  noFill();
  
  if (guiManager.getMode() == DRAW)
    ellipse(mouseX, mouseY, 8, 8);
  if (guiManager.getMode() == MOV)
  {
    rect(mouseX-5, mouseY-5, 10, 10);
  }
}

void setup()
{
  size(700, 700, P3D);
  myFace = loadImage("Data/myFace.jpg");
  noSmooth();
  guiManager = new GUIManager();
}

void draw()
{
  background(white);
  
  //3D view
  if (guiManager.view3D)
  {
    background(255);
    pushMatrix();   
      camera();       
      translate(width / 2, height / 2, dz); 
      lights();
      rotateX(rx); 
      rotateY(ry);
      rotateX(PI/2);
      if(center) 
        translate(-F.x,-F.y,-F.z);
      noStroke();
    
      pushMatrix();
        translate(-width / 2, -height / 2, 0);
        guiManager.displayGrid(0);
        guiManager.renderMesh(2);
        pickedPoint3D = guiManager.pick3D( mouseX, mouseY );
      popMatrix();
    popMatrix(); 

  }
  
  //2D view
  else
  {
    guiManager.displayGrid(-1);
    stroke(black);
    noFill();
    guiManager.renderActive();
    guiManager.renderMesh(1);
  }
  
  guiManager.displayText();
  displayOverlay();
  drawCursor();
  
}

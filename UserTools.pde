boolean scribeText=true;
int pictureCounter=0;
PImage myFace; 
String title ="CS6491 | Fall 2014 | Assignment 5: \n3D Walls", 
       name ="Gokul Raghuraman",
       menu="?: (show/hide) help",
       guide1 = "Controls:",
       guide2 = "   '1' : 2D Mode",
       guide3 = "   '2' : 3D Mode (Boundary Extruded)",
       guide4 = "   '3' : 3D Mode (Inner Sections Extruded)",
       guide5 = "\n2D Controls :",
       guide6 = "   'E' : Drawing mode: Left-Click and drag to draw edges and vertices.",
       guide7 = "   'W': Moving mode : Left-Click on vertex and drag to move it around.",
       guide8 = "   'C': Show all corners",
       guide9 = "\n3D Controls :",
       guide10 = "   'C' : Show all corners",
       guide11 = "   'Left-click': Select a corner",
       guide12 = "   'Space + left-click + drag : Look around the scene",
       guide13 = "   'F + left-click + drag : Move focus point",
       guide14 = "   'S' : Go to swing of corner",
       guide15 = "   'U' : Go to unswing of corner",
       guide16 = "   'N' : Go to next of corner",
       guide17 = "   'P' : Go to previous of corner",
       //guide3 = "   'E' : Drawing mode: Click and drag to draw edges and vertices.",
       //guide4 = "   'W': Moving mode : Click on vertex and drag to move it around.", 
       //guide5 = "'2' : 3D Mode (Boundary Extruded)",
       //guide6 = "   'Space + left-click + drag : Look around the scene",
       //guide4 = "'3' : 3D Mode (Inner Sections Extruded)",
       //guide5 = "'E' : Drawing mode: Click and drag to draw edges and vertices.",
       //guide6 = "'W' : Moving mode : Click on vertex and drag to move it around.", 
       //guide7 = "'C' : Display all the corners.",
       //guide8 = "'P' : Print the internal data structure.",
       guide = guide1 + '\n' + guide2 + '\n' + guide3 + '\n' + guide4 + '\n' + guide5 + '\n' + guide6 + '\n' + guide7 + '\n' + guide8
               + '\n' + guide9 + '\n' + guide10 + '\n' + guide11 + '\n' + guide12 + '\n' + guide13 + '\n' + guide14 + '\n' + guide15 
               + '\n' + guide16 + '\n' + guide17;

//*****Capturing Frames for a Movie*****
boolean filming=false;  // when true frames are captured in FRAMES for a movie
int frameCounter=0;     // count of frames captured (used for naming the image files)

void checkIfFilming()
{
 if(filming)
  {
    saveFrame("FRAMES/"+nf(frameCounter++,4)+".png");
    fill(red);
    stroke(red);
    ellipse(width - 20, height - 20, 5, 5);
  }  
}

//********Display Header/Footer*********
void displayOverlay()
{
 displayHeader();
 if(scribeText && !filming) 
   displayFooter();
}

void displayHeader()
{
  fill(dark_metal); 
  text(title, 10, 20); 
  text(name, width - 8.0 * name.length(), 40);
  noFill();
  image(myFace, width - myFace.width/3 - 30, 45, myFace.width/3,myFace.height/3);  
}

void displayFooter()
{  
  scribeFooter(guide, 15);
  scribeFooter(menu, 0);
}

void scribeFooter(String s, int i)  
{
  fill(dark_metal); 
  text(s, 10, height - 10 - i * 20); 
  noFill();
}

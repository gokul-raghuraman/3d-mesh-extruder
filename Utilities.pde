color black=#000000, white=#FFFFFF, // set more colors using Menu >  Tools > Color Selector
   red=#FF0000, green=#00FF01, blue=#0300FF, yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB,
   grey=#818181, orange=#FFA600, brown=#B46005, metal=#B5CCDE, dark_metal = #37576F, dgreen=#157901, 
   blue_light = #8AD2F5, blue_dark = #1F93DE, grey_light = #E8EDF0;
   
//For ray-casting
int rayCast(Vertex p, Vertex a, Vertex b)
{
  //Check for intersection between ray pq and segment ab
  //Returns 1 if there is an intersection, 0 otherwise 
  Vertex q = new Vertex(2 * width, 2 * height, 0); 
  
  if ((ccw(a, p, q) != ccw(b, p, q)) && (ccw(a, b, p) != ccw(a, b, q)))
    return 1;
    
  return 0;
}

boolean ccw(Vertex A, Vertex B, Vertex C)
{
  return ((C.y - A.y) * (B.x - A.x) > (B.y - A.y) * (C.x - A.x));
}




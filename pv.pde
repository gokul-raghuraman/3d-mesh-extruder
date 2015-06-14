// ===== Some useful 2d measures

class Vector2d { float x=0,y=0; 
 // CREATE
  Vector2d () {};
  Vector2d (float px, float py) {x = px; y = py;};

  Vector2d normalize() {float n=sqrt(sq(x)+sq(y)); if (n>0.000001) {x/=n; y/=n;}; return this;};
  Vector2d add(float u, float v) {x += u; y += v; return this;};
  Vector2d add(Vector2d V) {x += V.x; y += V.y; return this;};   
  Vector2d add(float s, Vector2d V) {x += s*V.x; y += s*V.y; return this;};
  Vector2d sub(Vector2d V) {x -= V.x; y -= V.y; return this;};  
  } // end vec class

float det(Vector2d U, Vector2d V) {return U.x*V.y-U.y*V.x; }



Vector2d R(Vector2d V) {return new Vector2d(-V.y,V.x);};                                                             // V turned right 90 degrees (as seen on screen)
Vector2d R(Vector2d V, float a) {float c=cos(a), s=sin(a); return(new Vector2d(V.x*c-V.y*s,V.x*s+V.y*c)); };                                     // V rotated by a radians

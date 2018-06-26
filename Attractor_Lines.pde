class Attractor_Lines {
  float x=0, y=0;
  float radius =110;
  float strength= 0.85;
  float ramp=0.05;
  float theX;
  float theY;

  Attractor_Lines( float theX, float theY) {
    x= theX;
    y = theY;
  }

  void attract_Lines (Node theNode) {

    float dx = x-theNode.x;
    float dy = y-theNode.y;
    float d= mag(dx, dy);
    if ( d > 0 && d < radius) {

      float s = pow(d/radius, 1/ramp);
      float f = s*9*strength*50 * (1/(s+1)+((s-3)/4))/d;
      theNode.velocity.x += dx*f;
      theNode.velocity.y += dy*f;
    }
  }
}

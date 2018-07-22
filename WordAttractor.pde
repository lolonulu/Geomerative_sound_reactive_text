class WordAttractor {

  float force_radious = 100;
  float maxForce = 16;
  RPoint position;
  RPoint[]points;

  WordAttractor(float x, float y, RPoint[] p) {
    points = p;
    position = new RPoint(x, y);
  }

  void attract() {

    for (int i =0; i < points.length; i++) {
      float d= points[i].dist(position);
      if (d < force_radious) {   
        RPoint desired = new RPoint(points[i]);
        //println( "avant x : "+ points[i].x +" y: "+points[i].y);
        desired.sub(position);
        desired.normalize();
        desired.scale(map(d, 0, force_radious, maxForce, 0));
        points[i].add(desired);
        //println( "après x : "+ points[i].x +" y: "+points[i].y);
      }
    }
  }
  void display () {
    stroke(0);
    strokeWeight(2);
    // ellipse (position.x, position.y-750, 30, 30);
  }
  void moveTo(float x, float y) {
    position.x=x;
    position.y=y;
  }
}

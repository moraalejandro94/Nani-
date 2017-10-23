class Path {
  ArrayList<PVector> points;
  float radius;

  Path() {
    radius = 30;
    points = new ArrayList();
  }
  void addPoint(float x, float y) {
    PVector point = new PVector(x, y);
    points.add(point);
  }
  void display() {
    for (int i = 0; i < points.size() - 1; i++) {
      PVector start = points.get(i);
      PVector end = points.get(i + 1);
      strokeWeight(radius * 2);
      stroke(#666767);
      line(start.x, start.y, end.x, end.y);
    }
    for (int i = 0; i < points.size() - 1; i++) {
      PVector start = points.get(i);
      PVector end = points.get(i + 1);
      strokeWeight(1);
      stroke(0);
      line(start.x, start.y, end.x, end.y);
    }
  }
  ArrayList<Segment> getSegments() {
    ArrayList<Segment> segments = new ArrayList();
    for (int i = 0; i < points.size() - 1; i++) {
      PVector start = points.get(i);
      PVector end = points.get(i + 1);
      Segment s = new Segment(start, end);
      segments.add(s);
    }
    return segments;
  }
}
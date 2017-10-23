class Agent {
  PVector pos;
  PVector vel;
  PVector acc;
  float mass = 1;
  float r = 10;
  float maxSpeed;
  float maxForce;
  float maxPathDistance = 200;
  float lookAhead = 50;
  float pathLookAhead = 20;
  color c;
  boolean debug = false;

  Agent(float x, float y, PVector vel, float maxSpeed, float maxForce) {
    pos = new PVector(x, y);
    this.vel = vel;
    acc = new PVector(0, 0);
    this.maxSpeed = maxSpeed;
    this.maxForce = maxForce;
    colorMode(HSB);
    c = color(frameCount%255, 255, 255);
    colorMode(RGB);
  }
  void update() {
    vel.add(acc);
    vel.limit(maxSpeed);
    pos.add(vel);
    acc.mult(0);
  }
  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acc.add(f);
  }
  void seek(PVector target) {
    PVector desired = PVector.sub(target, pos);
    desired.setMag(maxSpeed);
    PVector steering = PVector.sub(desired, vel);
    steering.limit(maxForce);
    applyForce(steering);
  }
  void display() {
    float ang = vel.heading();
    noStroke();
    fill(c);
    ellipse(pos.x, pos.y, r, r);
  }
  void borders() {
    pos.x = (pos.x + width) % width;
    pos.y = (pos.y + height) % height;
  }
  void follow(Path path) {
    PVector predicted = getPredictedPos();
    PVector normal = getClosestNormalPoint(path, predicted);
    float distance = PVector.dist(predicted, normal);
    if (distance > path.radius) {
      seek(normal);
    }
    if (debug) {
      noStroke();
      fill(0, 0, 255);
      ellipse(predicted.x, predicted.y, 5, 5);
      fill(255, 0, 0);
      ellipse(normal.x, normal.y, 5, 5);
    }
  }
  PVector getPredictedPos() {
    PVector predicted = vel.copy();
    predicted.setMag(lookAhead);
    predicted.add(pos);
    return predicted;
  }
  PVector getClosestNormalPoint(Path path, PVector predicted) {
    ArrayList<PVector> normalPoints = getNormalPoints(path, predicted);
    PVector closest = getClosest(normalPoints, predicted);
    return closest;
  }
  ArrayList<PVector> getNormalPoints(Path path, PVector predicted) {
    ArrayList<PVector> normalPoints = new ArrayList();
    for (Segment s : path.getSegments()) {
      PVector start, end;
      if (s.start.x < s.end.x) {
        start = s.start;
        end = s.end;
      } else {
        start = s.end;
        end = s.start;
      }
      PVector a = PVector.sub(predicted,start);
      PVector b = PVector.sub(end, start);
      b.normalize();
      b.mult(a.dot(b) + pathLookAhead);
      b.add(start);
      if ((b.x >= start.x && b.x <= end.x) || (b.x >= end.x && b.x <= start.x)) {
        if ((b.y >= start.y && b.y <= end.y) || (b.y >= end.y && b.y <= start.y)) {
          normalPoints.add(b);
        }
      }
    }
    return normalPoints;
  }
  // si no hay puntos normales válidos, retorna la predicción
  PVector getClosest(ArrayList<PVector> normalPoints, PVector predicted) {
    if (normalPoints.size() == 0) {
      return predicted;
    }
    PVector closest = normalPoints.get(0); // cambiar esto para que utilice un punto muy lejano
    for (int i = 1; i < normalPoints.size(); i++) {
      if (predicted.dist(normalPoints.get(i)) < predicted.dist(closest)) {
        closest = normalPoints.get(i);
      }
    }
    if (predicted.dist(closest) < maxPathDistance) {
      return closest;
    } else {
      return predicted;
    }
  }
}
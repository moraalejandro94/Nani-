class Agent extends GameObject{
  PVector vel;
  PVector acc;
  float maxSpeed, maxForce;
  GameObject target;

  Agent(float x, float y, float mass) {
    super(x, y, mass);
    this.maxSpeed = 2;
    this.vel = new PVector(0, 0);
    acc = new PVector(0, 0);
  }

  void update() {
    vel.add(acc);
    vel.limit(maxSpeed);
    objectPosition.add(vel);
    acc.mult(0);
  }
  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acc.add(f);
  }
  void seek(PVector target) {
    PVector desired = PVector.sub(target,  objectPosition);
    desired.setMag(maxSpeed);
    PVector steering = PVector.sub(desired, vel);
    applyForce(steering);
  }

  boolean isDead(PVector target, float ratio){
    float difference = PVector.dist(objectPosition, target);
    return difference < ratio;
  }

  void display() {
    noStroke();
    fill(pointsColor);
    ellipse(objectPosition.x, objectPosition.y, mass, mass);
  }
}
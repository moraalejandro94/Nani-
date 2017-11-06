class Particle extends GameObject{
  PVector speed,acc;
  float mass, friction, lifeSpan, decay;
  float maxSpeed;

  Particle(float x, float y, float mass){
    super(x, y, mass);
    this.speed = new PVector(0,0);
    this.acc = new PVector(0,0);
    this.mass = mass;
    this.maxSpeed = random(1, 10);
    this.decay = 0.5;
    this.lifeSpan = 255;
  }

  void display(){
    noStroke();
    fill(pointsColor,lifeSpan);
    ellipse(objectPosition.x, objectPosition.y, mass, mass);
  }

  void update(){
    speed.add(acc);
    objectPosition.add(speed);
    acc.mult(0);
    lifeSpan -= decay;
    seekPlayer();
  }

void seekPlayer(){
  PVector randy = PVector.random2D();
  randy.setMag(random(player.mass));
  PVector pos = player.getPixelPos().add(randy);
  seek(pos);
}

  void applyForce(PVector force){
    PVector f = PVector.div(force,mass);
    acc.add(f);
  }

  boolean isDead(){
    return lifeSpan <= 0;
  }

  boolean near(CollidingObject target){
    float distance = PVector.dist(objectPosition, target.getPixelPos());
    return distance < target.mass / 2;
  }

  void seek(PVector target) {
    PVector desired = PVector.sub(target, objectPosition);
    desired.setMag(maxSpeed);
    PVector steering = PVector.sub(desired, speed);
    steering.limit(maxSpeed);
    applyForce(steering);
  }

  void kill(){}
}
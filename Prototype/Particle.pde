class Particle extends GameObject{
  PVector pos,speed,acc;
  float mass, friction, lifeSpan, decay;

  Particle(float x, float y, float mass){
    super(x, y, mass);
    this.speed = new PVector(0,0);
    this.acc = new PVector(0,0);
    this.mass = mass;
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
  }

  void applyForce(PVector force){
    PVector f = PVector.div(force,mass);
    acc.add(f);
  }

  boolean isDead(){
    return lifeSpan <= 0;
  }
}
class Player extends Ship implements UserInput{
  float projectileMass;
  Vec2 projectileForce;

  Player(float x, float y, float mass){
    super(x, y, mass);
    projectileMass = 10;
    projectileForce = new Vec2(20000,0);
  }

  void update(){
    movementController();
    super.update();
  }

  void move(int direction) {
    //screenController(this.speed);
    speed.normalize();
    speed.add(getDirectionVector(direction));
    speed.setMag(normalSpeed);
    setSpeed(speed);
  }

  void moveUp() {
   if (keys[moveUp]) {
     move(UP);
   }
 }

 void moveLeft() {
   if (keys[moveLeft]) {
     move(LEFT);
   }
 }

 void moveRight() {
   if (keys[moveRight]) {
     move(RIGHT);
   }
 }

 void moveDown() {
   if (keys[moveDown]) {
     move(DOWN);
   }
 }

 void shoot() {
   if (keys[shoot] && frameCount%6 == 0) {
     Vec2 pos = box2d.getBodyPixelCoord(body);
     shoot(pos.x + mass + 2, pos.y, projectileMass, projectileForce);       
   }
 }

 void shoot(float posX, float posY, float mass, Vec2 force){
  Projectile p = new Projectile(posX, posY, mass, force);
  projectiles.add(p);
}

void stopMovement(){
  if (!(keys[moveUp] || keys[moveDown] || keys[moveLeft] || keys[moveRight])){
   stop();
 }
}

void movementController() {
  moveUp();
  moveLeft();
  moveDown();
  moveRight();
  stopMovement();
  shoot();
  elapsed++;
}

void display(){
  super.display();
  for(Projectile p : projectiles){
    p.display();
  }

}



}


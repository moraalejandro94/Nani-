import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Iterator; 
import shiffman.box2d.*; 
import org.jbox2d.collision.shapes.*; 
import org.jbox2d.common.*; 
import org.jbox2d.dynamics.*; 
import org.jbox2d.dynamics.contacts.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Prototype extends PApplet {








Player player;
Seeker seeker;
Box2DProcessing box2d;
boolean[] keys = new boolean[1024];
ArrayList<GameObject> objects;

public void setup(){
	
	background(0);
	objects = new ArrayList();
	box2dInit();
	playerInit();
}

public void playerInit(){	
	player = new Player(width/2, height/2, 40);
	player.normalSpeed = 100;
	seeker = new Seeker(100, 100, 40, 50);
	seeker.normalSpeed = 10;
	objects.add(player);
	objects.add(seeker);
}

public void box2dInit() {
	box2d = new Box2DProcessing(this);
	box2d.createWorld();
	box2d.setGravity(0,0);
	box2d.listenForCollisions();
}

public void draw(){
	background(0);
	box2d.step();

	for(GameObject o : objects){
		o.update();
		o.display();
	}	
}


public void beginContact(Contact c) {
	CollidingObject o1 = objectFromFixture(c.getFixtureA());
	CollidingObject o2 = objectFromFixture(c.getFixtureB());
	if (o1 instanceof Player){
		checkPlayer(o2);
	}
	if (o1 instanceof Ship && o2 instanceof Projectile){
		Ship s = (Ship)o1;
		s.decreaseHP();
		if(s.dead){
			objects.remove(s);
		}
	}

}

public void endContact(Contact c) {}

public CollidingObject objectFromFixture(Fixture fixture){
	Body body = fixture.getBody();
	Object object = body.getUserData();
	return (CollidingObject) object;
}

public void checkPlayer(CollidingObject o2){
	println("huy perro");
}

public void keyPressed(){
	keys[keyCode] = true;
}

public void keyReleased(){
	keys[keyCode] = false;
}
class CollidingObject extends GameObject{
	Body body;

	CollidingObject(float x, float y, float mass) {
		super(x,y, mass);
		makeBody();
	}
	public void makeBody() {
		BodyDef bd = new BodyDef();
		bd.position = box2d.coordPixelsToWorld(this.objectPosition.x, this.objectPosition.y);
		bd.type = BodyType.DYNAMIC;
		body = box2d.world.createBody(bd);

		CircleShape cs = new CircleShape();
		cs.setRadius(box2d.scalarPixelsToWorld(mass/2));

		FixtureDef fd = new FixtureDef();
		fd.setShape(cs);
		fd.setDensity(0);

		body.createFixture(fd);
		body.setUserData(this);
	}

	public void killBody() {
		box2d.destroyBody(body);
	}

	public boolean inScreen() {
		Vec2 pos = box2d.getBodyPixelCoord(body);
		if (pos.y < height + mass && pos.y > 0 - mass 
			&& pos.x < width + mass && pos.x > 0 - mass ) {      
			return true;
		}
		return false;
	}

	public void display() {
		if (inScreen()){
			Vec2 pos = box2d.getBodyPixelCoord(body);
			pushMatrix();
			translate(pos.x, pos.y);
			fill(255,0,0);
			ellipse(0, 0, mass, mass);
			popMatrix();
		}
	}

	public void applyForce(Vec2 force){
		Vec2 pos = body.getWorldCenter();
		body.applyForce(force, pos);
	}

	public void setSpeed(PVector pForce) {
		Vec2 force = new Vec2(pForce.x, pForce.y);
		body.setLinearVelocity(force);
	}

	public void stop(){
		body.setLinearVelocity(new Vec2(0, 0));
	}

	public PVector getPixelPos(){
		Vec2 playerPos = box2d.getBodyPixelCoord(body);
		PVector pos = box2d.coordWorldToPixelsPVector(playerPos);
		return pos;
	}

	public Vec2 getPos(){
		Vec2 pos = body.getWorldCenter();
		return pos;
	}

	public Vec2 vec2Limit(Vec2 vector, float max){
		float mag = vector.length();
		if (mag > max){
			vector.normalize();
			vector.mulLocal(max);
		}
		return vector;
	}

	public float vec2Heading(Vec2 vector){
		float angle = atan(vector.y/vector.x);
		return angle;

	}

	public void update(){}
}
class Enemy extends Ship {

	Enemy (float x, float y, float mass){
		super(x,y,mass);
	}


	


}
abstract class GameObject{
	 PVector objectPosition;
	 float mass;
	 

	 GameObject(float posX, float posY, float mass){
	 	this.objectPosition = new PVector(posX, posY);
	 	this.mass = mass;
	 }

	 public abstract void display();
	 
	 public abstract void update();

}
enum Directions{
  LEFT, RIGHT, UP, DOWN
}

PVector up = new PVector(0,1);
PVector down = new PVector(0,-1);
PVector left  = new PVector(-1,0);
PVector right  = new PVector(1,0);
PVector nullMove = new PVector(0,0);

public PVector getDirectionVector(int direction){
  switch (direction) {
    case LEFT:
    return left;
    case RIGHT:
    return right;
    case UP:
    return up;
    case DOWN:
    return down;
  }
  return nullMove;
}

public int getOppositeDirection(int direction){
  switch (direction) {
    case LEFT:
    return RIGHT;
    case RIGHT:
    return LEFT;
    case UP:
    return DOWN;
    case DOWN:
    return UP;
  }
  return 0;
}
class Player extends Ship implements UserInput{
  float projectileMass;
  Vec2 projectileForce;

  Player(float x, float y, float mass){
    super(x, y, mass);
    projectileMass = 10;
    projectileForce = new Vec2(20000,0);
  }

  public void update(){
    movementController();
    super.update();
  }

  public void move(int direction) {
    //screenController(this.speed);
    speed.normalize();
    speed.add(getDirectionVector(direction));
    speed.setMag(normalSpeed);
    setSpeed(speed);
  }

  public void moveUp() {
   if (keys[moveUp]) {
     move(UP);
   }
 }

 public void moveLeft() {
   if (keys[moveLeft]) {
     move(LEFT);
   }
 }

 public void moveRight() {
   if (keys[moveRight]) {
     move(RIGHT);
   }
 }

 public void moveDown() {
   if (keys[moveDown]) {
     move(DOWN);
   }
 }

 public void shoot() {
   if (keys[shoot] && frameCount%6 == 0) {
     Vec2 pos = box2d.getBodyPixelCoord(body);
     shoot(pos.x + mass + 2, pos.y, projectileMass, projectileForce);       
   }
 }

 public void shoot(float posX, float posY, float mass, Vec2 force){
  Projectile p = new Projectile(posX, posY, mass, force);
  projectiles.add(p);
}

public void stopMovement(){
  if (!(keys[moveUp] || keys[moveDown] || keys[moveLeft] || keys[moveRight])){
   stop();
 }
}

public void movementController() {
  moveUp();
  moveLeft();
  moveDown();
  moveRight();
  stopMovement();
  shoot();
  elapsed++;
}

public void display(){
  super.display();
  for(Projectile p : projectiles){
    p.display();
  }

}



}

class Projectile extends CollidingObject{
	Vec2 force;
	
	Projectile(float posX, float posY, float mass, Vec2 force){
		super(posX,posY,mass);
		applyForce(force);
	}

	public void display(){
		Vec2 pos = box2d.getBodyPixelCoord(body);
		float a = vec2Heading(getPos());
	    stroke(255);
	    strokeWeight(2);
	    fill(255,0,0);
	    pushMatrix();
	    translate(pos.x, pos.y);
	    ellipse(0, 0, this.mass, this.mass);
	    popMatrix();		
	}


	public void update(){}


}
class Seeker extends Enemy {
	float rotationSpeed;

	Seeker(float x, float y, float mass, float rotationSpeed){
		super(x,y,mass);
		this.rotationSpeed = rotationSpeed;
	}

	public void seek(Vec2 target) {
		Vec2 desired = target.sub(getPos());
		desired.normalize();
		desired.mulLocal(normalSpeed);	    
		Vec2 steering = desired.sub(new Vec2(speed.x, speed.y));
		steering = vec2Limit(steering,rotationSpeed);
		desired.mulLocal(normalSpeed);	    
		applyForce(steering);
	}

	public void display() {
		Vec2 pos = box2d.getBodyPixelCoord(body);
		float a = vec2Heading(getPos());
		stroke(255);
		strokeWeight(2);
		fill(255,0,0);
		pushMatrix();
		translate(pos.x, pos.y);
		ellipse(0, 0, this.mass, this.mass);
		popMatrix();
	}

	public void update(){
		super.update();
		seek(player.getPos());
	}



}
class Ship extends CollidingObject{
	int hp, elapsed;
	PVector speed;
	float normalSpeed, boostSpeed;
	boolean dead;
	ArrayList<Projectile> projectiles;


	Ship(float x, float y, float mass){
		super(x, y, mass);
		hp = 1;
		speed = new PVector(0, 0);
		normalSpeed = 0;
		boostSpeed = 0;
		elapsed = 0;
		dead = false;
		this.projectiles = new ArrayList();
	}

	public void update(){
		super.update();
		speed.mult(0);
		if (hp <= 0){
			die();
		}
	}

	public void decreaseHP(){
		this.hp--;
	}

	public void die(){		
		this.dead = true;
		println("dead: "+dead);
	}

	public void display(){
		if (!dead && inScreen()){
			Vec2 pos = box2d.getBodyPixelCoord(body);
			pushMatrix();
			translate(pos.x, pos.y);
			fill(255,0,0);
			ellipse(0, 0, mass, mass);
			popMatrix();
		}
	}

}
interface UserInput{
	char moveUp = 'W';
	char moveLeft = 'A';
	char moveDown = 'S';
	char moveRight = 'D';
	char shoot = ' ';

	public void movementController();
	public void moveUp();
	public void moveLeft();
	public void moveDown();
	public void moveRight();
	public void shoot();
}
  public void settings() { 	fullScreen(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Prototype" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

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
import java.util.Iterator; 
import java.util.LinkedList; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Prototype extends PApplet {








boolean pause = false;
char pauseButton = 'p';

int pointsColor;

Player player;
Seeker seeker;
Box2DProcessing box2d;
boolean[] keys = new boolean[1024];
ArrayList<GameObject> objects;
ArrayList<GameObject> garbage;

public void setup(){
	frameRate(60);
	
	background(0);
	box2dInit();
	gameInit();
	colorsInit();
}

// Inicializa todos los colores usados en el juego
public void colorsInit(){
	pointsColor = color(13, 108, 1);
}

// Inicializa el mundo de box2d
public void box2dInit() {
	box2d = new Box2DProcessing(this);
	box2d.createWorld();
	box2d.setGravity(0,0);
	box2d.listenForCollisions();
}

// Inicializa el jugador y los elementos del juego
public void gameInit(){	
	objects = new ArrayList();
	garbage = new ArrayList();
	player = new Player(width/2, height/2, 40);
	player.normalSpeed = 2500;
	objects.add(player);
}

// Muestra el juego y poine a correr el mundo
public void displayGame(){
	background(0);
	garbageCollector();
	box2d.step();
	for(GameObject o : objects){
		o.update();
		o.display();
	}	
}

// Actualiza los elementos del juego
public void updateGame(){
	if (frameCount % 60 == 0){
		Seeker s = new Seeker(width - random(100, 300), random(100, height - 100), random(30, 60), random(60, 70));
		s.normalSpeed = random(1500, 2500);
		s.score = 10;
		objects.add(s);
	}
}

// Muestra los elementos del juego pero no los actualiza y muestra el men\u00fa de pausa
public void displayPause(){
	for(GameObject o : objects){
		o.display();
	}
	noStroke();
	fill(0, 200);
	rect(0, 0, width, height);
	fill(255);
	textSize(60);
	textAlign(CENTER);
	text("PAUSED", width/2, height/2);
}

// Muestra las estad\u00edsticas del juego como el puntaje y la vida del jugador
public void displayStats(){
	stroke(16, 87,  177, 60);
	noFill();
	arc(width/2, height/5, width + 200, height/4, -PI, 0);
	textSize(40);
	textAlign(CENTER);
	String score = String.valueOf(player.score);
	fill(pointsColor);
	text(score, width - textWidth(score), 60);
	String hp = "HP : " + String.valueOf(player.hp);
	fill(13, 108, 1);
	text(hp, 0 + textWidth(hp), 60);
}


public void draw(){
	if (!pause) {
		displayGame();
		updateGame();
	}else{
		displayPause();
	}
	displayStats();
}

// Obtenemos el objecto a partir del fixture
public CollidingObject objectFromFixture(Fixture fixture){
	Body body = fixture.getBody();
	Object object = body.getUserData();
	return (CollidingObject) object;
}

// Se revisa el inicio de la colisi\u00f3n de 2 objetos
public void beginContact(Contact c) {
	CollidingObject o1 = objectFromFixture(c.getFixtureA());
	CollidingObject o2 = objectFromFixture(c.getFixtureB());
	if (o1 instanceof Player){
		checkPlayer(o2);
	}else if(o1 instanceof Enemy){
		checkEnemy((Enemy) o1, o2);
	}else if (o1 instanceof Projectile){
		checkProyectile((Projectile) o1, o2);
	}
}

// Revisamos todas las posibles colisiones de un jugador
public void checkPlayer(CollidingObject object){
	player.decreaseHP();
	object.decreaseHP();
	addToGarbage(object);
}

// Se hace la acci\u00f3n de dispararle a un enemigo
public void shootEnemy(Projectile p, Enemy e){
		e.decreaseHP();
		p.decreaseHP();
		addToGarbage(p);
}

// Se revisa todas las posibles colisiones de un enemigo con otro objeto
public void checkEnemy(Enemy enemy, CollidingObject object){
	if (object instanceof Projectile){
		shootEnemy((Projectile)object, enemy);
	}
	checkEnemy(enemy);
}

// Se revisa el estado del enemigo
public void checkEnemy(Enemy enemy){
	if(enemy.dead){
		addToGarbage(enemy);
		PVector pos = enemy.getPixelPos();
		ParticleSystem particleSystem = new ParticleSystem(pos.x, pos.y,enemy.score);
		objects.add(particleSystem);
		player.score += enemy.score;
	}
}

// Se revisa todas las posibles colisiones de un proyectil con otro objeto
public void checkProyectile(Projectile projectile, CollidingObject object){
	if (object instanceof Enemy){
		Enemy enemy = (Enemy)object;
		shootEnemy(projectile, enemy);
		checkEnemy(enemy);
	}
}

public void keyPressed(){
	keys[keyCode] = true;
	if (key == pauseButton){
		pause = !pause;
	}
}

public void keyReleased(){
	keys[keyCode] = false;
}

// Agregamos los objetos a eliminar del array principal
public void addToGarbage(GameObject object){
	if (object.dead){
		garbage.add(object);
	}
}

// Limpiamos el array principal
public void garbageCollector(){
	for(GameObject o: garbage){
		if (o instanceof Projectile){
			Projectile p = (Projectile)o;
			p.owner.projectiles.remove(p);
		}
		objects.remove(o);
		o.kill();
	}
}

// Agregamos la direcci\u00f3n opuesta a los elementos del mundo cuando el jugador se mueve
public void screenController(PVector speed){
	PVector applySpeed = speed.copy();
	applySpeed.mult(-1);

}

public void endContact(Contact c) {}
class CollidingObject extends GameObject{
	Body body;
	int hp;
	PVector speed;

	CollidingObject(float x, float y, float mass) {
		super(x,y, mass);
		speed = new PVector(0, 0);
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
		fd.setRestitution(0);

		body.createFixture(fd);
		body.setUserData(this);
	}

	public void killBody() {
		if (body != null){
			box2d.destroyBody(body);
			body.setUserData(null);
			body = null;
		}
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
	body.applyForce(force, body.getWorldCenter());
}

public void stop(){
	body.setLinearVelocity(new Vec2(0, 0));
}

public PVector getPixelPos(){
	Vec2 playerPos = box2d.getBodyPixelCoord(body);
	PVector pos = new PVector(playerPos.x, playerPos.y);
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

public void decreaseHP(){
	hp--;
	if (hp <= 0){
		die();
	}
}

public void die(){		
	dead = true;
}
public void kill(){
	killBody();
}
public void update(){
	stop();
}
}
class Enemy extends Ship {
	int score, cost;	
	Enemy (float x, float y, float mass){
		super(x,y,mass);
	}
}
class Flock extends GameObject {
	ArrayList<Particle> agents;
	float alignDistance, separationDistance, cohesionDistance;
	float alignRatio, separationRatio, cohesionRatio, maxForce;
	PVector alignForce, separationForce, cohesionForce, origin;
	int alignCount, separationCount, cohesionCount, maxParticles;
	Player player;

	Flock(float x, float y, int maxParticles, ArrayList<GameObject> objects, Player player){		
		super(x, y, 0);
		agents = new ArrayList();
		separationDistance = 5;
		alignDistance = 70;
		cohesionDistance = 300;
		separationRatio = 1;
		alignRatio = 1;
		cohesionRatio = 1;
		maxForce = 5;		
		origin = new PVector(x, y);
		this.maxParticles = maxParticles;
		this.player = player;
		fillParticles(x , y , 1, objects);		
	}

	public void fillParticles(float x, float y, float mass, ArrayList<GameObject> objects){
		for (int i = 0; i <= maxParticles ; i++){
			Particle p = new Particle(x + random(-20, 20), y + random(-20, 20), mass);		
			this.agents.add(p);	
			objects.add(p);
		}
	}

	public void addParticle(Particle agent){
		agents.add(agent);
	}

	public void display(){}
	public void kill(){}

	public void update(){
		Iterator<Particle> i = agents.iterator();
		while (i.hasNext()) {
			Particle p = i.next();			
			if (p.isDead()){
				//i.remove();
			}
			updateAgent(p);		
			//p.seek(player.getPixelPos());						
		}	
	}


	public void updateAgent(Particle agent){
		alignCount = 0;
		separationCount = 0;
		cohesionCount = 0;
		alignForce = new PVector(0, 0);
		separationForce  = new PVector(0, 0);
		cohesionForce  = new PVector(0, 0);
		for (Particle a : agents) {
			if (agent != a){
				calculateFlock(agent, a);
			}
		}
		applyFlock(agent);		
	}



	public void calculateFlock(Particle origin, Particle target){
		float distance = PVector.dist(origin.objectPosition, target.objectPosition);	
		align(distance, target);
		separate(distance, target, origin);
		cohere(distance, target);
	}

	public void align(float distance, Particle target){
		if (distance < alignDistance){
			alignForce.add(target.speed);
			alignCount++;
		}
	}

	public void separate(float distance, Particle target, Particle origin){
		if (distance < separationDistance){
			PVector difference = PVector.sub(origin.objectPosition, target.objectPosition);
			difference.normalize();
			difference.div(distance);
			separationForce.add(difference);
			separationCount++;	
		}
	}

	public void cohere(float distance, Particle target){
		if (distance < alignDistance){
			cohesionForce.add(target.objectPosition);
			cohesionCount++;
		}
	}

	public void applyAlign(Particle agent){
		if (alignCount > 0){
			alignForce.div(alignCount);
			alignForce.setMag(alignRatio);
			alignForce.limit(maxForce);
			agent.applyForce(alignForce);
			
		}
	}

	public void applySeparation(Particle agent){
		if (separationCount > 0){
			separationForce.div(separationCount);
			separationForce.setMag(separationRatio);
			separationForce.limit(maxForce);
			agent.applyForce(separationForce);					

		}
	}

	public void applyCohesion(Particle agent){
		if (cohesionCount > 0){
			cohesionForce.div(cohesionCount);
			PVector force = cohesionForce.sub(agent.objectPosition);
			force.setMag(cohesionRatio);
			force.limit(maxForce);
			agent.applyForce(force);
			
		}
	}

	public void applyFlock(Particle agent){
		applyAlign(agent);
		applySeparation(agent);
		applyCohesion(agent);		
	}
}
abstract class GameObject{
	 PVector objectPosition;
	 float mass;
	 boolean dead;
	 
	 GameObject(){}

	 GameObject(float posX, float posY, float mass){
	 	this.objectPosition = new PVector(posX, posY);
	 	this.mass = mass;
	 	dead = false;
	 }

	 public void applyForce(PVector speed){}
	 public abstract void kill();
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
class Particle extends GameObject{
  PVector speed,acc;
  float mass, friction, lifeSpan, decay;

  Particle(float x, float y, float mass){
    super(x, y, mass);
    this.speed = new PVector(0,0);
    this.acc = new PVector(0,0);
    this.mass = mass;
    this.decay = 0.5f;
    this.lifeSpan = 255;
  }

  public void display(){
    noStroke();
    fill(pointsColor,lifeSpan);
    ellipse(objectPosition.x, objectPosition.y, mass, mass);
  }

  public void update(){
    speed.add(acc);
    objectPosition.add(speed);
    acc.mult(0);
    lifeSpan -= decay;
  }

  public void applyForce(PVector force){
    PVector f = PVector.div(force,mass);
    acc.add(f);
  }

  public boolean isDead(){
    return lifeSpan <= 0;
  }

  public boolean near(CollidingObject target){
    float distance = PVector.dist(objectPosition, target.getPixelPos());
    return distance <= target.mass;
  }

  public void kill(){}
}



class ParticleSystem extends GameObject{
	PVector origin;
	LinkedList<Particle> particles;
	int maxParticles, current;

	ParticleSystem(float x, float y, int maxParticles){
		super(x, y, 0);
		origin = new PVector(x, y);
		particles = new LinkedList();
		this.maxParticles = maxParticles;
		current = 0;
	}

	public void update(){
		if (current < maxParticles){
			addParticle();
			current++;
		}
		Iterator<Particle> i = particles.iterator();
		while (i.hasNext()) {
			Particle p = i.next();
			p.update();
			if (p.isDead() || p.near(player)){
				i.remove();
			}
		}
	}

	public void display(){
		for (Particle p: particles){
			p.display();
		}
	}

	public void applyForce(PVector force){
		for (Particle p: particles){
			p.applyForce(force);
		}	
	}

	public void addParticle(){
		float mass = abs(randomGaussian())*2 + 5;
		Particle p = new Particle(origin.x, origin.y, mass);
		PVector dir = PVector.random2D();
		dir.setMag(randomGaussian()*1 + 1);
		p.applyForce(dir);
		particles.add(p);
	}

	public void kill(){
		
	}
}
class Player extends Ship implements UserInput{
	int score, recoveringElapsed, recoveryTime, blinkElapsed, blinkTime;
	boolean recovering = false;
	boolean display = true;

	Player(float x, float y, float mass){
		super(x, y, mass);
		hp = 3;
		score = 0;
		recoveryTime = 120;
		blinkElapsed = 0;
		blinkTime = 15;
	}

	public void update(){
		movementController();
		super.update();    
	}

	public void decreaseHP(){
		if (!recovering){
			super.decreaseHP();
			recovering = true;
			recoveringElapsed = 0;
			display = false;
			blinkElapsed = 0;
		}
	}

	public void move(int direction) {
		speed.normalize();
		speed.add(getDirectionVector(direction));
		speed.setMag(normalSpeed);
		if (direction == LEFT || direction == RIGHT){
			screenController(speed);
		}
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
      facingForward = false;
    }
  }

  public void moveRight() {
    if (keys[moveRight]) {
     move(RIGHT);
     facingForward = true;
   }
 }

 public void moveDown() {
  if (keys[moveDown]) {
   move(DOWN);
 }
}

public void shoot() {
  if (keys[shoot]) {
   shootProjectile();
 }
}


public void shootProjectile(){
  if(elapsed > shotSpeed){
    Vec2 pos = box2d.getBodyPixelCoord(body);
    elapsed = 0;
    if (facingForward){
      Projectile p = new Projectile(pos.x + mass, pos.y, projectileMass, projectileForce, this);
      projectiles.add(p);
    }
    else{
     Projectile p = new Projectile(pos.x - mass, pos.y, projectileMass, new Vec2(-projectileForce.x, projectileForce.y), this);
     projectiles.add(p); 
   }
 }
}

public void movementController() {
  moveUp();
  moveLeft();
  moveDown();
  moveRight();
  shoot();
  elapsed++;
  blinkElapsed ++;
  recoveringElapsed++;
  if (recoveringElapsed > recoveryTime){
   recovering = false;    
 }  
 if (recovering && blinkElapsed > blinkTime){
   display = !display;
   blinkElapsed = 0;
 }
}

public void display(){
  if (inScreen() && !recovering){
   Vec2 pos = box2d.getBodyPixelCoord(body);
   pushMatrix();
   translate(pos.x, pos.y);      
   fill(0,255,0);
   ellipse(0, 0, mass, mass);
   popMatrix();
 }
 if (inScreen() && display){    
   Vec2 pos = box2d.getBodyPixelCoord(body);
   pushMatrix();
   translate(pos.x, pos.y);      
   fill(0,255,0);
   ellipse(0, 0, mass, mass);
   popMatrix();    
 }
 for(Projectile p : projectiles){
   p.display();
 }

}

}

class Projectile extends CollidingObject{
	Vec2 force;
	Ship owner;
	
	Projectile(float posX, float posY, float mass, Vec2 force, Ship owner){
		super(posX,posY,mass);
		this.owner = owner;
		applyForce(force);		
	}

	public void display(){
		Vec2 pos = box2d.getBodyPixelCoord(body);
		float a = vec2Heading(getPos());
		strokeWeight(2);
		fill(0,0,255);
		pushMatrix();
		translate(pos.x, pos.y);
		ellipse(0, 0, this.mass, this.mass);
		popMatrix();		
	}


	public void update(){
		super.update();
	}


}
class Seeker extends Enemy {
	float rotationSpeed;

	Seeker(float x, float y, float mass, float rotationSpeed){
		super(x,y,mass);
		this.rotationSpeed = rotationSpeed;
	}

	public void seek(PVector target) {
		PVector desired = PVector.sub(target, getPixelPos());
		desired.setMag(normalSpeed);
		PVector steering = PVector.sub(desired, speed);
		steering.limit(normalSpeed);
		steering.y *= -1;
		setSpeed(steering);
	}

	public void display() {
		super.display();
	}

	public void update(){
		super.update();
		seek(player.getPixelPos());
	}



}
class Ship extends CollidingObject{
	int elapsed, shotSpeed;
	float normalSpeed, boostSpeed;
	ArrayList<Projectile> projectiles;
	float projectileMass;
  	Vec2 projectileForce;
  	boolean facingForward = true;


	Ship(float x, float y, float mass){
		super(x, y, mass);
		hp = 1;
		normalSpeed = 0;
		boostSpeed = 0;
		elapsed = 0;
		shotSpeed = 10;
		projectileMass = 10;
    		projectileForce = new Vec2(20000,0);
		this.projectiles = new ArrayList();
	}

	public void update(){
		super.update();
	}

	public void display(){
		if (inScreen()){
			Vec2 pos = box2d.getBodyPixelCoord(body);
			pushMatrix();
			translate(pos.x, pos.y);
			fill(255,0,0);
			ellipse(0, 0, mass, mass);
			popMatrix();
		}
	}

	public void shootProjectile(){
		if(elapsed > shotSpeed){
			Vec2 pos = box2d.getBodyPixelCoord(body);
			elapsed = 0;
			Projectile p = new Projectile(pos.x + mass, pos.y, projectileMass, projectileForce, this);
	  		projectiles.add(p);
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

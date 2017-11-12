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
int FRAME_RATE = 60;
float ROTATION_RATE = 0.004f;
int LEVEL_WAVES = 2;
int PLAYER_HIT_MULTIPLIER = 30 * FRAME_RATE;
float PARENT_COEFICIENT = 0.10f;

float BACKGROUND_MOVE = 1;
PImage gameBg;
float x_ofset;

int SECONDS_TO_WAVE = 1;

EnemyDna god;

Level currentLevel;

Menu menu;
int currentSkin = 1;
int maxSkins = 6;

int pointsColor;

Player player;
Box2DProcessing box2d;
boolean[] keys = new boolean[1024];

public void setup(){
	frameRate(FRAME_RATE);
	
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
	gameBg = loadImage("Images/GameBg.png");
	gameBg.resize(0, height);
	x_ofset = -width;
	player = new Player(width/2, height/2, 40);
	player.setSpeed(2500);
	player.boostSpeed = 7500;
	player.shipImage = loadImage("Images/Skins/" + Integer.toString(currentSkin) + ".png");
	god = new EnemyDna(4200, 100, 25);
	currentLevel = new Level(player, LEVEL_WAVES, 0);
	menu = new Menu();
}

// Muestra los elementos del juego pero no los actualiza y muestra el men\u00fa de pausa
public void displayPause(){
	currentLevel.display();
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

	String textToShow = String.valueOf(player.score);
	displayText(textToShow, width/2, 40, pointsColor, 40, CENTER);

	textToShow = "HP : " + String.valueOf(player.hp);
	displayText(textToShow, 0, 40, color(13, 108, 1), 30, LEFT);

	textToShow = "Boost : ";
	displayText(textToShow, 15, 90, color(13, 108, 1), 30, LEFT);

	rect(120,70,player.boostAvailable, 20);


	textToShow = "WAVE " + String.valueOf(currentLevel.waveCurrent + 1) + "/"+ String.valueOf(currentLevel.waveAmmount);
	displayText(textToShow, width, 40, color(13, 108, 1), 30, RIGHT);
	if (currentLevel.inWave()){
		// progresso del wave
	}else{
		textToShow = "WAVE STARTING IN " + String.valueOf(currentLevel.secondsToWave());
		displayText(textToShow, width/2, 75, color(13, 108, 1), 25, CENTER);
	}
}

public void displayText(String textToShow, float x, float y, int textColor, int textSize, int align){
	if (align == LEFT){
		x += textWidth(textToShow) / 2;
	}else if(align == RIGHT){
		x -= textWidth(textToShow) / 2;
	}
	textAlign(CENTER);
	textSize(textSize);
	fill(textColor);
	text(textToShow, x, y);
}


public void draw(){
	if (currentLevel.levelNumber > 0){
		if (!pause) {
			background(0);
			image(gameBg, x_ofset + width, height/2);
			box2d.step();
			currentLevel.display();
			currentLevel.update();
		}else{
			displayPause();
		}
		displayStats();
	}else{
		menu.showMenu();
	}
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
	if (!player.boosting){
		player.decreaseHP();
		if (object instanceof Enemy){
			((Enemy) object).playerHit();
		}
		else if (object instanceof Projectile){
			Projectile projectile = (Projectile) object;
			if (projectile.owner instanceof Enemy){
				((Enemy) projectile.owner).playerHit(); 
			}
		}
	}
	object.decreaseHP();
	currentLevel.addToGarbage(object);
}

// Se hace la acci\u00f3n de dispararle a un enemigo
public void shootEnemy(Projectile p, Enemy e){
	if (p.owner instanceof Player){
		e.decreaseHP();
	}
	p.decreaseHP();
	currentLevel.addToGarbage(p);
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
		currentLevel.addToGarbage(enemy);
		currentLevel.enemyDeath(enemy);
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
	if (!pause){
		keys[keyCode] = true;
	}
	if (key == pauseButton){
		pause = !pause;
	}
}

public void keyReleased(){
	keys[keyCode] = false;
}

public void endContact(Contact c) {}
class Boss{
	
}
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

public float angleHeading(PVector vector){
	PVector heading = PVector.sub(getPixelPos(), vector);
	float angle = heading.heading();
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
	speed.mult(0);
}
}
class Enemy extends Ship {
	int score;
	EnemyDna dna;
	int c; 
	float headginAngle;

	Enemy (float x, float y, float mass){
		super(x,y,mass);
		headginAngle = 0;
	}

	public void update(){
		super.update();
		dna.lifeElapsed++;
	}

	public void playerHit(){
		dna.playerHits ++;		
	}

	public void generateFitness(){		
		dna.fitness = dna.lifeElapsed;
		dna.fitness += dna.playerHits * PLAYER_HIT_MULTIPLIER; 					
	}

	public void display(){
		if (inScreen()){
			Vec2 pos = box2d.getBodyPixelCoord(body);
			pushMatrix();
			translate(pos.x, pos.y);
			imageMode(CENTER);
			rotate(headginAngle);
			fill(color(255*dna.speed , 255* dna.turnSpeed, 255*dna.shootElapsed));
			ellipse(0, 0, mass, mass);
			if (shipImage != null){
				image(shipImage, 0, 0, mass, mass);
			}
			popMatrix();
		}
	}
}
class EnemyDna {
	float speed;
	float turnSpeed;
	float shootElapsed;
	float mass;
	float fitness;
	int lifeElapsed;
	int score;
	int playerHits; 

	EnemyDna(float speed, float turnSpeed, float shootElapsed){
		this.speed = speed;
		this.turnSpeed = turnSpeed;
		this.shootElapsed = shootElapsed;
		this.mass = mass;
		fitness = 0;
		lifeElapsed = 0;
		playerHits = 0;
		score = getScore();
	}

	public int getScore(){
		return (int) map(speed, 0,1,5,1) * 10 ;
	}
}
class Flock extends GameObject {
	ArrayList<Enemy> agents;
	float alignDistance, separationDistance, cohesionDistance;
	float alignRatio, separationRatio, cohesionRatio, maxForce;
	PVector alignForce, separationForce, cohesionForce;
	int alignCount, separationCount, cohesionCount, maxEnemys;
	Player player;

	Flock(Player player, float maxForce){		
		super(0, 0, 0);
		agents = new ArrayList();
		separationDistance = 70;
		alignDistance = 70;
		cohesionDistance = 50;
		separationRatio = 100;
		alignRatio = 150;
		cohesionRatio = 150;
		this.maxForce = maxForce;
		this.player = player;
	}

	public void addEnemy(Enemy agent){
		agents.add(agent);
	}

	public void setSpeed(PVector speed){
		for(Enemy o : agents){
			o.setSpeed(speed);
		}
	}

	public void display(){}
	public void kill(){}

	public void update(){
		Iterator<Enemy> i = agents.iterator();
		while (i.hasNext()) {
			Enemy p = i.next();			
			if (p.dead){
				i.remove();
				p.kill();
			}else{
				updateAgent(p);
				p.update();
				p.display();
			}
		}	
	}

	public void updateAgent(Enemy agent){
		alignCount = 0;
		separationCount = 0;
		cohesionCount = 0;
		alignForce = new PVector(0, 0);
		separationForce  = new PVector(0, 0);
		cohesionForce  = new PVector(0, 0);
		for (Enemy a : agents) {
			if (agent != a){
				calculateFlock(agent, a);
			}
		}
		applyFlock(agent);		
	}



	public void calculateFlock(Enemy origin, Enemy target){
		float distance = PVector.dist(origin.objectPosition, target.objectPosition);	
		align(distance, target);
		separate(distance, target, origin);
		cohere(distance, target);
	}

	public void align(float distance, Enemy target){
		if (distance < alignDistance){
			alignForce.add(target.speed);
			alignCount++;
		}
	}

	public void separate(float distance, Enemy target, Enemy origin){
		if (distance < separationDistance){
			PVector difference = PVector.sub(origin.objectPosition, target.objectPosition);
			difference.normalize();
			difference.div(distance);
			separationForce.add(difference);
			separationCount++;	
		}
	}

	public void cohere(float distance, Enemy target){
		if (distance < alignDistance){
			cohesionForce.add(target.objectPosition);
			cohesionCount++;
		}
	}

	public void applyAlign(Enemy agent){
		if (alignCount > 0){
			alignForce.div(alignCount);
			alignForce.setMag(alignRatio * agent.dna.speed);
			alignForce.limit(maxForce);
			agent.setSpeed(alignForce);
			
		}
	}

	public void applySeparation(Enemy agent){
		if (separationCount > 0){
			separationForce.div(separationCount);
			separationForce.setMag(separationRatio * agent.dna.shootElapsed);
			separationForce.limit(maxForce);
			agent.setSpeed(separationForce);					

		}
	}

	public void applyCohesion(Enemy agent){
		if (cohesionCount > 0){
			cohesionForce.div(cohesionCount);
			PVector force = cohesionForce.sub(agent.objectPosition);
			force.setMag(cohesionRatio * agent.dna.turnSpeed);
			force.limit(maxForce);
			agent.setSpeed(force);
			
		}
	}

	public void applyFlock(Enemy agent){
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

	 public void setSpeed(PVector speed){}
	 public abstract void kill();
	 public abstract void display();
	 public abstract void update();

}
class Level{
	Player player;
	int levelNumber;

	int waveAmmount;
	int waveCurrent;
	Wave wave;

	ArrayList<GameObject> objects;
	ArrayList<GameObject> garbage;
	Flock flock;

	PVector worldDirection;
	PImage worldImage;
	float worldAngle;
	String mediaPath;

	PImage enemyImage;

	boolean completed;
	
	Level(Player player, int waveAmmount, int levelNumber){
		this.player = player;
		this.waveAmmount = waveAmmount;
		waveCurrent = 0;

		this.levelNumber = levelNumber;
		mediaPath = "Images/Level_" + levelNumber;
		completed = false;

		worldAngle = 0;
		if (levelNumber > 0){
			worldImage = loadImage(mediaPath + "/bg.png");
			enemyImage = loadImage(mediaPath + "/enemy.png");
		}

		objects = new ArrayList();
		garbage = new ArrayList();
		worldDirection = new PVector(0, 0);
		flock = new Flock(player, 500);

		ParticleSystem playerFire = new ParticleSystem(2);
		ParticleSystem playerFire2 = new ParticleSystem(10);
		objects.add(playerFire);
		objects.add(playerFire2);

		objects.add(flock);
		objects.add(player);

		wave = new Wave(flock, 50, 200, FRAME_RATE * SECONDS_TO_WAVE);
		wave.enemyImage = enemyImage;
	}


	public void display(){
		if (levelNumber > 0){
			garbageCollector();
			displayBackground();
			for(GameObject o : objects){
				o.update();
				o.display();
			}	
		}
	}

	public boolean inWave(){
		return wave.startElapse <= 0;
	}

	// Actualiza los elementos del juego
	public void update(){
		if (!completed && levelNumber > 0){
			updateLevel();
		}
	}

	public void updateLevel(){
		if (wave.cleared){
			nextWave();
		}
		wave.update();
		for (Projectile p  : player.projectiles){
			p.update();
		}
	}

	public int secondsToWave(){
		return wave.startElapse / FRAME_RATE;
	}

	public void nextWave(){
		// Caca genetica
		if (flock.agents.size() == 0){
			waveCurrent++;
			completed = waveCurrent == waveAmmount;			
			wave = new Wave(flock, 30, 100, FRAME_RATE * SECONDS_TO_WAVE, wave.sortedDnas);
			wave.enemyImage = enemyImage;
		}
	}

	// Agregamos los objetos a eliminar del array principal
	public void addToGarbage(GameObject object){
		if (object.dead){
			garbage.add(object);
			if (object instanceof Enemy){
				Enemy e = (Enemy) object;				
				e.generateFitness();
				wave.insertIntoSortedDNAS(e.dna);
			}
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

	public void enemyDeath(Enemy enemy){
		PVector deathPosition = enemy.getPixelPos();
		ParticleSystem particleSystem = new ParticleSystem(deathPosition.x, deathPosition.y, enemy.score);
		objects.add(particleSystem);
		player.score += enemy.score;
	}

	// Agregamos la direcci\u00f3n opuesta a los elementos del mundo cuando el jugador se mueve
	public void screenController(float speed){
		worldDirection.x = speed * -1;
		for(GameObject o : objects){
			o.setSpeed(worldDirection);
		}
	}

	public void addRotation(float rotation){
		x_ofset += (rotation > 0) ? BACKGROUND_MOVE : -BACKGROUND_MOVE;
		worldAngle += rotation;
		if (x_ofset > 0){
			x_ofset = -width;
		}else if (x_ofset < -width *2){
			x_ofset = -width;
		}
	}


	// Muestra y rota los elementos del fondo
	public void displayBackground(){
		if (levelNumber > 0){
			pushMatrix();
			translate(width/2, height + width/1.8f);
			imageMode(CENTER);
			rotate(worldAngle);
			image(worldImage, 0, 0, width * 1.5f, width * 1.5f);
			popMatrix();
		}

	}
}
class Menu{
	int clickElapsed = 0;
	PVector startButtonPos = new PVector(width/2, height/2 + 200);
	PImage nextButton;
	PImage previousButton;
	PImage startButton;

	public Menu() {
		nextButton = loadImage("Images/Buttons/next.png");
		previousButton = loadImage("Images/Buttons/previous.png");
		startButton = loadImage("Images/Buttons/start.png");
	}

	public void showMenu() {
		background(255);
		noFill();
		//noStroke();
		imageMode(CENTER);

    		// Next Skin
    		image(nextButton, width/2 + width/4, height/2);
    		if (mousePressed && 
    			mouseX > width/2 + width/4 - 25 && mouseX < width/2 + width/4 + 25 && 
    			mouseY > height/2 - 25 && mouseY < height/2 + 25 && clickElapsed > 20){
    			currentSkin = (currentSkin % maxSkins)+1;
    			player.shipImage = loadImage("Images/Skins/" + Integer.toString(currentSkin) + ".png");
    			clickElapsed = 0;
    		}

    		// Previous Skin
    		image(previousButton, width/2 - width/4, height/2);
    		if (mousePressed && 
    			mouseX > width/2 - width/4 - 25 && mouseX < width/2 - width/4 + 25 && 
    			mouseY > height/2 - 25 && mouseY < height/2 + 25 && clickElapsed > 20){
    			currentSkin = (currentSkin == 1) ? maxSkins : currentSkin - 1;
    			player.shipImage = loadImage("Images/Skins/" + Integer.toString(currentSkin) + ".png");
    			clickElapsed = 0;
    		}

 	   	// Bot\u00f3n de Start   
 	   	image(startButton, width/2, height/2 + height/3); 
 	   	if (mousePressed && clickElapsed > 20 && 
 	   		(mouseX > width/2 - 100 && mouseX < width/2 + 100) && 
 	   		(mouseY > height/2 + height/3 - 50 && mouseY < height/2 + height/3 + 50)){
 	   		currentLevel = new Level(player, LEVEL_WAVES, 1);
 	   	clickElapsed = 0;
 	   }
 	   image(player.shipImage, width/2, height/2, 250, 250);
 	   clickElapsed++;
 	}

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
	float maxSpeed;
	boolean seekPlayer;

	Particle(float x, float y, float mass){
		super(x, y, mass);
		this.speed = new PVector(0,0);
		this.acc = new PVector(0,0);
		this.mass = mass;
		this.maxSpeed = random(1, 10);
		this.decay = (seekPlayer) ? 0.5f : 2;
		this.lifeSpan = (seekPlayer) ? 255 : 100;
	}

	public void display(){
		noStroke();
		float pmass = mass;
		if (seekPlayer){
			fill(pointsColor,lifeSpan);
		}else{
			fill(255, 0, 0,lifeSpan);
			if(player.boosting && player.boostAvailable > 0){
				fill(0, 0, 255,lifeSpan);
				pmass = mass * 2;
			}
		}
		ellipse(objectPosition.x, objectPosition.y, pmass, pmass);
	}

	public void update(){
		speed.add(acc);
		objectPosition.add(speed);
		acc.mult(0);
		lifeSpan -= decay;
		if (seekPlayer){
			seekPlayer();
		}
	}

	public void seekPlayer(){
		PVector randy = PVector.random2D();
		randy.setMag(random(player.mass));
		PVector pos = player.getPixelPos().add(randy);
		seek(pos);
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
		return distance < target.mass / 2;
	}

	public void seek(PVector target) {
		PVector desired = PVector.sub(target, objectPosition);
		desired.setMag(maxSpeed);
		PVector steering = PVector.sub(desired, speed);
		steering.limit(maxSpeed);
		applyForce(steering);
	}

	public void kill(){}
}



class ParticleSystem extends GameObject{
	PVector origin;
	LinkedList<Particle> particles;
	int maxParticles, current;
	boolean seekPlayer;

	float offsetY;
	PVector force;

	ParticleSystem(float x, float y, int maxParticles){
		super(x, y, 0);
		origin = new PVector(x, y);
		particles = new LinkedList();
		this.maxParticles = maxParticles;
		seekPlayer = true;
		current = 0;
	}

	ParticleSystem(float offsetY){
		super(0, 0, 0);
		origin = new PVector(getPositionX(), getPositionY());
		particles = new LinkedList();
		this.maxParticles = maxParticles;
		seekPlayer = false;
		force = new PVector(0, 0);
		this.offsetY = offsetY;
		current = 0;
	}

	public float getPositionX(){
		if (player.facingForward){
			return player.getPixelPos().x - 30;
		}
		return player.getPixelPos().x + 30;
	}

	public float getPositionY(){
		return player.getPixelPos().y + offsetY;
	}

	public float getForceX(){
		float speedForce = (player.boosting && player.boostAvailable > 0) ? player.boostSpeed : player.normalSpeed;
		if (player.facingForward){
			return -speedForce / 10000;
		}
		return speedForce / 10000;
	}

	public void update(){
		if(!seekPlayer){
			addParticle();
			applyForce(force);
			origin.x = getPositionX();
			origin.y = getPositionY();
			force.x = getForceX();
		}
		if (current < maxParticles && seekPlayer){
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
		float mass = (seekPlayer) ? abs(randomGaussian())*3 + 5 : abs(randomGaussian())*3 + 2;
		Particle p = new Particle(origin.x, origin.y, mass);
		p.seekPlayer = seekPlayer;
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
	boolean boosting; 
	int boostTime, boostAvailable, boostRecharge, boostRechargeElapsed;	


	Player(float x, float y, float mass){
		super(x, y, mass);
		hp = 3;
		score = 0;
		recoveryTime = 120;
		blinkElapsed = 0;
		blinkTime = 15;
		boosting = false;
		boostTime = 300;
		boostAvailable =  300; 
		boostRecharge  = 60;
		boostRechargeElapsed = 0;
	}

	public void setSpeed(int speed){
		this.normalSpeed =  speed;
	}

	public void update(){
		movementController();
		if (boosting && boostAvailable != 0){			
			boostAvailable--;
		}
		if (!boosting && boostAvailable <= boostTime){
			boostRechargeElapsed ++;
			if (boostRechargeElapsed >= boostRecharge){
				boostAvailable++;
			}
		}
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
		if (boosting){			
			speed.setMag(boostSpeed);	
		}
		else{
			speed.setMag(normalSpeed);			
		}
		currentLevel.screenController(speed.x);
		setSpeed(speed);
	}

	public void moveUp() {
		if (keys[moveUp]) {
			if (getPixelPos().y > mass && !boosting){				
				move(UP);				
			}
		}
	}

	public void moveLeft() {
		if (keys[moveLeft]) {			
			if(!boosting){						
				move(LEFT);	
				currentLevel.addRotation(ROTATION_RATE);
			}
		}
	}

	public void moveRight() {
		if (keys[moveRight]) {
			if(!boosting){									
				currentLevel.addRotation(-ROTATION_RATE);
				move(RIGHT);     
			}
		}
	}
	public void faceRight(){
		if(keys[faceRight]){
			if (!boosting){			
				facingForward = true;
			}
		}
	}


	public void faceLeft(){
		if(keys[faceLeft]){
			if (!boosting){
				facingForward = false;
			}
		}
	}


	public void moveDown() {
		if (keys[moveDown]) {
			if (getPixelPos().y < height - mass && !boosting){
				move(DOWN);
			}
		}
	}

	public void shoot() {
		if (keys[shoot]) {
			shootProjectile();
		}
	}


	public void boost(){		
		if (keys[boost]){			
			boosting = true;	
			if (boostAvailable > 0){	
				boostRechargeElapsed = 0;			
				if (facingForward){
					move(RIGHT);
					currentLevel.addRotation(-ROTATION_RATE * (boostSpeed/normalSpeed));
				}
				else {
					move(LEFT);
					currentLevel.addRotation(ROTATION_RATE * (boostSpeed/normalSpeed));	
				}
			}		
		}
		else{			
			boosting = false; 			
		}
	}

	public void shootProjectile(){
		if(elapsed > shotSpeed && !boosting){
			Vec2 pos = box2d.getBodyPixelCoord(body);
			Vec2 bulletPos = new Vec2(pos.x + mass, pos.y - mass / 1.5f);
			Vec2 bulletForce = new Vec2(projectileForce.x, projectileForce.y);
			elapsed = 0;
			if (!facingForward){
				bulletPos.x -= mass*2;
				bulletForce.x *= -1;
			}
			Projectile p = new Projectile(bulletPos.x, bulletPos.y, projectileMass, bulletForce, this);
			projectiles.add(p); 		 
		}
	}

	public void movementController() {
		moveUp();
		moveLeft();
		moveDown();
		moveRight();
		faceLeft();
		faceRight();
		shoot();
		boost();
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
			displayShip();
			popMatrix();
		}
		if (inScreen() && display && recovering){    
			Vec2 pos = box2d.getBodyPixelCoord(body);
			pushMatrix();
			translate(pos.x, pos.y);      
			fill(0,255,0);
			displayShip();
			popMatrix();    
		}
		for(Projectile p : projectiles){
			p.display();
		}

	}

	public void displayShip(){
		if (shipImage != null){
			if (!facingForward){
				scale(-1,1);
			}
			image(shipImage, 0, 0, mass * 2, mass * 2);
		}else{
			ellipse(0, 0, mass, mass);
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
		strokeWeight(2);
		fill(0,0,255);
		pushMatrix();
		translate(pos.x, pos.y);
		ellipse(0, 0, this.mass, this.mass);
		popMatrix();		
	}


	public void update(){		
		if (!inScreen()){			
			dead = true; 		
			currentLevel.addToGarbage(this);			
		}
		
	}
}
class Seeker extends Enemy {
	float rotationSpeed;

	Seeker(float x, float y, float mass, float rotationSpeed){
		super(x,y,mass);
		this.rotationSpeed = rotationSpeed;
	}

	Seeker(float x, float y, float rotationSpeed, float normalSpeed, int shotSpeed){		
		super(x,y, map (normalSpeed,10, god.speed, 60, 15));
		this.rotationSpeed = rotationSpeed;
		this.normalSpeed = normalSpeed; 
		this.shotSpeed = shotSpeed; 
		projectileForce = new Vec2(15000,0);
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
		for(Projectile p : projectiles){
			p.display();
		}
	}

	public void update(){
		super.update();
		PVector playerPos = player.getPixelPos();
		headginAngle = angleHeading(playerPos);
		seek(playerPos);
		elapsed++;
		shootProjectile();
	}


	public void shootProjectile(){
		if(elapsed > shotSpeed){
			Vec2 pos = box2d.getBodyPixelCoord(body);
			Vec2 bulletPos = new Vec2(pos.x - mass, pos.y );
			Vec2 bulletForce = new Vec2(-projectileForce.x, projectileForce.y);
			elapsed = 0;
			if (pos.x < player.getPixelPos().x){
				bulletPos.x += mass*2;
				bulletForce.x *= -1;
			}			
			Projectile p = new Projectile(bulletPos.x, bulletPos.y, projectileMass, bulletForce, this);
			projectiles.add(p); 		 
		}
	}



}
class Ship extends CollidingObject{
	int elapsed, shotSpeed;
	float normalSpeed, boostSpeed;
	ArrayList<Projectile> projectiles;
	float projectileMass;
	Vec2 projectileForce;
	boolean facingForward = true;

	PImage shipImage;


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
	char faceLeft = 'K';
	char faceRight = 'L';
	char shoot = ' ';
	char boost ='Q'; 

	public void movementController();
	public void moveUp();
	public void moveLeft();
	public void moveDown();
	public void moveRight();
	public void faceRight();
	public void faceLeft();
	public void shoot();
	public void boost();
}
class Wave{
	int costActive;
	int costGlobal;
	int costUsed;

	int iParent;
	int jParent;
	int maxChilds;
	int lowestParent;

	float multiplierGod;
	float multiplierLevel;

	Flock flock;
	boolean cleared;

	ArrayList<EnemyDna> dnas;
	ArrayList<EnemyDna> sortedDnas;
	int startElapse;
	int currEnemy;

	PImage enemyImage;

	Wave(Flock flock, int costActive, int costGlobal, int elapse){
		generalInit(flock, costActive, costGlobal, elapse);
		createDna();
	}

	Wave(Flock flock, int costActive, int costGlobal, int elapse, ArrayList<EnemyDna> oldDna){
		generalInit( flock,  costActive, costGlobal, elapse);
		createDna(oldDna);
	}

	public void generalInit(Flock flock, int costActive, int costGlobal, int elapse){
		this.flock = flock;
		this.costActive = costActive;
		this.costGlobal = costGlobal;
		startElapse = elapse;
		costUsed = 0;
		currEnemy = 0;
		cleared = false;
	}

	public void createDna(){
		int currCost = 0;
		dnas = new ArrayList();
		sortedDnas = new ArrayList();
		while(currCost < costGlobal){
			float speedPercent = random(0, 1);
			float turnPercent = random( 0, 1-speedPercent);
			float fireRate = 1 - (speedPercent + turnPercent) + 0.0000000001f;
			EnemyDna dna = new EnemyDna(speedPercent, turnPercent , fireRate);
			dnas.add(dna);
			currCost += dna.score;
		}
		this.costGlobal = currCost;
		
	}

	public void createDna(ArrayList<EnemyDna> oldDna){
		int currCost = 0;
		dnas = new ArrayList();
		sortedDnas = new ArrayList();

		iParent = 0;
		jParent = iParent + 1;
		maxChilds = PApplet.parseInt(costGlobal / 10);
		lowestParent = PApplet.parseInt(maxChilds * PARENT_COEFICIENT) + 1;
		
		while(currCost < costGlobal){			
			EnemyDna parent1 = oldDna.get(iParent);
			EnemyDna parent2 = oldDna.get(jParent);

			EnemyDna child = combine(parent1, parent2);
			dnas.add(child);

			int score = child.score;
			currCost += score;

			nextParentSelection(oldDna.size());
		}
		this.costGlobal = currCost;
		
	}

	public EnemyDna combine(EnemyDna parent1, EnemyDna parent2){
		float parent1Percent = random(0.420f, 0.69f);
		float parent2Percent = 1 - parent1Percent;		
		float childSpeed = parent1Percent*parent1.speed + parent2Percent * parent2.speed;
		float childTurnSpeed = parent1Percent*parent1.turnSpeed + parent2Percent * parent2.turnSpeed;
		float childShootElapsed = parent1Percent * parent1.shootElapsed + parent2Percent * parent2.shootElapsed;
		EnemyDna child = new EnemyDna(childSpeed, childTurnSpeed, childShootElapsed);
		return child;
	}

	public void nextParentSelection(int size){
		jParent++;
		if (jParent == lowestParent || jParent >= size){
			iParent++;
			jParent = iParent + 1;
		}
		if (iParent == lowestParent || iParent >= size){
			iParent = 0;
			jParent = iParent + 1;
		}

	}

	public void update(){
		if (frameCount % 60 == 0 && currEnemy < dnas.size() && startElapse <= 0 && currentCost() < costActive){
			EnemyDna currDna = dnas.get(currEnemy);
			Seeker s = new Seeker(width, random(0, height) ,currDna.turnSpeed * god.turnSpeed, currDna.speed * god.speed, (int)( (god.shootElapsed / currDna.shootElapsed) ));			
			currEnemy ++;			
			s.dna = currDna;
			s.score = currDna.getScore();
			s.shipImage = enemyImage;
			flock.addEnemy(s);
			cleared = currEnemy >= dnas.size();
		}
		startElapse--;
	}

	public int currentCost(){
		int totalScore = 0;
		for(Enemy e: flock.agents){
			totalScore += e.score;
		}
		return totalScore;
	}

	public void insertIntoSortedDNAS(EnemyDna dna){
		int index = getIndex(dna);		
		sortedDnas.add(index, dna);
	}

	public int getIndex(EnemyDna dna){
		for (int i = 0 ; i < sortedDnas.size(); i++){
			if (dna.fitness >= dnas.get(i).fitness){
				sortedDnas.add(i, dna);
				return i;				
			}
		}
		return sortedDnas.size();
	}
}
  public void settings() { 	fullScreen(P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Prototype" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

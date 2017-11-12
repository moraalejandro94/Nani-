import java.util.Iterator;
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

boolean pause = false;
char pauseButton = 'p';
int gameFrame = 60;
float ROTATION_RATE = 0.004;

EnemyDna god;

Level currentLevel;

color pointsColor;

Player player;
Box2DProcessing box2d;
boolean[] keys = new boolean[1024];

void setup(){
	frameRate(gameFrame);
	fullScreen(P2D);
	background(0);
	box2dInit();
	gameInit();
	colorsInit();
}


// Inicializa todos los colores usados en el juego
void colorsInit(){
	pointsColor = color(13, 108, 1);
}

// Inicializa el mundo de box2d
void box2dInit() {
	box2d = new Box2DProcessing(this);
	box2d.createWorld();
	box2d.setGravity(0,0);
	box2d.listenForCollisions();
}

// Inicializa el jugador y los elementos del juego
void gameInit(){
	player = new Player(width/2, height/2, 40);
	player.normalSpeed = 2500;
	player.shipImage = loadImage("Images/player.png");
	god = new EnemyDna(4200, 100, 25);
	currentLevel = new Level(player, 2, 1);
}

// Muestra los elementos del juego pero no los actualiza y muestra el menú de pausa
void displayPause(){
	currentLevel.display();
	noStroke();
	fill(0, 200);
	rect(0, 0, width, height);
	fill(255);
	textSize(60);
	textAlign(CENTER);
	text("PAUSED", width/2, height/2);
}

// Muestra las estadísticas del juego como el puntaje y la vida del jugador
void displayStats(){
	stroke(16, 87,  177, 60);
	noFill();
	arc(width/2, height/5, width + 200, height/4, -PI, 0);

	String textToShow = String.valueOf(player.score);
	displayText(textToShow, width/2, 40, pointsColor, 40, CENTER);

	textToShow = "HP : " + String.valueOf(player.hp);
	displayText(textToShow, 0, 40, color(13, 108, 1), 30, LEFT);

	textToShow = "WAVE " + String.valueOf(currentLevel.waveCurrent + 1) + "/"+ String.valueOf(currentLevel.waveAmmount);
	displayText(textToShow, width, 40, color(13, 108, 1), 30, RIGHT);
	if (currentLevel.inWave()){
		// progresso del wave
	}else{
		textToShow = "WAVE STARTING IN " + String.valueOf(currentLevel.secondsToWave());
		displayText(textToShow, width/2, 75, color(13, 108, 1), 25, CENTER);
	}
}

void displayText(String textToShow, float x, float y, color textColor, int textSize, int align){
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


void draw(){

	if (!pause) {
		background(0);
		box2d.step();
		currentLevel.display();
		currentLevel.update();
	}else{
		displayPause();
	}
	displayStats();
}

// Obtenemos el objecto a partir del fixture
CollidingObject objectFromFixture(Fixture fixture){
	Body body = fixture.getBody();
	Object object = body.getUserData();
	return (CollidingObject) object;
}

// Se revisa el inicio de la colisión de 2 objetos
void beginContact(Contact c) {
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
void checkPlayer(CollidingObject object){
	player.decreaseHP();
	object.decreaseHP();
	currentLevel.addToGarbage(object);
}

// Se hace la acción de dispararle a un enemigo
void shootEnemy(Projectile p, Enemy e){
	e.decreaseHP();
	p.decreaseHP();
	currentLevel.addToGarbage(p);
}

// Se revisa todas las posibles colisiones de un enemigo con otro objeto
void checkEnemy(Enemy enemy, CollidingObject object){
	if (object instanceof Projectile){
		shootEnemy((Projectile)object, enemy);
	}
	checkEnemy(enemy);
}

// Se revisa el estado del enemigo
void checkEnemy(Enemy enemy){
	if(enemy.dead){
		currentLevel.addToGarbage(enemy);
		currentLevel.enemyDeath(enemy);
	}
}

// Se revisa todas las posibles colisiones de un proyectil con otro objeto
void checkProyectile(Projectile projectile, CollidingObject object){
	if (object instanceof Enemy){
		Enemy enemy = (Enemy)object;
		shootEnemy(projectile, enemy);
		checkEnemy(enemy);
	}
}

void keyPressed(){
	if (!pause){
		keys[keyCode] = true;
	}
	if (key == pauseButton){
		pause = !pause;
	}
}

void keyReleased(){
	keys[keyCode] = false;
}

void endContact(Contact c) {}

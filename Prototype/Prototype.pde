import java.util.Iterator;
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

boolean pause = false;
char pauseButton = 'p';

PImage bg;
float angle;

color pointsColor;

Player player;
Flock flock;
Box2DProcessing box2d;
boolean[] keys = new boolean[1024];
PVector worldDirection;

ArrayList<PVector> points;
PVector start;

boolean boss;

ArrayList<GameObject> objects;
ArrayList<GameObject> garbage;

void setup(){
	frameRate(60);
	points = new ArrayList();
	start = new PVector(width/2 + 500,150);
	boss = false;
	bg = loadImage("data/bg.png");
	angle = 0;
	fractal();
	fullScreen(P2D);
	background(0);
	box2dInit();
	gameInit();
	colorsInit();
}


void fractal(){
	points.add(new PVector(width/2 + 200, 100));
	points.add(new PVector(width/4 + 200, height - 100));
	points.add(new PVector(3*width/4 + 200, height - 100));
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
	objects = new ArrayList();
	garbage = new ArrayList();
	worldDirection = new PVector(0, 0);
	player = (boss) ? new Player(200, height/2, 40) : new Player(width/2, height/2, 40);
	player.normalSpeed = 2500;
	flock = new Flock(player, 500);
	objects.add(player);
	objects.add(flock);

}

// Muestra y rota los elementos del fondo
void displayBackground(){
	pushMatrix();
	translate(width/2, height + width/1.2);
	imageMode(CENTER);
	rotate(angle);
	image(bg, 0, 0);
	popMatrix();

}

// Muestra el juego y poine a correr el mundo
void displayGame(){
	background(0);
	displayBackground();
	garbageCollector();
	box2d.step();
	for(GameObject o : objects){
		o.update();
		o.display();
	}
}

// Actualiza los elementos del juego
void updateGame(){
	if (boss){
		int i = int(random(points.size()))	;
		PVector dist = PVector.sub(points.get(i), start);
		dist.div(2);
		start.add(dist);

		Seeker s = new Seeker(start.x, start.y, random(5, 10), random(60, 70));
		s.normalSpeed = (frameCount%30 == 0) ? random(1500, 2500) : 0 ;
		s.score = 1;
		objects.add(s);
	}else{
		if (frameCount % 60 == 0){
			Seeker s = new Seeker(width - random(10, 60), random(0, height), random(30 , 60), random(60, 70));
			s.normalSpeed = random(1000, 1500);
			s.score = 10;
			flock.addEnemy(s);
		}
	}
}

// Muestra los elementos del juego pero no los actualiza y muestra el menú de pausa
void displayPause(){
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

// Muestra las estadísticas del juego como el puntaje y la vida del jugador
void displayStats(){
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
	if(boss){
		fill(255, 0, 0);
		rectMode(CENTER);
		float w = 800 - player.score*2;
		rect(width/2, 40, w, 10);
		textSize(30);
		fill(255);
		text("Wacław Sierpiński", width/2, 30);
	}
}


void draw(){
	println("obe: "+objects.size());
	if (!pause) {
		displayGame();
		updateGame();
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
	addToGarbage(object);
}

// Se hace la acción de dispararle a un enemigo
void shootEnemy(Projectile p, Enemy e){
	e.decreaseHP();
	p.decreaseHP();
	addToGarbage(p);
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
		addToGarbage(enemy);
		PVector pos = enemy.getPixelPos();
		ParticleSystem particleSystem = new ParticleSystem(pos.x, pos.y,enemy.score);
		objects.add(particleSystem);
		player.score += enemy.score;
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
	keys[keyCode] = true;
	if (key == pauseButton){
		pause = !pause;
	}
}

void keyReleased(){
	keys[keyCode] = false;
}

// Agregamos los objetos a eliminar del array principal
void addToGarbage(GameObject object){
	if (object.dead){
		garbage.add(object);
	}
}

// Limpiamos el array principal
void garbageCollector(){
	for(GameObject o: garbage){
		if (o instanceof Projectile){
			Projectile p = (Projectile)o;
			p.owner.projectiles.remove(p);
		}
		objects.remove(o);
		o.kill();
	}
}

// Agregamos la dirección opuesta a los elementos del mundo cuando el jugador se mueve
void screenController(float speed){
	worldDirection.x = speed * -1;
	for(GameObject o : objects){
		o.setSpeed(worldDirection);
	}
}

void endContact(Contact c) {}

import java.util.Iterator;
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

boolean pause = false;
char pauseButton = 'p';

color pointsColor;

Player player;
Seeker seeker;
Box2DProcessing box2d;
boolean[] keys = new boolean[1024];
ArrayList<GameObject> objects;
ArrayList<GameObject> garbage;

void setup(){
	frameRate(60);
	fullScreen();
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
	objects = new ArrayList();
	garbage = new ArrayList();
	player = new Player(width/2, height/2, 40);
	player.normalSpeed = 2500;
	objects.add(player);
}

// Muestra el juego y poine a correr el mundo
void displayGame(){
	background(0);
	garbageCollector();
	box2d.step();
	for(GameObject o : objects){
		o.update();
		o.display();
	}	
}

// Actualiza los elementos del juego
void updateGame(){
	if (frameCount % 60 == 0){
		Seeker s = new Seeker(width - random(100, 300), random(100, height - 100), random(30, 60), random(60, 70));
		s.normalSpeed = random(1500, 2500);
		s.score = 10;
		objects.add(s);
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
}


void draw(){
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
void screenController(PVector speed){
	PVector applySpeed = speed.copy();
	applySpeed.mult(-1);

}

void endContact(Contact c) {}

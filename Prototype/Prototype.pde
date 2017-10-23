import java.util.Iterator;
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

boolean pause = false;
char pauseButton = 'p';

Player player;
Seeker seeker;
Box2DProcessing box2d;
boolean[] keys = new boolean[1024];
ArrayList<GameObject> objects;

void setup(){
	fullScreen();
	background(0);
	objects = new ArrayList();
	box2dInit();
	playerInit();
}

void playerInit(){	
	player = new Player(width/2, height/2, 40);
	player.normalSpeed = 100;
	seeker = new Seeker(100, 100, 40, 50);
	seeker.normalSpeed = 10;
	seeker.score = 10;
	objects.add(player);
	objects.add(seeker);
}

void box2dInit() {
	box2d = new Box2DProcessing(this);
	box2d.createWorld();
	box2d.setGravity(0,0);
	box2d.listenForCollisions();
}


void displayGame(){
	background(0);
	box2d.step();
	for(GameObject o : objects){
		o.update();
		o.display();
	}	
}

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

void displayStats(){
	stroke(16, 87,  177, 60);
	noFill();
	arc(width/2, height/5, width + 200, height/4, -PI, 0);
	textSize(40);
	textAlign(CENTER);
	String score = String.valueOf(player.score);
	fill(13, 108, 1);
	text(score, width - textWidth(score), 60);
}

void draw(){
	if (!pause) {
		displayGame();
	}else{
		displayPause();
	}
	displayStats();
}


void beginContact(Contact c) {
	CollidingObject o1 = objectFromFixture(c.getFixtureA());
	CollidingObject o2 = objectFromFixture(c.getFixtureB());
	if (o1 instanceof Player){
		checkPlayer(o2);
	}else if(o1 instanceof Enemy){
		checkEnemy((Enemy) o1, o2);
	}
}

void endContact(Contact c) {}

CollidingObject objectFromFixture(Fixture fixture){
	Body body = fixture.getBody();
	Object object = body.getUserData();
	return (CollidingObject) object;
}

void checkPlayer(CollidingObject object){
	player.decreaseHP();
	if(object instanceof Ship){
		Ship s = (Ship)object;
		objects.remove(s);			
	} 
	if(object instanceof Projectile){
		Projectile p = (Projectile)object;
		player.projectiles.remove(p);
	}
}

void checkEnemy(Enemy enemy, CollidingObject object){
	if (object instanceof Projectile){
		enemy.decreaseHP();
		Projectile projectiles = (Projectile)object;
		player.projectiles.remove(projectiles);
	}
	if(enemy.dead){
		objects.remove(enemy);
		player.score += enemy.score;
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
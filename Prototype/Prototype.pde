import java.util.Iterator;
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

Player player;
Seeker seeker;
Box2DProcessing box2d;
boolean[] keys = new boolean[1024];

void setup(){
	fullScreen();
	background(0);
	box2dInit();
	playerInit();
}

void playerInit(){
	player = new Player(width/2, height/2, 40);
	player.normalSpeed = 100;
	seeker = new Seeker(100, 100, 40, 10);
	seeker.normalSpeed = 10;
}

void box2dInit() {
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0,0);
  box2d.listenForCollisions();
}

void draw(){
	background(0);
	box2d.step();

	player.update();
	player.display();

	seeker.update();
	seeker.display();
}


void beginContact(Contact c) {
	println("caca");
  CollidingObject o1 = objectFromFixture(c.getFixtureA());
  CollidingObject o2 = objectFromFixture(c.getFixtureB());
  if (o1 instanceof Player){
  	checkPlayer(o2);
  }
}
void endContact(Contact c) {}

CollidingObject objectFromFixture(Fixture fixture){
	Body body = fixture.getBody();
	Object object = body.getUserData();
	return (CollidingObject) object;
}

void checkPlayer(CollidingObject o2){
	println("huy perro");
}

void keyPressed(){
  keys[keyCode] = true;
}

void keyReleased(){
  keys[keyCode] = false;
}
import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Tarea9 extends PApplet {

Flock flock;
Path p; 	
boolean settingPoints = true;
boolean pause = false;
boolean save = false;

public void setup() {
  
  background(0);
  p = new Path();
  flock = new Flock();
}

public void draw() {
  if (!pause) {
    background(0);
    p.display();
    flock.display(p);
  }
  if (mousePressed) {
    if (settingPoints) {
      p.addPoint(mouseX, mouseY);
    } else {
      float maxSpeed = 5;
      Agent a = new Agent(mouseX, mouseY, PVector.random2D().mult(maxSpeed), maxSpeed, 1);
      flock.addAgent(a);
    }
  }
  if (save) {
    saveFrame("img\\####.png");
  }
}
public void keyPressed() {
  if (key == '\n') {
    settingPoints = false;
  }
  if (key == 'p') {
    pause = !pause;
  }
  if (key == 'g') {
    save = !save;
  }
}
class Agent {
  PVector pos;
  PVector vel;
  PVector acc;
  float mass = 1;
  float r = 10;
  float maxSpeed;
  float maxForce;
  float maxPathDistance = 200;
  float lookAhead = 50;
  float pathLookAhead = 20;
  int c;
  boolean debug = false;

  Agent(float x, float y, PVector vel, float maxSpeed, float maxForce) {
    pos = new PVector(x, y);
    this.vel = vel;
    acc = new PVector(0, 0);
    this.maxSpeed = maxSpeed;
    this.maxForce = maxForce;
    colorMode(HSB);
    c = color(frameCount%255, 255, 255);
    colorMode(RGB);
  }
  public void update() {
    vel.add(acc);
    vel.limit(maxSpeed);
    pos.add(vel);
    acc.mult(0);
  }
  public void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acc.add(f);
  }
  public void seek(PVector target) {
    PVector desired = PVector.sub(target, pos);
    desired.setMag(maxSpeed);
    PVector steering = PVector.sub(desired, vel);
    steering.limit(maxForce);
    applyForce(steering);
  }
  public void display() {
    float ang = vel.heading();
    noStroke();
    fill(c);
    ellipse(pos.x, pos.y, r, r);
  }
  public void borders() {
    pos.x = (pos.x + width) % width;
    pos.y = (pos.y + height) % height;
  }
  public void follow(Path path) {
    PVector predicted = getPredictedPos();
    PVector normal = getClosestNormalPoint(path, predicted);
    float distance = PVector.dist(predicted, normal);
    if (distance > path.radius) {
      seek(normal);
    }
    if (debug) {
      noStroke();
      fill(0, 0, 255);
      ellipse(predicted.x, predicted.y, 5, 5);
      fill(255, 0, 0);
      ellipse(normal.x, normal.y, 5, 5);
    }
  }
  public PVector getPredictedPos() {
    PVector predicted = vel.copy();
    predicted.setMag(lookAhead);
    predicted.add(pos);
    return predicted;
  }
  public PVector getClosestNormalPoint(Path path, PVector predicted) {
    ArrayList<PVector> normalPoints = getNormalPoints(path, predicted);
    PVector closest = getClosest(normalPoints, predicted);
    return closest;
  }
  public ArrayList<PVector> getNormalPoints(Path path, PVector predicted) {
    ArrayList<PVector> normalPoints = new ArrayList();
    for (Segment s : path.getSegments()) {
      PVector start, end;
      if (s.start.x < s.end.x) {
        start = s.start;
        end = s.end;
      } else {
        start = s.end;
        end = s.start;
      }
      PVector a = PVector.sub(predicted,start);
      PVector b = PVector.sub(end, start);
      b.normalize();
      b.mult(a.dot(b) + pathLookAhead);
      b.add(start);
      if ((b.x >= start.x && b.x <= end.x) || (b.x >= end.x && b.x <= start.x)) {
        if ((b.y >= start.y && b.y <= end.y) || (b.y >= end.y && b.y <= start.y)) {
          normalPoints.add(b);
        }
      }
    }
    return normalPoints;
  }
  // si no hay puntos normales v\u00e1lidos, retorna la predicci\u00f3n
  public PVector getClosest(ArrayList<PVector> normalPoints, PVector predicted) {
    if (normalPoints.size() == 0) {
      return predicted;
    }
    PVector closest = normalPoints.get(0); // cambiar esto para que utilice un punto muy lejano
    for (int i = 1; i < normalPoints.size(); i++) {
      if (predicted.dist(normalPoints.get(i)) < predicted.dist(closest)) {
        closest = normalPoints.get(i);
      }
    }
    if (predicted.dist(closest) < maxPathDistance) {
      return closest;
    } else {
      return predicted;
    }
  }
}
class Flock{
	ArrayList<Agent> agents;
	float alignDistance, separationDistance, cohesionDistance;
	float alignRatio, separationRatio, cohesionRatio;
	PVector alignForce, separationForce, cohesionForce;
	int alignCount, separationCount, cohesionCount;

	Flock(){
		agents = new ArrayList();

		separationDistance = 70;
		alignDistance = 50;
		cohesionDistance = 70;

		separationRatio = 1;
		alignRatio = 1;
		cohesionRatio = 0.8f;
	}

	public void addAgent(Agent agent){
		agents.add(agent);
	}

	public void display(Path path){
		for (Agent agent : agents) {
			updateAgent(agent);
			agent.follow(path);
			agent.update();
			agent.borders();
			agent.display();
		}
	}

	public void calculateFlock(Agent origin, Agent target){
		float distance = PVector.dist(origin.pos, target.pos);	
		align(distance, target);
		separate(distance, target, origin);
		cohere(distance, target);
	}

	public void align(float distance, Agent target){
		if (distance < alignDistance){
			alignForce.add(target.vel);
			alignCount++;
		}
	}

	public void separate(float distance, Agent target, Agent origin){
		if (distance < separationDistance){
			PVector difference = PVector.sub(origin.pos, target.pos);
			difference.normalize();
			difference.div(distance);
			separationForce.add(difference);
			separationCount++;	
		}
	}

	public void cohere(float distance, Agent target){
		if (distance < alignDistance){
			cohesionForce.add(target.pos);
			cohesionCount++;
		}
	}

	public void applyAlign(Agent agent){
		if (alignCount > 0){
			alignForce.div(alignCount);
			alignForce.setMag(alignRatio);
			alignForce.limit(agent.maxForce);
			agent.applyForce(alignForce);
		}
	}

	public void applySeparation(Agent agent){
		if (separationCount > 0){
			separationForce.div(separationCount);
			separationForce.setMag(separationRatio);
			separationForce.limit(agent.maxForce);
			agent.applyForce(separationForce);
		}
	}

	public void applyCohesion(Agent agent){
		if (cohesionCount > 0){
			cohesionForce.div(cohesionCount);
			PVector force = cohesionForce.sub(agent.pos);
			force.setMag(cohesionRatio);
			force.limit(agent.maxForce);
			agent.applyForce(force);
		}
	}

	public void applyFlock(Agent agent){
			applyAlign(agent);
			applySeparation(agent);
			applyCohesion(agent);
	}

	public void updateAgent(Agent agent){
		alignCount = 0;
		separationCount = 0;
		cohesionCount = 0;
		alignForce = new PVector(0, 0);
		separationForce  = new PVector(0, 0);
		cohesionForce  = new PVector(0, 0);
		for (Agent a : agents) {
			if (agent != a){
				calculateFlock(agent, a);
			}
		}
		applyFlock(agent);
	}
}
class Path {
  ArrayList<PVector> points;
  float radius;

  Path() {
    radius = 30;
    points = new ArrayList();
  }
  public void addPoint(float x, float y) {
    PVector point = new PVector(x, y);
    points.add(point);
  }
  public void display() {
    for (int i = 0; i < points.size() - 1; i++) {
      PVector start = points.get(i);
      PVector end = points.get(i + 1);
      strokeWeight(radius * 2);
      stroke(0xff666767);
      line(start.x, start.y, end.x, end.y);
    }
    for (int i = 0; i < points.size() - 1; i++) {
      PVector start = points.get(i);
      PVector end = points.get(i + 1);
      strokeWeight(1);
      stroke(0);
      line(start.x, start.y, end.x, end.y);
    }
  }
  public ArrayList<Segment> getSegments() {
    ArrayList<Segment> segments = new ArrayList();
    for (int i = 0; i < points.size() - 1; i++) {
      PVector start = points.get(i);
      PVector end = points.get(i + 1);
      Segment s = new Segment(start, end);
      segments.add(s);
    }
    return segments;
  }
}
class Segment {
  PVector start;
  PVector end;
  Segment(PVector start, PVector end) {
    this.start = start;
    this.end = end;
  }
}
  public void settings() {  fullScreen(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Tarea9" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

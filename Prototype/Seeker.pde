class Seeker extends Enemy {
	float rotationSpeed;

	Seeker(float x, float y, float mass, float rotationSpeed){
		super(x,y,mass);
		this.rotationSpeed = rotationSpeed;
	}

	void seek(Vec2 target) {
	    Vec2 desired = target.sub(getPos());
	    desired.normalize();
	    desired.mulLocal(normalSpeed);
	    println("speed: "+speed);
	    Vec2 steering = desired.sub(new Vec2(speed.x, speed.y));
	    steering = vec2Limit(steering,rotationSpeed);
	    applyForce(steering);
  	}

	void display() {
		Vec2 pos = box2d.getBodyPixelCoord(body);
		float a = vec2Heading(getPos());
	    stroke(255);
	    strokeWeight(2);
	    fill(255,0,0);
	    pushMatrix();
	    translate(pos.x, pos.y);
	    rotate(-a);
	    beginShape();
	    vertex(objectMass, 0);
	    vertex(0, -objectMass/3);
	    vertex(0, objectMass/3);
	    endShape(CLOSE);
	    popMatrix();
	}

	void update(){
		super.update();
		seek(player.getPos());
	}



}
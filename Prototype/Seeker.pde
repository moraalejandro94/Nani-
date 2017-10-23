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
		Vec2 steering = desired.sub(new Vec2(speed.x, speed.y));
		steering = vec2Limit(steering,rotationSpeed);
		desired.mulLocal(normalSpeed);	    
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
		ellipse(0, 0, this.mass, this.mass);
		popMatrix();
	}

	void update(){
		super.update();
		seek(player.getPos());
	}



}
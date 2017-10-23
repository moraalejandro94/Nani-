class Projectile extends CollidingObject{
	Vec2 force;
	
	Projectile(float posX, float posY, float mass, Vec2 force){
		super(posX,posY,mass);
		applyForce(force);		
	}

	void display(){
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


	void update(){}


}
class Projectile extends CollidingObject{
	Vec2 force;
	Ship owner;
	
	Projectile(float posX, float posY, float mass, Vec2 force, Ship owner){
		super(posX,posY,mass);
		this.owner = owner;
		applyForce(force);		
	}

	void display(){
		Vec2 pos = box2d.getBodyPixelCoord(body);
		strokeWeight(2);
		fill(0,0,255);
		pushMatrix();
		translate(pos.x, pos.y);
		ellipse(0, 0, this.mass, this.mass);
		popMatrix();		
	}


	void update(){		
		if (!inScreen()){			
			dead = true; 		
			currentLevel.addToGarbage(this);			
		}
		
	}
}
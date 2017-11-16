class Projectile extends CollidingObject{
	Vec2 force;
	Ship owner;

	Projectile(){}
	
	Projectile(float posX, float posY, float mass, Vec2 force, Ship owner){
		super(posX,posY,mass);
		this.owner = owner;
		applyForce(force);		
	}

	void display(){
		Vec2 pos = box2d.getBodyPixelCoord(body);
		strokeWeight(2);
		colorMode(HSB);
		color c = color (0,255,255);
		if (owner instanceof Player){
			c = color (150,255,255);
		}
		pushMatrix();
		translate(pos.x, pos.y);
		fill(c);
		ellipse(0, 0, this.mass, this.mass);
		popMatrix();		
		colorMode(RGB);
	}


	void update(){		
		if (!inScreen()){			
			dead = true; 		
			currentLevel.addToGarbage(this);			
		}
		
	}
}
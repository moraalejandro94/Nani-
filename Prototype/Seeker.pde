class Seeker extends Enemy {
	float rotationSpeed;

	Seeker(float x, float y, float mass, float rotationSpeed){
		super(x,y,mass);
		this.rotationSpeed = rotationSpeed;
	}

	Seeker(float x, float y, float rotationSpeed, float normalSpeed, int shotSpeed){		
		super(x,y, map (normalSpeed,10, god.speed, 60, 15));
		this.rotationSpeed = rotationSpeed;
		this.normalSpeed = normalSpeed; 
		this.shotSpeed = shotSpeed; 
		projectileForce = new Vec2(15000,0);
	}

	void seek(PVector target) {
		PVector desired = PVector.sub(target, getPixelPos());
		desired.setMag(normalSpeed);
		PVector steering = PVector.sub(desired, speed);
		steering.limit(normalSpeed);
		steering.y *= -1;
		setSpeed(steering);
	}

	void display() {
		super.display();
		for(Projectile p : projectiles){
			p.display();
		}
	}

	void update(){
		super.update();
		seek(player.getPixelPos());
		elapsed++;
		shootProjectile();
	}


	void shootProjectile(){
		if(elapsed > shotSpeed){
			Vec2 pos = box2d.getBodyPixelCoord(body);
			Vec2 bulletPos = new Vec2(pos.x - mass, pos.y );
			Vec2 bulletForce = new Vec2(-projectileForce.x, projectileForce.y);
			elapsed = 0;			
			Projectile p = new Projectile(bulletPos.x, bulletPos.y, projectileMass, bulletForce, this);
			projectiles.add(p); 		 
		}
	}



}
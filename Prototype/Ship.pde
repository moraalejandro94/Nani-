class Ship extends CollidingObject{
	int elapsed, shotSpeed;
	PVector speed;
	float normalSpeed, boostSpeed;
	ArrayList<Projectile> projectiles;
	float projectileMass;
  	Vec2 projectileForce;


	Ship(float x, float y, float mass){
		super(x, y, mass);
		hp = 1;
		speed = new PVector(0, 0);
		normalSpeed = 0;
		boostSpeed = 0;
		elapsed = 0;
		shotSpeed = 10;
		projectileMass = 10;
    		projectileForce = new Vec2(20000,0);
		this.projectiles = new ArrayList();
	}

	void update(){
		super.update();
		speed.mult(0);
	}

	void display(){
		if (inScreen()){
			Vec2 pos = box2d.getBodyPixelCoord(body);
			pushMatrix();
			translate(pos.x, pos.y);
			fill(255,0,0);
			ellipse(0, 0, mass, mass);
			popMatrix();
		}
	}

	void shootProjectile(){
		if(elapsed > shotSpeed){
			Vec2 pos = box2d.getBodyPixelCoord(body);
			elapsed = 0;
			Projectile p = new Projectile(pos.x + mass, pos.y, projectileMass, projectileForce, this);
	  		projectiles.add(p);
  		}
	}

}
class Ship extends CollidingObject{
	int hp, elapsed, shotSpeed;
	PVector speed;
	float normalSpeed, boostSpeed;
	boolean dead;
	ArrayList<Projectile> projectiles;


	Ship(float x, float y, float mass){
		super(x, y, mass);
		hp = 1;
		speed = new PVector(0, 0);
		normalSpeed = 0;
		boostSpeed = 0;
		elapsed = 0;
		dead = false;
		shotSpeed = 10;
		this.projectiles = new ArrayList();
	}

	void update(){
		super.update();
		speed.mult(0);
	}

	void decreaseHP(){
		this.hp--;
		if (hp <= 0){
			die();
		}
	}

	void die(){		
		this.dead = true;
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

}
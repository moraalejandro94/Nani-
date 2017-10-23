class Ship extends CollidingObject{
	int hp, elapsed;
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
		this.projectiles = new ArrayList();
	}

	void update(){
		super.update();
		speed.mult(0);
		if (hp <= 0){
			die();
		}
	}

	void decreaseHP(){
		this.hp--;
	}

	void die(){		
		this.dead = true;
		println("dead: "+dead);
	}

	void display(){
		if (!dead && inScreen()){
			Vec2 pos = box2d.getBodyPixelCoord(body);
			pushMatrix();
			translate(pos.x, pos.y);
			fill(255,0,0);
			ellipse(0, 0, mass, mass);
			popMatrix();
		}
	}

}
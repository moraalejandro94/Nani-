class Player extends Ship implements UserInput{
	int score, recoveringElapsed, recoveryTime, blinkElapsed, blinkTime;
	boolean recovering = false;
	boolean display = true;

	Player(float x, float y, float mass){
		super(x, y, mass);
		hp = 3;
		score = 0;
		recoveryTime = 120;
		blinkElapsed = 0;
		blinkTime = 15;
	}

	void update(){
		movementController();
		super.update();
	}

	void decreaseHP(){
		if (!recovering){
			super.decreaseHP();
			recovering = true;
			recoveringElapsed = 0;
			display = false;
			blinkElapsed = 0;
		}
	}

	void move(int direction) {
		speed.normalize();
		speed.add(getDirectionVector(direction));
		speed.setMag(normalSpeed);
		currentLevel.screenController(speed.x);
		setSpeed(speed);
	}

	void moveUp() {
		if (keys[moveUp]) {
			move(UP);
		}
	}

	void moveLeft() {
		if (keys[moveLeft]) {
			move(LEFT);
			currentLevel.addRotation(ROTATION_RATE);
		}
	}

	void moveRight() {
		if (keys[moveRight]) {
			move(RIGHT);     
			currentLevel.addRotation(-ROTATION_RATE);
		}
	}
	void faceRight(){
		if(keys[faceRight]){
			facingForward = true;
		}
	}


	void faceLeft(){
		if(keys[faceLeft]){
			facingForward = false;
		}
	}


	void moveDown() {
		if (keys[moveDown]) {
			move(DOWN);
		}
	}

	void shoot() {
		if (keys[shoot]) {
			shootProjectile();
		}
	}


	void shootProjectile(){
		if(elapsed > shotSpeed){
			Vec2 pos = box2d.getBodyPixelCoord(body);
			Vec2 bulletPos = new Vec2(pos.x + mass, pos.y - mass / 1.5);
			Vec2 bulletForce = new Vec2(projectileForce.x, projectileForce.y);
			elapsed = 0;
			if (!facingForward){
				bulletPos.x -= mass*2;
				bulletForce.x *= -1;
			}
			Projectile p = new Projectile(bulletPos.x, bulletPos.y, projectileMass, bulletForce, this);
			projectiles.add(p); 		 
		}
	}

	void movementController() {
		moveUp();
		moveLeft();
		moveDown();
		moveRight();
		faceLeft();
		faceRight();
		shoot();
		elapsed++;
		blinkElapsed ++;
		recoveringElapsed++;
		if (recoveringElapsed > recoveryTime){
			recovering = false;    
		}  
		if (recovering && blinkElapsed > blinkTime){
			display = !display;
			blinkElapsed = 0;
		}
	}

	void display(){
		if (inScreen() && !recovering){
			Vec2 pos = box2d.getBodyPixelCoord(body);
			pushMatrix();
			translate(pos.x, pos.y);      
			fill(0,255,0);
			displayShip();
			popMatrix();
		}
		if (inScreen() && display && recovering){    
			Vec2 pos = box2d.getBodyPixelCoord(body);
			pushMatrix();
			translate(pos.x, pos.y);      
			fill(0,255,0);
			displayShip();
			popMatrix();    
		}
		for(Projectile p : projectiles){
			p.display();
		}

	}

	void displayShip(){
		if (shipImage != null){
			if (!facingForward){
				scale(-1,1);
			}
			image(shipImage, 0, 0, mass * 2, mass * 2);
		}else{
			ellipse(0, 0, mass, mass);
		}
	}

}


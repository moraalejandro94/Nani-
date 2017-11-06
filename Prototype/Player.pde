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
		screenController(speed.x);
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
			angle += 0.005;
		}
	}

	void moveRight() {
		if (keys[moveRight]) {
		 move(RIGHT);     
		 angle -= 0.005;
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
		elapsed = 0;
		if (facingForward){
			Projectile p = new Projectile(pos.x + mass, pos.y, projectileMass, projectileForce, this);
			projectiles.add(p);
		}
		else{
		 Projectile p = new Projectile(pos.x - mass, pos.y, projectileMass, new Vec2(-projectileForce.x, projectileForce.y), this);
		 projectiles.add(p); 
	 }
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
	 ellipse(0, 0, mass, mass);
	 popMatrix();
 }
 if (inScreen() && display){    
	 Vec2 pos = box2d.getBodyPixelCoord(body);
	 pushMatrix();
	 translate(pos.x, pos.y);      
	 fill(0,255,0);
	 ellipse(0, 0, mass, mass);
	 popMatrix();    
 }
 for(Projectile p : projectiles){
	 p.display();
 }

}

}


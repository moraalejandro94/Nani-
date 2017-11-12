class Player extends Ship implements UserInput{
	int score, recoveringElapsed, recoveryTime, blinkElapsed, blinkTime;
	boolean recovering = false;
	boolean display = true;
	boolean boosting; 
	int boostTime, boostAvailable, boostRecharge, boostRechargeElapsed;	


	Player(float x, float y, float mass){
		super(x, y, mass);
		hp = 3;
		score = 0;
		recoveryTime = 120;
		blinkElapsed = 0;
		blinkTime = 15;
		boosting = false;
		boostTime = 300;
		boostAvailable =  300; 
		boostRecharge  = 60;
		boostRechargeElapsed = 0;
	}

	void setSpeed(int speed){
		this.normalSpeed =  speed;
	}

	void update(){
		movementController();
		if (boosting && boostAvailable != 0){			
			boostAvailable--;
		}
		if (!boosting && boostAvailable <= boostTime){
			boostRechargeElapsed ++;
			if (boostRechargeElapsed >= boostRecharge){
				boostAvailable++;
			}
		}
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
		if (boosting){			
			speed.setMag(boostSpeed);	
		}
		else{
			speed.setMag(normalSpeed);			
		}
		currentLevel.screenController(speed.x);
		setSpeed(speed);
	}

	void moveUp() {
		if (keys[moveUp]) {
			if (getPixelPos().y > mass && !boosting){				
				move(UP);				
			}
		}
	}

	void moveLeft() {
		if (keys[moveLeft]) {			
			if(!boosting){						
				move(LEFT);	
				currentLevel.addRotation(ROTATION_RATE);
			}
		}
	}

	void moveRight() {
		if (keys[moveRight]) {
			if(!boosting){									
				currentLevel.addRotation(-ROTATION_RATE);
				move(RIGHT);     
			}
		}
	}
	void faceRight(){
		if(keys[faceRight]){
			if (!boosting){			
				facingForward = true;
			}
		}
	}


	void faceLeft(){
		if(keys[faceLeft]){
			if (!boosting){
				facingForward = false;
			}
		}
	}


	void moveDown() {
		if (keys[moveDown]) {
			if (getPixelPos().y < height - mass && !boosting){
				move(DOWN);
			}
		}
	}

	void shoot() {
		if (keys[shoot]) {
			shootProjectile();
		}
	}


	void boost(){		
		if (keys[boost]){			
			boosting = true;	
			if (boostAvailable > 0){	
				boostRechargeElapsed = 0;			
				if (facingForward){
					move(RIGHT);
					currentLevel.addRotation(-ROTATION_RATE * (boostSpeed/normalSpeed));
				}
				else {
					move(LEFT);
					currentLevel.addRotation(ROTATION_RATE * (boostSpeed/normalSpeed));	
				}
			}		
		}
		else{			
			boosting = false; 			
		}
	}

	void shootProjectile(){
		if(elapsed > shotSpeed && !boosting){
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
		boost();
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


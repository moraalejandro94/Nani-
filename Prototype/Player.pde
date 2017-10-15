class Player extends Ship implements UserInput{

	Player(float x, float y, float mass){
		super(x, y, mass);
	}

	void update(){
		movementController();
		super.update();
	}

	void move(int direction) {
    //screenController(this.speed);
    	speed.normalize();
    	speed.add(getDirectionVector(direction));
    	speed.setMag(normalSpeed);
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
    	}
  	}

  	void moveRight() {
    	if (keys[moveRight]) {
			move(RIGHT);
    	}
  	}

  	void moveDown() {
    	if (keys[moveDown]) {
			move(DOWN);
    	}
  	}

  	void shoot() {
    	if (keys[shoot]) {
			//shoot();
    	}
  	}

  	void stopMovement(){
  		if (!(keys[moveUp] || keys[moveDown] || keys[moveLeft] || keys[moveRight])){
  			stop();
  		}
  	}

  	void movementController() {
  		moveUp();
		moveLeft();
		moveDown();
		moveRight();
		stopMovement();
		shoot();
    	elapsed++;
  }


}
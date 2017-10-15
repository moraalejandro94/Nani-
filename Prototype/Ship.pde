class Ship extends CollidingObject{
	int hp, elapsed;
	PVector speed;
	float normalSpeed, boostSpeed;

	Ship(float x, float y, float mass){
		super(x, y, mass);
		hp = 1;
		speed = new PVector(0, 0);
		normalSpeed = 0;
		boostSpeed = 0;
		elapsed = 0;
	}

	void update(){
		super.update();
		speed.mult(0);
	}
}
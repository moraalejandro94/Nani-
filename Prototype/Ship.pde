class Ship extends CollidingObject{
	int hp, elapsed;
	PVector speed;
	float normalSpeed, boostSpeed;
	ArrayList<GameObject> objects;

	Ship(float x, float y, float mass, ArrayList<GameObject> objects){
		super(x, y, mass);
		hp = 1;
		speed = new PVector(0, 0);
		normalSpeed = 0;
		boostSpeed = 0;
		elapsed = 0;
		this.objects = objects;
	}

	void update(){
		super.update();
		speed.mult(0);
	}
}
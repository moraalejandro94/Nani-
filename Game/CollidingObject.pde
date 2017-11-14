class CollidingObject extends GameObject{
	Body body;
	int hp;
	int originalHP;
	int hpElpased;
	int hpElapsedTotal;
	PVector speed;

	int bodyType;

	CollidingObject(float x, float y, float mass) {
		super(x,y, mass);
		speed = new PVector(0, 0);
		initGeneralColliding();
		bodyType = 0;
		makeBody(BodyType.DYNAMIC);
	}

	CollidingObject(float x, float y, float mass, boolean staticBody, int bodyShape) {
		super(x,y, mass);
		speed = new PVector(0, 0);
		initGeneralColliding();
		this.bodyType = bodyShape;
		makeBody((staticBody) ? BodyType.STATIC  : BodyType.DYNAMIC);
	}

	void initGeneralColliding(){
		hpElapsedTotal = FRAME_RATE;
		hpElpased = hpElapsedTotal;
	}

	void setHP(int hp){
		this.hp = hp;
		this.originalHP = hp;
	}

	void makeBody(BodyType bodyType) {
		BodyDef bd = new BodyDef();
		bd.position = box2d.coordPixelsToWorld(this.objectPosition.x, this.objectPosition.y);
		bd.type = bodyType;
		body = box2d.world.createBody(bd);

		Shape finalShape = new CircleShape();
		finalShape.setRadius(box2d.scalarPixelsToWorld(mass/2));

		FixtureDef fd = new FixtureDef();
		fd.setShape(finalShape);
		fd.setDensity(0);
		fd.setRestitution(0);

		body.createFixture(fd);
		body.setUserData(this);
	}

	void killBody() {
		if (body != null){
			box2d.destroyBody(body);
			body.setUserData(null);
			body = null;
		}
	}

	boolean inScreen() {
		Vec2 pos = box2d.getBodyPixelCoord(body);
		if (pos.y < height + mass && pos.y > 0 - mass 
			&& pos.x < width + mass && pos.x > 0 - mass ) {      
			return true;
	}
	return false;
}

void display() {
	if (inScreen()){
		Vec2 pos = box2d.getBodyPixelCoord(body);
		pushMatrix();
		translate(pos.x, pos.y);
		displayForm();
		popMatrix();
	}
}

void displayForm(){
	if (bodyType == 0){
		ellipseMode(CENTER);
		ellipse(0, 0, mass, mass);
	}else if (bodyType == 1){
		rectMode(CENTER);
		rect(0, 0, mass, mass);
	}
	
}

void applyForce(Vec2 force){
	Vec2 pos = body.getWorldCenter();
	body.applyForce(force, pos);
}

void setSpeed(PVector pForce) {
	Vec2 force = new Vec2(pForce.x, pForce.y);
	body.applyForce(force, body.getWorldCenter());
}

void stop(){
	body.setLinearVelocity(new Vec2(0, 0));
}

PVector getPixelPos(){
	Vec2 playerPos = box2d.getBodyPixelCoord(body);
	PVector pos = new PVector(playerPos.x, playerPos.y);
	return pos;
}

Vec2 getPos(){
	Vec2 pos = body.getWorldCenter();
	return pos;
}

Vec2 vec2Limit(Vec2 vector, float max){
	float mag = vector.length();
	if (mag > max){
		vector.normalize();
		vector.mulLocal(max);
	}
	return vector;
}

float angleHeading(PVector vector){
	PVector heading = PVector.sub(getPixelPos(), vector);
	float angle = heading.heading();
	return angle;

}

void decreaseHP(){
	hp--;
	if (hp <= 0){
		die();
	}
	hpElpased = 0;
}

void displayHP(){
	if (!dead){
		PVector position = getPixelPos();
		rectMode(CENTER);
		rect(position.x, position.y - mass / 2 - 15, mass * hp / originalHP, 5);
	}
}

void die(){		
	dead = true;
}
void kill(){
	killBody();
}
void update(){
	stop();
	speed.mult(0);
	hpElpased++;
}
}
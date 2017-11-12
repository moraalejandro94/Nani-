class CollidingObject extends GameObject{
	Body body;
	int hp;
	PVector speed;

	CollidingObject(float x, float y, float mass) {
		super(x,y, mass);
		speed = new PVector(0, 0);
		makeBody();
	}
	void makeBody() {
		BodyDef bd = new BodyDef();
		bd.position = box2d.coordPixelsToWorld(this.objectPosition.x, this.objectPosition.y);
		bd.type = BodyType.DYNAMIC;
		body = box2d.world.createBody(bd);

		CircleShape cs = new CircleShape();
		cs.setRadius(box2d.scalarPixelsToWorld(mass/2));

		FixtureDef fd = new FixtureDef();
		fd.setShape(cs);
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
		fill(255,0,0);
		ellipse(0, 0, mass, mass);
		popMatrix();
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
}
}
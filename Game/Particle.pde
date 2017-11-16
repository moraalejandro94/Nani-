class Particle extends GameObject{
	PVector speed,acc;
	float mass, friction, lifeSpan, decay;
	float maxSpeed;
	boolean seekPlayer;

	Particle(){}

	Particle(float x, float y, float mass){
		super(x, y, mass);
		this.speed = new PVector(0,0);
		this.acc = new PVector(0,0);
		this.mass = mass;
		this.maxSpeed = random(1, 10);
		this.decay = (seekPlayer) ? 0.5 : 2;
		this.lifeSpan = (seekPlayer) ? 255 : 100;
	}

	void display(){
		noStroke();
		float pmass = mass;
		if (seekPlayer){
			fill(pointsColor,lifeSpan);
		}else{
			fill(255, 0, 0,lifeSpan);
			if(player.boosting && player.boostAvailable > 0){
				fill(0, 0, 255,lifeSpan);
				pmass = mass * 2;
			}
		}
		ellipse(objectPosition.x, objectPosition.y, pmass, pmass);
	}

	void update(){
		speed.add(acc);
		objectPosition.add(speed);
		acc.mult(0);
		lifeSpan -= decay;
		if (seekPlayer){
			seekPlayer();
		}
	}

	void seekPlayer(){
		PVector randy = PVector.random2D();
		randy.setMag(random(player.mass));
		PVector pos = player.getPixelPos().add(randy);
		seek(pos);
	}

	void applyForce(PVector force){
		PVector f = PVector.div(force,mass);
		acc.add(f);
	}

	boolean isDead(){
		return lifeSpan <= 0;
	}

	boolean near(CollidingObject target){
		float distance = PVector.dist(objectPosition, target.getPixelPos());
		return distance < target.mass / 2;
	}

	void seek(PVector target) {
		PVector desired = PVector.sub(target, objectPosition);
		desired.setMag(maxSpeed);
		PVector steering = PVector.sub(desired, speed);
		steering.limit(maxSpeed);
		applyForce(steering);
	}

	void kill(){}
}
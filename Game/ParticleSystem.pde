import java.util.Iterator;
import java.util.LinkedList;

class ParticleSystem extends GameObject{
	PVector origin;
	LinkedList<Particle> particles;
	int maxParticles, current;
	boolean seekPlayer;

	float offsetY;
	PVector force;

	ParticleSystem(){}

	ParticleSystem(float x, float y, int maxParticles){
		super(x, y, 0);
		origin = new PVector(x, y);
		particles = new LinkedList();
		this.maxParticles = maxParticles;
		seekPlayer = true;
		current = 0;
	}

	ParticleSystem(float offsetY){
		super(0, 0, 0);
		origin = new PVector(getPositionX(), getPositionY());
		particles = new LinkedList();
		this.maxParticles = maxParticles;
		seekPlayer = false;
		force = new PVector(0, 0);
		this.offsetY = offsetY;
		current = 0;
	}

	float getPositionX(){
		if (player.facingForward){
			return player.getPixelPos().x - 30;
		}
		return player.getPixelPos().x + 30;
	}

	float getPositionY(){
		return player.getPixelPos().y + offsetY;
	}

	float getForceX(){
		float speedForce = (player.boosting && player.boostAvailable > 0) ? player.boostSpeed : player.normalSpeed;
		if (player.facingForward){
			return -speedForce / 10000;
		}
		return speedForce / 10000;
	}

	void update(){
		if(!seekPlayer){
			addParticle();
			applyForce(force);
			origin.x = getPositionX();
			origin.y = getPositionY();
			force.x = getForceX();
		}
		if (current < maxParticles && seekPlayer){
			addParticle();
			current++;
		}
		Iterator<Particle> i = particles.iterator();
		while (i.hasNext()) {
			Particle p = i.next();
			p.update();
			if (p.isDead() || p.near(player)){
				i.remove();
			}
		}
	}

	void display(){
		for (Particle p: particles){
			p.display();
		}
	}

	void applyForce(PVector force){
		for (Particle p: particles){
			p.applyForce(force);
		}	
	}

	void addParticle(){
		float mass = (seekPlayer) ? abs(randomGaussian())*3 + 5 : abs(randomGaussian())*3 + 2;
		Particle p = new Particle(origin.x, origin.y, mass);
		p.seekPlayer = seekPlayer;
		PVector dir = PVector.random2D();
		dir.setMag(randomGaussian()*1 + 1);
		p.applyForce(dir);
		particles.add(p);
	}

	void kill(){
		
	}
}
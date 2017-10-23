import java.util.Iterator;
import java.util.LinkedList;

class ParticleSystem extends GameObject{
	PVector origin;
	LinkedList<Particle> particles;
	int maxParticles, current;

	ParticleSystem(float x, float y, int maxParticles){
		super(x, y, 0);
		origin = new PVector(x, y);
		particles = new LinkedList();
		this.maxParticles = maxParticles;
		current = 0;
	}

	void update(){
		if (current < maxParticles){
			addParticle();
			current++;
		}
		Iterator<Particle> i = particles.iterator();
		while (i.hasNext()) {
			Particle p = i.next();
			p.update();
			if (p.isDead()){
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
		float mass = abs(randomGaussian())*2 + 5;
		Particle p = new Particle(origin.x, origin.y, mass);
		PVector dir = PVector.random2D();
		dir.setMag(randomGaussian()*1 + 1);
		p.applyForce(dir);
		particles.add(p);
	}
}
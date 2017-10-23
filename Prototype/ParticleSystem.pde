import java.util.Iterator;
import java.util.LinkedList;

class ParticleSystem extends GameObject{
	LinkedList<GameObject> particles;
	Player target;
	int points, current;

	ParticleSystem(float x, float y, int points,float particleMass, Player target){
		super(x, y, particleMass);
		this.target = target;
		this.points = points;
		current = 0;
		particles = new LinkedList();
	}

	void update(){
		addParticle();
		Iterator<GameObject> i = particles.iterator();
		while (i.hasNext()) {
			GameObject p = i.next();
			updateParticle(p);
			if (removeParticle(p)){
				i.remove();
			}
		}
	}

	void updateParticle(GameObject object){
		if (object instanceof Agent){
			Agent agent = ((Agent)object);
			agent.seek(target.getPixelPos());
		}
		object.update();
	}

	boolean removeParticle(GameObject object){
		if (object instanceof Agent){
			return ((Agent)object).isDead(target.getPixelPos(), target.mass);
		}
		return false;
	}

	void display(){
		for (GameObject p: particles){
			p.display();
		}
	}

	void applyForce(PVector force){
		for (GameObject p: particles){
			if (p instanceof Agent){
				((Agent)p).applyForce(force);
			}
		}	
	}

	void addParticle(){
		if (current < points){
			Agent p = new Agent(objectPosition.x, objectPosition.y,mass);
			PVector dir = PVector.random2D();
			dir.setMag(randomGaussian()*2 + 5);
			p.applyForce(dir);
			particles.add(p);		
			current++;	
		}
	}
}
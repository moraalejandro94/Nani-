class Flock extends GameObject {
	ArrayList<Particle> agents;
	float alignDistance, separationDistance, cohesionDistance;
	float alignRatio, separationRatio, cohesionRatio, maxForce;
	PVector alignForce, separationForce, cohesionForce, origin;
	int alignCount, separationCount, cohesionCount, maxParticles;
	Player player;

	Flock(float x, float y, int maxParticles, ArrayList<GameObject> objects, Player player){		
		super(x, y, 0);
		agents = new ArrayList();
		separationDistance = 5;
		alignDistance = 70;
		cohesionDistance = 300;
		separationRatio = 1;
		alignRatio = 1;
		cohesionRatio = 1;
		maxForce = 5;		
		origin = new PVector(x, y);
		this.maxParticles = maxParticles;
		this.player = player;
		fillParticles(x , y , 1, objects);		
	}

	void fillParticles(float x, float y, float mass, ArrayList<GameObject> objects){
		for (int i = 0; i <= maxParticles ; i++){
			Particle p = new Particle(x + random(-20, 20), y + random(-20, 20), mass);		
			this.agents.add(p);	
			objects.add(p);
		}
	}

	void addParticle(Particle agent){
		agents.add(agent);
	}

	void display(){}
	void kill(){}

	void update(){
		Iterator<Particle> i = agents.iterator();
		while (i.hasNext()) {
			Particle p = i.next();			
			if (p.isDead()){
				//i.remove();
			}
			updateAgent(p);		
			//p.seek(player.getPixelPos());						
		}	
	}


	void updateAgent(Particle agent){
		alignCount = 0;
		separationCount = 0;
		cohesionCount = 0;
		alignForce = new PVector(0, 0);
		separationForce  = new PVector(0, 0);
		cohesionForce  = new PVector(0, 0);
		for (Particle a : agents) {
			if (agent != a){
				calculateFlock(agent, a);
			}
		}
		applyFlock(agent);		
	}



	void calculateFlock(Particle origin, Particle target){
		float distance = PVector.dist(origin.objectPosition, target.objectPosition);	
		align(distance, target);
		separate(distance, target, origin);
		cohere(distance, target);
	}

	void align(float distance, Particle target){
		if (distance < alignDistance){
			alignForce.add(target.speed);
			alignCount++;
		}
	}

	void separate(float distance, Particle target, Particle origin){
		if (distance < separationDistance){
			PVector difference = PVector.sub(origin.objectPosition, target.objectPosition);
			difference.normalize();
			difference.div(distance);
			separationForce.add(difference);
			separationCount++;	
		}
	}

	void cohere(float distance, Particle target){
		if (distance < alignDistance){
			cohesionForce.add(target.objectPosition);
			cohesionCount++;
		}
	}

	void applyAlign(Particle agent){
		if (alignCount > 0){
			alignForce.div(alignCount);
			alignForce.setMag(alignRatio);
			alignForce.limit(maxForce);
			agent.applyForce(alignForce);
			
		}
	}

	void applySeparation(Particle agent){
		if (separationCount > 0){
			separationForce.div(separationCount);
			separationForce.setMag(separationRatio);
			separationForce.limit(maxForce);
			agent.applyForce(separationForce);					

		}
	}

	void applyCohesion(Particle agent){
		if (cohesionCount > 0){
			cohesionForce.div(cohesionCount);
			PVector force = cohesionForce.sub(agent.objectPosition);
			force.setMag(cohesionRatio);
			force.limit(maxForce);
			agent.applyForce(force);
			
		}
	}

	void applyFlock(Particle agent){
		applyAlign(agent);
		applySeparation(agent);
		applyCohesion(agent);		
	}
}
class Flock extends GameObject {
	ArrayList<Enemy> agents;
	float alignDistance, separationDistance, cohesionDistance;
	float alignRatio, separationRatio, cohesionRatio, maxForce;
	PVector alignForce, separationForce, cohesionForce;
	int alignCount, separationCount, cohesionCount, maxEnemys;
	Player player;

	Flock(Player player, float maxForce){		
		super(0, 0, 0);
		agents = new ArrayList();
		separationDistance = 70;
		alignDistance = 70;
		cohesionDistance = 50;
		separationRatio = 100;
		alignRatio = 150;
		cohesionRatio = 150;
		this.maxForce = maxForce;
		this.player = player;
	}

	void addEnemy(Enemy agent){
		agents.add(agent);
	}

	void setSpeed(PVector speed){
		for(Enemy o : agents){
			o.setSpeed(speed);
		}
	}

	void display(){}
	void kill(){}

	void update(){
		Iterator<Enemy> i = agents.iterator();
		while (i.hasNext()) {
			Enemy p = i.next();			
			if (p.dead){
				i.remove();
				p.kill();
			}else{
				updateAgent(p);
				p.update();
				p.display();
			}
		}	
	}

	void updateAgent(Enemy agent){
		alignCount = 0;
		separationCount = 0;
		cohesionCount = 0;
		alignForce = new PVector(0, 0);
		separationForce  = new PVector(0, 0);
		cohesionForce  = new PVector(0, 0);
		for (Enemy a : agents) {
			if (agent != a){
				calculateFlock(agent, a);
			}
		}
		applyFlock(agent);		
	}



	void calculateFlock(Enemy origin, Enemy target){
		float distance = PVector.dist(origin.objectPosition, target.objectPosition);	
		align(distance, target);
		separate(distance, target, origin);
		cohere(distance, target);
	}

	void align(float distance, Enemy target){
		if (distance < alignDistance){
			alignForce.add(target.speed);
			alignCount++;
		}
	}

	void separate(float distance, Enemy target, Enemy origin){
		if (distance < separationDistance){
			PVector difference = PVector.sub(origin.objectPosition, target.objectPosition);
			difference.normalize();
			difference.div(distance);
			separationForce.add(difference);
			separationCount++;	
		}
	}

	void cohere(float distance, Enemy target){
		if (distance < alignDistance){
			cohesionForce.add(target.objectPosition);
			cohesionCount++;
		}
	}

	void applyAlign(Enemy agent){
		if (alignCount > 0){
			alignForce.div(alignCount);
			alignForce.setMag(alignRatio * agent.dna.speed);
			alignForce.limit(maxForce);
			agent.setSpeed(alignForce);
			
		}
	}

	void applySeparation(Enemy agent){
		if (separationCount > 0){
			separationForce.div(separationCount);
			separationForce.setMag(separationRatio * agent.dna.shootElapsed);
			separationForce.limit(maxForce);
			agent.setSpeed(separationForce);					

		}
	}

	void applyCohesion(Enemy agent){
		if (cohesionCount > 0){
			cohesionForce.div(cohesionCount);
			PVector force = cohesionForce.sub(agent.objectPosition);
			force.setMag(cohesionRatio * agent.dna.turnSpeed);
			force.limit(maxForce);
			agent.setSpeed(force);
			
		}
	}

	void applyFlock(Enemy agent){
		applyAlign(agent);
		applySeparation(agent);
		applyCohesion(agent);		
	}
}
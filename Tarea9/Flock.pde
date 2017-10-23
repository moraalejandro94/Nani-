class Flock{
	ArrayList<Agent> agents;
	float alignDistance, separationDistance, cohesionDistance;
	float alignRatio, separationRatio, cohesionRatio;
	PVector alignForce, separationForce, cohesionForce;
	int alignCount, separationCount, cohesionCount;

	Flock(){
		agents = new ArrayList();

		separationDistance = 30;
		alignDistance = 70;
		cohesionDistance = 70;

		separationRatio = 1;
		alignRatio = 1;
		cohesionRatio = 1;
	}

	void addAgent(Agent agent){
		agents.add(agent);
	}

	void display(Path path){
		for (Agent agent : agents) {
			updateAgent(agent);
			agent.follow(path);
			agent.update();
			agent.borders();
			agent.display();
		}
	}

	void calculateFlock(Agent origin, Agent target){
		float distance = PVector.dist(origin.pos, target.pos);	
		align(distance, target);
		separate(distance, target, origin);
		cohere(distance, target);
	}

	void align(float distance, Agent target){
		if (distance < alignDistance){
			alignForce.add(target.vel);
			alignCount++;
		}
	}

	void separate(float distance, Agent target, Agent origin){
		if (distance < separationDistance){
			PVector difference = PVector.sub(origin.pos, target.pos);
			difference.normalize();
			difference.div(distance);
			separationForce.add(difference);
			separationCount++;	
		}
	}

	void cohere(float distance, Agent target){
		if (distance < alignDistance){
			cohesionForce.add(target.pos);
			cohesionCount++;
		}
	}

	void applyAlign(Agent agent){
		if (alignCount > 0){
			alignForce.div(alignCount);
			alignForce.setMag(alignRatio);
			alignForce.limit(agent.maxForce);
			agent.applyForce(alignForce);
		}
	}

	void applySeparation(Agent agent){
		if (separationCount > 0){
			separationForce.div(separationCount);
			separationForce.setMag(separationRatio);
			separationForce.limit(agent.maxForce);
			agent.applyForce(separationForce);
		}
	}

	void applyCohesion(Agent agent){
		if (cohesionCount > 0){
			cohesionForce.div(cohesionCount);
			PVector force = cohesionForce.sub(agent.pos);
			force.setMag(cohesionRatio);
			force.limit(agent.maxForce);
			agent.applyForce(force);
		}
	}

	void applyFlock(Agent agent){
			applyAlign(agent);
			applySeparation(agent);
			applyCohesion(agent);
	}

	void updateAgent(Agent agent){
		alignCount = 0;
		separationCount = 0;
		cohesionCount = 0;
		alignForce = new PVector(0, 0);
		separationForce  = new PVector(0, 0);
		cohesionForce  = new PVector(0, 0);
		for (Agent a : agents) {
			if (agent != a){
				calculateFlock(agent, a);
			}
		}
		applyFlock(agent);
	}
}
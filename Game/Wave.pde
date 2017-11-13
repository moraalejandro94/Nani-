class Wave{
	int costActive;
	int costGlobal;
	int costUsed;

	int iParent;
	int jParent;
	int maxChilds;
	int lowestParent;

	float multiplierGod;
	float multiplierLevel;

	Flock flock;
	boolean cleared;

	ArrayList<EnemyDna> dnas;
	ArrayList<EnemyDna> sortedDnas;
	int startElapse;
	int currEnemy;

	PImage enemyImage;
	boolean bossFight;
	Boss finalBoss;

	Wave(Flock flock, int costActive, int costGlobal, int elapse){
		generalInit(flock, costActive, costGlobal, elapse);
		createDna();
	}

	Wave(Flock flock, int costActive, int costGlobal, int elapse, ArrayList<EnemyDna> oldDna){
		generalInit( flock,  costActive, costGlobal, elapse);
		createDna(oldDna);
	}

	void generalInit(Flock flock, int costActive, int costGlobal, int elapse){
		this.flock = flock;
		this.costActive = costActive;
		this.costGlobal = costGlobal;
		startElapse = elapse;
		costUsed = 0;
		currEnemy = 0;
		cleared = false;
		bossFight = false;
	}

	void createDna(){
		int currCost = 0;
		dnas = new ArrayList();
		sortedDnas = new ArrayList();
		while(currCost < costGlobal){
			float speedPercent = random(0, 1);
			float turnPercent = random( 0, 1-speedPercent);
			float fireRate = 1 - (speedPercent + turnPercent) + 0.0000000001;
			EnemyDna dna = new EnemyDna(speedPercent, turnPercent , fireRate);
			dnas.add(dna);
			currCost += dna.score;
		}
		this.costGlobal = currCost;
		
	}

	void createDna(ArrayList<EnemyDna> oldDna){
		int currCost = 0;
		dnas = new ArrayList();
		sortedDnas = new ArrayList();

		iParent = 0;
		jParent = iParent + 1;
		maxChilds = int(costGlobal / 10);
		lowestParent = int(maxChilds * PARENT_COEFICIENT) + 1;
		
		while(currCost < costGlobal){	
			EnemyDna parent1 = oldDna.get(0);
			EnemyDna parent2 = oldDna.get(0);
			if (oldDna.size() > 1){
				parent1 = oldDna.get(iParent);
				parent2 = oldDna.get(jParent);
			}

			EnemyDna child = combine(parent1, parent2);
			dnas.add(child);

			int score = child.score;
			currCost += score;

			nextParentSelection(oldDna.size());
		}
		this.costGlobal = currCost;
		
	}

	EnemyDna combine(EnemyDna parent1, EnemyDna parent2){
		float parent1Percent = random(0.420, 0.69);
		float parent2Percent = 1 - parent1Percent;		
		float childSpeed = parent1Percent*parent1.speed + parent2Percent * parent2.speed;
		float childTurnSpeed = parent1Percent*parent1.turnSpeed + parent2Percent * parent2.turnSpeed;
		float childShootElapsed = parent1Percent * parent1.shootElapsed + parent2Percent * parent2.shootElapsed;
		EnemyDna child = new EnemyDna(childSpeed, childTurnSpeed, childShootElapsed);
		return child;
	}

	void nextParentSelection(int size){
		jParent++;
		if (jParent == lowestParent || jParent >= size){
			iParent++;
			jParent = iParent + 1;
		}
		if (iParent == lowestParent || iParent >= size){
			iParent = 0;
			jParent = iParent + 1;
		}

	}

	void update(){
		if (bossFight){
			finalBoss.update();
			currentLevel.completed =finalBoss.hp <= 0;
		}else if (frameCount % 60 == 0 && currEnemy < dnas.size() && startElapse <= 0 && currentCost() < costActive){
			EnemyDna currDna = dnas.get(currEnemy);
			Seeker s = new Seeker(width, random(0, height) ,currDna.turnSpeed * god.turnSpeed, currDna.speed * god.speed, (int)( (god.shootElapsed / currDna.shootElapsed) ));			
			currEnemy ++;			
			s.dna = currDna;
			s.score = currDna.getScore();
			s.shipImage = enemyImage;
			flock.addEnemy(s);
			cleared = currEnemy >= dnas.size();
		}
		startElapse--;
	}

	void display(){
		if (bossFight){
			finalBoss.display();
		}
	}

	int currentCost(){
		int totalScore = 0;
		for(Enemy e: flock.agents){
			totalScore += e.score;
		}
		return totalScore;
	}

	void insertIntoSortedDNAS(EnemyDna dna){
		int index = getIndex(dna);		
		sortedDnas.add(index, dna);
	}

	int getIndex(EnemyDna dna){
		for (int i = 0 ; i < sortedDnas.size(); i++){
			if (dna.fitness >= dnas.get(i).fitness){
				sortedDnas.add(i, dna);
				return i;				
			}
		}
		return sortedDnas.size();
	}
}
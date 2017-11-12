class Wave{
	int costActive;
	int costGlobal;
	int costUsed;

	float multiplierGod;
	float multiplierLevel;

	Flock flock;
	boolean cleared;

	ArrayList<EnemyDna> dnas;
	int startElapse;
	int currEnemy;

	PImage enemyImage;

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
	}

	void createDna(){
		int currCost = 0;
		dnas = new ArrayList();
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
		while(currCost < costGlobal){
			float speedPercent = random(0, 1);
			float turnPercent = random( 0, 1-speedPercent);
			float fireRate = 1 - (speedPercent + turnPercent);
			EnemyDna dna = new EnemyDna(speedPercent, turnPercent , fireRate);
			dnas.add(dna);
			int score = dna.score;
			currCost += score;
		}
		this.costGlobal = currCost;
		
	}

	void update(){
		if (frameCount % 60 == 0 && currEnemy < dnas.size() && startElapse <= 0 && currentCost() < costActive){
			EnemyDna currDna = dnas.get(currEnemy);
			Seeker s = new Seeker(width, random(0, height) ,currDna.turnSpeed * god.turnSpeed, currDna.speed * god.speed, (int)( (god.shootElapsed / currDna.shootElapsed) ));			
			currEnemy ++;			
			s.score = currDna.getScore();
			s.shipImage = enemyImage;
			flock.addEnemy(s);
			cleared = currEnemy >= dnas.size();
		}
		startElapse--;
	}

	int currentCost(){
		int totalScore = 0;
		for(Enemy e: flock.agents){
			totalScore += e.score;
		}
		return totalScore;
	}
}
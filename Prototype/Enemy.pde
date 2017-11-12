class Enemy extends Ship {
	int score;
	EnemyDna dna;

	Enemy (float x, float y, float mass){
		super(x,y,mass);
	}

	void update(){
		super.update();
		dna.lifeElapsed++;
	}

	void playerHit(){
		dna.playerHits ++;		
	}

	void generateFitness(){		
		dna.fitness = dna.lifeElapsed;
		dna.fitness += dna.playerHits * PLAYER_HIT_MULTIPLIER; 					
	}
}
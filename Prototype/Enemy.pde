class Enemy extends Ship {
	int score;
	EnemyDna dna;
	color c; 

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

	void display(){
		if (inScreen()){
			Vec2 pos = box2d.getBodyPixelCoord(body);
			pushMatrix();
			translate(pos.x, pos.y);
			fill(color(255*dna.speed , 255* dna.turnSpeed, 255*dna.shootElapsed));
			ellipse(0, 0, mass, mass);
			if (shipImage != null){
				image(shipImage, 0, 0, mass, mass);
			}
			popMatrix();
		}
	}
}
class Enemy extends Ship {
	int score;
	EnemyDna dna;
	color c; 
	float headginAngle;

	Enemy (float x, float y, float mass){
		super(x,y,mass);
		headginAngle = 0;
	}

	Enemy (float x, float y, float mass, boolean isStatic, int bodyShape){
		super(x,y,mass, isStatic, bodyShape);
		headginAngle = 0;
	}
	
	void update(){
		super.update();
		dna.lifeElapsed++;
	}

	void playerHit(){
		dna.playerHits++;
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
			imageMode(CENTER);
			rotate(headginAngle);
			fill(color(255*dna.speed , 255* dna.turnSpeed, 255*dna.shootElapsed));
			displayForm();
			if (shipImage != null){
				image(shipImage, 0, 0, mass, mass);
			}
			popMatrix();
		}
		if (hpElpased < hpElapsedTotal){
			displayHP();
		}
	}
}
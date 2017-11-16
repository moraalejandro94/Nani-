class EnemyDna {
	float speed;
	float turnSpeed;
	float shootElapsed;
	float mass;
	float fitness;
	int lifeElapsed;
	int score;
	int playerHits; 

	EnemyDna(){}

	EnemyDna(float speed, float turnSpeed, float shootElapsed){
		this.speed = speed;
		this.turnSpeed = turnSpeed;
		this.shootElapsed = shootElapsed;
		this.mass = mass;
		fitness = 0;
		lifeElapsed = 0;
		playerHits = 0;
		score = getScore();
	}

	int getScore(){
		return (int) map(speed, 0,1,5,1) * 10 ;
	}
}
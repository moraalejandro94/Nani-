abstract class Boss{
	int hp; 
	int initHp;
	String name; 	
	ArrayList<Enemy> enemies;

	Boss(){}
	
	Boss(int hp){
		this.hp = hp;
		initHp = hp;
	}

	abstract void display();
	abstract void update();
	abstract Boss resetBoss();

	void cleanEnemies(){
		for(Enemy e: enemies){
			e.dead  = true;
			currentLevel.addToGarbage(e);			
		}
		enemies = new ArrayList();
	}

	void displayHP(){
		fill(255,0,0);
		rectMode(CORNER);
		float hpToDeath = hp * 30;
		rect(width - hpToDeath, 50, hpToDeath, 20);
	}


	void cleanEnemiesAndProjectiles(){
		for(Enemy e: enemies){
			e.dead  = true;
			currentLevel.addToGarbage(e);
			for(Projectile p: e.projectiles){
				p.dead = true;
				currentLevel.addToGarbage(p);
			}
		}
		enemies = new ArrayList();
	}
}
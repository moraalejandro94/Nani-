class Level{
	Player player;
	int levelNumber;

	int waveAmmount;
	int waveCurrent;
	Wave wave;

	ArrayList<GameObject> objects;
	ArrayList<GameObject> garbage;
	Flock flock;

	PVector worldDirection;
	PImage worldImage;
	float worldAngle;
	String mediaPath;

	PImage enemyImage;

	boolean completed;
	
	Level(Player player, int waveAmmount, int levelNumber){
		this.player = player;
		this.waveAmmount = waveAmmount;
		waveCurrent = 0;

		this.levelNumber = levelNumber;
		mediaPath = "Images/Level_" + levelNumber;
		completed = false;

		worldAngle = 0;
		if (levelNumber > 0){
			worldImage = loadImage(mediaPath + "/bg.png");
			enemyImage = loadImage(mediaPath + "/enemy.png");
		}

		objects = new ArrayList();
		garbage = new ArrayList();
		worldDirection = new PVector(0, 0);
		flock = new Flock(player, 500);

		ParticleSystem playerFire = new ParticleSystem(2);
		ParticleSystem playerFire2 = new ParticleSystem(10);
		objects.add(playerFire);
		objects.add(playerFire2);

		objects.add(flock);
		objects.add(player);

		wave = new Wave(flock, 50, 200, FRAME_RATE * SECONDS_TO_WAVE);
		wave.enemyImage = enemyImage;
	}


	void display(){
		if (levelNumber > 0){
			garbageCollector();
			displayBackground();
			for(GameObject o : objects){
				o.update();
				o.display();
			}	
		}
	}

	boolean inWave(){
		return wave.startElapse <= 0;
	}

	// Actualiza los elementos del juego
	void update(){
		if (!completed && levelNumber > 0){
			updateLevel();
		}
	}

	void updateLevel(){
		if (wave.cleared){
			nextWave();
		}
		wave.update();
		for (Projectile p  : player.projectiles){
			p.update();
		}
	}

	int secondsToWave(){
		return wave.startElapse / FRAME_RATE;
	}

	void nextWave(){
		// Caca genetica
		if (flock.agents.size() == 0){
			waveCurrent++;
			completed = waveCurrent == waveAmmount;			
			wave = new Wave(flock, 30, 100, FRAME_RATE * SECONDS_TO_WAVE, wave.sortedDnas);
			wave.enemyImage = enemyImage;
		}
	}

	// Agregamos los objetos a eliminar del array principal
	void addToGarbage(GameObject object){
		if (object.dead){
			garbage.add(object);
			if (object instanceof Enemy){
				Enemy e = (Enemy) object;				
				e.generateFitness();
				wave.insertIntoSortedDNAS(e.dna);
			}
		}
	}

	// Limpiamos el array principal
	void garbageCollector(){
		for(GameObject o: garbage){
			if (o instanceof Projectile){
				Projectile p = (Projectile)o;
				p.owner.projectiles.remove(p);			
			}
			objects.remove(o);
			o.kill();
		}
	}

	void enemyDeath(Enemy enemy){
		PVector deathPosition = enemy.getPixelPos();
		ParticleSystem particleSystem = new ParticleSystem(deathPosition.x, deathPosition.y, enemy.score);
		objects.add(particleSystem);
		player.score += enemy.score;
	}

	// Agregamos la dirección opuesta a los elementos del mundo cuando el jugador se mueve
	void screenController(float speed){
		worldDirection.x = speed * -1;
		for(GameObject o : objects){
			o.setSpeed(worldDirection);
		}
	}

	void addRotation(float rotation){
		float bgForce = (rotation > 0) ? BACKGROUND_MOVE : -BACKGROUND_MOVE;
		bgForce *= (player.boosting && player.boostAvailable > 0) ? 4 : 1;
		x_ofset += bgForce;
		x_ofset2 += bgForce;
		worldAngle += rotation;
		x_ofset = checkEnd(x_ofset);
		x_ofset2 = checkEnd(x_ofset2);
	}


	float checkEnd(float ofset){
		if (ofset < -width/2){
			return width*3 / 2;
		}else if (ofset > width*3 / 2){
			return -width/2;
		}
		return ofset;
	}

	// Muestra y rota los elementos del fondo
	void displayBackground(){
		if (levelNumber > 0){
			pushMatrix();
			translate(width/2, height + width/1.8);
			imageMode(CENTER);
			rotate(worldAngle);
			image(worldImage, 0, 0, width * 1.5, width * 1.5);
			popMatrix();
		}

	}
}
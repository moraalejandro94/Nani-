class Level{
	Player player;
	int levelNumber;

	int waveAmmount;
	int waveCurrent;
	Wave wave;

	ArrayList<GameObject> objects;
	ArrayList<GameObject> garbage;
	ArrayList<Boss> bosses;
	Flock flock;
	int animationElapsed;
	int animationTime;

	PVector worldDirection;
	PImage worldImage;
	float worldAngle;
	String mediaPath;

	PImage enemyImage;

	boolean completed;
	
	Level(Player player, int waveAmmount, int levelNumber){
		this.player = player;
		this.waveAmmount = waveAmmount;

		this.levelNumber = levelNumber;
		
		initLevel();
	}

	void initLevel(){
		mediaPath = "Images/Level_" + levelNumber;
		
		waveCurrent = 0;
		completed = false;
		animationElapsed = 0;
		animationTime = ((int)3 * FRAME_RATE);
		worldAngle = 0;
		if (levelNumber > 0 && levelNumber <= GAME_LEVELS){
			worldImage = loadImage(mediaPath + "/bg.png");
			enemyImage = loadImage(mediaPath + "/enemy.png");
		}

		bosses = new ArrayList();
		initBosses();

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

		wave = new Wave(flock, 10, 20, FRAME_RATE * SECONDS_TO_WAVE);
		wave.enemyImage = enemyImage;
	}

	void initBosses(){
		bosses.add(new Automata(5, 40));
	}


	void display(){
		if (levelNumber > 0){
			garbageCollector();
			displayBackground();
			for(GameObject o : objects){
				o.update();
				o.display();
			}	
			wave.display();
		}
	}

	boolean inWave(){
		return wave.startElapse <= 0;
	}

	// Actualiza los elementos del juego
	void update(){
		if (!GAME_OVER){
			if (levelNumber - 1 == GAME_LEVELS){
				GAME_WON = true;
			}else if (completed){
				levelNumber++;
				initLevel();
			}else if (!completed && levelNumber > 0 ){
				updateLevel();
			}
		}
	}

	void updateLevel(){
		if (wave.cleared && !GAME_OVER){
			nextWave();
		}
		if (waveCurrent == waveAmmount  && animationElapsed < animationTime){
			startBossFight();
		}
		if (animationElapsed >= animationTime){
			player.cutScene = false;
		}
		wave.update();
		for (Projectile p  : player.projectiles){
			p.update();
		}
	}

	void startBossFight(){
		player.stop();
		player.moveToPoint(new PVector(100, player.getPixelPos().y));
		player.cutScene = true;
		wave.bossFight = true;
		wave.finalBoss = bosses.get(levelNumber-1);
		animationElapsed ++;
	}

	int secondsToWave(){
		return wave.startElapse / FRAME_RATE;
	}

	void nextWave(){
		if (flock.agents.size() == 0){
			waveCurrent++;
			PLAYER_POINTS = player.score;
			wave = new Wave(flock, 10, 20, FRAME_RATE * SECONDS_TO_WAVE, wave.sortedDnas);
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
		if((enemy instanceof Seeker)){
			if ( !((Seeker)enemy).movable ){
				Boss currBoss = bosses.get(levelNumber-1);
				currBoss.hp --; 
			}
		}
	}

	// Agregamos la dirección opuesta a los elementos del mundo cuando el jugador se mueve
	void screenController(float speed){
		worldDirection.x = speed * -1;
		for(GameObject o : objects){			
			if (! ( o instanceof Seeker) ){				
				o.setSpeed(worldDirection);
			}
			else if (((Seeker)o).movable) {
				o.setSpeed(worldDirection);	
			}
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

	void resetWave(){
		if (wave.bossFight){
			Boss newBoss = wave.finalBoss.resetBoss();
			wave.finalBoss.cleanEnemies();
			bosses.set(levelNumber-1, newBoss);
			wave.finalBoss = newBoss;
			startBossFight();
		}else{
			for (Enemy e: flock.agents){
				e.dead = true;
				addToGarbage(e);
			}
			wave = (wave.parents == null) ? new Wave(flock, wave.costActive, wave.costGlobal, FRAME_RATE * SECONDS_TO_WAVE) : new Wave(flock, wave.costActive, wave.costGlobal, FRAME_RATE * SECONDS_TO_WAVE, wave.parents);
			wave.enemyImage = enemyImage;
		}
		player.score = PLAYER_POINTS;
		player.recovering = false;
		player.hp = 3;
		garbageCollector();
		GAME_OVER = false;
	}

	String waveName(){
		if (waveCurrent == waveAmmount){
			return bosses.get(levelNumber-1).name;
		}
		return "WAVE " + String.valueOf(waveCurrent + 1) + "/"+ String.valueOf(waveAmmount);
	}
}
class Sierpinski extends Boss{
	ArrayList<PVector> points;
	ArrayList<PVector> pointsDisplay;
	ArrayList<Enemy> enemies;
	PVector start;

	int pointLimit;

	Sierpinski(int hp){
		super(hp);
		name = "Wacław Sierpiński";

		pointLimit = 420;

		points = new ArrayList();
		pointsDisplay = new ArrayList();
		enemies = new ArrayList();
		start = new PVector(width/2 + 500,150);
		points.add(new PVector(width/2 + 200, 100));
		points.add(new PVector(width/4 + 200, height - 100));
		points.add(new PVector(3*width/4 + 200, height - 100));
	}

	void initEnemies(){
		if (frameCount % (60*10) == 0){	
			cleanEnemies();
			for (int i = 0; i < hp; i++){
				PVector sPoint = getPoint();
				Seeker s = new Seeker(sPoint.x, sPoint.y ,0, 0.9 * god.speed, 20);
				s.normalSpeed = 0;
				s.dna = god;			
				s.score = 1;
				s.movable = false;
				currentLevel.objects.add(s);
				enemies.add(s);
			}
		}
	}

	void cleanEnemies(){
		for(Enemy e: enemies){
			e.dead  = true;
			currentLevel.addToGarbage(e);
		}
		enemies = new ArrayList();
	}

	PVector getPoint(){
		int index = int(random(pointsDisplay.size()));
		return pointsDisplay.get(index);
	}

	void display(){
		for (PVector p: pointsDisplay){
			fill(255,50,50,150);
			ellipse(p.x, p.y, 10, 10);
		}
		fill(255,0,0);
		rect(width - 200, 50, hp *10, 20);
	}

	void update(){
		if (pointsDisplay.size() <  pointLimit){	
			int i = int(random(points.size()));
			PVector dist = PVector.sub(points.get(i), start);
			dist.div(2);
			start.add(dist);
			pointsDisplay.add(new PVector(start.x, start.y));
		}else{
			initEnemies();
		}
	}
}
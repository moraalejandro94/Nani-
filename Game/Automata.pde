class Automata extends Boss{
	ArrayList<PVector> points;
	ArrayList<PVector> pointsDisplay;	

	int rows;
	int columns;
	AutomataCell[][] cells;
	float w;
	int ellapsed = 0;
	int updateEllapsed = 0;
	int updatingEllapsed = 0;
	float reviveProbability = 0.4;
	int reviveEllapsed = 0;
	int updatingTime = FRAME_RATE; 
	int updateTime = FRAME_RATE * 2;
	int enemiesTime = FRAME_RATE;
	int enemieNumber = 4;
	int deathEllapsed = 0;
	int deathTime = FRAME_RATE*4;
	boolean rainbow;

	float xOfset;
	float yOfset;

	Automata(){}

	Automata(int hp, float w) {
		super(hp);

		xOfset = (width - width/3);
		yOfset = 150;
		rainbow = true;
		name = "Automata";
		rows = (int)((height/2) / w);
		columns = (int)((width/3) / w);
		this.w = w;
		cells = new AutomataCell[rows][];
		enemies = new ArrayList();		
		for (int r = 0; r < rows; r++) {
			cells[r] = new AutomataCell[columns];			
			for (int c = 0; c < columns; c++) {
				cells[r][c] = createCell(c * w + xOfset, r * w + yOfset, w);
			}
		}
	} 


	Automata(int hp, float w, boolean rainbow) {
		super(hp);
		this.rainbow = rainbow;
		xOfset = (width - width/3);
		yOfset = 150;

		name = "Automata";
		rows = (int)((height/2) / w);
		columns = (int)((width/3) / w);
		this.w = w;
		cells = new AutomataCell[rows][];
		enemies = new ArrayList();		
		for (int r = 0; r < rows; r++) {
			cells[r] = new AutomataCell[columns];			
			for (int c = 0; c < columns; c++) {
				cells[r][c] = createCell(c * w + xOfset, r * w + yOfset, w);
			}
		}
	} 

	void deathAnimation(){
		fill(255,0,0);
		for (int r = 0; r < rows; r++) {
			for (int c = 0; c < columns; c++) {
				colorMode(HSB);
				if (rainbow){					
					color co = getCellColorCenter(r,c);
					fill(co);
					cells[r][c].display(co);				
				}
				else{					
					cells[r][c].display();
					if (deathEllapsed < deathTime){
						cells[r][c].x += random(-2, 2);
						cells[r][c].y += random(-2, 2);				
					}					
					else {
						cells[r][c].x += random(-8, 8);
						cells[r][c].y += random(-8 , 8);							
					}						
				}
			}
		}
		deathEllapsed++;		
	}

	color getCellColorCenter(int rowNumber, int colNumber){
		int centerRow = (int)rows/2;
		int centerCol = (int)columns/2;
		int rowDistance = abs(rowNumber-centerRow);
		int colDistance = abs(colNumber - centerCol);
		int distance = rowDistance + colDistance;
		int hue =  ((int)map (distance, 0, centerRow, 0, 255));
		colorMode(HSB);
		int brightness = 60;
		if (cells[rowNumber][colNumber].state == 1){
			brightness = 255;
		}
		color c = color(hue, 255, brightness);
		return c; 
	}

	color getCellColorRow(int rowNumber, int colNumber){
		int centerRow = (int)rows/2;
		int centerCol = (int)columns/2;
		int rowDistance = abs(rowNumber-centerRow);
		int colDistance = abs(colNumber - centerCol);
		int distance = rowDistance + colDistance;
		int hue =  ((int)map (rowNumber, 0, rows, 0, 255));
		colorMode(HSB);
		int brightness = 60;
		if (cells[rowNumber][colNumber].state == 1){
			brightness = 255;
		}
		color c = color(hue, 255, brightness);
		return c; 
	}
	
	void display() {
		fill(255,0,0);
		for (int r = 0; r < rows; r++) {
			for (int c = 0; c < columns; c++) {
				colorMode(HSB);
				if (rainbow){					
					color co = getCellColorCenter(r,c);
					fill(co);
					cells[r][c].display(co);				
				}
				else{					
					cells[r][c].display();				
				}
			}
		}
		colorMode(RGB);
		displayHP();
		if (hp == 0){
			deathAnimation();
			resetCells();
		}
	}
	
	AutomataCell createCell(float x, float y, float w) {
		return new AutomataCell(x, y, w, (int)random(2));
	}


	void initEnemies(){		
		cleanEnemies();
		for (int i = 0; i < enemieNumber; i++){
			int rowNumber = (int)random(1, rows-2);
			int colNumber = (int)random(1, columns-2);
			activateNeighbors(rowNumber, colNumber);		
			AutomataCell c = cells[rowNumber][colNumber];	
			Seeker s = new Seeker(c.x, c.y ,0, 0.9 * god.speed, 20, true, 1);
			s.normalSpeed = 0;
			s.dna = god;		
			s.shotSpeed = 60;	
			s.projectileForce = new Vec2(9000,0);
			s.score = 1;
			s.movable = false;
			currentLevel.objects.add(s);
			enemies.add(s);
		}		
	}

	void activateNeighbors(int rowNumber, int colNumber){
		AutomataCell c = cells[rowNumber][colNumber];
		c.newState=1;
		cells[rowNumber-1][colNumber-1].newState=1;
		cells[rowNumber-1][colNumber].newState=1;
		cells[rowNumber][colNumber-1].newState=1;
		cells[rowNumber+1][colNumber].newState=1;
		cells[rowNumber][colNumber+1].newState=1;
		cells[rowNumber+1][colNumber+1].newState=1;
		cells[rowNumber-1][colNumber+1].newState=1;
		cells[rowNumber+1][colNumber-1].newState=1;
	}


	void next() {
		for (int r = 0; r < rows; r++) {
			for (int c = 0; c < columns; c++) {
				int n = neighbors(r, c);
				AutomataCell cell = cells[r][c];
				if (cell.state == 1 && n < 2) cell.newState = 0;
				else if (cell.state == 1 && n > 3) cell.newState = 0;
				else if (cell.state == 0 && n == 3) cell.newState = 1;
				else cell.newState = cell.state;							
			}
		}
	}
	int neighbors(int row, int col) {
		int result = 0;
		for (int r = row - 1; r < row + 2; r++) {
			for (int c = col -1; c < col + 2; c++) {
				if (r >= 0 && r < rows && c >= 0 && c < columns) {
					if (r != row || c != col) {
						result += cells[r][c].state;
					}
				}
			}
		}
		return result;
	}

	void resetCells(){
		reviveEllapsed = 0;
		for (int r = 0; r < rows; r++) {			
			for (int c = 0; c < columns; c++) {
				AutomataCell cell = cells[r][c];
				if (random(0, 1) > reviveProbability){
					cell.newState = 1;
				}else{
					cell.newState = 0;
				}
			}
		}

	}

	void update(){
		next();		
		ellapsed++;		
		if (reviveEllapsed > updateTime){
			resetCells();
			initEnemies();
		}
		if (ellapsed > enemiesTime){
			reviveEllapsed++;
			updatingTime++;
			if (updatingTime > updateTime){
				updateEllapsed++;
			}
			if (updateEllapsed > updateTime){
				updateEllapsed = 0;
				updatingEllapsed = 0;
			}

		}

	}

	Boss resetBoss(){
		return new Automata(initHp, w, rainbow);
	}


}
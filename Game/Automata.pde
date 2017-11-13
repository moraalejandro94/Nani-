class Automata extends Boss{
	ArrayList<PVector> points;
	ArrayList<PVector> pointsDisplay;	

	int rows;
	int columns;
	AutomataCell[][] cells;
	Seeker[][] enemies;
	float w;
	int ellapsed = 0;
	int updateEllapsed = 0;
	int updatingEllapsed = 0;
	int updatingTime = FRAME_RATE; 
	int updateTime = FRAME_RATE * 5;
	int enemiesTime = FRAME_RATE * 7;

	float xOfset;
	float yOfset;

	Automata(int hp, float w) {
		super(hp);

		xOfset = (width - width/3);
		yOfset = 150;

		name = "Automata";
		rows = (int)((height/2) / w);
		columns = (int)((width/3) / w);
		this.w = w;
		cells = new AutomataCell[rows][];
		enemies = new Seeker[rows][];		
		for (int r = 0; r < rows; r++) {
			cells[r] = new AutomataCell[columns];
			enemies[r] = new Seeker[columns];
			for (int c = 0; c < columns; c++) {
				cells[r][c] = createCell(c * w + xOfset, r * w + yOfset, w);
			}
		}
	} 
	
	void display() {
		fill(255,0,0);
		for (int r = 0; r < rows; r++) {
			for (int c = 0; c < columns; c++) {
				cells[r][c].display();
			}
		}
		fill(255,0,0);
		rect(width - 200, 50, hp *10, 20);
	}
	
	AutomataCell createCell(float x, float y, float w) {
		return new AutomataCell(x, y, w, (int)random(2));
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
				if (cell.state == 1 && (ellapsed > enemiesTime && updatingTime < updateTime) && !cell.isEnemy){
					Seeker s = new Seeker(c * w + xOfset, r * w + yOfset,0, 0.9 * god.speed, 20, true, 0);
					s.normalSpeed = 0;
					s.dna = god;			
					s.score = 1;
					s.movable = false;
					currentLevel.objects.add(s);
					enemies[r][c] = s;
					cell.isEnemy = true;
				}
				if (cell.state == 0 && enemies[r][c] != null && ellapsed > enemiesTime){
					currentLevel.addToGarbage(enemies[r][c]);
				}
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

	void update(){
		next();
		ellapsed++;
		if (ellapsed > enemiesTime){
			updatingTime++;
			if (updatingTime > updateTime){
				updateEllapsed++;
			}
			if (updateEllapsed > updateTime){
				updateEllapsed = 0;
				updatingEllapsed = 0;
			}

		}
		for (int r = 0; r < rows; r++) {
			for (int c = 0; c < columns; c++) {
				cells[r][c].display();
			}

		}		
	}


}
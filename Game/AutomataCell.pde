class AutomataCell{
	float x;
	float y;
	float w;
	int state;
	int newState;
	boolean isEnemy;

	AutomataCell(float x, float y, float w, int state) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.state = state;
		isEnemy = false;
	}

	void display() {
		state = newState;
		color c = getColor();
		noStroke();
		fill(c);
		rect(x, y, 15, 15);
		colorMode(RGB);
	}  

	void display(color c) {
		println("CACA");
		state = newState;		
		noStroke();		
		rect(x, y, 15, 15);
		colorMode(RGB);
	}  

	color getColor() {
		colorMode(HSB);
		return state == 0? color(150, 255, 200) : color(255, 255, 255);		
	}


}

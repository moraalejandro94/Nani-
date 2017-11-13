abstract class Boss{
	int hp; 
	String name; 	

	Boss(int hp){
		this.hp = hp;
	}

	abstract void display();
	abstract void update();
}
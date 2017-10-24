abstract class GameObject{
	 PVector objectPosition;
	 float mass;
	 boolean dead;
	 
	 GameObject(){}

	 GameObject(float posX, float posY, float mass){
	 	this.objectPosition = new PVector(posX, posY);
	 	this.mass = mass;
	 	dead = false;
	 }

	 void applyForce(PVector speed){}
	 abstract void kill();
	 abstract void display();
	 abstract void update();

}
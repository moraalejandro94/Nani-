abstract class GameObject{
	 PVector objectPosition;
	 float mass;
	 

	 GameObject(float posX, float posY, float mass){
	 	this.objectPosition = new PVector(posX, posY);
	 	this.mass = mass;
	 }
	 
	 abstract void display();
	 abstract void update();

}
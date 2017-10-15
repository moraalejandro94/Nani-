abstract class GameObject{
	 PVector objectPosition;
	 float objectMass;
	 

	 GameObject(float posX, float posY, float objectMass){
	 	this.objectPosition = new PVector(posX, posY);
	 	this.objectMass = objectMass;
	 }

	 abstract void display();
	 
	 abstract void update();

}
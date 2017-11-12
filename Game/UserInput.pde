interface UserInput{
	char moveUp = 'W';
	char moveLeft = 'A';
	char moveDown = 'S';
	char moveRight = 'D';
	char faceLeft = 'K';
	char faceRight = 'L';
	char shoot = ' ';
	char boost ='Q'; 

	public void movementController();
	public void moveUp();
	public void moveLeft();
	public void moveDown();
	public void moveRight();
	public void faceRight();
	public void faceLeft();
	public void shoot();
	public void boost();
}
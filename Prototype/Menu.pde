class Menu{
	int clickElapsed = 0;
	PVector startButtonPos = new PVector(width/2, height/2 + 200);
	PImage nextButton;
	PImage previousButton;
	PImage startButton;

	public Menu() {
		nextButton = loadImage("Images/Buttons/next.png");
		previousButton = loadImage("Images/Buttons/previous.png");
		startButton = loadImage("Images/Buttons/start.png");
	}

	void showMenu() {
		background(255);
		noFill();
		//noStroke();
		imageMode(CENTER);

    		// Next Skin
    		image(nextButton, width/2 + width/4, height/2);
    		if (mousePressed && 
    			mouseX > width/2 + width/4 - 25 && mouseX < width/2 + width/4 + 25 && 
    			mouseY > height/2 - 25 && mouseY < height/2 + 25 && clickElapsed > 20){
    			currentSkin = (currentSkin % maxSkins)+1;
    			player.shipImage = loadImage("Images/Skins/" + Integer.toString(currentSkin) + ".png");
    			clickElapsed = 0;
    		}

    		// Previous Skin
    		image(previousButton, width/2 - width/4, height/2);
    		if (mousePressed && 
    			mouseX > width/2 - width/4 - 25 && mouseX < width/2 - width/4 + 25 && 
    			mouseY > height/2 - 25 && mouseY < height/2 + 25 && clickElapsed > 20){
    			currentSkin = (currentSkin == 1) ? maxSkins : currentSkin - 1;
    			player.shipImage = loadImage("Images/Skins/" + Integer.toString(currentSkin) + ".png");
    			clickElapsed = 0;
    		}

 	   	// Botón de Start   
 	   	image(startButton, width/2, height/2 + height/3); 
 	   	if (mousePressed && clickElapsed > 20 && 
 	   		(mouseX > width/2 - 100 && mouseX < width/2 + 100) && 
 	   		(mouseY > height/2 + height/3 - 50 && mouseY < height/2 + height/3 + 50)){
 	   		currentLevel = new Level(player, LEVEL_WAVES, 1);
 	   	clickElapsed = 0;
 	   }
 	   image(player.shipImage, width/2, height/2, 250, 250);
 	   clickElapsed++;
 	}

 }
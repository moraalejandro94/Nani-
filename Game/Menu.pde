class Menu{
	int clickElapsed = 0;
	int finalElapsed = 15;
	PVector startButtonPos = new PVector(width/2, height/2 + 200);
	PImage nextButtonImage;
	PImage previousButtonImage;
	PImage startButtonImage;

	public Menu() {
		nextButtonImage = loadImage("Images/Buttons/next.png");
		previousButtonImage = loadImage("Images/Buttons/previous.png");
		startButtonImage = loadImage("Images/Buttons/start.png");
	}

	void showMenu() {
		background(255);
		noFill();
		//noStroke();
		imageMode(CENTER);

			// Next Skin
			image(nextButtonImage, width/2 + width/4, height/2);
			if (keys[nextButton] && clickElapsed > finalElapsed){
				currentSkin = (currentSkin % maxSkins)+1;
				player.shipImage = loadImage("Images/Skins/" + Integer.toString(currentSkin) + ".png");
				clickElapsed = 0;
			}

			// Previous Skin
			image(previousButtonImage, width/2 - width/4, height/2);
			if (keys[prevButton] && clickElapsed > finalElapsed){
				currentSkin = (currentSkin == 1) ? maxSkins : currentSkin - 1;
				player.shipImage = loadImage("Images/Skins/" + Integer.toString(currentSkin) + ".png");
				clickElapsed = 0;
			}

		// Botón de Start   
		image(startButtonImage, width/2, height/2 + height/3); 
		if (keys[startButton]){
			currentLevel = new Level(player, LEVEL_WAVES, 1);
			clickElapsed = 0;
		}
		image(player.shipImage, width/2, height/2, 250, 250);
		clickElapsed++;
	}

	void gameOverMenu(){
		if (keys[startButton]){
			currentLevel.resetWave();
		}

		image(gameOver, width/2, height/2);
		String textShow = "Press start to continue ... ";
		if (frameCount % FRAME_RATE > 0 && frameCount % FRAME_RATE < FRAME_RATE / 2){
			textShow = "";
		}
		displayText(textShow, width/2, height*3/4, color(255,255,255), 40, CENTER);
	}

}
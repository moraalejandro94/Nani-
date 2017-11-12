class LevelFactory{

	PImage nextButton;
	PImage previousButton;
	PImage startButton;

	public LevelFactory() {
		nextButton = loadImage("images/buttons/next.png");
		previousButton = loadImage("images/buttons/previous.png");
		startButton = loadImage("images/buttons/start.png");
	}

	Level loadLevel(int level) {
		if (level == 0){

		}
		return new Level(player, 2, level);
	}

}
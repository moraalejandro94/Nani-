Flock flock;
Path p; 	
boolean settingPoints = true;
boolean pause = false;
boolean save = false;

void setup() {
  fullScreen();
  background(0);
  p = new Path();
  flock = new Flock();
}

void draw() {
  if (!pause) {
    background(0);
    p.display();
    flock.display(p);
  }
  if (mousePressed) {
    if (settingPoints) {
      p.addPoint(mouseX, mouseY);
    } else {
      float maxSpeed = 5;
      Agent a = new Agent(mouseX, mouseY, PVector.random2D().mult(maxSpeed), maxSpeed, 1);
      flock.addAgent(a);
    }
  }
  if (save) {
    saveFrame("img\\####.png");
  }
}
void keyPressed() {
  if (key == '\n') {
    settingPoints = false;
  }
  if (key == 'p') {
    pause = !pause;
  }
  if (key == 'g') {
    save = !save;
  }
}
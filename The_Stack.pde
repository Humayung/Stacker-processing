public void Main() {
  startColor = color(random(256), random(256), random(256));
  endColor = color(random(256), random(256), random(256));
  initialTileBounds = new PVector(350, 350, 40);
  oscillatingSpeed = 0.03f;
  playButtonAlpha = 255;
  desiredDistance = 1;
  distance = 0.1f;
}

public void settings() {
  fullScreen(P3D);
}

private ArrayList<Tile> tiles;
private ArrayList<Tile> displayTiles;
private ArrayList<Tile> rubbles;

private Waves waves;

private final int MAX_TILES_ONSCREEN = 20;
private final int  BONUS_GAIN = 20;
private final int  ERROR_MARGIN = 15;

private float distance;
private float desiredDistance;
private int bgColor;
private float playButtonAlpha;

private PVector initialTileBounds;
private PVector tileBounds;
private ParticleSystem particleSystem;


private Tile oscillatingTile;
private Tile topTile;

private final int  MINIMUM_COMBO = 2;
private int score;
private int highScore;
private int combo;
private boolean gameOver;
private boolean gameStarted;

private float cameraZ;
private float desiredCameraZ;
private boolean isMovingOnX;

private final int  COLOR_RANGE = 12;
private int colorPos;
private int startColor;
private int endColor;


private float time;
private float oscillatingSpeed;

public void setup() {
  Main();
  ortho(-width / 2, width / 2, -height / 2, height / 2, -width, width);
  particleSystem = new ParticleSystem();
  rubbles = new ArrayList<Tile>();
  waves = new Waves();
  textAlign(CENTER);
  textSize(60);
  newGame();
}

public void draw() {
  background(bgColor);
  distance = lerp(distance, desiredDistance, 0.1f);
  translate(width / 2, height / 2);
  lights();

  // Draw Tiles
  pushMatrix();
  {
    rotateX(QUARTER_PI);
    rotateZ(QUARTER_PI);
    cameraZ = lerp(cameraZ, desiredCameraZ, 0.08f);
    scale(distance);
    translate(0, 0, cameraZ);

    oscillatingTile.update();
    for (Tile displayTile : displayTiles) {
      displayTile.update();
    }
    manageRubbles();
    waves.update();
    particleSystem.run();
  }
  popMatrix();
  if (gameStarted) oscillate();
  drawUI();
}


private void drawUI() {
  // Play Button, Score, and HighScore
  if (gameStarted) {
    fill(255);
    text(score, 0, -height / 4, 250);
  } else {
    fill(255, 200, 0);
    text(highScore, 0, (height / 4) + 100, 250);
  }
  drawPlayButton(0, 0, 250, height / 4);
}

private void newGame() {
  bgColor = color(
    random(150, 256), 
    random(150, 256), 
    random(150, 256)
    );
  startColor = color(
    random(256), 
    random(256), 
    random(256)
    );
  endColor = color(
    random(256), 
    random(256), 
    random(256)
    );

  tiles = new ArrayList<Tile>();
  displayTiles = new ArrayList<Tile>();
  tileBounds = initialTileBounds.copy();
  topTile = new Tile(new PVector(), tileBounds, getNextColor());
  tiles.add(topTile);
  displayTiles.add(topTile);
  oscillatingTile = new Tile(new PVector(0, 0, tileBounds.z), tileBounds, getNextColor());
  desiredCameraZ = 0;
  highScore = (highScore < score)
    ? score
    : highScore;
  score = 0;
  oscillatingSpeed = .03f;
}

public void mousePressed() {
  key = ' ';
  keyPressed();
}

public void keyPressed() {
  if (key == ' ') {
    if (gameStarted) {
      if (gameOver) {
        gameOver = false;
        gameStarted = false;
        desiredDistance = 1;
        newGame();
      } else {
        if (!placeTile()) {
          desiredDistance = min(0.8f, sqrt(tiles.size()) / (tiles.size() / 2f));
          displayTiles = tiles;
          gameOver = true;
        } else oscillatingSpeed += (sqrt(tiles.size()) / sq(tiles.size())) / 300;
      }
    } else {
      gameStarted = true;
      gameOver = false;
    }
  }
}

private void drawPlayButton(float x, float y, float z, float size) {
  playButtonAlpha = lerp(playButtonAlpha, gameStarted ? 0 : 255, 0.1f);
  if (playButtonAlpha > 0.1) {
    // Centroid
    float cx = 0.25f;
    float cy = 0.5f;
    //
    pushMatrix();
    {
      translate(x - (cx * size), y - (cy * size), z);
      scale(size);

      // Perimeter
      noFill();
      stroke(0, playButtonAlpha);
      strokeWeight(0.15f);
      ellipse(cx, cy, 1.5f, 1.5f);
      //

      noStroke();
      fill(0, playButtonAlpha);
      beginShape();
      {
        // Triangle
        vertex(0, 0);
        vertex(0, 1);
        vertex(sqrt(0.75f), 0.5f);
      }
      endShape();
      fill(255, 50, 10);
    }
    popMatrix();
  }
}

private void manageRubbles() {
  for (int i = rubbles.size() - 1; i >= 0; i--) {
    Tile r = rubbles.get(i);
    if (r.isOff()) {
      rubbles.remove(i);
    } else {
      r.update();
    }
  }
}

private boolean placeTile() {
  if (isMovingOnX) {
    float deltaX = topTile.pos.x - oscillatingTile.pos.x;
    if (abs(deltaX) > ERROR_MARGIN) {
      combo = 0;
      // Cut tile
      tileBounds.x -= abs(deltaX);
      if (tileBounds.x < 0) {
        // Rubble
        rubbles.add(oscillatingTile);
        oscillatingTile.dissolve();
        return false;
      }
      // Rubble
      float rubbleX = oscillatingTile.pos.x + (deltaX > 0 ? -1 : 1) * tileBounds.x / 2;
      PVector rubbleScale = new PVector(deltaX, tileBounds.y, tileBounds.z);
      Tile rubble = new Tile(new PVector(rubbleX, oscillatingTile.pos.y, oscillatingTile.pos.z), rubbleScale, oscillatingTile.getColor());
      rubbles.add(rubble);
      rubble.dissolve();

      float middle = topTile.pos.x + (oscillatingTile.pos.x / 2);
      oscillatingTile.setScale(tileBounds);
      oscillatingTile.setPos(middle - (topTile.pos.x / 2), topTile.pos.y, oscillatingTile.pos.z);
      score++;
    } else {

      // Align to top tile
      oscillatingTile.setPos(topTile.pos.x, topTile.pos.y, oscillatingTile.pos.z);
      waves.init(oscillatingTile.pos, tileBounds);
      combo++;
      score += ERROR_MARGIN - abs(deltaX);
      if (combo >= MINIMUM_COMBO) {
        oscillatingTile.scaleUp(BONUS_GAIN, 0);
        tileBounds.add(BONUS_GAIN, 0);
      }
    }
  } else {
    float deltaY = topTile.pos.y - oscillatingTile.pos.y;
    if (abs(deltaY) > ERROR_MARGIN) {
      combo = 0;
      // Cut Tile
      tileBounds.y -= abs(deltaY);
      if (tileBounds.y < 0) {
        // Rubble
        rubbles.add(oscillatingTile);
        oscillatingTile.dissolve();
        return false;
      }
      // Rubble
      float rubbleY = oscillatingTile.pos.y + (deltaY > 0 ? -1 : 1) * tileBounds.y / 2;
      PVector rubbleScale = new PVector(tileBounds.x, deltaY, tileBounds.z);
      Tile rubble = new Tile(new PVector(oscillatingTile.pos.x, rubbleY, oscillatingTile.pos.z), rubbleScale, oscillatingTile.getColor());
      rubble.dissolve();
      rubbles.add(rubble);

      float middle = topTile.pos.y + (oscillatingTile.pos.y / 2);
      oscillatingTile.setScale(tileBounds);
      oscillatingTile.setPos(topTile.pos.x, middle - (topTile.pos.y / 2), oscillatingTile.pos.z);
      score++;
    } else {

      // Align to top tile
      oscillatingTile.setPos(topTile.pos.x, topTile.pos.y, oscillatingTile.pos.z);
      waves.init(oscillatingTile.pos, tileBounds);
      combo++;
      score += ERROR_MARGIN - abs(deltaY);
      if (combo >= MINIMUM_COMBO) {
        oscillatingTile.scaleUp(0, BONUS_GAIN);
        tileBounds.add(0, BONUS_GAIN);
      }
    }
  }
  spawnTile();
  return true;
}

private void spawnTile() {
  topTile = oscillatingTile;
  tiles.add(oscillatingTile);
  displayTiles.add(oscillatingTile);
  if (displayTiles.size() > MAX_TILES_ONSCREEN) {
    displayTiles.remove(0);
  }
  oscillatingTile = new Tile(oscillatingTile.pos.copy().add(0, 0, tileBounds.z), tileBounds, getNextColor());

  //Focus
  desiredCameraZ -= tileBounds.z;

  //Alternate
  isMovingOnX = !isMovingOnX;
  time = -HALF_PI;
  oscillate();
}

private int getNextColor() {
  colorPos = (colorPos + 1) % COLOR_RANGE;
  if (colorPos == 0) {
    startColor = endColor;
    endColor = color(random(256), random(256), random(256));
  }
  float amt = (float) colorPos / COLOR_RANGE;
  return lerpColor(startColor, endColor, amt);
}

private void oscillate() {
  if (!gameOver) {
    time += oscillatingSpeed;
    if (isMovingOnX)
      oscillatingTile.pos.x = sin(time) * (initialTileBounds.x + 100);
    else
      oscillatingTile.pos.y = sin(time) * (initialTileBounds.y + 100);
  }
}

/*
    private void drawOrigin(PVector pos, float length) {
 pushMatrix();
 {
 translate(pos.x, pos.y, pos.z);
 point(0, 0, 0);
 stroke(0, 0, 255);
 line(0, 0, 0, length, 0, 0);
 stroke(0, 255, 0);
 line(0, 0, 0, 0, length, 0);
 stroke(255, 0, 0);
 line(0, 0, 0, 0, 0, length);
 }
 popMatrix();
 }
 
 
 void drawOrigin() {
 drawOrigin(new PVector(), 1000);
 }
 */

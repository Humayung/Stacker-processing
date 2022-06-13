public void assignVariables() {
  startColor = color(random(256), random(256), random(256));
  endColor = color(random(256), random(256), random(256));
  oscillatingSpeed = DEF_OSCILLATING_SPEED;
  playButtonAlpha = 0;
  titleAlpha = 255;
  desiredDistance = 1;
  distance = 0.1f;
  score = new Score();
  cameraPos = new PVector();
  desiredCameraPos = new PVector();
  desiredGlobalRotation = new PVector(QUARTER_PI, 0, QUARTER_PI);
  globalRotation = new PVector();
  desiredGlobalPosition = new PVector(width/2, height/2, 0);
  globalPosition = desiredGlobalPosition.copy();
  initialTileScale = new PVector(height/2.2f, height/2.2f, height/14f);
  bonusGain = height/40f;
  errorMargin = height/40f;
  maxScoreGain = 100;
  particleSystem = new Cubie();
  rubbles = new ArrayList<Tile>();
  waves = new Waves();
  textAlign(CENTER);
}


private ArrayList<Tile> tiles;
private ArrayList<Tile> displayTiles;
private ArrayList<Tile> rubbles;

private Waves waves;

private final int MAX_TILES_ONSCREEN = 20;
private float bonusGain;
private float maxScoreGain;
private float errorMargin;

private PVector cameraPos;
private PVector desiredCameraPos;
private float distance;
private float desiredDistance;
private int focusIndex = 0;
private PVector desiredGlobalRotation;
private PVector globalRotation;
private PVector desiredGlobalPosition;
private PVector globalPosition;

private final float FPS = 120;
private final float DEF_FPS = 60;
private float ANIM_MOD = DEF_FPS/FPS; 
private float ANIM_AMT = 0.1f * ANIM_MOD;
private float DEF_OSCILLATING_SPEED = 0.03f * ANIM_MOD;

private PVector initialTileScale = new PVector(height/2.2f, height/2.2f, height/14f);
private PVector tileScale;
private Tile oscillatingTile;
private Tile topTile;
private float time;
private float oscillatingSpeed;
private boolean isMovingOnX;
private boolean auto;

private Cubie particleSystem;

private final int  MINIMUM_COMBO = 5;
private Score score;
private int combo;
private boolean gameOver;
private boolean gameStarted;
private boolean titleScreen = true;

private final int  COLOR_RANGE = 10;
private int colorPos;
private int startColor;
private int endColor;
private int desiredBgColor;
private int bgColor;
private float playButtonAlpha;
private float titleAlpha;
private float comboScore = 0;


PFont titleFont1;
PFont titleFont2;
public void setup() {
  fullScreen(P3D);
  //size(640, 360, P3D);
  //size(805, 483, P3D);
  smooth(10);
  frameRate(FPS);
  titleFont2 = loadFont("Lato-Bold-48.vlw");
  titleFont1 = loadFont("Lato-Hairline-120.vlw");
  assignVariables();
  newGame();
}

void adaptiveAnimAmt(){
  ANIM_MOD = DEF_FPS/frameRate; 
  ANIM_AMT = 0.1f * ANIM_MOD;
  DEF_OSCILLATING_SPEED = 0.03f * ANIM_MOD;
}

public void auto(){
  if (!auto) return;
  if (isMovingOnX) {
    final float deltaX = topTile.pos.x - oscillatingTile.pos.x;
    if (abs(deltaX) < errorMargin) {
      mousePressed();
    }
  }else{
    final float deltaY = topTile.pos.y - oscillatingTile.pos.y;
    if (abs(deltaY) < errorMargin) {
      mousePressed();
    }
  }
}


public void draw() {
  pushMatrix();
  ortho(-width / 2, width / 2, -height / 2, height / 2, -width, width*10);
  globalUpdate();
  popMatrix();
  adaptiveAnimAmt();
  auto();
}

void globalUpdate() {
  pushMatrix();
  {
    background(bgColor);
    easeMotion();
    translate(globalPosition.x, globalPosition.y, globalPosition.z);
    lights();

    // Draw Tiles
    pushMatrix();
    {
      rotateX(globalRotation.x);
      rotateY(globalRotation.y);
      rotateZ(globalRotation.z);
      scale(distance);
      translate(-cameraPos.x, -cameraPos.y, -cameraPos.z);
      for (Tile displayTile : displayTiles) {
        displayTile.update();
      }
      updateRubbles();
      waves.update();
      particleSystem.run();
    }
    popMatrix();
    if (gameStarted) oscillate();
  }
  popMatrix();
  updateUI();
}

void easeMotion() {
  globalPosition.lerp(desiredGlobalPosition, ANIM_AMT);
  globalRotation.lerp(desiredGlobalRotation, ANIM_AMT);
  distance = lerp(distance, desiredDistance, ANIM_AMT);
  bgColor = lerpColor(bgColor, desiredBgColor, ANIM_AMT);
  cameraPos.lerp(desiredCameraPos, ANIM_AMT);
  score.ease();
}


private void updateUI() {
  // Play Button, Score, and HighScore
  pushMatrix();
  translate(width/2, height/2, height);
  textAlign(CENTER);
  if (!titleScreen) {
    fill(255 - red(desiredBgColor), 255 - green(desiredBgColor), 255 - blue(desiredBgColor));
    textFont(titleFont2);
    if (gameStarted) {
      textSize(height/12.8);
      text(score.score, 0, -height / 3.5);
      if(comboScore > 0){
        textSize(height/30);
        text("+" + int(comboScore), 0, -height / 2.8);
      }
      textSize(height/19.2);
      text(score.stack, 0, -height / 3.5 + height/12.8);
      if (auto){
        textSize(height/40);
        fill(255);
        rect(0, -height / 3.5 + height/7.3, width/25.2, height/32.7, 10);
        fill(topTile.getColor());
        text("auto", 0, -height / 3.5 + height/7);
      }
    } else {
      textSize(height/12.8);
      text(score.highScore, 0, (height / 3.5));
      textSize(height/19.2);
      text(score.highStack, 0, (height / 3.5) + height/12.8);
    }
  }
  drawPlayButton(0, 0, height/4f);
  drawTitle();
  popMatrix();
}

private void drawTitle() {
  textSize(height/3.45);
  titleAlpha = lerp(titleAlpha, titleScreen ? 255 : 0, 0.1);
  fill(255 - red(desiredBgColor), 255 - green(desiredBgColor), 255 - blue(desiredBgColor), titleAlpha);
  if (titleAlpha > 100) {
    textFont(titleFont1);
    textAlign(LEFT, CENTER);
    text("STACKER", -width/2.3, 0);
    textSize(height/26f);
    text("Inspired by KETCHAPP", -width/2.3f, -height/16.1 + height/5.5f);
    textFont(titleFont2);
    textSize(height/80f);
    text("ARROWS & WHEEL observe tiles\nSPACE place tile\nA auto", -width/2.3f, -height/16.1 + height/3.5f);
  }
}

private void newGame() {
  titleScreen = true;
  desiredBgColor = color(
    random(150, 256), 
    random(150, 256), 
    random(150, 256)
    );

  tiles = new ArrayList<Tile>();
  displayTiles = new ArrayList<Tile>();
  tileScale = initialTileScale.copy();

  topTile = new Tile(new PVector(), tileScale, getNextColor());
  tiles.add(topTile);
  displayTiles.add(topTile);
  oscillatingTile = new Tile(new PVector(0, 0, tileScale.z), tileScale, getNextColor());
  displayTiles.add(oscillatingTile);
  tiles.add(oscillatingTile);
  oscillatingSpeed = DEF_OSCILLATING_SPEED;
  gameOver = false;
  gameStarted = false;
  desiredDistance = 1;
  globalRotation.z %= PI;
  desiredGlobalRotation = new PVector(QUARTER_PI, 0, QUARTER_PI);
  desiredCameraPos = topTile.pos;
  desiredGlobalPosition.set(width/2 + 200, height/2, 0);
  score.reset();
}

public void mousePressed() {
  key = ' ';
  keyPressed();
}

public void keyPressed() {
  if (key == 'a' || key == 'A') auto = !auto;
  if (key == ' ') {
    if (!titleScreen) {
      if (gameStarted) {
        if (gameOver) {
          newGame();
        } else {
          if (!placeTile()) {
            gameOver();
          } else {
            accelerate();
            desiredCameraPos = topTile.pos;
          }
        }
      } else {
        startGame();
      }
    } else {
      enterGame();
    }
  }
  if (key == CODED) {
    if (gameOver) {
      switch(keyCode) {
      case UP:
        focusIndex = constrain(focusIndex + 1, 0, tiles.size() - 1);
        tiles.get(focusIndex).lightUp();
        desiredCameraPos = tiles.get(focusIndex).pos;
        break;
      case DOWN:
        focusIndex = constrain(focusIndex - 1, 0, tiles.size() - 1);
        tiles.get(focusIndex).lightUp();
        desiredCameraPos = tiles.get(focusIndex).pos;
        break;
      case LEFT:
        desiredGlobalRotation.z += 0.2;
        break;
      case RIGHT:
        desiredGlobalRotation.z -= 0.2;
        break;
      }
    }
  }
  if (key == 'q') {
    saveFrame("frame" + frameCount + ".png");
    println("saved");
  }
}

public void mouseWheel(MouseEvent e) {
  float amt = e.getCount() / abs(e.getCount());
  if (gameOver) {
    desiredDistance = constrain(desiredDistance + amt *0.1, getCoverageDistance(), getFocusDistance());
  }
}

void enterGame() {
  titleScreen = false;
  desiredGlobalPosition.set(width/2, height/2, 0);
}

void gameOver() {
  setCoverageDistance();
  displayTiles = tiles;
  gameOver = true;
}

void setCoverageDistance() {
  desiredDistance = getCoverageDistance();
}

float getCoverageDistance() {
  return min((1f/tiles.size()) * 8, 0.8);
}

void setFocusDistance() {
  desiredDistance = getFocusDistance();
}

float getFocusDistance() {
  return 1;
}

void startGame() {
  gameStarted = true;
  gameOver = false;
}

void accelerate() {
  oscillatingSpeed = min(oscillatingSpeed + 0.00018, DEF_OSCILLATING_SPEED + 0.00018 * 130);
}

private void drawPlayButton(final float x, final float y, final float size) {
  playButtonAlpha = lerp(playButtonAlpha, gameStarted ? 0 : titleScreen ? 0 : 255, ANIM_AMT);
  if (playButtonAlpha > 0.1) {
    // Centroid
    final float cx = 0.25f;
    final float cy = 0.5f;
    //
    pushMatrix();
    {
      translate(x - (cx * size), y - (cy * size));
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

private void updateRubbles() {
  for (int i = rubbles.size() - 1; i >= 0; i--) {
    final Tile r = rubbles.get(i);
    if (r.isOff()) {
      rubbles.remove(i);
    } else {
      r.update();
    }
  }
}

private boolean placeTile() {
  if (isMovingOnX) {
    final float deltaX = topTile.pos.x - oscillatingTile.pos.x;
    score.add((tileScale.x - min(abs(deltaX), tileScale.x))/initialTileScale.x * maxScoreGain);
    if (abs(deltaX) > errorMargin) {
      combo = 0;
      // Cut tile
      tileScale.x -= abs(deltaX);
      if (tileScale.x < 0) {
        // Rubble
        rubbles.add(oscillatingTile);
        tiles.remove(tiles.size() - 1);
        oscillatingTile.dissolve();
        return false;
      }
      // Rubble
      final float rubbleX = oscillatingTile.pos.x + (deltaX > 0 ? -1 : 1) * tileScale.x / 2;
      final PVector rubbleScale = new PVector(abs(deltaX), tileScale.y, tileScale.z);
      Tile rubble = new Tile(new PVector(rubbleX, oscillatingTile.pos.y, oscillatingTile.pos.z), rubbleScale, oscillatingTile.getColor());
      rubbles.add(rubble);
      rubble.dissolve();

      final float middle = topTile.pos.x + (oscillatingTile.pos.x / 2);
      oscillatingTile.setScale(tileScale);
      oscillatingTile.setPos(middle - (topTile.pos.x / 2), topTile.pos.y, oscillatingTile.pos.z);
    } else {

      // Align to top tile
      oscillatingTile.setPos(topTile.pos.x, topTile.pos.y, oscillatingTile.pos.z);
      combo++;
      if (combo >= MINIMUM_COMBO) {
        oscillatingTile.scaleUp(bonusGain, 0);
        waves.init(oscillatingTile.pos, tileScale, true);
      } else {
        waves.init(oscillatingTile.pos, tileScale);
      }
    }
  } else {
    final float deltaY = topTile.pos.y - oscillatingTile.pos.y;
    score.add((tileScale.y - min(abs(deltaY), tileScale.y))/initialTileScale.y * maxScoreGain);
    if (abs(deltaY) > errorMargin) {
      combo = 0;
      // Cut Tile
      tileScale.y -= abs(deltaY);
      if (tileScale.y < 0) {
        // Rubble
        rubbles.add(oscillatingTile);
        tiles.remove(tiles.size() - 1);
        oscillatingTile.dissolve();
        return false;
      }
      // Rubble
      final float rubbleY = oscillatingTile.pos.y + (deltaY > 0 ? -1 : 1) * tileScale.y / 2;
      final PVector rubbleScale = new PVector(tileScale.x, abs(deltaY), tileScale.z);
      Tile rubble = new Tile(new PVector(oscillatingTile.pos.x, rubbleY, oscillatingTile.pos.z), rubbleScale, oscillatingTile.getColor());
      rubble.dissolve();
      rubbles.add(rubble);

      final float middle = topTile.pos.y + (oscillatingTile.pos.y / 2);
      oscillatingTile.setScale(tileScale);
      oscillatingTile.setPos(topTile.pos.x, middle - (topTile.pos.y / 2), oscillatingTile.pos.z);
    } else {

      // Align to top tile
      oscillatingTile.setPos(topTile.pos.x, topTile.pos.y, oscillatingTile.pos.z);
      combo++;
      if (combo >= MINIMUM_COMBO) {
        oscillatingTile.scaleUp(0, bonusGain);
        waves.init(oscillatingTile.pos, tileScale, true);
      } else {
        waves.init(oscillatingTile.pos, tileScale);
      }
    }
  }
  spawnTile();
  return true;
}

private void spawnTile() {
  if (displayTiles.size() > MAX_TILES_ONSCREEN) {
    displayTiles.remove(0);
  }
  topTile = tiles.get(tiles.size() - 1);
  oscillatingTile = new Tile(oscillatingTile.pos.copy().add(0, 0, tileScale.z), tileScale, getNextColor());
  tiles.add(oscillatingTile);
  displayTiles.add(oscillatingTile);

  //Alternate
  isMovingOnX = !isMovingOnX;
  time = -HALF_PI;
  oscillate();
}

private final int getNextColor() {
  colorPos = (colorPos + 1) % COLOR_RANGE;
  if (colorPos == 0) {
    startColor = endColor;
    endColor = color(random(256), random(256), random(256));
  }
  final float amt = (float) colorPos / COLOR_RANGE;
  return lerpColor(startColor, endColor, amt);
}

private void oscillate() {
  if (!gameOver) {
    time += oscillatingSpeed;
    if (isMovingOnX)
      oscillatingTile.pos.x = topTile.pos.x + sin(time) * (initialTileScale.x*1.7);
    else
      oscillatingTile.pos.y = topTile.pos.y + sin(time) * (initialTileScale.y*1.7);
  }
}

class Score {
  int score;
  int stack = 0;
  int highStack;
  int desiredScore = 0;
  int highScore;

  void add(float add) {
    stack++;
    if (combo > 0){
      comboScore = combo * add;
    }else {
      comboScore = 0;
    }
    desiredScore += add + comboScore;
    highScore = score > highScore ? score : highScore;
    highStack = stack > highStack ? stack : highStack;
  }

  void reset() {
    stack = 0;
    desiredScore = 0;
  }

  void ease() {
    score = floor(lerp(score, desiredScore, 0.3));
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

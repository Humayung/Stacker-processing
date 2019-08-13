class Tile {
  PVector rot;
  PVector aVel;

  PVector scale;
  PVector desiredScale;
  PVector pos;
  PVector desiredPos;
  PVector vel;

  boolean dissolve;
  float alpha;
  float desiredAlpha;
  int color_;
  int desiredColor;
  boolean off;

  Tile(PVector pos, PVector scale, int color_) {
    this.desiredScale = scale.copy();
    this.desiredPos = pos.copy();
    this.scale = scale.copy();
    this.pos = pos.copy();
    this.setColor(color_);
    this.color_ = color_;
    this.desiredColor = color_;

    aVel = PVector.random3D().setMag(0.01f);
    rot = new PVector();
    desiredAlpha = 255;
  }

  void update() {
    // Adjust position to the scale changes
    final PVector pScale = scale.copy();
    easeChanges();
    pos.add(PVector.sub(scale, pScale).mult(0.5f));
    alpha = lerp(alpha, desiredAlpha, 0.05f);
    if (dissolve) {
      rot.add(aVel);
      pos.add(vel);
      if (alpha < 0.1) {
        setOff(true);
      }
    }

    display();
  }

  void easeChanges() {
    color_ = lerpColor(color_, desiredColor, 0.1);
    scale.lerp(desiredScale, 0.1f);
  }

  void display() {
    noStroke();
    fill(color_, alpha);

    // Drawing tile
    pushMatrix();
    {
      //translate(pos.x - (scale.x / 2), pos.y - (scale.y / 2), pos.z - (scale.z / 2));
      translate(pos.x, pos.y, pos.z);
      rotateX(rot.x);
      rotateY(rot.y);
      rotateZ(rot.z);
      scale(scale.x, scale.y, scale.z);
      box(1);
    }
    popMatrix();
  }

  void scaleUp(float x, float y) {
    desiredScale.add(x, y, 0);
    desiredScale.x = constrain(desiredScale.x, 0, initialTileScale.x);
    desiredScale.y = constrain(desiredScale.y, 0, initialTileScale.y);
    tileScale.x = constrain(tileScale.x + x, 0, initialTileScale.x);
    tileScale.y = constrain(tileScale.y + y, 0, initialTileScale.y);
    lightUp();
  }

  void setScale(PVector scale) {
    this.desiredScale = scale.copy();
    this.scale = scale.copy();
  }

  void setPos(float x, float y, float z) {
    this.pos = new PVector(x, y, z);
  } 

  void dissolve() {
    vel = PVector.sub(pos, topTile.pos).normalize().mult(0.5);
    desiredAlpha = 0;
    alpha = 255;
    dissolve = true;
  }

  int getColor() {
    return color_;
  }

  void setColor(int color_) {
    this.color_ = color_;
  }

  void lightUp() {
    color_ = color(255);
  }

  boolean isOff() {
    return off;
  }

  void setOff(boolean off) {
    this.off = off;
  }
}

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
  private int color_;
  private boolean off;

  Tile(PVector pos, PVector scale, int color_) {
    this.desiredScale = scale.copy();
    this.desiredPos = pos.copy();
    this.scale = scale.copy();
    this.pos = pos.copy();
    this.setColor(color_);

    aVel = PVector.random3D().mult(0.01f);
    rot = new PVector();
    vel =  PVector.random3D().mult(0.08f);
    desiredAlpha = 255;
  }

  void update() {
    // Adjust position to the scale changes
    PVector pScale = scale.copy();
    scale.lerp(desiredScale, 0.2f);
    pos.add(PVector.sub(scale, pScale).mult(0.5f));
    if (alpha < 0.1) setOff(true);
    alpha = lerp(alpha, desiredAlpha, 0.04f);
    if (dissolve) {
      rot.add(aVel);
      pos.add(vel);
    }

    display();
  }

  void display() {
    noStroke();
    fill(getColor(), alpha);

    // Drawing tile
    pushMatrix();
    {
      translate(pos.x - (scale.x / 2), pos.y - (scale.y / 2), pos.z - (scale.z / 2));
      rotateX(rot.x);
      rotateY(rot.y);
      rotateZ(rot.z);
      beginShape(QUAD);
      {
        vertex(0, 0, 0);
        vertex(scale.x, 0, 0);
        vertex(scale.x, scale.y, 0);
        vertex(0, scale.y, 0);

        vertex(0, 0, scale.z);
        vertex(scale.x, 0, scale.z);
        vertex(scale.x, scale.y, scale.z);
        vertex(0, scale.y, scale.z);

        vertex(0, 0, 0);
        vertex(0, 0, scale.z);
        vertex(0, scale.y, scale.z);
        vertex(0, scale.y, 0);

        vertex(scale.x, 0, 0);
        vertex(scale.x, 0, scale.z);
        vertex(scale.x, scale.y, scale.z);
        vertex(scale.x, scale.y, 0);

        vertex(0, 0, 0);
        vertex(0, 0, scale.z);
        vertex(scale.x, 0, scale.z);
        vertex(scale.x, 0, 0);

        vertex(0, scale.y, 0);
        vertex(0, scale.y, scale.z);
        vertex(scale.x, scale.y, scale.z);
        vertex(scale.x, scale.y, 0);
      }
      endShape();
    }
    popMatrix();
  }

  void scaleUp(float x, float y) {
    desiredScale.add(x, y, 0);
    desiredScale.x = constrain(desiredScale.x, 0, initialTileBounds.x);
    desiredScale.y = constrain(desiredScale.y, 0, initialTileBounds.y);
  }

  void setScale(PVector scale) {
    this.desiredScale = scale.copy();
    this.scale = scale.copy();
  }

  void setPos(float x, float y, float z) {
    this.pos = new PVector(x, y, z);
  }

  void dissolve() {
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

  boolean isOff() {
    return off;
  }

  void setOff(boolean off) {
    this.off = off;
  }
}

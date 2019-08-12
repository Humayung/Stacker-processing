class Waves {
  ArrayList<Rect> waves = new ArrayList<Rect>();

  void init(PVector pos, PVector scale) {
    waves.add(new Rect(pos, scale));
  }

  void update() {
    for (int i = waves.size() - 1; i >= 0; i--) {
      Rect r = waves.get(i);
      if (r.off) waves.remove(i);
      else r.update();
    }
  }

  class Rect {
    PVector desiredScale;
    float lifespan;
    PVector scale;
    PVector pos;
    boolean off;

    Rect(PVector pos, PVector scale) {
      this.desiredScale = scale.copy().add(scale.copy().mult(0.3f));
      this.scale = scale.copy();
      this.pos = pos.copy();
      lifespan = 255;
    }

    void display() {
      pushMatrix();
      {
        translate(pos.x - (scale.x / 2), pos.y - (scale.y / 2), pos.z);
        fill(255, 200, 0, lifespan);
        beginShape(QUAD);
        {
          vertex(0, 0, 0);
          vertex(scale.x, 0, 0);
          vertex(scale.x, scale.y, 0);
          vertex(0, scale.y, 0);
        }
        endShape();
      }
      popMatrix();
    }

    void update() {
      lifespan = lerp(lifespan, 0, 0.1f);
      scale.lerp(desiredScale, 0.1f);
      if (lifespan < 0.01f) off = true;
      display();
    }
  }
}

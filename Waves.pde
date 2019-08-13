class Waves {
  ArrayList<Wave> waves = new ArrayList<Wave>();
  void init(PVector pos, PVector scale) {
    waves.add(new Wave(pos, scale, false));
  }
  
  void init(PVector pos, PVector scale, boolean golden) {
    waves.add(new Wave(pos, scale, golden));
  }

  void update() {
    rectMode(CENTER);
    for (int i = waves.size() - 1; i >= 0; i--) {
      Wave r = waves.get(i);
      if (r.off) waves.remove(i);
      else r.update();
    }
  }
  
  class Wave {
    PVector desiredScale;
    float lifespan;
    PVector scale;
    PVector pos;
    boolean off;
    int color_;

    Wave(PVector pos, PVector scale, boolean golden) {
      this.desiredScale = scale.copy().add(scale.copy().mult(0.4f));
      this.scale = scale.copy();
      this.pos = pos;
      this.color_ = golden ? color(255, 200, 0) : color(255);
      lifespan = 255;
    }

    void display() {
      pushMatrix();
      {
        translate(pos.x, pos.y, pos.z - tileScale.z/2);
        fill(color_, lifespan);
        rect(0, 0, scale.x, scale.y);
      }
      popMatrix();
    }

    void update() {
      easeMotion();
      if (lifespan < 0.01f) off = true;
      display();
    }
    
    void easeMotion(){
      lifespan = lerp(lifespan, 0, 0.1f);
      scale.lerp(desiredScale, 0.1f);
    }
  }
}

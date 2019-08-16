class Cubie {
  ArrayList<Cube> particles = new ArrayList<Cube>();

  void run() {
    if (random(1) < 0.1) {
      final float a = random(TWO_PI);
      final float r =  random(height/1.38, height/0.93);
      final float x = sin(a) *r;
      final float y = cos(a) * r;
      particles.add(new Cube(x, y, topTile.pos.z + random(-height/2)));
    }
    for (int i = particles.size() - 1; i >= 0; i--) {
      final Cube p = particles.get(i);
      if (p.off) particles.remove(i);
      else p.update();
    }
  }

  class Cube {
    PVector rot;
    PVector aVel;
    PVector pos;
    PVector scale;

    boolean off;

    float alpha;
    float time;
    int color_;

    Cube(float x, float y, float z) {
      color_ = color(
        random(150, 256), 
        random(150, 256), 
        random(150, 256)
        );
      aVel = PVector.random3D().mult(0.01f);
      pos = new PVector(x, y, z);
      rot = PVector.random3D();
      scale = new PVector(height/76.8, height/76.8, height/76.8);
    }


    void update() {
      alpha = (-cos(time) * 128) + 128;
      pos.add(0, 0, 0.3f);
      rot.add(aVel);
      time += 0.01;
      if (time > TWO_PI) {
        off = true;
      }
      display();
    }

    void display() {
      pushMatrix();
      {
        fill(color_, alpha);
        translate(pos.x, pos.y, pos.z);
        rotateX(rot.x);
        rotateY(rot.y);
        rotateZ(rot.z);
        scale(scale.x, scale.y, scale.z);
        box(1);
      }
      popMatrix();
    }
  }
}

class ParticleSystem {
  ArrayList<Particle> particles = new ArrayList<Particle>();

  void run() {
    if (random(1) < 0.05) {
      particles.add(new Particle(
        random(-width / 2, width / 2) - 400, 
        random(-height / 2, height / 2) - 400, 
        random(-200, 200) - cameraZ)
        );
    }
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      if (p.off) particles.remove(i);
      else p.update();
    }
  }

  class Particle {
    PVector rot;
    PVector aVel;
    PVector pos;

    boolean off;

    float alpha;
    float time;
    int color_;

    Particle(float x, float y, float z) {
      color_ = color(
        random(150, 256), 
        random(150, 256), 
        random(150, 256)
        );
      aVel = PVector.random3D().mult(0.01f);
      pos = new PVector(x, y, z);
      rot = PVector.random3D();
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
        translate(pos.x, pos.y, pos.z);
        fill(color_, alpha);
        rotateX(rot.x);
        rotateY(rot.y);
        rotateZ(rot.z);
        box(10);
      }
      popMatrix();
    }
  }
}

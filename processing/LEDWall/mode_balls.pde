import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;

Particle[] particles;
int p_spectrum_count = 0;
VerletPhysics2D physics;
//Attractor attractor;

void setupParticles() {
  physics = new VerletPhysics2D ();
  //physics.setWorldBounds(new Rect(0, 0, buffer.width, buffer.height));
  physics.setDrag(0.1);

  //attractor = new Attractor(new Vec2D(buffer.width/2,buffer.height/2));

  particles = new Particle [256];
  for (int i = 0; i < particles.length; i++) {
    float x = random(buffer.width); 
    float y = random(buffer.height);
    Vec2D loc = new Vec2D(x, y);
    particles[i] = new Particle(loc, i % 6);
  }
  println("Particles SETUP ...");
}

void doParticles() {
  physics.update ();
  kinect.updateUser();

  buffer.beginDraw();
  buffer.background(audio.COLOR);

  for (Particle p: particles) {
    if (p.lifespan < 128) buffer.blendMode(BLEND);
    else buffer.blendMode(ADD);
    p.display();
  }

  buffer.blendMode(BLEND);
  buffer.image(kinect.buffer_image, 0, 0);
  buffer.endDraw();
}

/*
class Attractor extends VerletParticle2D {
 
 float r;
 
 Attractor (Vec2D loc) {
 super (loc);
 r = 24;
 physics.addParticle(this);
 physics.addBehavior(new AttractionBehavior(this, buffer.width / 2, 0.05));
 }
 
 void display () {
 set(kinect.user_center.x, kinect.user_center.y);
 //fill(0);
 //ellipse (x, y, r*2, r*2);
 }
 }
 */

class Particle extends VerletParticle2D {

  float r;
  color p_color;
  int spectrum;
  float lifespan = 255;
  boolean update_color;

  Particle (Vec2D loc, int spec) {
    super(loc);
    spectrum = spec + 1;
    reset();
    physics.addParticle(this);
    //physics.addBehavior(new AttractionBehavior(this, r, -0.005));
  }

  void setRadius() {
    r = map(audio.averageSpecs[spectrum].value, 0, 100, 2, buffer.height / 4);
  }

  void setColor() {
    int RED   = int(map(audio.averageSpecs[1].value, 0, 100, 0, 255));
    int GREEN = int(map(audio.averageSpecs[3].value, 0, 100, 0, 255));
    int BLUE  = int(map(audio.averageSpecs[spectrum].value, 0, 100, 0, 255));
    p_color = color(RED, GREEN, BLUE);
  }

  void reset() {
    float test = random(1);
    if (test < 0.35) update_color = false;
    else update_color = true;
    lifespan = random(255);
    setRadius();
    setWeight(r);
    setColor();
    if (update_color == false) {
      if (kinect.user_id != -1) {
        x = kinect.user_center.x; 
        y = kinect.user_center.y;
      } 
      else {
        x = buffer.width / 2; 
        y = buffer.height / 2;
      }
    } 
    else {
      float _x = random(buffer.width); 
      float _y = random(buffer.height);
      x = _x; 
      y = _y;
    }
    clearForce();
    clearVelocity();
    Vec2D v = Vec2D.randomVector();
    addVelocity(v);
  }

  void updateit() {
    if (lifespan < 0) {
      reset();
    } 
    else {
      if (update_color) {
        //setColor();
        setRadius();
        setWeight(r);
      } 
      //else {
      //  p_color = color(red(p_color), green(p_color), blue(p_color), lifespan);
      //}

      clearForce();
      Vec2D f = getVelocity();

      if (x < (r/2) ) {
        f.x *= -1;
      }
      else if (x > (buffer.width - (r/2)) ) {
        f.x *= -1;
      }
      if (y < (r/2) ) {
        f.y *= -1;
      }
      else if (y > (buffer.height - (r/2)) ) {
        f.y *= -1;
      }
      clearVelocity();
      f.limit(2);
      addVelocity(f);
      f.normalize();

      float push = map(audio.averageSpecs[spectrum].value, 0, 100, 0.00025, 0.5);
      f = f.scale(push );
      f.limit(2);
      addForce(f);
    }
  }

  void display () {
    updateit();
    //buffer.stroke(p_color, lifespan);
    buffer.noStroke();
    buffer.fill(p_color, lifespan);
    buffer.ellipse(x, y, r, r);
    lifespan -= 1;
  }
}


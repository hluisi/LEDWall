import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;

Particle[] particles;
int p_spectrum_count = 0;
VerletPhysics2D physics;
//Attractor attractor;

void setupParticles() {
  physics = new VerletPhysics2D ();
  physics.setWorldBounds(new Rect(0, 0, buffer.width, buffer.height));
  physics.setDrag(0.01);
  
  //attractor = new Attractor(new Vec2D(buffer.width/2,buffer.height/2));
  
  particles = new Particle [256];
  for (int i = 0; i < particles.length; i++) {
    float x = random(buffer.width); float y = random(buffer.height);
    Vec2D loc = new Vec2D(x,y);
    particles[i] = new Particle(loc, i % 6);
  }
  println("Particles SETUP ...");
}

void doParticles() {
  physics.update ();
  
  buffer.beginDraw();
  buffer.background(0,255);
  //buffer.fill(0, 10);
  //buffer.rect(0,0,buffer.width, buffer.height);
  buffer.pushStyle();
  buffer.blendMode(ADD);
  
  //attractor.display();
  
  for (Particle p: particles) {
    
    p.display();
    
  }
  
  
  //kinect.updateUser(audio.COLOR[COLOR_MODE_NOBLACK]);
  //if (kinect.user_id != 99999) {
    kinect.updateUserBlack();
    buffer.blend(kinect.buffer_image,0,0,kinect.buffer_image.width,kinect.buffer_image.height,0,0,buffer.width,buffer.height,MULTIPLY);
  //}
  //buffer.image(kinect.buffer_image, 0, 0);
  
  buffer.strokeWeight(1);
  buffer.stroke(255);
  for (int i = 0; i < 160 - 1; i++) {
    buffer.line(i, (buffer.height / 2) + audio.in.left.get(i)*30, i + 1, (buffer.height / 2) + audio.in.left.get(i+1)*30);
    //buffer.line(i, 60 + in.right.get(i)*30, i + 1, 60 + in.right.get(i+1)*30);
  }
  buffer.popStyle();
  buffer.endDraw();
  buffer.blendMode(BLEND);
}

/*
class Attractor extends VerletParticle2D {

  float r;

  Attractor (Vec2D loc) {
    super (loc);
    r = 24;
    physics.addParticle(this);
    physics.addBehavior(new AttractionBehavior(this, buffer.width / 2, 0.005));
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
    //physics.addBehavior(new AttractionBehavior(this, r * 2, -0.05));
  }
  
  void setRadius() {
    r = map(audio.averageSpecs[spectrum].value, 0, 100, 2, buffer.height / 4);
  }
  
  void reset() {
    float test = random(1);
    if (test < 0.15) update_color = false;
    else update_color = true;
    lifespan = random(255);
    setRadius();
    p_color = audio.COLOR;
    if (update_color == false) {
      if (kinect.user_id != -1) {
        x = kinect.user_center.x; y = kinect.user_center.y;
      } else {
        x = buffer.width / 2; y = buffer.height / 2;
      }
    } else {
      float _x = random(buffer.width); float _y = random(buffer.height);
      x = _x; y = _y;
    }
    clearVelocity();
    Vec2D v = Vec2D.randomVector();
    addVelocity(v);
    
  }
  
  void display () {
    if (lifespan < 0) reset();
    
    if (update_color) {
      p_color = audio.COLOR;
      setRadius();
    }
    
    
    Vec2D f = getVelocity();
    clearVelocity();
    
    f.normalize();
    
    if (x < 1 || x > buffer.width - 1)  f.x *= -1;
    if (y < 1 || y > buffer.height - 1) f.y *= -1;
    
    float push = map(audio.averageSpecs[spectrum].value, 0, 100, 0, 2);
    f = f.scale(spectrum * push );
    //f.jitter(0.1,0.1);
    
    addVelocity(f);
    
    buffer.noStroke();
    buffer.fill(p_color, lifespan);
    buffer.ellipse(x, y, r, r);
    
    lifespan -= 1;
  }
}

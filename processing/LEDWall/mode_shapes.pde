// NEED TO HAVE SHAPES FOLLOW USERS

import geomerative.*;

final int TOTAL_PARTICLES = 8;
final float MARGIN = -10;


RShape[] svgs;
Shapes shapes;
Slider shapeSlider;

void setupShapes() {
  RG.init(this);
  RG.ignoreStyles(true);
  
  // load the svgs
  String[] shape_file_names = getFileNames("shapes", "svg"); // get the svg file names

  svgs = new RShape [shape_file_names.length];               // set the length of the svg array
  for (int i = 0; i < svgs.length; i++) {
    String fileName = shape_file_names[i];
    String[] test = split(fileName, '\\');
    String name = test[test.length - 1];
    svgs[i] = RG.loadShape(fileName);
    svgs[i] = RG.centerIn(svgs[i], buffer, MARGIN);
    svgs[i] = RG.polygonize(svgs[i]);
    
    svgs[i].setName(name);
    //svgs[i].scale(0.95);
    println(i + ": " + svgs[i].name);
  }

  shapes = new Shapes();

  int x = TAB_START + 10;
  int y = WINDOW_YSIZE - 80;
  int m = svgs.length - 1;

  // controler name, min, max, value, x, y, width, height, label, handle size, text size, type, move to tab
  shapeSlider = 
    createSlider("doShapeSlider", 0, m, shapes.current, x, y, TAB_MAX_WIDTH + 20, 40, "shapes", 20, lFont, Slider.FLEXIBLE, DISPLAY_STR[DISPLAY_MODE_SHAPES]);

  // controll name, text name, x, y, width, height, text size, value, move 2 tab
  createToggle("allowShapeSwitch", "Random", TAB_START + 20, DEBUG_WINDOW_START + 50, 50, 50, mFont, ControlP5.DEFAULT, shapes.switchOn, DISPLAY_STR[DISPLAY_MODE_SHAPES]);
  createToggle("allowShapeZ", "Scale Z", TAB_START + 80, DEBUG_WINDOW_START + 50, 50, 50, mFont, ControlP5.DEFAULT, shapes.particles[0].scaleZ, DISPLAY_STR[DISPLAY_MODE_SHAPES]);

  println("Shapes SETUP ...");
}

void doShapes() {
  buffer.blendMode(ADD);
  shapes.display();
  buffer.blendMode(BLEND);
}

void doShapeSlider(int v) {
  shapes.setShape(v);
}

void allowShapeSwitch(boolean b) {
  shapes.switchOn = b;
}

void allowShapeZ(boolean b) {
  for (int i = 0; i < shapes.particles.length; i++) {
    shapes.particles[i].scaleZ = b;
  }
}

class Shapes {
  Particle[] particles;
  int current = 0;
  float switchValue = 0.65;
  boolean switchOn = true;

  Shapes() {
    // create the particles
    particles = new Particle [TOTAL_PARTICLES];
    int start_shape = int(random(svgs.length - 1));
    for (int i = 0; i < particles.length; i++) {
      particles[i] = new Particle(i % 4);
      particles[i].setShape( start_shape );
    }
  }

  void randomShape() {
    int new_shape = round(random(svgs.length - 1));
    setShape(new_shape);
    shapeSlider.setValue(current);
  }

  void setShape(int v) {
    current = v;
    for (Particle p: particles) {
      p.setShape(v);
    }
    String name = svgs[particles[0].pShape].name;
    cp5.getController("doShapeSlider").getCaptionLabel().setText(name);
  }

  void update() {
    if ( audio.isOnBeat() ) {
      float test = random(0, 1);
      if (test < switchValue && switchOn) {
        randomShape();
      }
    }
  }

  void display() {
    update();
    for (Particle p: particles) {
      p.update();
      p.display();
    }
  }
}

class Particle {
  int pSpec;
  int pShape;
  int TOTAL_SHAPES;
  int minZ = -150;
  int maxZ = 10;
  float minPush = 0.025;
  float maxPush = 10.0;

  final int MAX_SPEC = 4;

  PVector location;
  PVector velocity;
  PVector acceleration;

  float pAngle;
  float pDrag = 0.01;

  color pColor;

  boolean scaleZ = true;

  Particle(int _spec) {
    pSpec   = _spec;
    defaults();
  }

  void defaults() {
    location = new PVector();
    velocity = new PVector();
    acceleration = new PVector();
    pColor   = color(64);
    reset();
  }

  void reset() {
    pShape   = 0;
    pAngle   = 0;
    location.set( round(random(buffer.width)), round(random(buffer.height)) );
    velocity = PVector.random2D();
    velocity.normalize();
    acceleration.set(0, 0);
  }

  void set(PVector vec) {
    location.set(vec.x, vec.y);
  }

  void set(float x, float y) {
    location.x = x;
    location.y = y;
  }

  void setShape(int index) {
    if ( index > (svgs.length - 1) ) index = 0;
    pShape = index;
  }

  void setSpec(int spec) {
    if (spec > MAX_SPEC) spec = 0;
    pSpec = spec;
  }

  color getColor() {
    if (brightness(audio.colors.background) < 32 ) {
      return color(brightness(audio.colors.grey)+16);
    } 
    else {
      return audio.colors.users[pSpec];
    }
  }

  void update() {
    location.add(velocity);

    int j = pSpec - 1;
    if ( j < 0 ) j = MAX_SPEC - 1;

    //pAngle = map(audio.averageSpecs[pSpec].value, 0, 100, -360, 360);
    
    if (scaleZ) location.z = map(audio.averageSpecs[j].value, 0, 100, minZ, maxZ);
    else location.z = minZ;

    if ( location.x < 0 + minZ || location.x > buffer.width - minZ) {
      velocity.x *= -1;
    }
    if ( location.y < 0 + (minZ / 2) || location.y > buffer.height - (minZ / 2)) {
      velocity.y *= -1;
    }

    float force = map(audio.averageSpecs[pSpec].value, 0, 100, minPush, maxPush);
    velocity.normalize();
    velocity.mult(force);

    pColor = getColor();
  }

  void display() {
    //buffer.pushStyle();
    //buffer.strokeWeight(1);
    //buffer.stroke(color(2,2,2));
    buffer.fill(pColor);
    buffer.pushMatrix();
    buffer.translate(location.x, location.y, location.z);
    svgs[pShape].draw(buffer);
    buffer.popMatrix();
    //buffer.popStyle();
  }
}


// NEED TO HAVE SHAPES FOLLOW USERS

import geomerative.*;

//final int TOTAL_PARTICLES = 8;
final float MARGIN = -10;

int totalShapes = 16;  // how many shapes on the screen

RShape[] svgs;
Shapes shapes;
Slider shapeSlider;
Textfield totalText;
Textfield sMinZText;
Textfield sMaxZText;
Textfield sMinPush;
Textfield sMaxPush;
Textfield sSwitch;

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
    if (name.equals("distrikt.svg") == true) spec.setDistrikt(i);
    println(i + ": " + svgs[i].name);
  }

  shapes = new Shapes();

  shapeSlider = 
    createSlider("doShapeSlider",                         // function name
                 0,                                       // min
                 svgs.length - 1,                         // max
                 shapes.current,                          // starting value
                 TAB_START + 20,                          // x postion
                 WINDOW_YSIZE - 105,                      // y postion
                 TAB_MAX_WIDTH,                           // width
                 60,                                      // height
                 "shapes",                                // caption text
                 40,                                      // handle size
                 xFont,                                   // font
                 Slider.FLEXIBLE,                         // slider type
                 DISPLAY_STR[DISPLAY_MODE_SHAPES]);       // tab
  
  
  
  // controll name, text name, x, y, width, height, text size, value, move 2 tab
  createToggle("allowShapeSwitch",                        // function name
               "Random",                                  // button text
               TAB_START + 20,                           // x postion
               DEBUG_WINDOW_START + 40,                   // y postion
               100,                                       // width
               100,                                       // height
               lFont,                                     // font
               ControlP5.DEFAULT,                         // toggle type
               shapes.switchOn,                           // starting value
               DISPLAY_STR[DISPLAY_MODE_SHAPES]);         // tab
  
  createToggle("allowShapeZ",                             // function name
               "Scale Z",                                 // button text
               TAB_START + 140,                           // x postion
               DEBUG_WINDOW_START + 40,                   // y postion
               100,                                       // width
               100,                                       // height
               lFont,                                     // font
               ControlP5.DEFAULT,                         // toggle type
               shapes.particles[0].scaleZ,                // starting value
               DISPLAY_STR[DISPLAY_MODE_SHAPES]);         // tab
  
  // sets the max speed for the movies when mapped to BPM
  totalText = 
    createTextfield("setTotalShapes",                     // function name
                    "Total",                              // caption name
                    TAB_START + 260,                       // x postion
                    DEBUG_WINDOW_START + 40,              // y postion
                    100,                                   // width
                    100,                                   // height
                    nf(totalShapes, 2),                   // starting value
                    lFont,                                // font
                    ControlP5.INTEGER,                    // input filter (BITFONT, DEFAULT, FLOAT, or INTEGER)
                    DISPLAY_STR[DISPLAY_MODE_SHAPES]);    // tab
  
  sMinZText = 
    createTextfield("setShapeMinZ",                       // function name
                    "MIN Z",                              // caption name
                    TAB_START + 380,                      // x postion
                    DEBUG_WINDOW_START + 40,              // y postion
                    100,                                   // width
                    100,                                   // height
                    nf(shapes.particles[0].minZ, 3), // starting value
                    lFont,                                // font
                    ControlP5.INTEGER,                    // input filter (BITFONT, DEFAULT, FLOAT, or INTEGER)
                    DISPLAY_STR[DISPLAY_MODE_SHAPES]);    // tab
  
  sMaxZText =               
    createTextfield("setShapeMaxZ",                       // function name
                    "MAX Z",                              // caption name
                    TAB_START + 500,                      // x postion
                    DEBUG_WINDOW_START + 40,              // y postion
                    100,                                   // width
                    100,                                   // height
                    nf(shapes.particles[0].maxZ, 2),      // starting value
                    lFont,                                // font
                    ControlP5.INTEGER,                    // input filter (BITFONT, DEFAULT, FLOAT, or INTEGER)
                    DISPLAY_STR[DISPLAY_MODE_SHAPES]);    // tab
  
  sMinPush = 
    createTextfield("setShapeMinPush",                       // function name
                    "MIN PUSH",                              // caption name
                    TAB_START + 620,                      // x postion
                    DEBUG_WINDOW_START + 40,              // y postion
                    100,                                   // width
                    100,                                   // height
                    nf(shapes.particles[0].minPush, 1, 2), // starting value
                    lFont,                                // font
                    ControlP5.FLOAT,                    // input filter (BITFONT, DEFAULT, FLOAT, or INTEGER)
                    DISPLAY_STR[DISPLAY_MODE_SHAPES]);    // tab
  
  sMaxPush =               
    createTextfield("setShapeMaxPush",                       // function name
                    "MAX PUSH",                              // caption name
                    TAB_START + 740,                      // x postion
                    DEBUG_WINDOW_START + 40,              // y postion
                    100,                                   // width
                    100,                                   // height
                    nf(shapes.particles[0].maxPush, 1, 2),      // starting value
                    lFont,                                // font
                    ControlP5.FLOAT,                    // input filter (BITFONT, DEFAULT, FLOAT, or INTEGER)
                    DISPLAY_STR[DISPLAY_MODE_SHAPES]);    // tab
          
    sSwitch =
      createTextfield("setShapeSwitch",                       // function name
                      "Switch",                              // caption name
                      TAB_START + 860,                      // x postion
                      DEBUG_WINDOW_START + 40,              // y postion
                      100,                                   // width
                      100,                                   // height
                      nf(shapes.switchValue, 1, 2),      // starting value
                      lFont,                                // font
                      ControlP5.FLOAT,                    // input filter (BITFONT, DEFAULT, FLOAT, or INTEGER)
                      DISPLAY_STR[DISPLAY_MODE_SHAPES]);    // tab
  
  

  println("Shapes SETUP ...");
}

void doShapeSlider(int v) {
  shapes.setShape(v);
}

void setTotalShapes(String valueString) {
  totalShapes = int(valueString);
  if (totalShapes > 50) totalShapes = 50;
  if (totalShapes < 1)  totalShapes = 1;
  
  shapes.resetShapes();
  totalText.setText(nf(totalShapes,2));
}

void setShapeMinZ(String valueString) {
  int v = int(valueString);
  v *= -1;
  shapes.setMinZ(v);
  sMinZText.setText(nf(v,3));
}

void setShapeMaxZ(String valueString) {
  int v = int(valueString);
  shapes.setMaxZ(v);
  sMaxZText.setText(nf(v,2));
}

void setShapeMinPush(String valueString) {
  float v = float(valueString);
  shapes.setMinPush(v);
  sMinPush.setText(nf(v,1,2));
}

void setShapeMaxPush(String valueString) {
  float v = float(valueString);
  shapes.setMaxPush(v);
  sMaxPush.setText(nf(v,1,2));
}

void setShapeSwitch(String valueString) {
  float v = float(valueString);
  if (v > 0.99) v = 0.99;
  if (v < 0.01) v = 0.01;
  shapes.switchValue = v;
  sSwitch.setText(nf(v,1,2));
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
  float switchValue = 0.75;
  boolean switchOn = true;

  Shapes() {
    // create the particles
    current = round(random(svgs.length - 1));
    resetShapes();
  }
  
  void resetShapes() {
    int min_z = 9999;
    int max_z = -1;
    float min_p = 9999;
    float max_p = -1;
    
    if (particles != null) {
      min_z = particles[0].minZ;
      max_z = particles[0].maxZ;
      min_p = particles[0].minPush;
      max_p = particles[0].maxPush;
    } 
    
    particles = new Particle [totalShapes];
    for (int i = 0; i < particles.length; i++) {
      particles[i] = new Particle(i % 4);
      particles[i].setShape( current );
    }
    if (max_z != -1) {
      setMinZ(min_z);
      setMaxZ(max_z);
      setMinPush(min_p);
      setMaxPush(max_p);
    }
  }

  void randomShape() {
    int new_shape = round(random(svgs.length - 1));
    setShape(new_shape);
    shapeSlider.setValue(current);
  }
  
  void setMinZ(int v) {
    for (Particle p: particles) {
      p.minZ = v;
    }
  }
  
  void setMaxZ(int v) {
    for (Particle p: particles) {
      p.maxZ = v;
    }
  }
  
  void setMinPush(float v) {
    for (Particle p: particles) {
      p.minPush = v;
    }
  }
  
  void setMaxPush(float v) {
    for (Particle p: particles) {
      p.maxPush = v;
    }
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
      if (test > switchValue && switchOn) {
        randomShape();
      } else {
        for (Particle p: particles) {
          p.newDirection();
        }
      }
    }
  }

  void draw() {
    update();
    doBackground();
    buffer.blendMode(ADD);
    //buffer.blendMode(REPLACE);
    for (Particle p: particles) {
      p.update();
      p.display();
    }
    buffer.blendMode(BLEND);
  }
}

class Particle {
  int pSpec;
  int pShape;
  int TOTAL_SHAPES;
  int minZ = -200;
  int maxZ = 40;
  float minPush = 0.5;
  float maxPush = 5.0;

  final int MAX_SPEC = 4;

  PVector location;
  PVector velocity;
  PVector acceleration;

  float pAngle;
  float pDrag = 0.01;

  boolean scaleZ = true;

  Particle(int _spec) {
    pSpec   = _spec;
    defaults();
  }

  void defaults() {
    location = new PVector();
    velocity = new PVector();
    acceleration = new PVector();
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
  
  void newDirection() {
    velocity = PVector.random2D();
    velocity.normalize();
  }

  void setShape(int index) {
    if ( index > (svgs.length - 1) ) index = 0;
    pShape = index;
  }

  void setSpec(int spec) {
    if (spec > MAX_SPEC) spec = 0;
    pSpec = spec;
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

  }

  void display() {
    buffer.fill( colors.users[pSpec] );
    //buffer.stroke(0);
    //buffer.strokeWeight(0.5);
    buffer.noStroke();
    buffer.pushMatrix();
    buffer.translate(location.x, location.y, location.z);
    svgs[pShape].draw(buffer);
    buffer.popMatrix();
  }
}


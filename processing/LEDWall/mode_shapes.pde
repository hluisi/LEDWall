final int TOTAL_PARTICLES = 64;
final float SHAPES_SIZE = 10;

PShape[] svgs;
Shapes shapes;

void setupShapes() {
  // load the svgs
  String[] shape_file_names = getFileNames("shapes", "svg"); // get the svg file names

  svgs = new PShape [shape_file_names.length];               // set the length of the svg array
  for (int i = 0; i < svgs.length; i++) {
    svgs[i] = loadShape(shape_file_names[i]);
    svgs[i].disableStyle();
    println(i + ": " + svgs[i].getName());
  }
  
  shapes = new Shapes();

  println("Shapes SETUP ...");
}

void doShapes() {
  //buffer.background(0);
  buffer.blendMode(ADD);
  shapes.display();
}

class Shapes {
  Particle[] particles;
  int current = 0;

  Shapes() {
    // create the particles
    particles = new Particle [TOTAL_PARTICLES];
    int start_shape = int(random(svgs.length - 1));
    for (int i = 0; i < particles.length; i++) {
      particles[i] = new Particle(SHAPES_SIZE, i % 4);
      particles[i].setShape( start_shape );
    }
  }

  void newShape() {
    int new_shape = round(random(svgs.length - 1));
    for (Particle p: particles) {
      p.setShape(new_shape);
    }
  }

  void update() {
    if ( audio.isOnBeat() ) {
      float test = random(0, 1);
      if (test < 0.65) {
        current = round( random(svgs.length - 1) );
        newShape();
        println( "SHAPES - new shape: " + svgs[particles[0].pShape].getName() );
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

  final int MAX_SPEC = 4;

  PVector location;
  PVector velocity;
  PVector acceleration;
  PVector size;

  float pWidth;
  float pHeight;
  float pRadius;
  float pAngle;
  float pDrag = 0.01;

  color pColor;

  Particle(float _radius, int _spec) {
    pSpec   = _spec;
    pRadius = _radius;

    defaults();
  }

  void defaults() {
    location = new PVector();
    velocity = new PVector();
    acceleration = new PVector();
    size     = new PVector();
    pColor   = color(64);
    reset();
  }

  void reset() {
    pWidth   = pRadius;
    pHeight  = pRadius;
    pShape   = 0;
    pAngle   = 0;
    location.set( round(random(pWidth, buffer.width - pWidth)), round(random(pHeight, buffer.height - pHeight)) );
    velocity = PVector.random2D();
    velocity.normalize();
    acceleration.set(0, 0);
    size.set(0, 0, 0);
  }

  void set(PVector vec) {
    location.set(vec.x, vec.y);
  }

  void set(float x, float y) {
    location.x = x;
    location.y = y;
  }

  void checkRadius() {
    if (pWidth >= pHeight) {
      pRadius = pWidth;
    } else {
      pRadius = pHeight;
    }
  }

  void setWidth(float x) {
    pWidth = x;
    checkRadius();
  }

  void setHeight(float y) {
    pHeight = y;
    checkRadius();
  }

  void setRadius(float r) {
    pRadius = r;
    pWidth = r;
    pHeight = r;
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
    } else {
      return audio.colors.users[pSpec];
    }
  }

  void update() {
    location.add(velocity);

    int j = pSpec - 1;
    if ( j < 0 ) j = MAX_SPEC - 1;

    //pAngle = map(audio.averageSpecs[pSpec].value, 0, 100, -360, 360);
    size.x = map(audio.averageSpecs[pSpec].value, 0, 100, pWidth, buffer.width/4);
    size.y = map(audio.averageSpecs[j].value, 0, 100, pHeight, buffer.height/2);
    
    if ( location.x < (size.x/2) || location.x > (buffer.width - (size.x/2)) ) {
      velocity.x *= -1;
    }
    if ( location.y < (size.y/2) || location.y > (buffer.height - (size.y/2)) ) {
      velocity.y *= -1;
    }

    size.z = map(audio.averageSpecs[pSpec].value, 0, 100, 0.025, 4);
    velocity.normalize();
    velocity.mult(size.z);

    pColor = getColor();
  }

  void display() {
    //buffer.stroke(0);
    //buffer.strokeWeight(0.5);
    buffer.noStroke();
    buffer.fill(pColor);
    buffer.pushMatrix();
    buffer.translate(location.x, location.y);
    buffer.shapeMode(CENTER);
    buffer.shape(svgs[pShape], 0, 0, size.x, size.y);
    buffer.popMatrix();
  }
}


Textlabel sSize, sRot;

Squares squares;


void setupSquares() {
  squares = new Squares();
  // name, default text, x, y, color, font, tab
  sSize = createTextlabel("squaresSize", "Size: " + nf(squares.size,3), TAB_START + 20, DEBUG_WINDOW_START + 40, color(255), lFont, DISPLAY_STR[DISPLAY_MODE_SQUARES]);
  sRot  = createTextlabel("squaresRotation", "Rotation: " + nf(squares.rotation,3), TAB_START + 20, DEBUG_WINDOW_START + 60, color(255), lFont, DISPLAY_STR[DISPLAY_MODE_SQUARES]);
}

void doSquares() {
  squares.draw();
  sSize.setText("Size: " + nf(squares.size,3));
  sRot.setText("Rotation: " + nf(squares.rotation,3));
}

class Squares {
  PVector b1;
  PVector b2;
  PVector b3;
  PVector b4;
  int size;
  int rotation;
  int Z = -50;
  int maxSize = 200;
  int minSize = 50;

  Squares() {
    b1 = new PVector(80, 40, 0);
    b2 = new PVector(80, 40, 0);
    b3 = new PVector(80, 40, 0);
    b4 = new PVector(80, 40, 0);
  }

  int getBoxSize() {
    int r;
    if (audioOn) {
      r = round( map(audio.bass.value, 0, 100, minSize, maxSize) );
      return r;
    } 
    else {
      return round( random(minSize, maxSize) );
    }
  }

  int getRotation() {
    int r;
    if (audioOn) {
      r = round( map(audio.treb.value, 0, 100, 0, 360) );
      return r;
    } 
    else {
      return round( random(0, 360) );
    }
  }

  int getAudio(int spec) {
    int r;
    if (audioOn) {
      r = audio.averageSpecs[spec].value;
      return r;
    } 
    else {
      return round( random(0, 100) );
    }
  }

  void update() {
    size     = getBoxSize();
    rotation = getRotation();
    int v;

    v = getAudio(0);
    b1.x = map(v, 0, 100, 80, 0);
    b1.y = map(v, 0, 100, 40, 0);
    b1.x = size*cos(rotation * b1.x) + b1.x;
    b1.y = size*sin(rotation * b1.y) + b1.y;

    v = getAudio(1);
    b2.x = map(v, 0, 100, 80, 160);
    b2.y = map(v, 0, 100, 40, 80);
    b2.x = size*cos(rotation * b2.x) + b2.x;
    b2.y = size*sin(rotation * b2.y) + b2.y;

    v = getAudio(2);
    b3.x = map(v, 0, 100, 80, 160);
    b3.y = map(v, 0, 100, 40, 0);
    b3.x = size*cos(rotation * b3.x) + b3.x;
    b3.y = size*sin(rotation * b3.y) + b3.y;

    v = getAudio(3);
    b4.x = map(v, 0, 100, 80, 0);
    b4.y = map(v, 0, 100, 40, 80);
    b4.x = size*cos(rotation * b4.x) + b4.x;
    b4.y = size*sin(rotation * b4.y) + b4.y;
  }
  
  void drawBox(int x, int y, color c) {
    buffer.fill(c);
    buffer.pushMatrix();
    buffer.translate(x, y);
    buffer.translate(0, 0, Z);
    buffer.rotate(radians(rotation));
    buffer.box(size, size, size);
    buffer.popMatrix();
  }

  void draw() {
    update();
    doBackground();
    buffer.blendMode(ADD);
    buffer.noStroke();
    drawBox(round(b1.x), round(b1.y), audio.colors.users[11]);
    drawBox(round(b2.x), round(b2.y), audio.colors.users[10]);
    drawBox(round(b3.x), round(b3.y), audio.colors.users[9]);
    drawBox(round(b4.x), round(b4.y), audio.colors.users[8]);
    buffer.blendMode(BLEND);
  }
}

void dSquares() {
  buffer.background(0);
  buffer.blendMode(ADD);
  buffer.noStroke();

  int Z = -50;

  PVector b1 = new PVector(80, 40, 0);
  PVector b2 = new PVector(80, 40, 0);
  PVector b3 = new PVector(80, 40, 0);
  PVector b4 = new PVector(80, 40, 0);
  PVector k = getSingleUser();

  float r = map(audio.bass.value, 0, 100, 50, 200);
  float ra = radians(map(audio.treb.value, 0, 100, 0, 360));

  b1.x = map(audio.averageSpecs[0].value, 0, 100, 80, 0);
  b1.y = map(audio.averageSpecs[0].value, 0, 100, 40, 0);
  b1.x = r*cos(ra * b1.x) + b1.x;
  b1.y = r*sin(ra * b1.y) + b1.y;

  b2.x = map(audio.averageSpecs[1].value, 0, 100, 80, 160);
  b2.y = map(audio.averageSpecs[1].value, 0, 100, 40, 80);
  b2.x = r*cos(ra * b2.x) + b2.x;
  b2.y = r*sin(ra * b2.y) + b2.y;

  b3.x = map(audio.averageSpecs[2].value, 0, 100, 80, 160);
  b3.y = map(audio.averageSpecs[2].value, 0, 100, 40, 0);
  b3.x = r*cos(ra * b3.x) + b3.x;
  b3.y = r*sin(ra * b3.y) + b3.y;

  b4.x = map(audio.averageSpecs[3].value, 0, 100, 80, 0);
  b4.y = map(audio.averageSpecs[3].value, 0, 100, 40, 80);

  b4.x = r*cos(ra * b4.x) + b4.x;
  b4.y = r*sin(ra * b4.y) + b4.y;



  buffer.fill(audio.colors.users[11]);
  buffer.pushMatrix();
  buffer.translate(b1.x, b1.y);
  buffer.translate(0, 0, Z);
  buffer.box(r, r, r);
  buffer.popMatrix();

  buffer.fill(audio.colors.users[10]);
  buffer.pushMatrix();
  buffer.translate(b2.x, b2.y);
  buffer.translate(0, 0, Z);
  buffer.box(r, r, r);
  buffer.popMatrix();

  buffer.fill(audio.colors.users[9]);
  buffer.pushMatrix();
  buffer.translate(b3.x, b3.y);
  buffer.translate(0, 0, Z);
  buffer.box(r, r, r);
  buffer.popMatrix();

  buffer.fill(audio.colors.users[8]);
  buffer.pushMatrix();
  buffer.translate(b4.x, b4.y);
  buffer.translate(0, 0, Z);
  buffer.box(r, r, r);
  buffer.popMatrix();

  buffer.blendMode(BLEND);
}


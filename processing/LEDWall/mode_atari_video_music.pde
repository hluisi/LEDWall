AtariVideoMusic atari; 

void setupAtari() {
  atari = new AtariVideoMusic();
}

void doAtari() {
  buffer.beginDraw();
  buffer.background(audio.COLOR);
  buffer.blendMode(ADD);
  atari.draw();
  buffer.blendMode(BLEND);
  kinect.updateUser();
  buffer.image(kinect.buffer_image, 0, 0);
  buffer.endDraw();
}

class AtariVideoMusic {
  final int SOLID = 0;
  final int HOLE  = 1;
  final int RING  = 2;
  int mode = 0;
  int display_count = 1;
  
  AtariSingle[] alist = new AtariSingle [32];
  
  AtariVideoMusic() {
    for (int i = 0; i < alist.length; i++) {
      alist[i] = new AtariSingle();
    }
    changeDisplay();
  }
  
  void changeDisplay() {                 // 1x1 - 1
    //int count = int(random(0,6));
    int count = int( noise(xoff) * 6 );
    if (count == 0) {
      alist[0].set(80, 40, 160, 80);
      display_count = 1;
    }
    if (count == 1) {                // 2x1 - 2
      alist[0].set(40, 40, 100, 80);
      alist[1].set(120, 40, 100, 80);
      display_count = 2;
    }
    if (count == 2) {                 // 2x2 - 4
      alist[0].set(40,20,90,50);
      alist[1].set(120,20,90,50);
      alist[2].set(40,60,90,50);
      alist[3].set(120,60,90,50);
      display_count = 4;
    }
    if (count == 3) {                // 4x2 - 8
      alist[0].set(20,20,60,50);
      alist[1].set(60,20,60,50);
      alist[2].set(100,20,60,50);
      alist[3].set(140,20,60,50);
      alist[4].set(20,60,60,50);
      alist[5].set(60,60,60,50);
      alist[6].set(100,60,60,50);
      alist[7].set(140,60,60,50);
      display_count = 8;
    }
    if (count == 4) {               // 4x4 - 16
      alist[0].set(20,10,50,30);
      alist[1].set(60,10,50,30);
      alist[2].set(100,10,50,30);
      alist[3].set(140,10,50,30);
      alist[4].set(20,30,50,30);
      alist[5].set(60,30,50,30);
      alist[6].set(100,30,50,30);
      alist[7].set(140,30,50,30);
      alist[8].set(20,50,50,30);
      alist[9].set(60,50,50,30);
      alist[10].set(100,50,50,30);
      alist[11].set(140,50,50,30);
      alist[12].set(20,70,50,30);
      alist[13].set(60,70,50,30);
      alist[14].set(100,70,50,30);
      alist[15].set(140,70,50,30);
      display_count = 16;
      
    }
    if (count == 5) {               // 8x4 - 32
      alist[0].set(10,10,30,30);
      alist[1].set(30,10,30,30);
      alist[2].set(50,10,30,30);
      alist[3].set(70,10,30,30);
      alist[4].set(90,10,30,30);
      alist[5].set(110,10,30,30);
      alist[6].set(130,10,30,30);
      alist[7].set(150,10,30,30);
      alist[8].set(10,30,30,30);
      alist[9].set(30,30,30,30);
      alist[10].set(50,30,30,30);
      alist[11].set(70,30,30,30);
      alist[12].set(90,30,30,30);
      alist[13].set(110,30,30,30);
      alist[14].set(130,30,30,30);
      alist[15].set(150,30,30,30);
      alist[16].set(10,50,30,30);
      alist[17].set(30,50,30,30);
      alist[18].set(50,50,30,30);
      alist[19].set(70,50,30,30);
      alist[20].set(90,50,30,30);
      alist[21].set(110,50,30,30);
      alist[22].set(130,50,30,30);
      alist[23].set(150,50,30,30);
      alist[24].set(10,70,30,30);
      alist[25].set(30,70,30,30);
      alist[26].set(50,70,30,30);
      alist[27].set(70,70,30,30);
      alist[28].set(90,70,30,30);
      alist[29].set(110,70,30,30);
      alist[30].set(130,70,30,30);
      alist[31].set(150,70,30,30);
      display_count = 32;
    }
    println("ATARI - displaying: " + display_count);
  }
  
  void update() {
    if ( audio.isOnBeat() ) {
      float test = random(0, 1);
      if (test < 0.25) changeDisplay();
      if (test > 0.75) {
        //mode = int(random(0,3));
        mode = int( noise(xoff) * 3 );
        println("ATARI - mode: " + mode);
      }
    }
  }
  
  void draw() {
    update();
    for (int i = 0; i < display_count; i++) {
      alist[i].setMode(mode);
      alist[i].draw();
    }
  }
}

class AtariSingle {
  final int SOLID = 0;
  final int HOLE  = 1;
  final int RING  = 2;
  int mode = 0;
  float x, y, w, h, stroke_weight = 2;
  
  AtariSingle() {
    
  }

  color setColor(int i) {
    int RED   = audio.averageSpecs[1].gray;
    int GREEN = audio.averageSpecs[3].gray;
    int BLUE  = audio.averageSpecs[i].gray;
    return color(RED, GREEN, BLUE);
  }
  
  void set(float _x, float _y, float _w, float _h) {
    x = _x; y = _y;
    w = _w; h = _h;
  }
  
  void setMode(int i) {
    mode = i;
  }
  
  void draw() {
    if (mode == SOLID) {
      buffer.noStroke();
    }
    else if (mode == HOLE) {
      stroke_weight = map(audio.volume.value, 0, 100, 1, (h / 5) /* + 1 */);
      buffer.strokeWeight(stroke_weight);
    } 
    else {
      stroke_weight = 2;
      buffer.strokeWeight(stroke_weight);
    }
    
    for (int i = 0; i < (audio.averageSpecs.length - 1) ; i++) {
      float thisWidth  = (w/8) * (i);
      thisWidth += map(audio.averageSpecs[i].value, 0, 100, 0, (w/8));
      float thisHeight = map(audio.averageSpecs[i].value, 0, 100, 0, h);
      color thisColor  = setColor(i);

      if (mode == SOLID) {
        buffer.noStroke();
        buffer.fill(thisColor);
      }
      else {
        buffer.noFill();
        buffer.stroke(thisColor);
      }
      //buffer.fill(thisColor);
      buffer.rectMode(CENTER);
      buffer.rect(x, y, thisWidth, thisHeight);
    }
  }
}


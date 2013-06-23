int DISPLAY_MODE = 1;
float xoff = 0.0;

final int DISPLAY_MODE_TEST    = 0;
final int DISPLAY_MODE_SHOWEQ  = 1;
final int DISPLAY_MODE_USERBG  = 2;
final int DISPLAY_MODE_RAINBOW = 3;
final int DISPLAY_MODE_SHAPES  = 4;
final int DISPLAY_MODE_SPIN    = 5;
final int DISPLAY_MODE_PULSAR  = 6;
final int DISPLAY_MODE_CITY    = 7;
final int DISPLAY_MODE_ATARI   = 8;
final int DISPLAY_MODE_CLIPS   = 9;
final int DISPLAY_MODE_CHING   = 10;

boolean AUTOMODE = false;
boolean useAudio = true;
boolean useKinect = true;
boolean AUDIO_BG_ON = false;

final String[] DISPLAY_STR = { 
  "TEST", "EQ", "USER BG", "RAINBOW", "SHAPES", "SPIN", "PULSAR", "CITY", "ATARI", "CLIPS", "iCHING"
};


PImage smpte, test, wall_image;

DisposeHandler dh;

void setup() {
  //hint(ENABLE_STROKE_PURE);

  int x, y;
  if (DEBUG_SHOW_WALL) {
    x = DEBUG_WINDOW_XSIZE;
    y = (ROWS * DEBUG_REAL_PIXEL_SIZE_Y) + DEBUG_WINDOW_YSIZE;
  } 
  else {
    x = DEBUG_WINDOW_XSIZE;
    y = DEBUG_WINDOW_YSIZE + (ROWS*2);
    DEBUG_WINDOW_START = ROWS*2;
  }

  size(x, y, P2D);


  //smooth();

  dh = new DisposeHandler(this);

  smpte = loadImage("smpte_640x320.png");
  test  = loadImage("test_640x320.png");
  wall_image = createImage(COLUMNS * 2, ROWS * 2, RGB);

  setupBuffer();
  setupMinim();
  setupTeensys();

  setupWall();
  setupKinect();

  setupRainbow();
  setupEQ();

  setupShapes();
  setupCircles();
  setupAtari();
  setupClips();
  setupIChing();
  
  
  
  // must be last
  setupControl();
  frameRate(500);

  frame.setTitle("Wall of Light");
  background(0);
}

void autoMode() {
  if ( audio.isOnMode() ) {
    float test = random(1);
    if (test < 0.15) {
      int count = round(random(1, 10));
      DISPLAY_MODE = count;
      r.activate(count);
      //println("MODE - " + DISPLAY_STR[count]);
    }
  }
}

void draw() {
  //background(0);      

  buffer.beginDraw();         // begin buffering
  buffer.noStroke();
  buffer.noFill();

  //if (AUDIO_BG_ON) buffer.background(audio.colors.background); else buffer.background(0);
  buffer.background(0);

  if (AUTOMODE) autoMode();   // auto change mode to audio beat

  doMode();                   // do the current mode(s)

  if (AUDIO_BG_ON) {
    buffer.blendMode(ADD);
    buffer.rectMode(CENTER);
    buffer.fill(audio.colors.background); 
    buffer.rect(buffer.width / 2, buffer.height / 2, buffer.width + 20, buffer.height + 10);
  }

  buffer.blendMode(BLEND);    // reset to blend mode

  if (useKinect) {  // using the kinect?
    kinect.update(); // update the kinect
    buffer.image(kinect.buffer_image, 0, 0); // draw kinect user(s)
  }

  buffer.noStroke(); // reset stroke
  buffer.noFill();   // reset fill

    buffer.endDraw();           // end buffering
  wall.draw();                // draw the wall
  drawDebug();                // draw debug info
  xoff += 0.2;
}



void doMode() {
  if (DISPLAY_MODE == DISPLAY_MODE_TEST)    doTest();
  if (DISPLAY_MODE == DISPLAY_MODE_SHOWEQ)  doEQ();
  if (DISPLAY_MODE == DISPLAY_MODE_USERBG)  doUserBg();
  if (DISPLAY_MODE == DISPLAY_MODE_SPIN)    doCircles();
  if (DISPLAY_MODE == DISPLAY_MODE_PULSAR)  doPulsar();
  if (DISPLAY_MODE == DISPLAY_MODE_CITY)    doCity();
  if (DISPLAY_MODE == DISPLAY_MODE_RAINBOW) doRainbow();
  if (DISPLAY_MODE == DISPLAY_MODE_ATARI)   doAtari();
  if (DISPLAY_MODE == DISPLAY_MODE_CLIPS)   doClips();
  if (DISPLAY_MODE == DISPLAY_MODE_SHAPES)  doShapes();
  if (DISPLAY_MODE == DISPLAY_MODE_CHING)   doIChing();
  displayModeText.setText( DISPLAY_STR[DISPLAY_MODE] );
}

void keyPressed() {

  if (key == '0') DISPLAY_MODE = DISPLAY_MODE_TEST;
  if (key == '1') DISPLAY_MODE = DISPLAY_MODE_SHOWEQ;
  if (key == '2') DISPLAY_MODE = DISPLAY_MODE_USERBG;
  if (key == '3') DISPLAY_MODE = DISPLAY_MODE_RAINBOW;
  if (key == '4') DISPLAY_MODE = DISPLAY_MODE_SHAPES;
  if (key == '5') DISPLAY_MODE = DISPLAY_MODE_SPIN;
  if (key == '6') DISPLAY_MODE = DISPLAY_MODE_PULSAR;
  if (key == '7') DISPLAY_MODE = DISPLAY_MODE_CITY;
  if (key == '8') DISPLAY_MODE = DISPLAY_MODE_ATARI;
  if (key == '9') DISPLAY_MODE = DISPLAY_MODE_CLIPS;
  if (key == '-') DISPLAY_MODE = DISPLAY_MODE_CHING;

  r.activate(DISPLAY_MODE);
}

public class DisposeHandler {

  DisposeHandler(PApplet p) {
    p.registerDispose(this);
  }

  void dispose() {
    System.out.println("CLOSING DOWN!!!");
    kinect.close();

    // always close Minim audio classes when you are done with them
    audio.close();
    minim.stop();

    for (int i = 0; i < teensys.length; i++) {
      teensys[i].quit();
    }
  }
}


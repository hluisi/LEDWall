import processing.serial.*;

int DISPLAY_MODE = 1;

final int DISPLAY_MODE_TEST       = 0;
final int DISPLAY_MODE_SHOWEQ     = 1;
final int DISPLAY_MODE_KINECT     = 2;
final int DISPLAY_MODE_BGCOLOR    = 3;
final int DISPLAY_MODE_USERBG     = 4;
final int DISPLAY_MODE_USERAUDIO  = 5;
final int DISPLAY_MODE_WHEEL      = 6;
final int DISPLAY_MODE_WHEELAUDIO = 7;
final int DISPLAY_MODE_BALLS      = 8;

final String[] DISPLAY_STR = { 
  "TEST", "EQ", "KINECT", "BACKGROUND", "USER_BG", "USER_AUDIO", "WHEEL_COLORS", "WHEEL_AUDIO", "BALLS"
};
final String[] AUDIO_STR = { 
  "RAW", "SMOOTHED", "BALANCED"
};
final String[] COLOR_STR = { 
  "AUDIO UP", "AUDIO DOWN", "SINGLE UP", "SINGLE DOWN", "MAPPED WHITE", "MAPPED BLACK"
};

PImage smpte, test, wall_image;


void setup() {
  int x = DEBUG_WINDOW_XSIZE, y;
  if (DEBUG_SHOW_WALL) y = (ROWS * DEBUG_REAL_PIXEL_SIZE_Y) + DEBUG_WINDOW_YSIZE;
  else y = DEBUG_WINDOW_YSIZE;

  size(x, y, P3D);

  smpte = loadImage("smpte_640x320.png");
  test  = loadImage("test_640x320.png");
  wall_image = createImage(COLUMNS, ROWS, RGB);

  setupAudio();
  setupSerial();
  setupBuffer();
  setupWall();
  setupWheel();
  setupEQ();
  //setupBalls();
  
  setupKinect();
  setupParticles();
  frameRate(30);
  
  TColor col = TColor.newRGB(0,0,255);
  float[] test = new float [4];
  col.toRGBAArray(test);
  println(test);
}

void draw() {
  doMode();
  wall.display();
  drawDebug();
}

void drawDebug() {
  // fill debug window dary grey
  fill(#313131);
  rectMode(CORNER);
  rect(0, DEBUG_WINDOW_START, DEBUG_WINDOW_XSIZE, DEBUG_WINDOW_START + DEBUG_WINDOW_YSIZE);
  
  // fill text display background
  fill(#212121);
  rect(5, DEBUG_WINDOW_START + 5, 300, 210);
  
  fill(255);
  text("FPS: " + frameRate, 10, DEBUG_WINDOW_START + 20);
  text("display mode: " + DISPLAY_STR[DISPLAY_MODE] + "  (use number keys to change)", 10, DEBUG_WINDOW_START + 35);
  text("audio mode: " + AUDIO_STR[AUDIO_MODE] + "  (use: r, s, or b to change)", 10, DEBUG_WINDOW_START + 65);
  text("audio volume: " + audio.VOLUME, 10, DEBUG_WINDOW_START + 80);
  
  text("User: " + kinect.user_id, 10, DEBUG_WINDOW_START + 110);
  text("kinect user  X: " + (kinect.user_center.x) + "  Y: " + (kinect.user_center.y), 10, DEBUG_WINDOW_START + 125);
  
  text("color mode: " + COLOR_STR[COLOR_MODE] + " (use arrow keys to change)", 10, DEBUG_WINDOW_START + 155);
  text("Brightness: " + brightness(audio.COLOR[COLOR_MODE]) + "   Hue: " + hue(audio.COLOR[COLOR_MODE]), 10, DEBUG_WINDOW_START + 170);
  text("R: " + red(audio.COLOR[COLOR_MODE]) + "  G: " + green(audio.COLOR[COLOR_MODE]) + "   B: " + blue(audio.COLOR[COLOR_MODE]), 10, DEBUG_WINDOW_START + 185);
  
  
  //image(buffer, DEBUG_WINDOW_XSIZE - (buffer.width + 10) - 170, DEBUG_WINDOW_START + 10);
  //image(buffer, width - 270, DEBUG_WINDOW_START + 10);
  
  fill(#212121);
  rectMode(CORNER);
  rect(DEBUG_WINDOW_XSIZE - 150, DEBUG_WINDOW_START + 5, 145, 210);
  for(int i = 0; i < wall.teensyImages.length; i++) {
    pushMatrix();
    int y = DEBUG_WINDOW_START + 14 + (i * 16);
    
    String temp = "Teensy " + i;
    fill(255);
    text(temp, DEBUG_WINDOW_XSIZE - 90 - textWidth(temp) - 5, y + (i * 4) + 12);
    
    translate(DEBUG_WINDOW_XSIZE - 90, y + (i * 4));
    
    //rotateZ(radians(90));
    //rotateX(radians(-180));
    image(wall.teensyImages[i], 0, 0);
    popMatrix();
  }
}

void doMode() {
  if (DISPLAY_MODE == DISPLAY_MODE_TEST)      doTest();
  if (DISPLAY_MODE == DISPLAY_MODE_BGCOLOR)   doBGColor();
  if (DISPLAY_MODE == DISPLAY_MODE_SHOWEQ)    doEQ();
  if (DISPLAY_MODE == DISPLAY_MODE_KINECT)    doKinect();
  if (DISPLAY_MODE == DISPLAY_MODE_USERAUDIO) doUserAudio();
  if (DISPLAY_MODE == DISPLAY_MODE_USERBG)    doUserBg();
  if (DISPLAY_MODE == DISPLAY_MODE_BALLS)     doParticles(); //doBalls();
  if (DISPLAY_MODE == DISPLAY_MODE_WHEELAUDIO) {
    if (wheel.use_audio != true) wheel.audioOn();
    doWheel();
  }
  if (DISPLAY_MODE == DISPLAY_MODE_WHEEL) {
    if (wheel.use_audio != false) wheel.audioOff();
    doWheel();
  }
}

void keyPressed() {
  //println("keyPressed: " + key);
  if (key == CODED) {
    if (keyCode == UP) {
      COLOR_MODE++;
      if (COLOR_MODE > 5) COLOR_MODE = 0;
    } 
    else if (keyCode == DOWN) {
      COLOR_MODE--;
      if (COLOR_MODE < 0) COLOR_MODE = 5;
    }
    println("Color set to " + COLOR_STR[COLOR_MODE] + " mode ...");
  }
  
  if (key == '1') DISPLAY_MODE = DISPLAY_MODE_TEST;
  if (key == '2') DISPLAY_MODE = DISPLAY_MODE_SHOWEQ;
  if (key == '3') DISPLAY_MODE = DISPLAY_MODE_KINECT;
  if (key == '4') DISPLAY_MODE = DISPLAY_MODE_BGCOLOR;
  if (key == '5') DISPLAY_MODE = DISPLAY_MODE_USERBG;
  if (key == '6') DISPLAY_MODE = DISPLAY_MODE_USERAUDIO;
  if (key == '7') DISPLAY_MODE = DISPLAY_MODE_WHEEL;
  if (key == '8') DISPLAY_MODE = DISPLAY_MODE_WHEELAUDIO;
  if (key == '9') DISPLAY_MODE = DISPLAY_MODE_BALLS;


  if (key == 'r') {
    AUDIO_MODE = AUDIO_MODE_RAW;
    println("Audio set to RAW mode ...");
  }
  if (key == 's') {
    AUDIO_MODE = AUDIO_MODE_SMOOTHED;
    println("Audio set to SMOOTHED mode ...");
  }
  if (key == 'b') {
    AUDIO_MODE = AUDIO_MODE_BALANCED;
    println("Audio set to BALANCED mode ...");
  }
  
  //if (key == ',') kinect.moveKinect(0.5);
  
}


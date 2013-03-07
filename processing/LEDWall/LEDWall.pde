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
  "AUDIO", "NO WHITE", "NO BLACK"
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
  setupBalls();
  setupKinect();
  frameRate(30);
}

void update() {
  buffer.updatePixels();
  //wall_image.copy(buffer, 0, 0, BUFFER_WIDTH, BUFFER_HEIGHT, 0, 0, COLUMNS, ROWS);
}

void draw() {
  doMode();
  update();
  wall.setFrame(buffer);
  wall.display();
  drawDebug();
}

void drawDebug() {
  fill(#212121);
  rectMode(CORNER);
  rect(0, DEBUG_WINDOW_START, DEBUG_WINDOW_XSIZE, DEBUG_WINDOW_START + DEBUG_WINDOW_YSIZE);
  fill(255);
  text("FPS: " + frameRate, 10, DEBUG_WINDOW_START + 20);
  text("display mode: " + DISPLAY_STR[DISPLAY_MODE] + "  (use number keys to change)", 10, DEBUG_WINDOW_START + 35);
  text("audio mode: " + AUDIO_STR[AUDIO_MODE] + "  (use: r, s, or b to change)", 10, DEBUG_WINDOW_START + 50);
  text("audio volume: " + audio.VOLUME, 10, DEBUG_WINDOW_START + 65);
  text("color mode: " + COLOR_STR[COLOR_MODE] + " (use arrow keys to change)", 10, DEBUG_WINDOW_START + 80);
  text("kinect user  X: " + (kinect.user_center.x) + "  Y: " + (kinect.user_center.y), 10, DEBUG_WINDOW_START + 95);
  text("Balls: " + balls.size(), 10, DEBUG_WINDOW_START + 110);
  BigBall b = balls.get(0);
  text("User: " + kinect.user_id, 10, DEBUG_WINDOW_START + 125);
  text("Brightness: " + brightness(audio.COLOR[COLOR_MODE]), 10, DEBUG_WINDOW_START + 140);
  text("R: " + red(audio.COLOR[COLOR_MODE]) + "  G: " + green(audio.COLOR[COLOR_MODE]) + "   B: " + blue(audio.COLOR[COLOR_MODE]), 10, DEBUG_WINDOW_START + 155);

  image(buffer, DEBUG_WINDOW_XSIZE - (buffer.width + 10), DEBUG_WINDOW_START + 10);
}

void doMode() {
  if (DISPLAY_MODE == DISPLAY_MODE_TEST)      doTest();
  if (DISPLAY_MODE == DISPLAY_MODE_BGCOLOR)   doBGColor();
  if (DISPLAY_MODE == DISPLAY_MODE_SHOWEQ)    doEQ();
  if (DISPLAY_MODE == DISPLAY_MODE_KINECT)    doKinect();
  if (DISPLAY_MODE == DISPLAY_MODE_USERAUDIO) doUserAudio();
  if (DISPLAY_MODE == DISPLAY_MODE_USERBG)    doUserBg();
  if (DISPLAY_MODE == DISPLAY_MODE_BALLS)     doBalls();
  if (DISPLAY_MODE == DISPLAY_MODE_WHEELAUDIO) {
    if (wheel.use_audio != true) wheel.audioOn();
    doWheel();
  }
  if (DISPLAY_MODE == DISPLAY_MODE_WHEEL) {
    if (wheel.use_audio != false) wheel.audioOff();
    doWheel();
  }
}

void displayImage(PImage _image) {
  PImage bufferImage = createImage(COLUMNS, ROWS, ARGB);
  bufferImage.copy(_image, 0, 0, _image.width, _image.height, 0, 0, bufferImage.width, bufferImage.height);
  buffer.beginDraw();
  buffer.image(bufferImage, 0, 0);
  buffer.endDraw();
}

void doTest() {
  displayImage(smpte);
}

void doBGColor() {
  color thisColor = audio.COLOR[COLOR_MODE]; //audio.COLORS[AUDIO_MODE];
  buffer.beginDraw();
  buffer.background(thisColor);
  buffer.endDraw();
}

void doUserAudio() {
  color thisColor = audio.COLOR[COLOR_MODE]; //audio.COLORS[AUDIO_MODE];
  kinect.updateUser(thisColor);
  buffer.beginDraw();
  buffer.background(0);
  buffer.image(kinect.current_image, 0, 0);
  //if (audio.VOLUME < 70) buffer.filter(INVERT);
  buffer.endDraw();
}

void doUserBg() {
  color thisColor = audio.COLOR[COLOR_MODE]; //audio.COLORS[AUDIO_MODE];
  kinect.updateUserBlack();
  buffer.beginDraw();
  buffer.background(thisColor);
  buffer.image(kinect.current_image, 0, 0);
  //if (audio.VOLUME < 70) buffer.filter(POSTERIZE,5);
  buffer.endDraw();
}

void keyPressed() {
  //println("keyPressed: " + key);
  if (key == CODED) {
    if (keyCode == UP) {
      COLOR_MODE++;
      if (COLOR_MODE > 2) COLOR_MODE = 0;
    } 
    else if (keyCode == DOWN) {
      COLOR_MODE--;
      if (COLOR_MODE < 0) COLOR_MODE = 2;
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
  
}


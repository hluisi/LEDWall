import processing.serial.*;

int DISPLAY_MODE = 1;

final int DISPLAY_MODE_TEST         = 0;
final int DISPLAY_MODE_BGCOLOR = 1;
final int DISPLAY_MODE_SHOWEQ  = 2;
final int DISPLAY_MODE_KINECT     = 3;
final int DISPLAY_MODE_USERAUDIO = 4;
final int DISPLAY_MODE_USERBG = 5;
final int DISPLAY_MODE_WHEELAUDIO = 6;
final int DISPLAY_MODE_WHEEL = 7;

final String[] DISPLAY_STR = { "TEST", "BACKGROUND", "EQ", "KINECT", "USER_AUDIO", "USER_BG", "WHEEL_AUDIO", "WHEEL_COLORS" };
final String[] AUDIO_STR = { "RAW", "SMOOTHED", "BALANCED"  };

PImage smpte, test, wall_image;

void setup() {
  int x = DEBUG_WINDOW_XSIZE, y;
  if (DEBUG_SHOW_WALL) y = (ROWS * DEBUG_REAL_PIXEL_SIZE_Y) + DEBUG_WINDOW_YSIZE;
  else y = DEBUG_WINDOW_YSIZE;

  size(x, y, P3D);

  smpte = loadImage("smpte_640x320.png");
  test = loadImage("test_640x320.png");
  wall_image = createImage(COLUMNS, ROWS, RGB);

  setupAudio();
  setupSerial();
  setupBuffer();
  setupWall();
  setupWheel();
  setupEQ();
  setupKinect();
}

void update() {
  buffer.updatePixels();
  wall_image.copy(buffer, 0, 0, BUFFER_WIDTH, BUFFER_HEIGHT, 0, 0, COLUMNS, ROWS);
}

void draw() {
  doMode();
  update();
  wall.setFrame(wall_image);
  wall.display();
  drawDebug();
}

void drawDebug() {
  fill(#212121);
  rectMode(CORNER);
  rect(0, DEBUG_WINDOW_START, DEBUG_WINDOW_XSIZE, DEBUG_WINDOW_START + DEBUG_WINDOW_YSIZE);
  fill(255);
  text("FPS: " + frameRate, 10, DEBUG_WINDOW_START + 20);
  text("display mode: " + DISPLAY_STR[DISPLAY_MODE] + "  (use arrow keys to change)", 10, DEBUG_WINDOW_START + 35);
  text("audio mode: " + AUDIO_STR[AUDIO_MODE] + "  (use: r, s, or b to change)", 10, DEBUG_WINDOW_START + 50);
  text("audio volume: " + audio.VOLUME, 10, DEBUG_WINDOW_START + 65);
  text("kinect user  X: " + kinect.user1_center.x + "  Y: " + kinect.user1_center.y, 10, DEBUG_WINDOW_START + 80);
  
  image(wall_image, DEBUG_WINDOW_XSIZE - (wall_image.width + 10), DEBUG_WINDOW_START + 10);
}

void doMode() {
  if (DISPLAY_MODE == DISPLAY_MODE_TEST)         doTest();
  if (DISPLAY_MODE == DISPLAY_MODE_BGCOLOR) doBGColor();
  if (DISPLAY_MODE == DISPLAY_MODE_SHOWEQ)  doEQ();
  if (DISPLAY_MODE == DISPLAY_MODE_KINECT)     doKinect();
  if (DISPLAY_MODE == DISPLAY_MODE_USERAUDIO)     doUserAudio();
  if (DISPLAY_MODE == DISPLAY_MODE_USERBG)     doUserBg();
  if (DISPLAY_MODE == DISPLAY_MODE_WHEELAUDIO) {
    if (wheel.use_audio != true) wheel.audioOn();
    doWheel();
  }
  if (DISPLAY_MODE == DISPLAY_MODE_WHEEL) {
    if (wheel.use_audio != false) wheel.audioOff();
    doWheel();
  }
}

void doTest() {
  buffer.beginDraw();
  buffer.image(smpte, 0, 0);
  buffer.endDraw();
}

void doBGColor() {
  color thisColor = audio.COLORS[AUDIO_MODE];
  buffer.beginDraw();
  buffer.background(thisColor);
  buffer.endDraw();
}

void doUserAudio() {
  color thisColor = audio.COLORS[AUDIO_MODE];
  kinect.updateUser(thisColor);
  buffer.beginDraw();
  buffer.background(0);
  buffer.image(kinect.user_image, 0, 0);
  //if (audio.VOLUME < 70) buffer.filter(INVERT);
  buffer.endDraw();
}

void doUserBg() {
  color thisColor = audio.COLORS[AUDIO_MODE];
  kinect.updateUserBlack();
  buffer.beginDraw();
  buffer.background(thisColor);
  buffer.image(kinect.user_image, 0, 0);
  //if (audio.VOLUME < 70) buffer.filter(POSTERIZE,5);
  buffer.endDraw();
}

void keyPressed() {
  //println("keyPressed: " + key);
  if (key == CODED) {
    if (keyCode == UP) {
      DISPLAY_MODE++;
      if (DISPLAY_MODE > 7) DISPLAY_MODE = 0;
    } 
    else if (keyCode == DOWN) {
      DISPLAY_MODE--;
      if (DISPLAY_MODE < 0) DISPLAY_MODE = 7;
    }
  }
  if (key == '1') KINECT_MODE = KINECT_MODE_RGB;
  if (key == '2') KINECT_MODE = KINECT_MODE_DEPTH;
  //if (key == '3') KINECT_MODE = KINECT_MODE_USER;
  //if (key == '4') DISPLAY_MODE = DISPLAY_MODE_KINECT;

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


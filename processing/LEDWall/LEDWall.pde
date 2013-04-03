int DISPLAY_MODE = 1;

final int DISPLAY_MODE_TEST    = 0;
final int DISPLAY_MODE_SHOWEQ  = 1;
final int DISPLAY_MODE_USERBG  = 2;
final int DISPLAY_MODE_WHEEL   = 3;
final int DISPLAY_MODE_BALLS   = 4;
final int DISPLAY_MODE_SPIN    = 5;
final int DISPLAY_MODE_PULSAR  = 6;
final int DISPLAY_MODE_CITY    = 7;
final int DISPLAY_MODE_ATARI   = 8;
final int DISPLAY_MODE_CLIPS   = 9;


final String[] DISPLAY_STR = { 
  "TEST", "EQ", "USER BG", "WHEEL", "BALLS", "SPIN", "PULSAR", "CITY", "ATARI", "CLIPS"
};


PImage smpte, test, wall_image;


void setup() {
  int x = DEBUG_WINDOW_XSIZE, y;
  if (DEBUG_SHOW_WALL) y = (ROWS * DEBUG_REAL_PIXEL_SIZE_Y) + DEBUG_WINDOW_YSIZE;
  else y = DEBUG_WINDOW_YSIZE;

  size(x, y, JAVA2D);

  smpte = loadImage("smpte_640x320.png");
  test  = loadImage("test_640x320.png");
  wall_image = createImage(COLUMNS, ROWS, RGB);

  setupBuffer();
  setupMinim();
  //setupSerial();
  
  setupWall();
  setupWheel();
  setupEQ();
  
  setupKinect();
  setupParticles();
  setupCircles();
  setupAtari();
  setupClips();
  //frameRate(30);
  
  image_buffer = createImage(COLUMNS, ROWS, ARGB);
}

void draw() {
  //updateMinim();
  doMode();
  //minimTest();
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
  //text("audio mode: " + AUDIO_STR[AUDIO_MODE] + "  (use: r, s, or b to change)", 10, DEBUG_WINDOW_START + 65);
  //text("audio volume: " + audio.VOLUME, 10, DEBUG_WINDOW_START + 80);
  text("BASS: " + audio.BASS, 10, DEBUG_WINDOW_START + 65); 
  text("MIDS: " + audio.MIDS, 80, DEBUG_WINDOW_START + 65);
  text("TREB: " + audio.TREB, 150, DEBUG_WINDOW_START + 65);
  text("BPM: " + audio.BPM + "  count: " + audio.bpm_count + "  secs: " + audio.sec_count, 10, DEBUG_WINDOW_START + 80);
  text("GAIN: " + audio.in.gain(), 10, DEBUG_WINDOW_START + 95);
  
  text("RAW: " + audio.volume.value, 10, DEBUG_WINDOW_START + 125);
  //text("SMO: " + audio.spectrums[0].raw_smoothed, 150, DEBUG_WINDOW_START + 125);
  //text("EQL: " + audio.spectrums[0].raw_equalized, 290, DEBUG_WINDOW_START + 125);
  text("PEAK: " + audio.volume.peak, 80, DEBUG_WINDOW_START + 125);
  text("MAX PEAK: " + audio.volume.max_peak, 150, DEBUG_WINDOW_START + 125);
  text("dB: " + audio.volume.dB, 10, DEBUG_WINDOW_START + 140);
  
  text("atari - x:" + atari.alist[0].x + "  y:" + atari.alist[0].y + " s:" + atari.alist[0].stroke_weight, 10, DEBUG_WINDOW_START + 155);

  text("kinect user  X: " + (kinect.user_center.x) + "  Y: " + (kinect.user_center.y), 10, DEBUG_WINDOW_START + 170);
  
  text("circles: " + circles.theta, 10, DEBUG_WINDOW_START + 185);
  text("Brightness: " + brightness(audio.COLOR) + "   Sat: " + saturation(audio.COLOR), 10, DEBUG_WINDOW_START + 200);
  text("R: " + audio.RED + "  G: " + audio.GREEN + "   B: " + audio.BLUE, 10, DEBUG_WINDOW_START + 215);
  
  
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
  if (DISPLAY_MODE == DISPLAY_MODE_TEST)    doTest();
  if (DISPLAY_MODE == DISPLAY_MODE_SHOWEQ)  doEQ();
  if (DISPLAY_MODE == DISPLAY_MODE_USERBG)  doUserBg();
  if (DISPLAY_MODE == DISPLAY_MODE_BALLS)   doParticles(); 
  if (DISPLAY_MODE == DISPLAY_MODE_SPIN)    doCircles();
  if (DISPLAY_MODE == DISPLAY_MODE_PULSAR)  doPulsar();
  if (DISPLAY_MODE == DISPLAY_MODE_CITY)    doCity();
  if (DISPLAY_MODE == DISPLAY_MODE_WHEEL)   doWheel();
  if (DISPLAY_MODE == DISPLAY_MODE_ATARI)   doAtari();
  if (DISPLAY_MODE == DISPLAY_MODE_CLIPS)   doClips();
}

void stop() {
  
  kinect.close();
  
  // always close Minim audio classes when you are done with them
  audio.close();
  minim.stop();
  super.stop();
}

void keyPressed() {
  //println("keyPressed: " + key);
  //if (key == CODED) {
  //  if (keyCode == UP) {
   //   COLOR_MODE++;
   //   if (COLOR_MODE > 3) COLOR_MODE = 0;
   // } 
   // else if (keyCode == DOWN) {
   //   COLOR_MODE--;
   //   if (COLOR_MODE < 0) COLOR_MODE = 3;
   // }
   // println("Color set to " + COLOR_STR[COLOR_MODE] + " mode ...");
  //}
  
  if (key == '0') DISPLAY_MODE = DISPLAY_MODE_TEST;
  if (key == '1') DISPLAY_MODE = DISPLAY_MODE_SHOWEQ;
  if (key == '2') DISPLAY_MODE = DISPLAY_MODE_USERBG;
  if (key == '3') DISPLAY_MODE = DISPLAY_MODE_WHEEL;
  if (key == '4') DISPLAY_MODE = DISPLAY_MODE_BALLS;
  if (key == '5') DISPLAY_MODE = DISPLAY_MODE_SPIN;
  if (key == '6') DISPLAY_MODE = DISPLAY_MODE_PULSAR;
  if (key == '7') DISPLAY_MODE = DISPLAY_MODE_CITY;
  if (key == '8') DISPLAY_MODE = DISPLAY_MODE_ATARI;
  if (key == '9') DISPLAY_MODE = DISPLAY_MODE_CLIPS;



  //if (key == 'r') {
  //  AUDIO_MODE = AUDIO_MODE_RAW;
  //  println("Audio set to RAW mode ...");
  //}
  //if (key == 's') {
  //  AUDIO_MODE = AUDIO_MODE_SMOOTHED;
  //  println("Audio set to SMOOTHED mode ...");
  //}
  //if (key == 'b') {
  //  AUDIO_MODE = AUDIO_MODE_BALANCED;
  //  println("Audio set to BALANCED mode ...");
  //}
  
  //if (key == ',') kinect.moveKinect(0.5);
}


    


  

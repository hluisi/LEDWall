int DISPLAY_MODE = 1;
float xoff = 0.0;

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

boolean AUTOMODE = false;
boolean useAudio = true;
boolean useKinect = true;

final String[] DISPLAY_STR = { 
  "TEST", "EQ", "USER BG", "WHEEL", "BALLS", "SPIN", "PULSAR", "CITY", "ATARI", "CLIPS"
};


PImage smpte, test, wall_image;

void setup() {
  //hint(ENABLE_STROKE_PURE);
  int x, y;
  if (DEBUG_SHOW_WALL) {
    x = DEBUG_WINDOW_XSIZE;
    y = (ROWS * DEBUG_REAL_PIXEL_SIZE_Y) + DEBUG_WINDOW_YSIZE;
  } else {
    x = DEBUG_WINDOW_XSIZE;
    y = DEBUG_WINDOW_YSIZE + (ROWS*2);
    DEBUG_WINDOW_START = ROWS*2;
  }

  size(x, y, JAVA2D);

  smpte = loadImage("smpte_640x320.png");
  test  = loadImage("test_640x320.png");
  wall_image = createImage(COLUMNS * 2, ROWS * 2, RGB);

  setupBuffer();
  setupMinim();
  setupSerial();

  setupWall();
  setupKinect();

  setupWheel();
  setupEQ();

  setupShapes();
  setupParticles();
  setupCircles();
  setupAtari();
  setupClips();
  
  // must be last
  setupControl();
  frameRate(300);

  frame.setTitle("Wall of Light");
}

void autoMode() {
  if ( audio.isOnMode() ) {
    float test = random(1);
    if (test < 0.15) {
      int count = int(random(1, 10));
      DISPLAY_MODE = count;
      r.activate(count);
      println("MODE - " + DISPLAY_STR[count]);
    }
  }
}

void draw() {
  background(0);      
  
  buffer.beginDraw();         // begin buffering
  buffer.noStroke();
  buffer.noFill();
  buffer.background(audio.colors.background);
  if (AUTOMODE) autoMode();   // auto change mode to audio beat
  doMode();                   // do the current mode(s)
  
  buffer.blendMode(BLEND);    // reset blend mode
  if (useKinect) {  // using the kinect?
    kinect.update(); // update the kinect
    buffer.image(kinect.buffer_image, 0, 0); // draw kinect user(s)
  }
  
  
  buffer.endDraw();           // end buffering
  wall.draw();                // draw the wall
  drawDebug();                // draw debug info
  xoff += 0.2;
}

void drawDebug() {
  if (!DEBUG_SHOW_WALL) {
    wall_image.copy(buffer.get(), 0, 0, BUFFER_WIDTH, BUFFER_HEIGHT, 0, 0, COLUMNS*2, ROWS*2);
    image(wall_image, (width / 2) - ( (COLUMNS*2) / 2) , 0);
  }
  textSize(11);
  fill(#313131);
  stroke(0);
  strokeWeight(1);
  rectMode(CORNER);
  rect(0, DEBUG_WINDOW_START, DEBUG_WINDOW_XSIZE, DEBUG_WINDOW_START + DEBUG_WINDOW_YSIZE);
  
  

  // fill text display background
  fill(#212121);
  rect(5, DEBUG_WINDOW_START + 5, 200, 210);

  fill(255);
  text("FPS: " + String.format("%.2f", frameRate), 10, DEBUG_WINDOW_START + 20);
  text("Display Mode:  " + DISPLAY_STR[DISPLAY_MODE], 10, DEBUG_WINDOW_START + 35);

  text("BPM: " + audio.BPM + "  count: " + audio.bpm_count + "  secs: " + audio.sec_count, 10, DEBUG_WINDOW_START + 65);
  text("BASS: " + audio.BASS, 10, DEBUG_WINDOW_START + 80); 
  text("MIDS: " + audio.MIDS, 70, DEBUG_WINDOW_START + 80);
  text("TREB: " + audio.TREB, 140, DEBUG_WINDOW_START + 80);
  text("dB: " + String.format("%.2f", audio.volume.dB), 10, DEBUG_WINDOW_START + 95);

  if (buffer.wattage > 3000) fill(255, 0, 0);
  text("WATTS: " + String.format("%.2f", buffer.wattage), 10, DEBUG_WINDOW_START + 125);
  text("Max: "   + String.format("%.2f", buffer.max_watts), 115, DEBUG_WINDOW_START + 125);
  fill(255);
  text("R: " + audio.RED, 10, DEBUG_WINDOW_START + 140);
  text("G: " + audio.GREEN, 50, DEBUG_WINDOW_START + 140);
  text("B: " + audio.BLUE, 90, DEBUG_WINDOW_START + 140);
  text("Clips speed: " + clips.current_speed, 10, DEBUG_WINDOW_START + 170);
  text("send time: " + wall.send_time, 10, DEBUG_WINDOW_START + 185);

  fill(#212121);
  rectMode(CORNER);
  rect(DEBUG_WINDOW_XSIZE - 150, DEBUG_WINDOW_START + 5, 145, 210);
  for (int i = 0; i < wall.teensyImages.length; i++) {
    pushMatrix();
    int y = DEBUG_WINDOW_START + 14 + (i * 16);

    String temp = "Teensy " + i;
    fill(255);
    text(temp, DEBUG_WINDOW_XSIZE - 90 - textWidth(temp) - 5, y + (i * 4) + 12);

    translate(DEBUG_WINDOW_XSIZE - 90, y + (i * 4));

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

void dispose() {
  shutdown();
  super.dispose();
}

void shutdown() {
  System.out.println("CLOSING DOWN!!!");
  buffer.beginDraw();
  buffer.background(0);
  buffer.endDraw();
  wall.display();

  kinect.close();

  // always close Minim audio classes when you are done with them
  audio.close();
  minim.stop();
  for (int i = 0; i < TEENSY_TOTAL; i++) {
    teensys[i].quit();
  }
}

void keyPressed() {

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

  r.activate(DISPLAY_MODE);
}







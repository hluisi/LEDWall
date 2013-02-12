class Modes {

  static final int TEST   = 0;
  static final int MAIN   = 1;
  static final int KRGB   = 2;
  static final int KDEPTH = 3;
  static final int KSCENE = 4;

  int current;
  int start_time, check_time;

  PFont testFont = createFont("Arial-Black", 46);
  TextOverlay text_overlay = new TextOverlay(CENTER, CENTER, testFont);

  Modes() {
    set(TEST);
  }

  void set(int c) {
    current = c;
    start_time = millis();
    check_time = 0;
  }

  void doTest() {
    int now = millis();
    check_time = now - start_time;
    if (check_time > 20000) {
      set(MAIN);
    } 
    else if (check_time > 16000) {
      showImage(smpte);
    } 
    else if (check_time > 14000) {
      showTestColor(color(255, 255, 255), "W H I T E");
    } 
    else if (check_time > 12000) {
      showTestColor(color(0, 0, 255), "B L U E");
    } 
    else if (check_time > 10000) {
      showTestColor(color(0, 255, 0), "G R E E N");
    } 
    else if (check_time > 8000) {
      showTestColor(color(255, 0, 0), "R E D");
    } 
    else {
      showImage(test);
    }
  }

  void showImage(PImage img) {
    buffer.beginDraw();
    buffer.RAW.background(0);
    buffer.RAW.image(img, 0, 0, FRAME_BUFFER_WIDTH, FRAME_BUFFER_HEIGHT);
    text_overlay.on();
    text_overlay.setColor(color(255, 255, 0));
    text_overlay.set("This is a test. For the next sixty seconds, this station will conduct a test of the Emergency Broadcast System. This is only a test.");
    text_overlay.display();
    text_overlay.off();
    buffer.endDraw();
    buffer.update();
    buffer.send();
  }

  void showTestColor(color c, String s) {
    buffer.beginDraw();
    buffer.RAW.background(c);
    text_overlay.on();
    text_overlay.setColor(color(0, 0, 0));
    text_overlay.set(s);
    text_overlay.display();
    text_overlay.off();
    buffer.endDraw();
    buffer.update();
    buffer.send();
  }

  void doMain() {
    set(KRGB);
  }

  void doKRGB() {
    kinect.update();
    PImage img = kinect.rgbImage();
    showImage(img);
  }

  void doKDEPTH() {
    kinect.update();
    PImage img = kinect.depthImage();
    showImage(img);
  }

  void doKSCENE() {
    kinect.update();
    PImage img = kinect.sceneImage();
    showImage(img);
  }

  void run() {
    switch(current) {
    case TEST:
      doTest();
      break;
    case MAIN:
      doMain();
      break;
    case KRGB:
      doKRGB();
      break;
    case KDEPTH:
      doKDEPTH();
      break;
    case KSCENE:
      doKSCENE();
      break;
    }
  }
}


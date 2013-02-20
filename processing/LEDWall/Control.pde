// PApplet parent
PApplet PA = this;


// main comtrol of the wall
class Control {

  FrameBuffers buffer;  // frame buffers
  Kinect kinect;        // kinect 
  TextOverlay text_overlay;  // text overlay 
  Mode mode;
  Sun sun;

  int check_time;

  String text = new String();

  Control() {
    buffer  = new FrameBuffers();
    PFont testFont = loadFont("Arial-Black-42.vlw");
    text_overlay = new TextOverlay(buffer.RAW, CENTER, CENTER, testFont);
    kinect  = new Kinect(PA, SimpleOpenNI.RUN_MODE_MULTI_THREADED); 
    kinect.update();
    mode = new Mode(TEST);
    sun = new Sun(buffer.RAW, 0, 0);
  }

  void doTest() {
    int now = millis();
    check_time = now - mode.start_time;
    if (check_time > 20000) {
      mode.set(MAIN);
    } 
    else if (check_time > 16000) {
      text = "This concludes this test of the Emergency Broadcast System.";
      showText = true;
      showImage(smpte);
    } 
    else if (check_time > 14000) {
      showText = false;
      showTestColor(color(255, 255, 255));
    } 
    else if (check_time > 12000) {
      showText = false;
      showTestColor(color(0, 0, 255));
    } 
    else if (check_time > 10000) {
      showText = false;
      showTestColor(color(0, 255, 0));
    } 
    else if (check_time > 8000) {
      showText = false;
      showTestColor(color(255, 0, 0));
    } 
    else {
      text = "This is a test. For the next few seconds, this station will conduct a test of the Emergency Broadcast System. This is only a test.";
      showText = true;
      showImage(smpte);
    }
  }

  void showImage(PImage img) {
    buffer.beginDraw();
    buffer.RAW.image(img, 0, 0, FRAME_BUFFER_WIDTH, FRAME_BUFFER_HEIGHT);
    if (showText) {
      text_overlay.on();
    } 
    else {
      text_overlay.off();
    }
    text_overlay.setColor(color(255, 255, 128));
    text_overlay.set(text);
    text_overlay.display();
    buffer.endDraw();
    buffer.update();
    buffer.send();
  }

  void showTestColor(color c) {
    buffer.beginDraw();
    buffer.drawBackground(c);
    if (showText) {
      text_overlay.on();
    } 
    else {
      text_overlay.off();
    }
    text_overlay.setColor(color(0, 0, 0));
    text_overlay.set(text);
    text_overlay.display();
    buffer.endDraw();
    buffer.update();
    buffer.send();
  }

  void doMain() {
    doKRGB();
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

  void doSINGLE() {
    kinect.update();
    PImage img = kinect.singleImage();
    buffer.beginDraw();
    buffer.RAW.background(0);
    sun.setLocation(kinect.user_center.x, kinect.user_center.y);
    sun.display();
    buffer.RAW.image(img,0,0);
    /*
    buffer.RAW.stroke(255);
    buffer.RAW.strokeWeight(5);
    buffer.RAW.noFill();
    buffer.RAW.rect(kinect.user_start.x,kinect.user_start.y, 
                    kinect.user_end.x - kinect.user_start.x, kinect.user_end.y - kinect.user_start.y);
    */
    buffer.endDraw();
    buffer.update();
    buffer.send();
  }

  void run() {
    switch(mode.CURRENT) {
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
    case SINGLE:
      doSINGLE();
      break;
    }
  }
}


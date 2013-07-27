/*  NOTES FOR PAUL
 
 1. Strips are setup verticaly, not horizontal, with the teensy's on the bottom of the wall.
 2. All teensy's have a layout of left->right, which is now bottom->top.
 3. Using two frame (PGraphics) buffers.  One for image creation, the other for final image processing. 
 4. The line sync for the teensys has been removed (see "SimpleDisplay.ino" for more details).
 5. I tried to simplify things as much as I could.  
 6. Please excuse my bad programming style, I'm completely self taught. 
 
 PC specs and environment is as follows:
 * Windows 8 64bit w/ 16.0GB of ram
 * Intel i5-4670K CPU @ 3.40GHz
 * Processing 2.0.1 (32bit)
 * Arduino 1.0.5
 * Teensyduino 1.15
 
 */

final int COLUMNS = 160;             // the amount of LEDs per column (x)
final int ROWS    = 80;              // the amount of LEDs per row (y)
final int TOTAL   = COLUMNS * ROWS;  // the total amount of LEDs on the wall
final boolean SHOW_COMS = true;

int DEBUG_X, DEBUG_Y;
int FRAME_TIME;
int MAX_FRAME;
int SEND_TIME;
int MAX_SEND;
int kBs;
int kBs_timer;
int kBs_tracker;
int MAX_KBS;
int simCount;
float MIN_FPS = 99999;

boolean toggleLines = false;
boolean lastState = toggleLines;
boolean simulate_10 = false;

PImage showImage;
PFont font;

DisposeHandler dh;

void setup() {

  size(COLUMNS * 3, COLUMNS * 3, P3D);
  smooth(4);

  dh = new DisposeHandler(this);

  setupBuffers();  // setup buffers
  setupMovie();    // load test movie
  setupTeensys();  // setup Teensy(s)

  showImage = createImage(frameBuffer.width*3, frameBuffer.height*3, RGB);  // create the pc image
  DEBUG_Y = showImage.height + 16;  // debug Y start
  DEBUG_X = 5;                      // debug X start
  font = loadFont("Verdana-Bold-14.vlw");  // load the font
  textFont(font);  // set the font  
  kBs_tracker = 0;      // reset kB/s tracker
  kBs_timer = millis(); // start kB/s timer
  MAX_KBS = 0;          // reset max kB/s tracker
  simCount = 10 - teensys.length;  // set the sim count
  frameRate(30);
}

void draw() {
  if (millis() - kBs_timer > 999) {
    clac_kBs();
  }
  MIN_FPS = min(frameRate, MIN_FPS);       // set the min fps
  int stime;                               // int start time
  stime = millis();                        // set the start to current millis
  drawFrame();                             // draw the frame (in fuctions tab)
  FRAME_TIME = millis() - stime;           // set the frame time
  MAX_FRAME = max(FRAME_TIME, MAX_FRAME);  // set the max frame time
  stime = millis();                        // reset start to current millis
  sendFrame();                             // send the frame to teensy's (in fuction tab)
  SEND_TIME = millis() - stime;            // set the send time
  MAX_SEND = max(SEND_TIME, MAX_SEND);     // set the max send time
  drawScreen();                            // draw the screen
}

// draws the frame buffer
void drawFrame() {
  frameBuffer.beginDraw();         // start drawing to the frame buffer
  if (toggleLines != lastState) {  // did we switch modes?
    frameBuffer.background(0);     // reset the background
    lastState = toggleLines;       // set the last state
  }
  if (toggleLines) {               // should we draw lines?
    drawMovie();                   // draw movie frame
    drawLines();                   // draw lines
  } 
  else {                         // just draw the movie
    frameBuffer.background(0);     // draw background
    drawMovie();                   // draw the movie
  }
  drawComs();
  frameBuffer.endDraw();           // close the frame buffer
}

// draws the screen
void drawScreen() {
  background(24);   // set background
  showImage.copy(frameBuffer.get(), 0, 0, frameBuffer.width, frameBuffer.height, 0, 0, showImage.width, showImage.height); // resize frame buffer
  image(showImage, 0, 0);  // add the image
  fill(220);               // set text to offwhite 
  text("FPS: " + String.format("%.2f", frameRate) + " / " + String.format("%.2f", MIN_FPS), DEBUG_X, DEBUG_Y); // FPS current and min
  //text("Watts: " + String.format("%.2f", WALL_WATTS) + " / " + String.format("%.2f", MAX_WATTS), width / 2, DEBUG_Y); // Watts current and min
  text("kB/s: " + kBs + " / " + MAX_KBS, width / 2, DEBUG_Y); // Watts current and min
  text("Send millis: " + SEND_TIME + " / " + MAX_SEND, DEBUG_X, DEBUG_Y + 16);   // total send time (current and max)
  text("Frame millis: " + FRAME_TIME + " / " + MAX_FRAME, width / 2, DEBUG_Y + 16);  // total frame processing time (current and max)
  text("------------------------  Teensy Data  ---------------------------", DEBUG_X, DEBUG_Y + 36); // spacer

  // per teensy send and processing time (current and mx)
  for (int i = 0; i < teensys.length; i++) {
    text("T" + i + " send millis: " + teensys[i].send_time + " / " + teensys[i].max_send, DEBUG_X + 5, DEBUG_Y + 4 + ((i+3) * 16)); 
    text("T" + i + " frame millis: " + teensys[i].proc_time + " / " + teensys[i].max_proc, width / 2, DEBUG_Y + 4 + ((i+3) * 16));
  }
  pushStyle();
  textAlign(CENTER);
  textSize(12);
  text("Left click adds more CPU, right reset maxs, anykey simulates 10 teensy's", width / 2, height - 5);
  popStyle();
}

void resetMaxs() {
  MIN_FPS = 99999;
  MAX_SEND = 0;
  MAX_FRAME = 0;
  MAX_WATTS = 0;
  MAX_KBS = 0;
  for (int i = 0; i < teensys.length; i++) {
    teensys[i].max_send = 0;
    teensys[i].max_proc = 0;
  }
}

// mouse controls
void mousePressed() {
  if (mouseButton == LEFT) {         // left button toggles lines
    toggleLines = !toggleLines;
  } 
  else if (mouseButton == RIGHT) { // right button resets max/min values
    resetMaxs();
  }
}

void keyPressed() {
  simulate_10 = !simulate_10; // any key simulates 10 teensy's
}

public class DisposeHandler {

  DisposeHandler(PApplet p) {
    p.registerDispose(this);
  }

  void dispose() {
    System.out.println("CLOSING DOWN!!!");
    for (int i = 0; i < teensys.length; i++) {
      teensys[i].clear();
    }

    delay(50); // wait a bit for teensys to clear
  }
}


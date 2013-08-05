/*  LEDWall LEDWall.pde - Code to control a large LED matrix wall. 
 This code is geared to our "Wall of Light" Mutant Vehicle (bike) 
 for burning man 2013
 
 Copyright (c) 2013 Hunter Luisi / hunterluisi.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

////////////////////////////////////////////////////////
// LEDWall hardware
////////////////////////////////////////////////////////
// Use below if you don't have some of the hardware needed 
// to successfully run the LED wall  
final boolean USE_MINIM   = true;  // load minim and use minim for audio reaction
final boolean USE_SOPENNI = true;  // load and use simpleOpenNi for kinect interaction
final boolean USE_TEENSYS = true; // send data to teensy's via serial


////////////////////////////////////////////////////////
// LEDWall MODES
////////////////////////////////////////////////////////
// Constants used for switching modes
final int DISPLAY_MODE_EQ      = 1;
final int DISPLAY_MODE_USERBG  = 2;
final int DISPLAY_MODE_RAINBOW = 3;
final int DISPLAY_MODE_SHAPES  = 4;
final int DISPLAY_MODE_SPIN    = 5;
final int DISPLAY_MODE_PULSAR  = 6;
final int DISPLAY_MODE_CITY    = 7;
final int DISPLAY_MODE_ATARI   = 8;
final int DISPLAY_MODE_CLIPS   = 9;
final int DISPLAY_MODE_TEST    = 10;
final int TOTAL_MODES = 10;

final String[] DISPLAY_STR = { 
  "Globals", "EQ", "Users", "Rainbow", "Shapes", "Spin", "Pulsar", "Spec", "Atari", "Movies", "Test", "Debug"
};


////////////////////////////////////////////////////////
// LEDWall defaults
////////////////////////////////////////////////////////
// Use below to set the defaults when first starting
// the LED wall  
boolean autoOn   = true;   // start in auto mode?
boolean audioOn  = true;   // start with audio reation on?
boolean aBackOn  = true;  // start with audio background on?
boolean debugOn  = true;  // show debug info on wall?
boolean kinectOn = true;  // show kinect users  
boolean wallOn   = true;   // send data to teensy's
boolean simulateOn = false; // simulate the leds on the PC screen
boolean delayOn    = false;


////////////////////////////////////////////////////////
// LEDWall timers (in milliseconds)
////////////////////////////////////////////////////////
int SEND_TIME;  // the time it takes to send the data to the teensy's
int MAX_SEND;
int TBUFFER_TIME; // the time it takes to update the teensy buffer
int MAX_TBUFFER;
int MODE_TIME;  // the time it takes to do the current mode
int MAX_MODE;
int SIMULATE_TIME;  // the time it takes to simulate the wall or display it's image (in non sumilate mode)
int MAX_SIMULATE;
int KINECT_TIME;
int MAX_KINECT;
int MAP_TIME;
int MAX_MAP;
int AUDIO_TIME;
int MAX_AUDIO;
int DEBUG_TIME; // the time it takes to draw the debug info
int MAX_DEBUG;
int CP5_TIME;
int MAX_CP5;

int MAX_BRIGHTNESS = 192;  // starting brightness of the wall

int DISPLAY_MODE = 2;          // starting mode
int LAST_MODE    = 0;  // start on the right tab
float xoff = 0.0, yoff = 0.0, zoff = 0.0;              // used for perlin noise
float noiseInc = 0.2;
int IMAGE_MULTI = 3;           // how much should we blowup the image 
int PIXEL_SIZE = 3;


// images... needs it's own mode (backgrounds?)
PImage smpte, test;

// exit handler
DisposeHandler dh;

void setup() {

  size(WINDOW_XSIZE, WINDOW_YSIZE, P3D);
  smooth(4);


  //textFont(sFont);

  noStroke();

  dh = new DisposeHandler(this);

  smpte = loadImage("smpte_640x320.png");
  test  = loadImage("test_640x320.png");

  setupUtils();
  setupGamma();

  setupBuffer();

  if (USE_MINIM) setupMinim();
  else audioOn = false;

  if (USE_SOPENNI) setupKinect();
  else kinectOn = false;

  setupControl();

  setupRainbow();
  setupEQ();

  setupCircles();  // must come before shapes
  setupShapes();
  setupAtari();
  setupClips();

  if (USE_TEENSYS) setupTeensys();
  else delayOn = true;

  setupWall();

  // must be last

  //frameRate(60);

  frame.setTitle("Wall of Light");

  hint(DISABLE_DEPTH_MASK);
  hint(DISABLE_DEPTH_TEST);
  hint(DISABLE_DEPTH_SORT);
  //hint(DISABLE_STROKE_PERSPECTIVE);
  //hint(DISABLE_TEXTURE_MIPMAPS);
}

void autoMode() {
  if ( audio.isOnMode() ) {
    float test = random(1);
    if (test > 0.9) {
      int count = round( random(2, TOTAL_MODES - 1) );
      DISPLAY_MODE = count;
      //r.activate(count);
    }
  }
}

void draw() {
  background(0);

  buffer.beginDraw();         // begin buffering
  buffer.pushStyle();
  buffer.noStroke();
  buffer.noFill();

  if (aBackOn) buffer.background(audio.colors.background); 
  else buffer.background(0);
  //buffer.background(0);

  if (autoOn) autoMode();   // auto change mode to audio beat

  doMode();                   // do the current mode(s)

  int stime;

  if (kinectOn) {  // using the kinect?
    KINECT_TIME = 0;
    stime = millis();
    kinect.draw();
    KINECT_TIME = millis() - stime;
    MAX_KINECT = max(MAX_KINECT, KINECT_TIME);
  }

  if (debugOn) drawOnScreenDebug();

  buffer.popStyle();
  buffer.endDraw();           // end buffering
  wall.draw();                // draw the wall

  DEBUG_TIME = 0;
  stime = millis();
  if (!simulateOn) drawDebug();                // draw debug info
  DEBUG_TIME = millis() - stime;
  MAX_DEBUG = max(MAX_DEBUG, DEBUG_TIME);

  CP5_TIME = 0;
  stime = millis();
  drawControlBack();
  cp5.draw();
  CP5_TIME = millis() - stime;
  MAX_CP5 = max(MAX_CP5, CP5_TIME);

  updateNoise(); // update noise offsets
}

void drawOnScreenDebug() {
  buffer.textFont(mFont);
  buffer.textAlign(CENTER, CENTER);
  buffer.fill(255);
  buffer.text(nf(frameRate, 2, 2), 20, ROWS - 6);
  if (audioOn)  {
    buffer.text(audio.BPM, 80, 74);
    /*
    buffer.rectMode(CENTER);
    buffer.noStroke();
    buffer.fill(0);
    buffer.rect(80,40,84,24);
    int r = round(red(audio.colors.users[0]));
    int g = round(green(audio.colors.users[0]));
    int b = round(blue(audio.colors.users[0]));
    buffer.fill(color(r,0,0));
    buffer.rect(53,34, 28, 10);
    buffer.fill(color(0,g,0));
    buffer.rect(80,34, 28, 10);
    buffer.fill(color(0,0,b));
    buffer.rect(107,34, 28, 10);
    
    buffer.fill(255);
    buffer.text(nf(r,3) + "/" + nf(g,3) + "/" + nf(b,3), 80, 46);
    */
  }
    
  if (kinectOn) buffer.text(kinect.users.length, COLUMNS - 5, ROWS - 6);
  if (USE_TEENSYS) {
    buffer.textFont(xsFont);
    buffer.fill(255);
    buffer.stroke(255);
    buffer.strokeWeight(0.5);
    for (int i = 0; i < teensys.length; i++) {
      buffer.text(teensys[i].comNumber, 8 + (16*i), 5);
      buffer.text(nf(teensys[i].sendTime,2), 8 + (16*i), 14);
      if (i != 9) buffer.line(16 + (16*i), 2, 16 + (16*i), 16);
    }
    //buffer.line(0, 20, 160, 20);
  }
}

void drawControlBack() {
  rectMode(CORNER);
  // globals tab
  fill( color(40, 3, 6) );
  noStroke();
  //strokeWeight(1);
  rect(0, DEBUG_WINDOW_START, TAB_START, DEBUG_WINDOW_START + DEBUG_WINDOW_YSIZE);

  //noStroke();

  // other tabs
  fill( color(16, 1, 2) );
  rect(TAB_START, DEBUG_WINDOW_START, WINDOW_XSIZE - TAB_START, DEBUG_WINDOW_START + DEBUG_WINDOW_YSIZE);
}

void updateNoise() {
  xoff = xoff + noiseInc;
  if ( (frameCount % 2) == 0) yoff = yoff + 0.03;
  if ( (frameCount % 3) == 0) zoff = zoff + 0.02;
}


void doMode() {

  int stime = millis();
  if (DISPLAY_MODE == DISPLAY_MODE_TEST)    doTest();
  if (DISPLAY_MODE == DISPLAY_MODE_EQ)      doEQ();
  if (DISPLAY_MODE == DISPLAY_MODE_USERBG)  doUserBg();
  if (DISPLAY_MODE == DISPLAY_MODE_SPIN)    doCircles();
  if (DISPLAY_MODE == DISPLAY_MODE_PULSAR)  doPulsar();
  if (DISPLAY_MODE == DISPLAY_MODE_CITY)    doCity();
  if (DISPLAY_MODE == DISPLAY_MODE_RAINBOW) doRainbow();
  if (DISPLAY_MODE == DISPLAY_MODE_ATARI)   doAtari();
  if (DISPLAY_MODE == DISPLAY_MODE_CLIPS)   doClips();
  if (DISPLAY_MODE == DISPLAY_MODE_SHAPES)  doShapes();
  MODE_TIME = millis() - stime;
  MAX_MODE = max(MAX_MODE, MODE_TIME);

  if (LAST_MODE != DISPLAY_MODE) {
    cp5.getTab(DISPLAY_STR[DISPLAY_MODE]).bringToFront();
    LAST_MODE = DISPLAY_MODE;
  }
}

void resetMaxs() {
  MAX_SEND = 0;
  MAX_TBUFFER = 0;
  MAX_MODE = 0;
  MAX_SIMULATE = 0;
  MAX_KINECT = 0;
  MAX_MAP = 0;
  MAX_AUDIO = 0;
  MAX_DEBUG = 0;
  MAX_CP5 = 0;
  for (int i = 0; i < teensys.length; i++) {
    teensys[i].maxSend = 0;
  }
}

void mousePressed() {
  if (mouseButton == LEFT) {         // left button toggles lines
    //delayOn = !delayOn;
  } 
  else if (mouseButton == RIGHT) { // right button resets max/min values
    resetMaxs();
  }
}

public class DisposeHandler {

  DisposeHandler(PApplet p) {
    p.registerDispose(this);
  }

  void dispose() {
    System.out.println("CLOSING DOWN!!!");
    if (USE_TEENSYS) {
      for (int i = 0; i < teensys.length; i++) {
        teensys[i].clear();
      }
      delay(50); // wait a bit for teensys to clear
    }

    if (USE_SOPENNI) kinect.close();

    // always close Minim audio classes when you are done with them
    if (USE_MINIM) {
      audio.close();
      minim.stop();
    }
  }
}


import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import SimpleOpenNI.*; 
import java.util.Map; 
import ddf.minim.*; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import geomerative.*; 
import processing.video.*; 
import processing.serial.*; 
import java.util.Arrays; 
import java.util.Comparator; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class LEDWall extends PApplet {

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
boolean debugOn  = false;  // show debug info on wall?
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

int DISPLAY_MODE = 1;          // starting mode
int LAST_MODE    = 0;  // start on the right tab
float xoff = 0.0f, yoff = 0.0f, zoff = 0.0f;              // used for perlin noise
float noiseInc = 0.2f;
int IMAGE_MULTI = 3;           // how much should we blowup the image 
int PIXEL_SIZE = 3;


// images... needs it's own mode (backgrounds?)
PImage smpte, test;

// exit handler
DisposeHandler dh;

public void setup() {

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

  frameRate(60);

  frame.setTitle("Wall of Light");

  hint(DISABLE_DEPTH_MASK);
  hint(DISABLE_DEPTH_TEST);
  hint(DISABLE_DEPTH_SORT);
  //hint(DISABLE_STROKE_PERSPECTIVE);
  //hint(DISABLE_TEXTURE_MIPMAPS);
}

public void autoMode() {
  if ( audio.isOnMode() ) {
    float test = random(1);
    if (test < 0.15f) {
      int count = round( random(1, TOTAL_MODES - 1) );
      DISPLAY_MODE = count;
      //r.activate(count);
    }
  }
}

public void draw() {
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

public void drawOnScreenDebug() {
  buffer.textAlign(CENTER, CENTER);
  buffer.fill(255);
  buffer.text(nf(frameRate, 2, 2), 20, ROWS - 7);
  if (audioOn)  buffer.text(audio.BPM, COLUMNS / 2, ROWS - 7);
  if (kinectOn) buffer.text(kinect.users.length, COLUMNS - 5, ROWS - 7);
  if (USE_TEENSYS) {
    //buffer.textSize(10);
    //buffer.textFont(sFont);
    //buffer.textAlign(LEFT,BASELINE);
    for (int i = 0; i < teensys.length; i++) {
      if (teensys[i].threadData) buffer.fill(255,255,0);
      else buffer.fill(255);
      buffer.text(nf(teensys[i].sendTime,2), 8 + (16*i), 10);
    }
  }
}

public void drawControlBack() {
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

public void updateNoise() {
  xoff = xoff + noiseInc;
  if ( (frameCount % 2) == 0) yoff = yoff + noiseInc;
  if ( (frameCount % 3) == 0) zoff = zoff + noiseInc;
}


public void doMode() {

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

public void resetMaxs() {
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

public void mousePressed() {
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

  public void dispose() {
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

// move to LEDWall

PGraphics buffer;

public void setupBuffer() {
  buffer = createGraphics(COLUMNS, ROWS, P3D);  
  buffer.smooth(8);
  //buffer.hint(DISABLE_DEPTH_TEST);
  //buffer.hint(DISABLE_DEPTH_MASK);
  buffer.beginDraw();
  buffer.background(0);
  buffer.endDraw();
  buffer.loadPixels();
  println("BUFFER SETUP ...");
}


// STILL A TON TO ADD



ControlP5 cp5;
final int TAB_START  = 200;
final int TAB_HEIGHT = 25;
int TAB_MAX_WIDTH;
int TAB_WIDTH;
PFont tabFont; // tab font   (12)
PFont sFont;   // small font (11)
PFont mFont;  // medium font (14)
PFont lFont; // large font   (20)
PFont xFont; // x-large font (40)

public void setupControl() {
  tabFont = loadFont("Arial-BoldMT-12.vlw");
  sFont   = loadFont("Arial-BoldMT-11.vlw");
  mFont   = loadFont("Arial-BoldMT-14.vlw");
  lFont   = loadFont("Arial-BoldMT-20.vlw");
  xFont   = loadFont("Arial-BoldMT-40.vlw");
  
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  cp5.window().setPositionOfTabs(0, DEBUG_WINDOW_START);
  cp5.setColor(ControlP5.RED);
  
  TAB_MAX_WIDTH = WINDOW_XSIZE - TAB_START - 40;
  TAB_WIDTH = TAB_MAX_WIDTH / TOTAL_MODES;

  // create and setup the tabs
  setTab("default", DISPLAY_STR[0], 0, TAB_START - 5, TAB_HEIGHT, tabFont, false, true);

  for (int i = 1; i <= TOTAL_MODES; i++) {
    String name = DISPLAY_STR[i];
    cp5.addTab(name);
    setTab(name, name, i, TAB_WIDTH, TAB_HEIGHT, tabFont, true, false);
  }

  int b = MAX_BRIGHTNESS;
  
  // controler name, min, max, value, x, y, width, height, label, handle size, text size, type, move to tab
  createSlider("doSliderBrightness", 0, 255, b, TAB_START - 60, DEBUG_WINDOW_START + 35, 50, DEBUG_WINDOW_YSIZE - 60, "Brightness", 10, tabFont, Slider.FLEXIBLE, "default");

  createToggle("doToggleAutoOn", "Auto",  10, DEBUG_WINDOW_START + 35, 30, 30, sFont, ControlP5.DEFAULT, autoOn, "default");
  if (USE_MINIM) createToggle("doToggleAudioOn", "Audio",  50, DEBUG_WINDOW_START + 35, 30, 30, sFont, ControlP5.DEFAULT, audioOn, "default");
  if (USE_SOPENNI) createToggle("doToggleKinectOn", "Kinect",  90, DEBUG_WINDOW_START + 35, 30, 30, sFont, ControlP5.DEFAULT, kinectOn, "default");
  
  createToggle("doToggleScreenDebug", "Debug", 10, DEBUG_WINDOW_START + 95, 30, 30, sFont, ControlP5.DEFAULT, debugOn, "default");
  if (USE_MINIM) createToggle("doToggleAudioBackOn","Back", 50, DEBUG_WINDOW_START + 95, 30, 30, sFont, ControlP5.DEFAULT, aBackOn, "default");
  
  if (USE_SOPENNI) createToggle("doToggleUserMap", "User",  90, DEBUG_WINDOW_START + 95, 30, 30, sFont, ControlP5.DEFAULT, kinect.mapUser, "default");
  
  createToggle("doToggleSimulate", "Simulate Wall", 10, DEBUG_WINDOW_START + 155, 110, 40, tabFont, ControlP5.DEFAULT, simulateOn, "default");
}

public Textfield createTextfield(String cN, String lN, int x, int y, int w, int h, String value, PFont f, int ty, String m2t) {
  Textfield tf = cp5.addTextfield(cN, x, y, w, h);
  
  tf.setPosition(x, y);
  tf.setText(value);
  tf.setSize(w, h);                                                  // set size to 50x50
  tf.setInputFilter(ty);
  tf.moveTo(m2t);
  tf.setAutoClear(false);
  tf.captionLabel().setFont(f);
  tf.valueLabel().setFont(f);
  tf.captionLabel().setText(lN);    
  tf.captionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE); // set alignment
  tf.valueLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  tf.setColorBackground(color(20,0,0));
  return tf;
}

// create a Slider controller
// controler name, min, max, value, x, y, width, height, label, handle size, text size, type, move to tab
public Slider createSlider(String cN, float s, float e, float v, int x, int y, int w, int h, String lN, int hs, PFont tf, int ty, String m2t) {
  Slider sc = cp5.addSlider(cN, s, e, v, x, y, w, h);
  
  sc.getValueLabel().setFont(tf);
  sc.getCaptionLabel().setFont(tf);
  sc.setLabel(lN);
  sc.setHandleSize(hs);
  sc.setSliderMode(ty);
  sc.moveTo(m2t);
  sc.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(5);
  sc.getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(5);
  
  sc.captionLabel().toUpperCase(false);
  return sc;
}

public Toggle createToggle(String controllerName, String textName, int x, int y, int w, int h, PFont tf, int tm, boolean value, String m2t) {
  Toggle tc = cp5.addToggle(controllerName);
  tc.setPosition(x, y);
  tc.setSize(w, h);                                                  // set size to 50x50
  tc.captionLabel().setFont(tf);
  tc.setMode(tm);
  tc.setValue(value);
  tc.captionLabel().toUpperCase(false);
  tc.captionLabel().setText(textName);                                 // set name
  tc.captionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE); // set alignment
  tc.moveTo(m2t);
  return tc;
}

public void setTab(String cName, String tabName, int ID, int w, int h, PFont tf, boolean activate, boolean alwaysActive) {
  Tab tab = cp5.getTab(cName);            // get tab
  tab.captionLabel().setFont(tf);         // set tab font
  tab.setWidth(w);                        // set tab width
  tab.setHeight(h);                       // set tab height
  tab.setId(ID);                          // set tabs id
  tab.setAlwaysActive(alwaysActive);      // set tab as always active
  tab.activateEvent(activate);            // set tab as active
  tab.captionLabel().toUpperCase(false);  // allow lowercase text
  tab.setLabel(tabName);                  // set tab text
}

public void doSliderBrightness(int v) {
  MAX_BRIGHTNESS = v;
}

public void controlEvent(ControlEvent theEvent) {
  // tab?
  if ( theEvent.isTab() ) {
    int ID = theEvent.getTab().getId();
    if (ID > 0) DISPLAY_MODE = ID;
  }
}

// turn on auto mode
public void doToggleAutoOn(boolean b) {
  autoOn = b;
}

// turn on debug
public void doToggleScreenDebug(boolean b) {
  debugOn = b;
}

// turn on audio
public void doToggleAudioOn(boolean b) {
  audioOn = b;
}

// turn on audio background
public void doToggleAudioBackOn(boolean b) {
  aBackOn = b;
}

// turn on kinect
public void doToggleKinectOn(boolean b) {
  kinectOn = b;
}

// turn on user depth mapping
public void doToggleUserMap(boolean b) {
  kinect.mapUser = b;
}

// simulate wall
public void doToggleSimulate(boolean b) {
  simulateOn = b;
}

// ALWAYS NEEDS A REWRITE

public void debugBack() {
  fill( 24 );
  rect(480, 0, WINDOW_XSIZE - 480, WINDOW_YSIZE - DEBUG_WINDOW_YSIZE);
  fill( 16 );     // background for top area
  rect(0, 240, WINDOW_XSIZE - 480, WINDOW_YSIZE - DEBUG_WINDOW_YSIZE - 240);
}

public void debugWallImage() {
  image(buffer, 0, 0, 480, 240);
}

public void debugKinectImages() {
  textFont(lFont);
  for (int i = 0; i < kinect.users.length && i < 12; i++) {
    image(kinect.users[i].img, 0, 240, 480, 240);
    textAlign(CENTER, CENTER);
    fill(255);
    text(kinect.users[i].i, (kinect.users[i].x*3), (kinect.users[i].y*3) + 240 );
    textAlign(LEFT, BASELINE);
    if (i < 12) text(nf(kinect.users[i].i, 2) + ": " + 
      nf(kinect.users[i].x, 3, 1) + "," +
      nf(kinect.users[i].y, 3, 1) + "," +
      nf(kinect.users[i].z, 3, 1), 490, 260 + (20 * i));
  }
}

public void debugTeensyImages() {
  int tx =  520;
  int ty, v, m;
  fill(255);
  textFont(mFont);
  textAlign(LEFT, BASELINE);
  for (int i =0; i < wall.teensyImages.length; i++) {
    ty = 10 + (22 * i);
    text("T:" + i, tx - 25, ty + 12);
    image(wall.teensyImages[i], tx, ty);
    if (USE_TEENSYS) {
      v = teensys[i].sendTime;
      m = teensys[i].maxSend;
    } 
    else {
      v = SIM_DELAY;
      m = SIM_DELAY;
    }
    text(nf(v, 3) + " / " + nf(m, 3), tx + 80 + 10, ty + 12);
  }
}

public void debugTimers() {
  textFont(lFont);
  textAlign(RIGHT, BASELINE);
  fill(255);
  text("FPS: " + nf(frameRate, 2, 1), 950, 20);
  if (audioOn) {
    text("BPM: " + nf(audio.BPM, 3), 950, 60);
    text("Vol: " + nf(audio.volume.value, 3), 950, 80);
  }
  
  text("Mode: " + nf(MODE_TIME,2) + "/" + nf(MAX_MODE,2), 950, 120);
  text("Audio: " + nf(AUDIO_TIME,2) + "/" + nf(MAX_AUDIO,2), 950, 140);
  text("Kinect: " + nf(KINECT_TIME,2) + "/" + nf(MAX_KINECT,2), 950, 160);
  text("User Map: " + nf(MAP_TIME,2) + "/" + nf(MAX_MAP,2), 950, 180);
  text("TBuffer: " + nf(TBUFFER_TIME,2) + "/" + nf(MAX_TBUFFER,2), 950, 200);
  text("Send: " + nf(SEND_TIME,2) + "/" + nf(MAX_SEND,2), 950, 220);
  
  text("Debug: " + nf(DEBUG_TIME,2) + "/" + nf(MAX_DEBUG,2), 950, 260);
  text("CP5: " + nf(CP5_TIME,2) + "/" + nf(MAX_CP5,2), 950, 280);
  text("Simulate: " + nf(SIMULATE_TIME,2) + "/" + nf(MAX_SIMULATE,2), 950, 300);
  
  //if (kinectOn) {
  //  text("USERS: " + nf(kinect.users.length,2), 950, 240);
  //}
}

public void drawDebug() {
  pushStyle();         // push the style
  noStroke();          // turn off stroke
  debugBack();         // draw background
  debugWallImage();    // draw wall image
  debugKinectImages(); // draw kinect images

    debugTimers();
  debugTeensyImages(); // draw teensy images

  /*
  fill(cp5.getColor().getCaptionLabel());
   //text("Display Mode: " + DISPLAY_STR[DISPLAY_MODE], DEBUG_TEXT_X, DEBUG_WINDOW_START + 20);
   text("FPS: " + String.format("%.2f", frameRate), DEBUG_TEXT_X, DEBUG_WINDOW_START + 50);
   
   if (audioOn) {
   text("BASS: " + audio.bass.value, DEBUG_TEXT_X, DEBUG_WINDOW_START + 65); 
   text("MIDS: " + audio.mids.value, DEBUG_TEXT_X + 60, DEBUG_WINDOW_START + 65);
   text("TREB: " + audio.treb.value, DEBUG_TEXT_X + 120, DEBUG_WINDOW_START + 65);
   text("BPM: " + audio.BPM + "  count: " + audio.bpm_count + "  secs: " + audio.sec_count, DEBUG_TEXT_X, DEBUG_WINDOW_START + 80);
   text("dB: " + String.format("%.2f", audio.volume.dB), DEBUG_TEXT_X, DEBUG_WINDOW_START + 95);
   }
   
   if (wallOn) {
   text("WATTS: " + String.format("%.2f", WALL_WATTS), DEBUG_TEXT_X, DEBUG_WINDOW_START + 125);
   text("Max: "   + String.format("%.2f", MAX_WATTS), DEBUG_TEXT_X + 100, DEBUG_WINDOW_START + 125);
   }
   */

  popStyle();
}

// DONE WITH REWRITE, STILL NEEDS A FEW COMMENTS

  // import simple open ni
   // import hash map

final int KINECT_WIDTH  = 640;  // the x size of the kinect's depth image
final int KINECT_HEIGHT = 320;  // the y size of the kinect's depth image 
// the y is really 480, but we need a 2:1 format of the image

PImage transparent;  // a transparent image used to reset the user images       
Kinect kinect;     // the kinect object

volatile HashMap<Integer, User> userHash; // user hash map

////////////////////////////////////////////////////////
// Kinect setup function - setupKinect
////////////////////////////////////////////////////////
// setup the kinect
public void setupKinect() {
  println("SETUP - setting up KINECT...");
  transparent = createImage(KINECT_WIDTH, KINECT_HEIGHT, ARGB); // create the transparent image
  transparent.loadPixels();                                     // load it's pixels
  for (int i = 0; i < transparent.pixels.length; i++) {         // loop through the image pixels
    transparent.pixels[i] = color(0, 0, 0, 0);                  // and set them all to transparent
  }
  transparent.updatePixels();                                   // finalize (update) the image pixels
  SimpleOpenNI.start();                      // tell simpleOpenNI to start
  kinect  = new Kinect(this);                // create the kinect object
  kinect.context.update();                   // updating the kinect now helps things to load faster 
  userHash = new HashMap<Integer, User>();   // init the user hash table
}

////////////////////////////////////////////////////////
// Kinect object class - Kinect
////////////////////////////////////////////////////////
// This class sets up and creates the main kinect object
class Kinect {
  SimpleOpenNI context;         // kinect context
  User[] users;                 // an array of users (this class tracks user locations and creates user images)
  int[] depthMap;               // depth image used for mapping user depths
  int[] userMap;                // an array of user numbers on a per pixel level
  boolean mapUser = false;      // map the user color to the depth image

    Kinect(PApplet parent) {
    context = new SimpleOpenNI(parent, SimpleOpenNI.RUN_MODE_MULTI_THREADED);  // init the kinect
    //context = new SimpleOpenNI(parent, SimpleOpenNI.RUN_MODE_SINGLE_THREADED);  // init the kinect
    defaults();                     // setup defaults
  }

  private void defaults() {

    // enable depth
    if (context.enableDepth() == false) {  // enable the depth image
      println("KINECT - ERROR opening the depthMap! Is the kinect connected?!?!");
      exit();
      return;
    }

    //context.enableRGB();

    // enable user
    if (context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL) == false) {  // enable user tracking
      println("KINECT - ERROR opening the userMap! Is the kinect connected?!?!");
      exit();
      return;
    }

    //alternativeViewPointDepthToImage();  // fit the depth image to the kinect's RGB image
    context.setMirror(true);             // turn on mirroring
  }

  public synchronized void updateUsersArray() {
    for (Map.Entry u : userHash.entrySet() ) {  // loop through the user hash table
      User thisUser = userHash.get( u.getKey() );
      if ( thisUser != null ) {
        if ( thisUser.isActive() ) {
          thisUser.update();
        } 
        else {
          //thisUser.resetPixels();
          thisUser.isSet = false;
        }
      }
    }
    users = userHash.values().toArray( new User [userHash.size()] );  // set the users array
    Arrays.sort(users, UserByZ);               // sort the users array by z distance (UserByZ comparator found in utils)
  }

  public void updateUsersImage() {
    if (mapUser) depthMap = context.depthMap();
    userMap  = context.getUsersPixels(SimpleOpenNI.USERS_ALL);  // get the userMap (it's n 2D array of user numbers for each pixel)

    // loop through the users and set their image pixels
    for (int i = 0; i < KINECT_WIDTH * KINECT_HEIGHT; i++) {          // loop through the part of the user map 
      User thisUser = userHash.get(userMap[i]);                       // get the current user
      if ( thisUser != null && thisUser.isActive() && thisUser.onScreen() ) {                // do we have a user?
        if (mapUser) thisUser.setPixel(i, depthMap[i]); 
        else thisUser.setPixel(i, 0);         // set user's pixel using the user's own color
      }
    }
  }


  public void update() {
    context.update();    // update the kinect
    updateUsersArray();  // update the user array
    updateUsersImage();  // update user images
  }

  public void drawImages() {
    buffer.pushStyle();
    for (int i = 0; i < users.length; i++) {
      if ( users[i].onScreen() ) {
        users[i].updatePixels(mapUser);
        buffer.image(users[i].img, 0, 0);
        buffer.fill(255);
        if (debugOn) buffer.text(users[i].i, users[i].x, users[i].y);
      }
    }
    buffer.fill(255);
    if (debugOn) {
      buffer.textAlign(CENTER, CENTER);
      buffer.text(users.length, COLUMNS - 5, ROWS - 7);
    }
    buffer.popStyle();
  }

  public void draw() {
    update();
    drawImages();
  }

  public void close() {
    context.close();
  }
}

class User {
  float x = 0.0f;
  float y = 0.0f;
  float z = 0.0f;
  PVector realWorld;
  PVector projWorld;
  PVector headJoint;
  int i;
  boolean active;
  boolean skeleton;
  boolean isSet;
  PImage img, userImage;
  int[] depthMap;
  int depthMAX, depthMIN;
  int colorIndex;
  int c;

  User(int i) {
    this.i = i;
    setup();
  }

  public void setup() {
    userImage = createImage(KINECT_WIDTH, KINECT_HEIGHT, ARGB);
    userImage.loadPixels();
    arrayCopy(transparent.pixels, userImage.pixels);
    userImage.updatePixels();
    img = createImage(COLUMNS, ROWS, ARGB);
    img.loadPixels();
    colorIndex = i % 12;
    depthMap = new int [userImage.pixels.length];
    depthMAX = 0;
    depthMIN = 9000;
    realWorld = new PVector();
    projWorld = new PVector();
    headJoint = new PVector();
  }

  public void resetPixels() {
    arrayCopy(transparent.pixels, userImage.pixels);
    userImage.updatePixels();
    depthMAX = 0;
    depthMIN = 9000;
  }

  public void setPixel(int index, int depth) {
    if (index > 0 && index < userImage.pixels.length) {
      userImage.pixels[index] = c;
      depthMap[index] = depth;
      depthMAX = max(depth, depthMAX);
      depthMIN = min(depth, depthMIN);
    }
  }

  public void copyImage() {
    userImage.updatePixels();
    img.copy(userImage, 0, 0, KINECT_WIDTH, KINECT_HEIGHT, 0, 0, COLUMNS, ROWS);
  }
  
  public void updatePixels(boolean mapDepth) {
    if (mapDepth) {
      MAP_TIME = 0;
      int stime = millis();
      pushStyle();
      colorMode(HSB, 360, 1.0f, 1.0f);
      int tc = color(hue(c), 1.0f, 1.0f);
      popStyle();
      int tr = (tc >> 16) & 0xFF;  // get the red value of the user's color
      int tg = (tc >> 8) & 0xFF;   // get the green value of the user's color
      int tb =  tc & 0xFF;         // get the blue value of the user's color
      
      for (int i = 0; i < userImage.pixels.length; i++) {
        if (userImage.pixels[i] == 0) continue;
        float r = map(depthMap[i], depthMAX, depthMIN, 16, tr);  // map brightness from depth image to the red of the user color
        float g = map(depthMap[i], depthMAX, depthMIN, 16, tg);  // map brightness from depth image to the green of the user color
        float b = map(depthMap[i], depthMAX, depthMIN, 16, tb);  // map brightness from depth image to the blue of the user color
        userImage.pixels[i] = color(r,g,b);
      }
      MAP_TIME = millis() - stime;
      MAX_MAP = max(MAX_MAP, MAP_TIME);
    }
    copyImage();
  }

  public boolean onScreen() {
    return isSet;
  }

  public boolean isActive() {
    return active;
  }

  public void setActive(boolean a) {
    active = a;
  }

  public boolean hasSkeleton() {
    return skeleton;
  }

  public void setSkeleton(boolean a) {
    skeleton = a;
  }

  public void setIndex(int i) {
    this.i = i;
  }

  public int index() {
    return i;
  }

  public void setColor() {
    c = audio.colors.get(colorIndex);
  }

  public void updateCoM(PVector projected) {
    // set the user location based on the wall size
    x = projected.x / 4;  // div by 4 because the wall is 4 times 
    y = projected.y / 4;  // smaller then the kinect user image
    z = projected.z / 4;    // bring things closer.  May want to remove this
    
    // check make sure we have real numbers
    if ( x != x || y != y || z != z) {    // checking for NaN
      isSet = false;  // got NaN so we're not set
    } else { // all is good
      resetPixels();
      setColor();
      isSet = true;
    }
  }

  public void update() {
    

    if ( kinect.context.getCoM(i, realWorld) ) {        // try to set center of mass real world location
      // let's try to get the head joint, which is better then the CoM
      
      float confidence = kinect.context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_HEAD, headJoint);
      if (confidence < 0.5f) {
        // not very good, so lets use the CoM
        skeleton = false; // bad skeleton, bad!
        kinect.context.convertRealWorldToProjective(realWorld, projWorld);  // convert real world to projected world
        updateCoM(projWorld);
      } 
      else { 
        skeleton = true; // good skeley, good boy!
        kinect.context.convertRealWorldToProjective(headJoint, projWorld);  // convert real world to projected world
        updateCoM(projWorld);
      }
      
    } 
    else {
      isSet = false;    // couldn't get CoM so nothing is set.
    }
  }
}


////////////////////////////////////////////////////////
// Kinect User Callback - onNewUser
////////////////////////////////////////////////////////
// called when a new user is found
public void onNewUser(int userId) {
  println("KINECT - onNewUser - found new user: " + userId);
  println(" - starting pose detection");

  kinect.context.requestCalibrationSkeleton(userId, true); // try to auto calibrate user skeleton 
  userHash.put( userId, new User(userId) );                // create new user object and add it to the user hash map
  userHash.get(userId).setActive(true);                    // set the user object as active (so it will be updated)
  userHash.get(userId).update();                           // update the user
}

////////////////////////////////////////////////////////
// Kinect User Callback - onLostUser
////////////////////////////////////////////////////////
// called when user can't be found for 10 seconds. The file
// may be found (PrimeSense\SensorKinect\Data\GlobalDefaultsKinect.ini)
public void onLostUser(int userId) {
  println("KINECT - onLostUser - lost user: " + userId);
  userHash.get(userId).setActive(false);    // set user to non-active status (won't be updated)
  userHash.remove(userId);                  // remove user from the hash table
}

////////////////////////////////////////////////////////
// Kinect User Callback - onExitUser
////////////////////////////////////////////////////////
// called when user leaves the tracking area
public void onExitUser(int userId) {
  println("KINECT - onExitUser - user " + userId + " has exited.");
  userHash.get(userId).setActive(false);    // set user to non-active status (won't be updated)

  // save for now, may want to do pose detection
  //println(" - stopping pose detection");
  //kinect.stopPoseDetection(userId);
}

////////////////////////////////////////////////////////
// Kinect User Callback - onReEnterUser
////////////////////////////////////////////////////////
// called when the user re-enter's the tacking area
public void onReEnterUser(int userId) {
  println("KINECT - onReEnterUser - user " + userId + " has come back.");
  println(" - starting pose detection");
  kinect.context.requestCalibrationSkeleton(userId, true);  // try to auto calibrate user skeleton again
  userHash.get(userId).setActive(true);                     // set to active again (so it will be updated)
}

////////////////////////////////////////////////////////
// Kinect User Callback - onStartCalibration
////////////////////////////////////////////////////////
// called when OpenNi starts the user's skeleton calibration process.
// This can be done from onStartPose to tell OpenNI that the user
// has started a calibration pose, or automaticly by adding true to the
// requestCalibrationSkeleton(userId, true) method.  
public void onStartCalibration(int userId) {
  println("KINECT - onStartCalibration - starting calibration on user: " + userId);
}

////////////////////////////////////////////////////////
// Kinect User Callback - onEndCalibration
////////////////////////////////////////////////////////
// called when OpenNi has ended the skeleton calibration process. 
// it's successfull or it wasn't and you can try using pose detection
// calibrate the skeleton.   
public void onEndCalibration(int userId, boolean successfull) {
  if (successfull) {
    println("KINECT - onEndCalibration - calibration for user " + userId + " was successfull!");
    kinect.context.startTrackingSkeleton(userId); // start tracking skeleton
  } 
  else {
    println("KINECT - onEndCalibration - calibration for user " + userId + " has failed!!!");

    // try standard calibration pose, but it will keep trying util you
    // tell it to stop via the stopPoseDetection(userId) method. 
    //println(" - Trying pose detection");
    //kinect.startPoseDetection("Psi", userId);
  }
}

////////////////////////////////////////////////////////
// Kinect User Callback - onStartPose
////////////////////////////////////////////////////////
// called when OpenNi thinks its found the start of a pose called from
// the startPoseDetection method. You can stop there or start looking
// for the end of the pose, etc...
public void onStartPose(String pose, int userId) {
  println("KINECT - onStartPose - userId: " + userId + ", pose: " + pose);

  if (pose.equals("Psi") == true) {
    println(" - stoping 'Psi' pose detection");
    kinect.context.stopPoseDetection(userId); 
    kinect.context.requestCalibrationSkeleton(userId, true);
  }
}

////////////////////////////////////////////////////////
// Kinect User Callback - onStartPose
////////////////////////////////////////////////////////
// found the end of a pose. Don't forget to stop the pose detection!
public void onEndPose(String pose, int userId) {
  println("onEndPose - userId: " + userId + ", pose: " + pose);
  kinect.context.stopPoseDetection(userId);
}

// NEED TO ADD COMMENTS

// USING BETA VERSION OF MINIM!!





Minim minim;
AverageListener audio;

public void setupMinim() {
  minim = new Minim(this);
  audio = new AverageListener();
}

class AverageListener implements AudioListener {
  AudioInput in;     // audio input
  FFT fft;           // FFT 
  BeatDetect beat;   // beat detect

  boolean gotBeat = false, gotMode = false, gotKinect = false;

  int last_update = millis();
  int BPM = 0, check = 0;
  int bpm_count = 0, sec_count = 0;
  int[] bpms = new int [15];
  AudioSpectrum[] averageSpecs, fullSpecs;
  AudioSpectrum volume, bass, mids, treb;
  Colors colors;

  AverageListener() {
    in = minim.getLineIn(Minim.MONO, 512);           // create the audio in 
    in.mute();                                       // mute it
    in.addListener(this);                            // add this object to listen to the audio in
    fft = new FFT(in.bufferSize(), in.sampleRate()); // create the FFT
    fft.logAverages(63, 1);                          // config the averages 
    fft.window(FFT.HAMMING);                         // shape the FFT buffer window using the HAMMING method
    beat = new BeatDetect();                         // create a new beat detect 
    beat.setSensitivity(280);                        // set it's sensitivity

    averageSpecs = new AudioSpectrum [ fft.avgSize() ];
    fullSpecs = new AudioSpectrum [ fft.specSize() ];
    for (int i = 0; i < averageSpecs.length; i++) averageSpecs[i] = new AudioSpectrum("" + fft.getAverageCenterFrequency(i) + " Hz");
    for (int i = 0; i < fullSpecs.length; i++) fullSpecs[i] = new AudioSpectrum("" + fft.indexToFreq(i) + " Hz");

    volume = new AudioSpectrum("Volume");
    bass   = new AudioSpectrum("Bass");
    mids   = new AudioSpectrum("Mids");
    treb   = new AudioSpectrum("Treb");

    colors = new Colors();

    for (int i = 0; i < bpms.length; i++) bpms[i] = 0;
  }

  public void mapSpectrums() {
    for ( int i = 0; i < averageSpecs.length; i++) averageSpecs[i].set( fft.getAvg(i) );
    for ( int i = 0; i < fullSpecs.length; i++) fullSpecs[i].set( fft.getBand(i) );
  }

  public void mapRanges() {
    bass.set( (averageSpecs[0].value + averageSpecs[1].value) / 2 );
    mids.set( (averageSpecs[2].value + averageSpecs[3].value) / 2 );
    treb.set( (averageSpecs[4].value + averageSpecs[5].value) / 2 );
    volume.set( in.mix.level()*100 );
  }

  public void mapColors() {
    colors.update();
  }

  public void mapBPM() {

    // do we have a beat?
    if ( beat.isOnset() ) {
      bpm_count++; 
      gotBeat = true; 
      gotMode = true; 
      gotKinect = true;
    }

    check = millis();
    if (check - last_update > 1000) {
      if (sec_count == bpms.length) {
        sec_count = 0;
      }
      bpms[sec_count] = bpm_count;
      sec_count++;

      BPM = 0;
      for (int i = 0; i < bpms.length; i++) BPM += bpms[i];
      BPM *= 4;

      bpm_count = 0;
      last_update = check;
    }
  }

  public boolean isOnBeat() {
    if ( gotBeat ) {
      gotBeat = false;
      return true;
    } 
    else return false;
  }

  public boolean isOnMode() {
    if ( gotMode ) {
      gotMode = false;
      return true;
    } 
    else return false;
  }

  public boolean isOnKinect() {
    if ( gotKinect ) {
      gotKinect = false;
      return true;
    } 
    else return false;
  }

  public void close() {
    in.close();
  }

  public void update(float[] samples) {
    int stime = millis();
    AUDIO_TIME = 0;
    fft.forward(samples);
    beat.detect(samples);
    mapSpectrums();
    mapRanges();
    mapColors();
    mapBPM();
    AUDIO_TIME = millis() - stime;
    MAX_AUDIO = max(MAX_AUDIO, AUDIO_TIME);
  }



  public void samples(float[] samps) {
    if (audioOn) update(samps);
  }

  public void samples(float[] sampsL, float[] sampsR) {
    if (audioOn) update(sampsL);
  }
}

class AudioSpectrum {
  final int FRAME_TRIGGER = 40; // how many frames must pass before changing the peak and low values 
  String name;                  // the name of the audio spectrum
  float raw_peak = 0;           // the peak or max level of the spectrum
  float max_peak = 0;           // the current max peak level
  float raw_base = 9999;        // the base or lowest level of the spectrum
  float raw      = 0;           // the raw level of the spectrum
  float dB = 0;                 // current db of the level
  float spectrumGain = 1.5f;     // the gain of the level.  No idea id this is right, but it seems to work 
  byte value = 0;               // raw value mapped from 0 to 100
  byte peak = 0;                // current peak
  byte grey = 0;                // level mapped from 0 to 255
  int peak_count = 0;           // counter for smooth
  int smooth_count = 0;         // counter for peak
  float peak_check = 0;         // count before max peak is lowered
  boolean lowerPeak = false;    // are we lowering the peak?

  AudioSpectrum(String name) {
    this.name = name;
  }

  public void set(float v) {

    raw = v * spectrumGain; // set raw

    peak_check = max(raw_peak, raw); // get the max peak level
    if (peak_check < 1) peak_check = 1;

    raw_base = min(raw_base, raw);             // set the min base level

    if (peak_check == raw_peak) peak_count++; // if peak is the same as last time, inc the peak counter

    raw_peak = peak_check;  // now that we know if its the same or not, set it
    max_peak = max(max_peak, raw_peak);

    if (peak_count > FRAME_TRIGGER) {  // is our peak count higher the the trigger?
      lowerPeak = true; // start trying to lower the peak
      peak_count = 0;   // and reset the peak counter
    }

    if (lowerPeak == true && raw < raw_peak) { // should we lower the peak?
      raw_peak -= 0.5f;
    } 
    else if (lowerPeak == true && raw >= raw_peak) { // should we stop trying to lower the peak?
      lowerPeak = false;
    }

    dB = 20*((float)Math.log10(raw)); 

    grey  = (byte) round(map(raw, 0, max_peak, 0, 255));
    grey  = (byte) constrain(grey, 0, 255);

    value = (byte) round(map(raw, 0, max_peak, 0, 100));
    value = (byte) constrain(value, 0, 100);

    peak  = (byte) round(map(raw_peak, 0, max_peak, 0, 100));
    peak  = (byte) constrain(peak, 0, 100);

    raw_base += 0.25f; // keep trying to raise the base level a small amount every loop 
    max_peak -= 0.05f;
    if (max_peak < 24) max_peak = 24;
  }
}


// class uses audio.averageSpecs to map colors to different arrays
class Colors {
  int[] users;
  int[] reds;
  int[] greens;
  int[] blues;
  int background, grey;

  Colors() {
    reds   = new int [4];
    greens = new int [4];
    blues  = new int [4];
    users  = new int [12];
  }

  public int colorMap(int r1, int r2, int g1, int g2, int b1, int b2) {
    int RED   = audio.averageSpecs[r1].grey + audio.averageSpecs[r1].grey / 2;
    int GREEN = audio.averageSpecs[g1].grey + audio.averageSpecs[g2].grey / 2;
    int BLUE  = audio.averageSpecs[b1].grey + audio.averageSpecs[b2].grey / 2; 
    return color(RED, GREEN, BLUE);
  }

  public int colorMapBG(int r1, int r2, int g1, int g2, int b1, int b2) {
    int RED   = audio.averageSpecs[r1].grey + audio.averageSpecs[r1].grey / 6;
    int GREEN = audio.averageSpecs[g1].grey + audio.averageSpecs[g2].grey / 6;
    int BLUE  = audio.averageSpecs[b1].grey + audio.averageSpecs[b2].grey / 6; 
    return color(RED, GREEN, BLUE);
  }

  public void updateBackground() {
    background = colorMapBG(0, 1, 2, 3, 4, 5);
  }

  public void updateGrey() {
    int temp = audio.volume.value + 16;
    if (temp > MAX_BRIGHTNESS) temp = MAX_BRIGHTNESS;
    grey = color(temp);
  }

  public void updateReds() {
    reds[0] = colorMap(0, 1, 2, 4, 3, 5);
    reds[1] = colorMap(0, 1, 3, 5, 2, 4);
    reds[2] = colorMap(0, 1, 4, 5, 2, 3);
    reds[3] = colorMap(0, 2, 1, 3, 4, 5);
  }

  public void updateGreens() {
    greens[0] = colorMap(2, 3, 0, 1, 4, 5);
    greens[1] = colorMap(4, 5, 0, 1, 2, 3);
    greens[2] = colorMap(2, 4, 0, 1, 3, 5);
    greens[3] = colorMap(3, 5, 0, 1, 2, 4);
  }

  public void updateBlues() {
    blues[0] = colorMap(2, 3, 4, 5, 0, 1);
    blues[1] = colorMap(4, 5, 2, 3, 0, 1);
    blues[2] = colorMap(2, 4, 3, 5, 0, 1);
    blues[3] = colorMap(3, 5, 2, 4, 0, 1);
  }

  public void updateUsers() {
    users[0]  = reds[0];
    users[1]  = greens[0];
    users[2]  = blues[0];
    users[3]  = reds[1];
    users[4]  = greens[1];
    users[5]  = blues[1];
    users[6]  = reds[2];
    users[7]  = greens[2];
    users[8]  = blues[2];
    users[9]  = reds[3];
    users[10] = greens[3];
    users[11] = blues[3];
  }

  public void update() {
    updateBackground();
    updateGrey();
    updateReds();
    updateGreens();
    updateBlues();
    updateUsers();
  }

  public int get(int i) {
    int rtn_color;
    if (i < 0 || i > 11) rtn_color = grey;
    else rtn_color = users[i];

    if ( brightness(rtn_color) < 10 ) { 
      return color(brightness(audio.colors.grey) + 8);
    } 
    else {
      return rtn_color;
    }
  }
    
}

// NEED TO REWRITE TO TRACK USERS

AtariVideoMusic atari; 

public void setupAtari() {
  atari = new AtariVideoMusic();
}

public void doAtari() {
  buffer.blendMode(ADD);
  atari.draw();
  buffer.blendMode(BLEND);
}

class AtariVideoMusic {
  final int SOLID = 0;
  final int HOLE  = 1;
  final int RING  = 2;
  int mode = 0;
  int display_count = 1;

  AtariSingle[] alist = new AtariSingle [32];

  AtariVideoMusic() {
    for (int i = 0; i < alist.length; i++) {
      alist[i] = new AtariSingle();
    }
    changeDisplay();
  }

  public void changeDisplay() {                 // 1x1 - 1
    //int count = int(random(0,6));
    int count = round( noise(xoff) * 5 );
    if (count == 0) {
      alist[0].set(80, 40, 160, 80);
      display_count = 1;
    }
    if (count == 1) {                // 2x1 - 2
      alist[0].set(40, 40, 100, 80);
      alist[1].set(120, 40, 100, 80);
      display_count = 2;
    }
    if (count == 2) {                 // 2x2 - 4
      alist[0].set(40, 20, 90, 50);
      alist[1].set(120, 20, 90, 50);
      alist[2].set(40, 60, 90, 50);
      alist[3].set(120, 60, 90, 50);
      display_count = 4;
    }
    if (count == 3) {                // 4x2 - 8
      alist[0].set(20, 20, 60, 50);
      alist[1].set(60, 20, 60, 50);
      alist[2].set(100, 20, 60, 50);
      alist[3].set(140, 20, 60, 50);
      alist[4].set(20, 60, 60, 50);
      alist[5].set(60, 60, 60, 50);
      alist[6].set(100, 60, 60, 50);
      alist[7].set(140, 60, 60, 50);
      display_count = 8;
    }
    if (count == 4) {               // 4x4 - 16
      alist[0].set(20, 10, 50, 30);
      alist[1].set(60, 10, 50, 30);
      alist[2].set(100, 10, 50, 30);
      alist[3].set(140, 10, 50, 30);
      alist[4].set(20, 30, 50, 30);
      alist[5].set(60, 30, 50, 30);
      alist[6].set(100, 30, 50, 30);
      alist[7].set(140, 30, 50, 30);
      alist[8].set(20, 50, 50, 30);
      alist[9].set(60, 50, 50, 30);
      alist[10].set(100, 50, 50, 30);
      alist[11].set(140, 50, 50, 30);
      alist[12].set(20, 70, 50, 30);
      alist[13].set(60, 70, 50, 30);
      alist[14].set(100, 70, 50, 30);
      alist[15].set(140, 70, 50, 30);
      display_count = 16;
    }
    if (count == 5) {               // 8x4 - 32
      alist[0].set(10, 10, 30, 30);
      alist[1].set(30, 10, 30, 30);
      alist[2].set(50, 10, 30, 30);
      alist[3].set(70, 10, 30, 30);
      alist[4].set(90, 10, 30, 30);
      alist[5].set(110, 10, 30, 30);
      alist[6].set(130, 10, 30, 30);
      alist[7].set(150, 10, 30, 30);
      alist[8].set(10, 30, 30, 30);
      alist[9].set(30, 30, 30, 30);
      alist[10].set(50, 30, 30, 30);
      alist[11].set(70, 30, 30, 30);
      alist[12].set(90, 30, 30, 30);
      alist[13].set(110, 30, 30, 30);
      alist[14].set(130, 30, 30, 30);
      alist[15].set(150, 30, 30, 30);
      alist[16].set(10, 50, 30, 30);
      alist[17].set(30, 50, 30, 30);
      alist[18].set(50, 50, 30, 30);
      alist[19].set(70, 50, 30, 30);
      alist[20].set(90, 50, 30, 30);
      alist[21].set(110, 50, 30, 30);
      alist[22].set(130, 50, 30, 30);
      alist[23].set(150, 50, 30, 30);
      alist[24].set(10, 70, 30, 30);
      alist[25].set(30, 70, 30, 30);
      alist[26].set(50, 70, 30, 30);
      alist[27].set(70, 70, 30, 30);
      alist[28].set(90, 70, 30, 30);
      alist[29].set(110, 70, 30, 30);
      alist[30].set(130, 70, 30, 30);
      alist[31].set(150, 70, 30, 30);
      display_count = 32;
    }
    //println("ATARI - displaying: " + display_count);
  }

  public void update() {
    if ( audio.isOnBeat() ) {
      float test = random(0, 1);
      if (test < 0.25f) changeDisplay();
      if (test > 0.75f) {
        mode = round( random(2) );
        //println("ATARI - mode: " + mode);
      }
    }
  }

  public void draw() {
    update();
    for (int i = 0; i < display_count; i++) {
      alist[i].setMode(mode);
      alist[i].draw();
    }
  }
  
}

class AtariSingle {
  final int SOLID = 0;
  final int HOLE  = 1;
  final int RING  = 2;
  int mode = 0;
  float x, y, w, h, weight;

  AtariSingle() {
  }

  public int setColor(int i) {
    int RED   = audio.averageSpecs[1].grey;
    int GREEN = audio.averageSpecs[3].grey;
    int BLUE  = audio.averageSpecs[i].grey;
    return color(RED, GREEN, BLUE);
  }

  public void set(float _x, float _y, float _w, float _h) {
    x = _x; 
    y = _y;
    w = _w; 
    h = _h;
  }

  public void setMode(int i) {
    mode = i;
  }

  public void draw() {
    
    for (int i = 0; i < (audio.averageSpecs.length - 1) ; i++) {
      float thisWidth  = (w/8) * (i);
      thisWidth += map(audio.averageSpecs[i].value, 0, 100, 0, (w/8));
      float thisHeight = map(audio.averageSpecs[i].value, 0, 100, 0, h);
      int thisColor  = setColor(i);

      if (mode == SOLID) {
        buffer.noStroke();
        buffer.fill(thisColor);
      } else if (mode == HOLE) {
        buffer.noFill();
        buffer.stroke(thisColor);
        weight = map(audio.averageSpecs[i].value, 0, 100, 1, (h / 5) /* + 1 */);
        buffer.strokeWeight(weight);
      } else {
        buffer.noFill();
        buffer.stroke(thisColor);
        buffer.strokeWeight(2);
      }
      buffer.rectMode(CENTER);
      buffer.hint(DISABLE_DEPTH_TEST);
      buffer.rect(x, y, thisWidth, thisHeight);
      buffer.hint(ENABLE_DEPTH_TEST);
    }
    buffer.strokeWeight(1);
  }
}

// NOT SURE, WAVE MODE?  

public void doUserBg() {
  buffer.blendMode(ADD);
  buffer.stroke(255);
  buffer.strokeWeight(2);
  for (int i = 0; i < 160 - 1; i++) {
    buffer.line(i, 40 + audio.in.mix.get(i)*60, -5, i + 1, 40 + audio.in.mix.get(i+1)*60, -5);
  }
  buffer.blendMode(BLEND);
}

public void displayImage(PImage _image) {
  //buffer.blendMode(BLEND);
  if (_image.width != buffer.width && _image.height != buffer.height) {
    buffer.copy(_image, 0, 0, _image.width, _image.height, 0, 0, buffer.width, buffer.height);
  } 
  else {
    buffer.image(_image, 0, 0);
  }
}

public void doTest() {
  displayImage(smpte);
}

// COULD USE A REWRITE

ConcCircles circles;
SpecCity city;
Pulsar pulsar;

int CIRCLE_MODE = 0;

public void setupCircles() {
  circles = new ConcCircles();
  city = new SpecCity();
  pulsar = new Pulsar();
  
  // controll name, text name, x, y, width, height, text size, value, move 2 tab
  createToggle("distriktOn", "distrikt", TAB_START + 20, DEBUG_WINDOW_START + 50, 50, 50, mFont, ControlP5.DEFAULT, city.dOn, DISPLAY_STR[DISPLAY_MODE_CITY]);
}

public void distriktOn(boolean b) {
  city.dOn = b;
}

public void doCircles() {
  buffer.blendMode(ADD);
  circles.draw();
  buffer.blendMode(BLEND);
}

public void doPulsar() {
  buffer.blendMode(ADD);
  pulsar.draw();
  buffer.blendMode(BLEND);
}

public void doCity() {
  buffer.blendMode(ADD);
  city.draw();
  buffer.blendMode(BLEND);
}


class ConcCircles {
  float r = 16;
  float theta = 0;
  float numCircles = 32;
  int rows = 8;
  PVector kinectUser;
  int maxSize;
  int size;

  ConcCircles() {
    maxSize = 32;
    kinectUser = new PVector();
  }

  public int getCircleColor(int i) {
    if (audioOn) {
      int m = i % (audio.averageSpecs.length - 1);
      return color(audio.averageSpecs[1].grey, audio.averageSpecs[3].grey, audio.averageSpecs[m].grey);
    } else {
      float b = round( noise(zoff, yoff, xoff) * 255 );
      float g = round( noise(zoff, yoff) * 255 );
      float r = round( noise(zoff) * 255 );
      return color(r,g,b);
    }
  }
  
  public int getCirlceSize(int i) {
    if (audioOn) {
      int m = i % (audio.averageSpecs.length - 1);
      return round( map(audio.averageSpecs[m].value + 10, 10, 110, 2, maxSize) );
    } else {
      return round( random(2, maxSize) );
    }
  }

  public void updateTheta() {
    int speed;
    
    // is the audio on?
    if (audioOn) speed = audio.BPM + 1;
    else speed = round( random(100,200) );
    
    // update theta
    if (theta > 0) theta += 360 / numCircles / speed;
    else theta -= 360 / numCircles / speed;
  }

  public void drawCircle(int n, int size) {
    float x = (r+16*n)*cos(theta) + kinectUser.x;
    float y = (r+16*n)*sin(theta) + kinectUser.y;

    buffer.ellipse(x, y, size, size);
  }

  public void draw() {
    kinectUser = getSingleUser();

    for (int i = 0; i < rows ; i++) {
      buffer.fill( getCircleColor(i) );
      size = getCirlceSize(i);
      for (int n = 0; n < numCircles; n++) {
        drawCircle(n, size);
        updateTheta();
      }
    }
    
    if ( audioOn ) {
      if ( audio.isOnBeat() ) {
        float test = random(0, 1);
        if (test < 0.25f) theta = random(theta * -1, theta);
        if (test > 0.75f) theta *= -1;
      }
    } else {
      float test = random(0, 1);
      if (test < 0.1f) theta = random(theta * -1, theta);
      if (test > 0.9f) theta *= -1;
    }
  }
}



class SpecCity {

  PVector kinectUser;
  int LINE_MAX;
  int SPEC_MAX;
  int Z = -15;
  int distrikt;
  boolean dOn = false;

  SpecCity() {
    LINE_MAX = 60;
    SPEC_MAX = 160;
    kinectUser     = new PVector();
  }
  
  public void setDistrikt(int v) {
    distrikt = v;
  }

  public void draw() {
    kinectUser = getSingleUser();
    //buffer.strokeWeight(1);
    buffer.pushMatrix();
    //buffer.translate(kinectUser.x, kinectUser.y);
    buffer.translate(80, 40);

    for (int i = 1; i <= SPEC_MAX + 5 ; i++) {
      // set the line color
      buffer.stroke(audio.fullSpecs[i].grey, audio.averageSpecs[1].grey, audio.averageSpecs[3].grey);
      int weight = round(map(audio.fullSpecs[i].value, 0, 100, 1, 4));
      buffer.strokeWeight(weight);

      int xR = i;
      int xL = i * -1;
      int yU = round( map(audio.fullSpecs[i].value, 0, 100, 2, LINE_MAX) );
      int yD = yU * -1;

      buffer.line(xL, 0, Z, xL, yU, Z);  // left side up
      buffer.line(xL, 0, Z, xL, yD, Z);  // left side down
      buffer.line(xR, 0, Z, xR, yU, Z);  // right side up
      buffer.line(xR, 0, Z, xR, yD, Z);  // right side down
    }
    
    if (dOn) {
      LINE_MAX = 100;
      buffer.fill(200);
      buffer.noStroke();
      buffer.translate(0, 0, -25);
      svgs[distrikt].draw(buffer);
    } else LINE_MAX = 60;
    
    buffer.popMatrix();
  }
}

class Pulsar {
  int lineColor;
  float kx, ky;
  float Z = -5;
  PVector kinectUser;

  Pulsar() {
  }

  public int setColor(int i) {
    int RED   = audio.averageSpecs[1].grey;
    int GREEN = audio.averageSpecs[3].grey;
    int BLUE  = audio.fullSpecs[i].grey;
    return color(RED, GREEN, BLUE);
  }

  public void drawLine(float radius, float angle) {
    float x = kinectUser.x + ( radius * cos( radians(angle) ) );
    float y = kinectUser.y + ( radius * sin( radians(angle) ) );
    buffer.line(kinectUser.x, kinectUser.y, Z, x, y, Z);
  }

  public void draw() {
    buffer.noFill();
    kinectUser = getSingleUser();

    for (int i = 0; i < (audio.fullSpecs.length / 2); i++) {    
      //buffer.strokeWeight(1);
      buffer.stroke( setColor(i) );
      int weight = round(map(audio.fullSpecs[i].value, 0, 100, 1, 4));
      buffer.strokeWeight(weight);

      float angle  = map(i, 0, (audio.fullSpecs.length - 1) / 4, 0, 180);
      float radius = map(audio.fullSpecs[i].value, 0, 100, 1, 720);
      float spin   = map(audio.volume.value, 0, 100, 0, 180);

      drawLine(radius, angle + spin);
      drawLine(radius, angle + 180 + spin);
    }
  }
}

// NEEDS A REWRITE BIGTIME!!


class baseBar {
  float base_width;       // width of the Bar
  float base_height;      // height of the Bar
  float base_half_width;  // half of the width
  float base_half_height; // half of the height
  int base_color;       // color of the Bar
  int base_stroke;      // stroke of the Bar
  float base_weight;      // stroke weight of the Bar
  int base_align_x;       // X alignment (LEFT, CENTER, RIGHT)
  int base_align_y;       // Y alignment (TOP, CENTER, BOTTOM)
  int base_corners;       // rounded corner amount

  PVector location;       // the Bar's location
  PVector base_start;     // the start location for drawing the Bar
  PVector base_end;       // the end location for drawing the Bar

  boolean base_stroke_on; // is the stroke on or off?

  baseBar(float _x, float _y, float _width, float _height, int _align_x, int _align_y) {
    location = new PVector(_x, _y); // set starting location
    base_width   = _width;          // set width
    base_height  = _height;         // set height
    base_align_x = _align_x;        // set X alignment
    base_align_y = _align_y;        // set Y alignment
    defaults();                     // set the defaults
  }

  private void defaults() {
    base_start   = new PVector(); // create start drawing vector
    base_end     = new PVector(); // create end drawing vector
    base_color   = color(0);      // set base color to black
    base_stroke  = color(0);      // set base stroke to black
    base_weight  = 2;             // set base stroke to 2
    base_corners = 7;             // set conrner roundness to 7
    base_stroke_on = true;        // turn on stroke
  }

  public void update() {
    base_half_width  = base_width  / 2;
    base_half_height = base_height / 2;

    if (base_align_x == LEFT && base_align_y == TOP) { 
      base_start.x = location.x;
      base_start.y = location.y;
      base_end.x   = location.x + base_width;
      base_end.y   = location.y + base_height;
    }

    if (base_align_x == CENTER && base_align_y == TOP) {
      base_start.x = location.x - base_half_width;
      base_start.y = location.y;
      base_end.x   = location.x + base_half_width;
      base_end.y   = location.y + base_height;
    }

    if (base_align_x == RIGHT && base_align_y == TOP) {
      base_start.x = location.x - base_width;
      base_start.y = location.y;
      base_end.x   = location.x;
      base_end.y   = location.y + base_height;
    }

    if (base_align_x == LEFT && base_align_y == CENTER) {
      base_start.x = location.x;
      base_start.y = location.y - base_half_height;
      base_end.x   = location.x + base_width;
      base_end.y   = location.y + base_half_height;
    }

    if (base_align_x == CENTER && base_align_y == CENTER) {
      base_start.x = location.x - base_half_width;
      base_start.y = location.y - base_half_height;
      base_end.x   = location.x + base_half_width;
      base_end.y   = location.y + base_half_height;
    }

    if (base_align_x == RIGHT && base_align_y == CENTER) {
      base_start.x = location.x - base_width;
      base_start.y = location.y - base_half_height;
      base_end.x   = location.x;
      base_end.y   = location.y + base_half_height;
    }

    if (base_align_x == LEFT && base_align_y == BOTTOM) {
      base_start.x = location.x;
      base_start.y = location.y - base_height;
      base_end.x   = location.x + base_width;
      base_end.y   = location.y;
    }

    if (base_align_x == CENTER && base_align_y == BOTTOM) {
      base_start.x = location.x - base_half_width;
      base_start.y = location.y - base_height;
      base_end.x   = location.x + base_half_width;
      base_end.y   = location.y;
    }

    if (base_align_x == RIGHT && base_align_y == BOTTOM) {
      base_start.x = location.x - base_width;
      base_start.y = location.y - base_height;
      base_end.x   = location.x;
      base_end.y   = location.y;
    }
  }

  public void setAlign(int _align_x, int _align_y) {
    base_align_x = _align_x;
    base_align_y = _align_y;
  }

  public void setCorners(int _v) {
    base_corners = _v;
  }

  public void setWidth(float _w) {
    base_width = _w;
  }

  public void setHeight(float _h) {
    base_height = _h;
  }

  public void setColor(int _c) {
    base_color = _c;
  }

  public void setStroke(int _s) {
    base_stroke = _s;
  }

  public void setWeight(int _w) {
    base_weight = _w;
  }

  public void strokeOn() {
    base_stroke_on = true;
  }

  public void strokeOff() {
    base_stroke_on = false;
  }

  public void move(float _x, float _y) {
    location.x = _x;
    location.y = _y;
  }

  public void move(PVector _location) {
    location.x = _location.x;
    location.y = _location.y;
  }

  public void drawBar() {
    buffer.rectMode(CORNERS);      // set rect mode to corners
    if (base_stroke_on) {
      buffer.stroke(base_stroke);
      buffer.strokeWeight(base_weight);
    } 
    else {
      buffer.noStroke();
    }
    buffer.fill(base_color);           // color bar to value level
    buffer.rect(base_start.x, base_start.y, base_end.x, base_end.y, base_corners);
    buffer.rectMode(CORNER);
  }

  public void display(int _c) {
    setColor(_c);
    update();
    drawBar();
  }

  public void display() {
    update();
    drawBar();
  }
}

class textBar extends baseBar {
  String   text_string, f;
  String[] words_array;
  ArrayList<String> line_list;    // lines of text
  float font_height;       // font height
  int text_color;
  PFont text_font;
  boolean text_is_set;
  boolean show_text;
  boolean show_bg;

  textBar(float _x, float _y, float _width, float _height, int _align_x, int _align_y, PFont _font) {
    super(_x, _y, _width, _height, _align_x, _align_y);
    text_font   = _font;
    text_color  = color(0);
    line_list  = new ArrayList<String>();
    text_string = "";
    show_text = true;
    show_bg = false;
  }

  public void setText(String _text) {
    //if (text_string.equals(_text)) return; 
    text_string = _text;
    setupText();
  }

  private void setupText() {
    buffer.textFont(text_font);
    font_height = buffer.textAscent() + buffer.textDescent(); // figure out the font height
    words_array = text_string.split(" "); // split text into a string array of words
    String current_line = "";             // reset the current line string
    line_list.clear();                    // clear the lines list

    for (int i = 0; i < words_array.length; i++) {             // loop through the words
      if ((font_height * (line_list.size() + 1)) > base_height) break;
      String line_test = current_line + words_array[i] + " ";  // create a test string with the new word
      if (buffer.textWidth(line_test) + 10 > base_width) {     // test to see if new word fits inside the base bar
        line_list.add(current_line.trim());                    // if it is, add the current line to the line list
        current_line = words_array[i] + " ";                   // then make new current line with just the new word
        if (i == (words_array.length - 1)) {                   // now make sure we're not on the last word
          line_list.add(current_line);                         // if we are, then add that to the line list too
        }
      } 
      else {                                  // the line still fits inside the base bar
        current_line = line_test;             // so make the test line the current line
        if (i == (words_array.length - 1)) {  // again make sure we're not on the last word
          line_list.add(current_line);        // if we are, then add that to the line list too
        }
      }
    }
    text_is_set = true;
    //println(words_array);
    //println(font_height);
  }

  public void setColor(int _c) {
    text_color = _c;
  }

  public void setBgColor(int _c) {
    base_color = _c;
  }

  public void bgOn() {
    show_bg = true;
  }

  public void bgOff() {
    show_bg = false;
  }

  public void setFont(PFont _font) {
    text_font = _font;
  }

  public void on() {
    show_text = true;
  }

  public void off() {
    show_text = false;
  }

  public void drawText() {
    super.update();
    if (show_bg) super.drawBar();
    buffer.textFont(text_font);
    buffer.textAlign(base_align_x, base_align_y);

    float text_height = font_height * line_list.size();

    float start_y;
    if (base_align_y == BOTTOM) {
      start_y = location.y - text_height + font_height;
    } 
    else if (base_align_y == CENTER) {
      start_y = location.y - (text_height / 2) + (font_height / 2);
    } 
    else {
      start_y = location.y;
    }

    float start_x = 0;
    if (base_align_x == LEFT) {
      start_x = 2;
    }
    if (base_align_x == RIGHT) {
      start_x = -2;
    }

    // build a new string with all the line
    buffer.fill(text_color);
    for (int i = 0; i < line_list.size(); i++) {

      String thisLine = (String) line_list.get(i);
      float x = location.x + start_x;
      float y = start_y + (font_height * i);
      //println(y);
      buffer.text(thisLine, x, y);
    }
  }

  public void display() {
    if (show_text) drawText();
  }
}

class valueBar extends baseBar {
  PFont   value_text_font; // font for value text
  int     value;           // value
  int     peak;            // the peak of the value
  int     MIN, MAX;        // the min and MAX values for mapping
  int   value_color;     // the color of the value bar
  int   value_stroke;    // the stroke color of the value bar
  int     value_weight;    // the stroke weight of the value bar
  float   text_height;
  int   text_color;      // the color of the value text 
  int     text_offset;     // offset text acording to alignment
  PVector value_start;     // the start location for drawing the value bar
  PVector value_end;       // the end location for drawing the value bar
  PVector peak_start;
  PVector peak_end;
  int   peak_color;
  int     peak_weight;
  boolean value_stroke_on; // is the stroke on for the value bar?
  boolean value_text_on;   // is the value text on?
  boolean base_bg_on;      // is the background on?
  boolean peak_on;

  valueBar(float _x, float _y, float _width, float _height, int _align_x, int _align_y, PFont _font) {
    super(_x, _y, _width, _height, _align_x, _align_y); // create the base bar
    super.defaults();                                   // do the base defaults;
    value_text_font   = _font;                          // set the text font
    defaults();                                         // set defaults
  }

  public void defaults() {
    value = 0;    // default value of zero
    MIN   = 0;    // default min of zero
    MAX   = 1023; // default max of 1023

      value_color     = color(0); // default value bar color of black
    value_stroke    = color(0); // default value bar stroke of black
    value_weight    = 2;        // default value stroke weight of two
    text_color      = color(0); // default value text color of black
    text_offset     = 0;
    value_stroke_on = true;     // value stroke is on
    value_text_on   = true;     // value text is on

    value_start = new PVector(); // create value bar start vector
    value_end   = new PVector(); // create value bar end vector

      peak_start  = new PVector();
    peak_end    = new PVector();
    peak_color = color(0);
    peak_weight = 1;
    peak = 0;
    peak_on = false;
  }

  public void update() {
    super.update();  // first up the base

      // start the value bar from the base bar vectors
    value_start.x = base_start.x;
    value_start.y = base_start.y;
    value_end.x   = base_end.x;
    value_end.y   = base_end.y;

    peak_start.x = base_start.x;
    peak_start.y = base_start.y;
    peak_end.x   = base_end.x;
    peak_end.y   = base_end.y;

    // mapping from the top left to the bottom right
    if (base_align_x == LEFT && base_align_y == TOP) {
      value_end.x = map(value, MIN, MAX, location.x, location.x + base_width);
      value_end.y = map(value, MIN, MAX, location.y, location.y + base_height);
      peak_end.x = map(peak, MIN, MAX, location.x, location.x + base_width);
      peak_start.y = map(peak, MIN, MAX, location.y, location.y + base_height);
      peak_end.y = peak_start.y;
    }
    // mapping from the top center to the bottom center
    if (base_align_x == CENTER && base_align_y == TOP) {
      value_end.y = map(value, MIN, MAX, location.y, location.y + base_height);
      peak_start.y = map(peak, MIN, MAX, location.y, location.y + base_height);
      peak_end.y = peak_start.y;
    }
    // mapping from the top right to the bottom left
    if (base_align_x == RIGHT && base_align_y == TOP) {
      value_start.x = map(value, MIN, MAX, location.x, location.x - base_width);
      value_end.y   = map(value, MIN, MAX, location.y, location.y + base_height);
      peak_start.x = map(peak, MIN, MAX, location.x, location.x - base_width);
      peak_start.y = map(peak, MIN, MAX, location.y, location.y + base_height);
      peak_end.y = peak_start.y;
    }
    // mapping from the center left to the center right
    if (base_align_x == LEFT && base_align_y == CENTER) {
      value_end.x = map(value, MIN, MAX, location.x, location.x + base_width);
      peak_start.x = map(peak, MIN, MAX, location.x, location.x + base_width);
      peak_end.x = peak_start.x;
    }
    // mapping from the center outward
    if (base_align_x == CENTER && base_align_y == CENTER) {

      if (base_width >= base_height) {
        value_start.x = map(value, MIN, MAX, location.x, location.x - base_half_width);
        value_end.x   = map(value, MIN, MAX, location.x, location.x + base_half_width);
        peak_start.x = map(peak, MIN, MAX, location.x, location.x - base_half_width);
        peak_end.x   = map(peak, MIN, MAX, location.x, location.x + base_half_width);
      }
      if (base_width <= base_height) {
        value_start.y = map(value, MIN, MAX, location.y, location.y - base_half_height);
        value_end.y   = map(value, MIN, MAX, location.y, location.y + base_half_height);
        peak_start.y = map(peak, MIN, MAX, location.y, location.y - base_half_height);
        peak_end.y   = map(peak, MIN, MAX, location.y, location.y + base_half_height);
      }
    }
    // mapping from the center right to the center left
    if (base_align_x == RIGHT && base_align_y == CENTER) {
      value_start.x = map(value, MIN, MAX, location.x, location.x - base_width);
      peak_start.x = map(peak, MIN, MAX, location.x, location.x - base_width);
      peak_end.x = peak_start.x;
    }
    // mapping from the bottom left to the top right
    if (base_align_x == LEFT && base_align_y == BOTTOM) {
      value_end.x   = map(value, MIN, MAX, location.x, location.x + base_width);
      value_start.y = map(value, MIN, MAX, location.y, location.y - base_height);
      peak_end.x   = map(peak, MIN, MAX, location.x, location.x + base_width);
      peak_start.y = map(peak, MIN, MAX, location.y, location.y - base_height);
      peak_end.y = peak_start.y;
    }
    // mapping from the bottom center to the top center
    if (base_align_x == CENTER && base_align_y == BOTTOM) {
      value_start.y = map(value, MIN, MAX, location.y, location.y - base_height);
      peak_start.y = map(peak, MIN, MAX, location.y, location.y - base_height);
      peak_end.y = peak_start.y;
    }
    // mapping from the bottom right to the top left
    if (base_align_x == RIGHT && base_align_y == BOTTOM) {
      value_start.x = map(value, MIN, MAX, location.x, location.x - base_width);
      value_start.y = map(value, MIN, MAX, location.y, location.y - base_height);
      peak_start.x = map(peak, MIN, MAX, location.x, location.x - base_width);
      peak_start.y = map(peak, MIN, MAX, location.y, location.y - base_height);
      peak_end.y = peak_start.y;
    }

    //peak_start.x = round(peak_start.x);  peak_end.x = round(peak_end.x);
    //peak_start.y = round(peak_start.y);  peak_end.y = round(peak_end.y);
  }

  private void setValue(int v) {
    value = v;
  }

  public void setMin(int _v) {
    MIN = _v;
  }

  public void setMax(int _v) {
    MAX = _v;
  }

  public void textOn() {
    value_text_on = true;
  }

  public void textOff() {
    value_text_on = false;
  }

  public void textColor(int c) {
    text_color = c;
  }

  public void setFont(PFont ff) {
    value_text_font = ff;
  }

  public void bgOn() {
    base_bg_on = true;
  }

  public void bgOff() {
    base_bg_on = false;
  }

  public void setColor(int _c) {
    value_color = _c;
  }

  public void setBgColor(int _c) {
    base_color = _c;
  }

  public void setStroke(int _s) {
    value_stroke = _s;
  }

  public void setBgStroke(int _s) {
    base_stroke = _s;
  }

  public void setWeight(int _w) {
    value_weight = _w;
  }

  public void setBgWeight(int _w) {
    base_weight = _w;
  }

  public void strokeOn() {
    value_stroke_on = true;
  }

  public void strokeBgOn() {
    base_stroke_on = true;
  }

  public void strokeOff() {
    value_stroke_on = false;
  }

  public void strokeBgOff() {
    base_stroke_on = false;
  }

  public void textOffset(int _offset) {
    text_offset = _offset;
  }

  public void setPeak(int p) {
    peak = p;
  }

  public void setPeakColor (int c) {
    peak_color = c;
  }

  public void setPeakWeight(int v) {
    peak_weight = v;
  }

  public void peakOn() {
    peak_on = true;
  }

  public void peakOff() {
    peak_on = false;
  }

  public void drawText() {
    buffer.textFont(value_text_font);  // set the font
    text_height = buffer.textAscent() + buffer.textDescent();
    buffer.fill(text_color);     // set color for font
    buffer.textAlign(base_align_x, base_align_y);
    if (base_align_x == LEFT && base_align_y == TOP) {
      buffer.text(value, location.x - text_offset, location.y - text_offset);
    } 
    else if (base_align_x == CENTER && base_align_y == TOP) {
      buffer.text(value, location.x, location.y - text_offset);
    } 
    else if (base_align_x == RIGHT && base_align_y == TOP) {
      buffer.text(value, location.x + text_offset, location.y - text_offset);
    } 
    else if (base_align_x == LEFT && base_align_y == CENTER) {
      buffer.text(value, location.x - text_offset, location.y);
    } 
    else if (base_align_x == CENTER && base_align_y == CENTER) {
      buffer.text(value, location.x, location.y);
    } 
    else if (base_align_x == RIGHT && base_align_y == CENTER) {
      buffer.text(value, location.x + text_offset, location.y);
    } 
    else if (base_align_x == LEFT && base_align_y == BOTTOM) {
      buffer.text(value, location.x - text_offset, location.y + text_offset);
    } 
    else if (base_align_x == CENTER && base_align_y == BOTTOM) {
      buffer.text(value, location.x, location.y + text_offset);
    } 
    else {
      buffer.text(value, location.x + text_offset, location.y + text_offset);
    }
  }

  public void drawBar() {
    buffer.rectMode(CORNERS);      // set rect mode to corners
    if (value_stroke_on) {
      buffer.stroke(value_stroke);
      buffer.strokeWeight(value_weight);
    } 
    else {
      buffer.noStroke();
    }
    buffer.fill(value_color);           // color bar to value level
    buffer.rect(value_start.x, value_start.y, value_end.x, value_end.y, base_corners);
    buffer.rectMode(CORNER);
    if (peak_on && peak > 4) {
      buffer.stroke(peak_color);
      buffer.strokeWeight(1);
      if (base_align_x == CENTER && base_align_y == CENTER) {
        if (base_width >= base_height) {
          buffer.line(peak_start.x, peak_start.y, peak_start.x, peak_end.y - 1);
          buffer.line(peak_end.x, peak_start.y, peak_end.x, peak_end.y - 1);
        }
        if (base_width <= base_height) {
          buffer.line(peak_start.x, peak_start.y, peak_end.x, peak_start.y);
          buffer.line(peak_start.x, peak_end.y, peak_end.x, peak_end.y);
        }
      } 
      else {
        buffer.line(peak_start.x, peak_end.y - 1, peak_end.x - 1, peak_end.y - 1);
      }
    }
  }

  public void display() {
    update();
    if (base_bg_on) super.drawBar();
    drawBar();
    if (value_text_on) drawText();
  }

  public void display(int v) {
    setValue(v);
    update();
    if (base_bg_on) super.drawBar();
    drawBar();
    if (value_text_on) drawText();
  }
}


class eqBar {
  baseBar RED, ORANGE, YELLOW, GREEN;
  valueBar VALUE;
  int eq_align_x, eq_align_y;
  int eq_value;
  float eq_x, eq_y, eq_width, eq_height;
  int eq_value_color;
  PFont eq_font;
  PFont label_font;
  String eq_label;
  int eq_label_color;
  boolean label_set;

  final float orange_cutoff = 0.9f;
  final float yellow_cutoff = 0.75f;
  final float green_cutoff = 0.5f;

  eqBar(float _x, float _y, float _width, float _height, int _align_x, int _align_y, PFont _font) {
    eq_x       = _x;
    eq_y       = _y;
    eq_width   = _width;
    eq_height  = _height;
    eq_align_x = _align_x;
    eq_align_y = _align_y;
    eq_font    = _font;
    eq_label = "";
    label_set = false;
    init();
  }

  private void init() {
    eq_value_color = color(0, 255, 0);
    eq_label_color = color(0);

    VALUE = new valueBar(eq_x, eq_y, eq_width, eq_height, eq_align_x, eq_align_y, eq_font);
    VALUE.bgOff();
    VALUE.strokeOff();
    VALUE.setCorners(0);

    RED = new baseBar(eq_x, eq_y, eq_width, eq_height, eq_align_x, eq_align_y);
    RED.setColor(color(0xff641919));
    RED.setStroke(color(32));
    RED.setWeight(2);
    RED.strokeOn();
    RED.setCorners(0);

    ORANGE = new baseBar(eq_x, eq_y, eq_width, eq_height, eq_align_x, eq_align_y);
    ORANGE.setColor(color(0xff624212));
    ORANGE.strokeOff();
    ORANGE.setCorners(0);

    YELLOW = new baseBar(eq_x, eq_y, eq_width, eq_height, eq_align_x, eq_align_y);
    YELLOW.setColor(color(0xff625E12));
    YELLOW.strokeOff();
    YELLOW.setCorners(0);

    GREEN  = new baseBar(eq_x, eq_y, eq_width, eq_height, eq_align_x, eq_align_y);
    GREEN.setColor(color(0xff136212));
    GREEN.strokeOff();
    GREEN.setCorners(0);

    setWidth(eq_width);
    setHeight(eq_height);
  }

  public void setWidth(float _w) {
    eq_width = _w;
    VALUE.setWidth(eq_width);
    RED.setWidth(eq_width);
    ORANGE.setWidth(eq_width);
    YELLOW.setWidth(eq_width);
    GREEN.setWidth(eq_width);

    if (eq_align_x != CENTER) {
      ORANGE.setWidth(eq_width * orange_cutoff);
      YELLOW.setWidth(eq_width * yellow_cutoff);
      GREEN.setWidth(eq_width * green_cutoff);
    }

    if (eq_align_x == CENTER && eq_width >= eq_height) {
      ORANGE.setWidth(eq_width * orange_cutoff);
      YELLOW.setWidth(eq_width * yellow_cutoff);
      GREEN.setWidth(eq_width * green_cutoff);
    }
  }

  public void setHeight(float _h) {
    eq_height = _h;
    RED.setHeight(eq_height);
    VALUE.setHeight(eq_height);
    ORANGE.setHeight(eq_height);
    YELLOW.setHeight(eq_height);
    GREEN.setHeight(eq_height);

    if (eq_align_y != CENTER) {
      ORANGE.setHeight(eq_height * orange_cutoff);
      YELLOW.setHeight(eq_height * yellow_cutoff);
      GREEN.setHeight(eq_height * green_cutoff);
    }

    if (eq_align_y == CENTER && eq_height >= eq_width) {
      ORANGE.setHeight(eq_height * orange_cutoff);
      YELLOW.setHeight(eq_height * yellow_cutoff);
      GREEN.setHeight(eq_height * green_cutoff);
    }
  }

  public void setAlign(int _align_x, int _align_y) {
    eq_align_x = _align_x;
    eq_align_y = _align_y;
    VALUE.setAlign(eq_align_x, eq_align_y);
    RED.setAlign(eq_align_x, eq_align_y);
    ORANGE.setAlign(eq_align_x, eq_align_y);
    YELLOW.setAlign(eq_align_x, eq_align_y);
    GREEN.setAlign(eq_align_x, eq_align_y);
  }

  public void setWeight(int w) {
    RED.setWeight(w);
  }

  public void setStroke(int c) {
    RED.setStroke(c);
  }

  public void strokeOn() {
    RED.strokeOn();
  }

  public void strokeOff() {
    RED.strokeOff();
  }

  public void setValueColor(int _c) {
    eq_value_color = _c;
  }

  public void setLabel(String _t) {
    eq_label = _t;
    label_set = true;
  }

  public void clearLabel() {
    eq_label = "";
    label_set = false;
  }

  public void setLabelColor(int _c) {
    eq_label_color = _c;
  }

  public void setLabelFont(PFont ff) {
    label_font = ff;
  }

  public void setFont(PFont ff) {
    eq_font = ff;
    VALUE.setFont(eq_font);
  }

  public void setPeak(int p) {
    VALUE.setPeakColor( getColor(p) );
    VALUE.setPeak(p);
  }

  public void move(float _x, float _y) {
    eq_x = _x;
    eq_y = _y;
    RED.location.x = eq_x;
    RED.location.y = eq_y;
    ORANGE.location.x = eq_x;
    ORANGE.location.y = eq_y;
    YELLOW.location.x = eq_x;
    YELLOW.location.y = eq_y;
    GREEN.location.x = eq_x;
    GREEN.location.y = eq_y;
    VALUE.location.x = eq_x;
    VALUE.location.y = eq_y;
  }

  public void move(PVector newLoc) {
    eq_x = newLoc.x;
    eq_y = newLoc.y;
    RED.location.x = eq_x;
    RED.location.y = eq_y;
    ORANGE.location.x = eq_x;
    ORANGE.location.y = eq_y;
    YELLOW.location.x = eq_x;
    YELLOW.location.y = eq_y;
    GREEN.location.x = eq_x;
    GREEN.location.y = eq_y;
    VALUE.location.x = eq_x;
    VALUE.location.y = eq_y;
  }

  private int getColor(int v) {
    int return_color;
    if (v < VALUE.MAX * 0.5f) {
      return_color = color(0, 255, 0); // less then half is green
    } 
    else if (v > VALUE.MAX * 0.5f && v < VALUE.MAX * 0.75f) {
      return_color = color(255, 255, 0); // then yellow
    } 
    else if (v > VALUE.MAX * 0.75f && v < VALUE.MAX * 0.9f) {
      return_color = color(229, 128, 0);  // then orange
    } 
    else {
      return_color = color(255, 0, 0);
    }
    return return_color;
  }

  private void updateColor() { 
    eq_value_color = getColor(eq_value);
  }

  public void setValue(int _v) {
    eq_value = _v;
    VALUE.setValue(eq_value);
    updateColor();
    VALUE.setColor(eq_value_color);
  }

  public void drawLabel() {
    buffer.textAlign(RED.base_align_x, CENTER);
    buffer.textFont(label_font);
    buffer.fill(eq_label_color);
    buffer.pushMatrix();
    buffer.translate(RED.location.x, RED.location.y);
    if (RED.base_align_y == BOTTOM) {
      buffer.rotate(radians(-90));
    } 
    else if (RED.base_align_y == TOP) {
      buffer.rotate(radians(-90));
    }

    float x = 0;
    if (RED.base_align_x == LEFT)   x = 3;
    if (RED.base_align_x == RIGHT)  x = -3;
    if (RED.base_align_x == CENTER && RED.base_align_y == BOTTOM) x = 3 + (buffer.textWidth(eq_label) / 2);
    if (RED.base_align_x == CENTER && RED.base_align_y == TOP) x = 0 - (buffer.textWidth(eq_label) / 2) - 3;
    buffer.text(eq_label, x, 0);
    buffer.popMatrix();
  }

  public void drawAll() {
    RED.display();
    ORANGE.display();
    YELLOW.display();
    GREEN.display();
    VALUE.display(eq_value);
    if (label_set) drawLabel();
  }

  public void display(int _v) {
    setValue(_v);
    drawAll();
  }

  public void display() {
    drawAll();
  }
}


EQ eq;

public void setupEQ() {
  eq = new EQ();
  println("SETUP EQ ...");
}

public void doEQ() {
  buffer.blendMode(BLEND);
  buffer.background(0);
  eq.display();
}


class EQ {

  PFont volumeFont, eqFont, audioFont, tFont;

  eqBar volume; //, eq0, eq1, eq2, eq3, eq4, eq5, eq6, eq7, eq8;
  eqBar[] spec = new eqBar [9];

  EQ() {

    volumeFont = createFont("Impact", 10, true);  //"Verdana-Bold"
    eqFont     = createFont("Verdana-Bold", 10, true);
    tFont      = createFont("Verdana-Bold", 11, true);

    volume = new eqBar( buffer.width / 2, buffer.height - 6, buffer.width - 16, 10, CENTER, CENTER, tFont);
    volume.VALUE.textColor(color(0, 255));
    volume.VALUE.textOffset(0);
    volume.VALUE.setMax(100);
    volume.VALUE.setPeakWeight(1);
    volume.VALUE.peakOn();
    //volume.setLabel("VOLUME");
    volume.strokeOff();

    int x = 16;

    for (int i = 0; i < 9; i++) {
      spec[i] = new eqBar( x, 60, 14, 58, CENTER, BOTTOM, eqFont);
      spec[i].VALUE.textColor(color(255, 255));
      spec[i].VALUE.textOffset(10);
      spec[i].VALUE.setMax(100);
      spec[i].VALUE.setPeakWeight(1);
      spec[i].VALUE.peakOn();
      spec[i].strokeOff(); 
      spec[i].setLabelFont(tFont);
      spec[i].setLabelColor(color(0));
      spec[i].setLabel(round(audio.fft.getAverageCenterFrequency(i)) + " Hz");

      x += 16;
    }
  }

  public void show() {

    //buffer.background(0);
    volume.setPeak(audio.volume.peak);
    volume.display(audio.volume.value);

    for (int i = 0; i < 9; i++) {
      spec[i].setPeak( audio.averageSpecs[i].peak );
      spec[i].display( audio.averageSpecs[i].value );
      //spec[i].display(audio.AVERAGES[i]);
    }
  }

  public void display() {
    buffer.hint(DISABLE_DEPTH_TEST);
    show();
    buffer.hint(ENABLE_DEPTH_TEST);
  }
}

// COULD USE A REWRITE

Rainbow rainbow;

final String[] RAINBOW_STR = { 
  "WHEEL", "TUNNEL"
};

public void setupRainbow() {
  rainbow = new Rainbow();
  rainbow.audioOff();
  println("RAINBOW SETUP ...");
}

// need to rewrite this

public void doRainbow() {
  PVector kinectUser = getSingleUser();
  rainbow.setLocation(kinectUser.x, kinectUser.y );
  rainbow.setCycle(audio.BPM);
  buffer.blendMode(BLEND);
  buffer.background(0);
  rainbow.display();
}


class Rainbow {
  final int MODE_WHEEL  = 0;
  final int MODE_TUNNEL = 1;
  final int TOTAL_MODES = 2;
  float horizontal = 0;
  float vertical = 0;
  float random_test = 0;
  int mode = 1;
  boolean use_audio;
  PVector location;                       // the location of the center of the wheel
  PVector size;
  PVector last_size;
  int last_cycle, bi;                           // the last time the colors were cycled
  int cycle_time = 100;                // the time between cycling colors
  int[] colors = new int [8];
  int[] default_colors = {
    color(255, 0, 0), color(255, 127, 0), color(255, 127, 0), color(127, 255, 0), 
    color(0, 255, 0), color(0, 255, 127), color(0, 127, 255), color(0, 0, 255)
  };


  Rainbow() {
    location = new PVector();
    size = new PVector();
    last_size = new PVector();
    resetColors();
    resetSize();
    last_cycle = millis();
    use_audio = false;
  }

  public void resetSize() {
    size.set(buffer.width*3, buffer.height*6);
    last_size.set(size.x*1.1f, size.y*1.1f);
  }

  public void setCycle(int t) {
    int temp = PApplet.parseInt(map(t, 1, 200, 172, 1));
    cycle_time = temp;
  }

  private void cycleColors() {
    int saved = colors[0];
    for (int i = 0; i < (colors.length - 1); i++) {
      colors[i] = colors[i + 1];
    }
    colors[colors.length - 1] = saved;
  }

  private void cycleColors(int c) {
    for (int i = 0; i < (colors.length - 1); i++) {
      colors[i] = colors[i + 1];
    }
    colors[colors.length - 1] = c;
  }

  public void resetColors() {
    arrayCopy(default_colors, colors);
  }

  public void setLocation(float x, float y) {
    location.x = round(x);
    location.y = round(y);
  }

  public void audioOn() {
    use_audio = true;
    resetColors();
    cycle_time = 50;
  }

  public void audioOff() {
    use_audio = false;
    resetColors();
    cycle_time = 50;
  }

  private void check() {
    int cTime = millis();
    if (cTime - last_cycle > cycle_time) {
      if (use_audio) cycleColors(audio.colors.background); 
      else cycleColors();
      last_cycle = cTime;
    }

    if ( audio.isOnBeat() ) {
      random_test = random(0, 1);
      if (random_test < 0.65f) {
        mode = round( random(TOTAL_MODES - 1) );
      }
    }
  }

  public void doWheel() {
    buffer.noStroke();
    //buffer.strokeWeight(0.5);

    for (int i = 0; i < colors.length; i++) {
      int rnd = round( random(-1,1) );
      //int h_spec = i + rnd;
      //int v_spec = i - 1 + rnd;
        
      //if (v_spec < 0) v_spec = colors.length - 1;
      //if (v_spec > colors.length) v_spec = 0;
      //if (h_spec < 0) h_spec = colors.length - 1;
      //if (h_spec > colors.length) h_spec = 0;
      
      //rnd = round( random(-1,1) );

      //horizontal = map(audio.averageSpecs[h_spec].value, 0, 100, 20, 5);
      //vertical   = map(audio.averageSpecs[v_spec].value, 0, 100, 10, 1);
      
      horizontal = map(audio.volume.value, 0, 100, 20, 10 + (rnd * 2) );
      vertical   = map(audio.volume.value, 0, 100, 10, 5 + rnd);

      buffer.fill( mapByVol( colors[i] ) );
      if ((i + rnd) % 2 == 0) buffer.fill( audio.colors.get(i) );
      buffer.triangle(location.x, location.y, 0, (i * 10) + vertical, 0, ((i + 1) * 10) - vertical);
      buffer.triangle(location.x, location.y, (i * 20) + horizontal, 0, ((i + 1) * 20) - horizontal, 0);

      bi = 7 - i;
      buffer.fill( mapByVol( colors[bi] ) );
      if ((i + rnd) % 2 == 0) buffer.fill( audio.colors.get(bi) );
      buffer.triangle(location.x, location.y, buffer.width, (i * 10) + vertical, buffer.width, ((i + 1) * 10) - vertical);
      buffer.triangle(location.x, location.y, (i * 20) + horizontal, buffer.height, ((i + 1) * 20) - horizontal, buffer.height);
    }
  }

  public void doTunnel() {
    buffer.rectMode(CENTER);
    buffer.noStroke();

    buffer.pushMatrix();
    buffer.translate(location.x, location.y);

    for (int j = 0; j < 2; j++) {
      for (int i = 0; i < colors.length; i++) {
        int rnd = round( random(-1,1) );
        int h_spec = i + rnd;
        int v_spec = i - 1 + rnd;
        
        if (v_spec < 0) v_spec = colors.length - 1;
        if (v_spec > colors.length) v_spec = 0;
        if (h_spec < 0) h_spec = colors.length - 1;
        if (h_spec > colors.length) h_spec = 0;
        
        rnd = round( random(-1,1) );
        
        
        if ((i + rnd) % 2 == 0) {
          //buffer.fill(0);
          //buffer.fill(colors[i]);
          buffer.fill( audio.colors.get(i) );
          horizontal = map(audio.averageSpecs[h_spec].value, 0, 100, size.x, last_size.x + last_size.x);
          vertical   = map(audio.averageSpecs[v_spec].value, 0, 100, size.y, last_size.y + last_size.y);
        } else {
          //buffer.fill(0);
          buffer.fill( mapByVol( colors[i] ) );
          horizontal = map(audio.averageSpecs[h_spec].value, 0, 100, last_size.x, size.x);
          vertical   = map(audio.averageSpecs[v_spec].value, 0, 100, last_size.y, size.y);
        }
        buffer.rect(0, 0, horizontal, vertical);
        last_size.set(size.x, size.y);
        size.div(1.25f);
      }
    }

    buffer.fill(0);
    buffer.rect(0, 0, size.x, size.y, 5);
    buffer.popMatrix();
    resetSize();
  }


  public void display() {
    check();
    if (mode == MODE_WHEEL) doWheel();
    if (mode == MODE_TUNNEL) doTunnel();
    //doTunnel();
    buffer.noStroke();  // reset to no stroke
  }
}

// NEED TO HAVE SHAPES FOLLOW USERS



final int TOTAL_PARTICLES = 8;
final float MARGIN = -10;


RShape[] svgs;
Shapes shapes;
Slider shapeSlider;

public void setupShapes() {
  RG.init(this);
  RG.ignoreStyles(true);
  
  // load the svgs
  String[] shape_file_names = getFileNames("shapes", "svg"); // get the svg file names

  svgs = new RShape [shape_file_names.length];               // set the length of the svg array
  for (int i = 0; i < svgs.length; i++) {
    String fileName = shape_file_names[i];
    String[] test = split(fileName, '\\');
    String name = test[test.length - 1];
    svgs[i] = RG.loadShape(fileName);
    svgs[i] = RG.centerIn(svgs[i], buffer, MARGIN);
    svgs[i] = RG.polygonize(svgs[i]);
    
    svgs[i].setName(name);
    if (name.equals("distrikt.svg") == true) city.setDistrikt(i);
    println(i + ": " + svgs[i].name);
  }

  shapes = new Shapes();

  int x = TAB_START + 10;
  int y = WINDOW_YSIZE - 80;
  int m = svgs.length - 1;

  // controler name, min, max, value, x, y, width, height, label, handle size, text size, type, move to tab
  shapeSlider = 
    createSlider("doShapeSlider", 0, m, shapes.current, x, y, TAB_MAX_WIDTH + 20, 40, "shapes", 20, lFont, Slider.FLEXIBLE, DISPLAY_STR[DISPLAY_MODE_SHAPES]);

  // controll name, text name, x, y, width, height, text size, value, move 2 tab
  createToggle("allowShapeSwitch", "Random", TAB_START + 20, DEBUG_WINDOW_START + 50, 50, 50, mFont, ControlP5.DEFAULT, shapes.switchOn, DISPLAY_STR[DISPLAY_MODE_SHAPES]);
  createToggle("allowShapeZ", "Scale Z", TAB_START + 80, DEBUG_WINDOW_START + 50, 50, 50, mFont, ControlP5.DEFAULT, shapes.particles[0].scaleZ, DISPLAY_STR[DISPLAY_MODE_SHAPES]);

  println("Shapes SETUP ...");
}

public void doShapes() {
  buffer.blendMode(ADD);
  shapes.display();
  buffer.blendMode(BLEND);
}

public void doShapeSlider(int v) {
  shapes.setShape(v);
}

public void allowShapeSwitch(boolean b) {
  shapes.switchOn = b;
}

public void allowShapeZ(boolean b) {
  for (int i = 0; i < shapes.particles.length; i++) {
    shapes.particles[i].scaleZ = b;
  }
}

class Shapes {
  Particle[] particles;
  int current = 0;
  float switchValue = 0.65f;
  boolean switchOn = true;

  Shapes() {
    // create the particles
    particles = new Particle [TOTAL_PARTICLES];
    int start_shape = PApplet.parseInt(random(svgs.length - 1));
    for (int i = 0; i < particles.length; i++) {
      particles[i] = new Particle(i % 4);
      particles[i].setShape( start_shape );
    }
  }

  public void randomShape() {
    int new_shape = round(random(svgs.length - 1));
    setShape(new_shape);
    shapeSlider.setValue(current);
  }

  public void setShape(int v) {
    current = v;
    for (Particle p: particles) {
      p.setShape(v);
    }
    String name = svgs[particles[0].pShape].name;
    cp5.getController("doShapeSlider").getCaptionLabel().setText(name);
  }

  public void update() {
    if ( audio.isOnBeat() ) {
      float test = random(0, 1);
      if (test < switchValue && switchOn) {
        randomShape();
      }
    }
  }

  public void display() {
    update();
    for (Particle p: particles) {
      p.update();
      p.display();
    }
  }
}

class Particle {
  int pSpec;
  int pShape;
  int TOTAL_SHAPES;
  int minZ = -150;
  int maxZ = 10;
  float minPush = 0.025f;
  float maxPush = 10.0f;

  final int MAX_SPEC = 4;

  PVector location;
  PVector velocity;
  PVector acceleration;

  float pAngle;
  float pDrag = 0.01f;

  int pColor;

  boolean scaleZ = true;

  Particle(int _spec) {
    pSpec   = _spec;
    defaults();
  }

  public void defaults() {
    location = new PVector();
    velocity = new PVector();
    acceleration = new PVector();
    pColor   = color(64);
    reset();
  }

  public void reset() {
    pShape   = 0;
    pAngle   = 0;
    location.set( round(random(buffer.width)), round(random(buffer.height)) );
    velocity = PVector.random2D();
    velocity.normalize();
    acceleration.set(0, 0);
  }

  public void set(PVector vec) {
    location.set(vec.x, vec.y);
  }

  public void set(float x, float y) {
    location.x = x;
    location.y = y;
  }

  public void setShape(int index) {
    if ( index > (svgs.length - 1) ) index = 0;
    pShape = index;
  }

  public void setSpec(int spec) {
    if (spec > MAX_SPEC) spec = 0;
    pSpec = spec;
  }

  public int getColor() {
    if (brightness(audio.colors.background) < 32 ) {
      return color(brightness(audio.colors.grey)+16);
    } 
    else {
      return audio.colors.users[pSpec];
    }
  }

  public void update() {
    location.add(velocity);

    int j = pSpec - 1;
    if ( j < 0 ) j = MAX_SPEC - 1;

    //pAngle = map(audio.averageSpecs[pSpec].value, 0, 100, -360, 360);
    
    if (scaleZ) location.z = map(audio.averageSpecs[j].value, 0, 100, minZ, maxZ);
    else location.z = minZ;

    if ( location.x < 0 + minZ || location.x > buffer.width - minZ) {
      velocity.x *= -1;
    }
    if ( location.y < 0 + (minZ / 2) || location.y > buffer.height - (minZ / 2)) {
      velocity.y *= -1;
    }

    float force = map(audio.averageSpecs[pSpec].value, 0, 100, minPush, maxPush);
    velocity.normalize();
    velocity.mult(force);

    pColor = getColor();
  }

  public void display() {
    //buffer.pushStyle();
    //buffer.strokeWeight(1);
    //buffer.stroke(color(2,2,2));
    buffer.fill(pColor);
    buffer.pushMatrix();
    buffer.translate(location.x, location.y, location.z);
    svgs[pShape].draw(buffer);
    buffer.popMatrix();
    //buffer.popStyle();
  }
}

// ADD COMMENTS



MovieClips movies;
Slider movieSlider;
Slider movieSpeed;

public void setupClips() {
  println("VIDEO CLIPS - starting setup...");
  movies = new MovieClips(this, "videos");

  int x = TAB_START + 10;
  int y = WINDOW_YSIZE - 80;
  int m = movies.clips.length - 1;

  // controler name, min, max, value, x, y, width, height, label, handle size, text size, type, move to tab
  movieSlider = 
    createSlider("doMovieSlider", 0, m, movies.current, x, y, TAB_MAX_WIDTH + 20, 40, "Brightness", 20, lFont, Slider.FLEXIBLE, DISPLAY_STR[DISPLAY_MODE_CLIPS]);
  movieSpeed = 
    createSlider("doMovieSpeed", movies.minSpeed, movies.maxSpeed, movies.speed, TAB_MAX_WIDTH-220, DEBUG_WINDOW_START+50, 220, 50, "Speed", 14, mFont, Slider.FLEXIBLE, DISPLAY_STR[DISPLAY_MODE_CLIPS]);

  // controll name, text name, x, y, width, height, text size, value, move 2 tab
  createToggle("allowMovieSwitch", "Random", TAB_START + 20, DEBUG_WINDOW_START + 50, 50, 50, mFont, ControlP5.DEFAULT, movies.switchOn, DISPLAY_STR[DISPLAY_MODE_CLIPS]);
  createToggle("allowMovieJumps", "Jump", TAB_START + 80, DEBUG_WINDOW_START + 50, 50, 50, mFont, ControlP5.DEFAULT, movies.jumpsOn, DISPLAY_STR[DISPLAY_MODE_CLIPS]);
  createToggle("allowMovieBPM", "BPM", TAB_START + 140, DEBUG_WINDOW_START + 50, 50, 50, mFont, ControlP5.DEFAULT, movies.bpmOn, DISPLAY_STR[DISPLAY_MODE_CLIPS]);

  createTextfield("setMinSpeed", "min speed", TAB_MAX_WIDTH + 10, DEBUG_WINDOW_START+55, 50, 20, nf(movies.minSpeed, 1, 0), sFont, ControlP5.FLOAT, DISPLAY_STR[DISPLAY_MODE_CLIPS]);
  cp5.getController("setMinSpeed").captionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE);
  createTextfield("setMaxSpeed", "max speed", TAB_MAX_WIDTH + 10, DEBUG_WINDOW_START+80, 50, 20, nf(movies.maxSpeed, 1, 0), sFont, ControlP5.FLOAT, DISPLAY_STR[DISPLAY_MODE_CLIPS]);
  createTextfield("setMaxBPM", "max bpm", TAB_MAX_WIDTH + 70, DEBUG_WINDOW_START+65, 50, 30, nf(movies.maxBPM, 1), sFont, ControlP5.INTEGER, DISPLAY_STR[DISPLAY_MODE_CLIPS]);
  cp5.getController("setMaxBPM").captionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(5);

  println("VIDEO CLIPS - setup finished!");
}

public void doMovieSlider(int v) {
  movies.setClip(v);
}

public void doMovieSpeed(float v) {
  if (!movies.bpmOn) movies.setSpeed(v);
}

public void setMinSpeed(String valueString) {
  float minSpeed  = PApplet.parseFloat(valueString);
  movies.minSpeed = minSpeed;
  movieSpeed.setMin(minSpeed);
  movieSpeed.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(5);
  movieSpeed.getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(5);
}

public void setMaxSpeed(String valueString) {
  float maxSpeed  = PApplet.parseFloat(valueString);
  movies.maxSpeed = maxSpeed;
  movieSpeed.setMax(maxSpeed);
  movieSpeed.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(5);
  movieSpeed.getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(5);
}

public void setMaxBPM(String valueString) {
  int maxBPM  = PApplet.parseInt(valueString);
  movies.maxBPM = maxBPM;
}

public void allowMovieSwitch(boolean b) {
  movies.switchOn = b;
}

public void allowMovieJumps(boolean b) {
  movies.jumpsOn = b;
}

public void allowMovieBPM(boolean b) {
  movies.bpmOn = b;
}

public void doClips() {
  //buffer.blendMode(ADD);
  buffer.background(0);
  movies.draw();
  buffer.blendMode(BLEND);
}

class MovieClips {
  float speed = 1.0f;
  float minSpeed = 0.5f;
  float maxSpeed = 1.0f;
  int maxBPM = 130;

  int current = 0;
  Movie[] clips;
  int switch_count = 0;
  int jump_count = 0;
  String[] names;

  boolean switchOn = true;
  boolean jumpsOn  = true;
  boolean bpmOn    = true;

  MovieClips(PApplet app, String dir) {
    String[] movie_files = getFileNames(dir, "mov");
    clips = new Movie [movie_files.length];
    names = new String [movie_files.length];

    for (int i = 0; i < clips.length; i++) {
      //String[] parts = movie_files[i].split(java.io.File.pathSeparatorChar);
      names[i] = movie_files[i].substring(movie_files[i].lastIndexOf("\\")+1);
      println("CLIPS - loading clip - " + i + ": " + names[i]);
      clips[i] = new Movie(app, movie_files[i]);
      clips[i].loop();
    }
  }

  public void setClip(int v) {
    if (switch_count > 7) {
      switch_count = 0;
      int seed = round(random(frameCount));
      randomSeed(seed);
    }
    
    current = v;
    cp5.getController("doMovieSlider").getCaptionLabel().setText(names[current]);
    switch_count++;
  }

  public void setRandomClip() {
    int next = round( random(clips.length - 1) );
    setClip(next);
    movieSlider.setValue(current);
    //cp5.getController("doMovieSlider").setValue(current);
  }

  public void setSpeed(float v) {
    clips[current].speed(v);
    speed = v;
  }
  
  public void doJump() {
    if (jump_count > 7) {
      jump_count = 0;
      int seed = round(random(frameCount));
      noiseSeed(seed);
    }
    float spot = noise(xoff) * clips[current].duration();
    clips[current].jump( spot );
    jump_count++;
  }

  public void update() {
    // switch clips?
    if ( audio.isOnBeat() ) {
      float test = random(0, 1);
      if (test > 0.75f && switchOn) {
        setRandomClip();
      } 
      else {
        if (jumpsOn) doJump();
      }
    }

    // read the new frame
    if (clips[current].available() == true) {
      clips[current].read();
    }

    // set the speed of the next frame according to the current BPM
    if (bpmOn) {
      speed = map(audio.BPM, 0, maxBPM, minSpeed, maxSpeed);
      clips[current].speed(speed);
      movieSpeed.setValue(speed);
    }
  }

  public void draw() {
    update();
    buffer.image(clips[current], 0, 0); //, buffer.width, buffer.height);
  }
}


  


float WALL_WATTS = 0;
float MAX_WATTS = 0;

int[][] gammaTable;


final int TEENSY_TOTAL  = 10;
final int TEENSY_WIDTH  = 80;
final int TEENSY_HEIGHT = 16;
final int BAUD_RATE = 921600; //115200;

final float RED_GAMMA = 2.1f;
final float GREEN_GAMMA = 2.1f;
final float BLUE_GAMMA = 2.1f;

Teensy[] teensys = new Teensy [TEENSY_TOTAL];

public void setupTeensys() {
  println("starting teensy setup...");
  String[] list = Serial.list();
  delay(20);
  println("Serial Ports List:");
  println(list);

  teensys[0] = new Teensy(this, 0, "COM12", false);
  teensys[1] = new Teensy(this, 1, "COM8", true);
  teensys[2] = new Teensy(this, 2, "COM11", false);
  teensys[3] = new Teensy(this, 3, "COM9", false);
  teensys[4] = new Teensy(this, 4, "COM10", true);
  teensys[5] = new Teensy(this, 5, "COM5", false);
  teensys[7] = new Teensy(this, 6, "COM6", false);
  teensys[6] = new Teensy(this, 7, "COM4", true);
  teensys[8] = new Teensy(this, 8, "COM3", false);  
  teensys[9] = new Teensy(this, 9, "COM7", false);


  //println(gammaTable);

  println("TEENSYS SETUP!!");
  println();
}

public void setupGamma() {
  gammaTable = new int [256][3];
  float d;
  for (int i = 0; i < 256; i++) {
    d =  i / 255.0f;
    gammaTable[i][0] = floor(255 * pow(d, RED_GAMMA) + 0.5f); // RED
    gammaTable[i][1] = floor(255 * pow(d, GREEN_GAMMA) + 0.5f); // GREEN
    gammaTable[i][2] = floor(255 * pow(d, BLUE_GAMMA) + 0.5f); // BLUE
  }
}



class Teensy {
  boolean threadData; // teensy is master
  int     id;       // id of the image that will be sent to teensy
  float   watts;
  byte[]  data;     // converted image data that gets sent
  Serial  port;     // serial port of the teensy
  tThread t;
  String  portName; // serial port name
  int sendTime = 0;
  int maxSend = 0;

  Teensy(PApplet parent, int ID, String name, boolean threadData) {
    println("Setting up teensy: " + name + " ...");
    data     = new byte[(TEENSY_WIDTH * TEENSY_HEIGHT * 3) + 3]; // setup the data array
    this.threadData = threadData;  // should we thread the data?
    portName = name;    // set the port name
    id       = ID;      // set the id 

    // setup serial port
    try {
      port = new Serial(parent, portName, BAUD_RATE);           // create the port
      if (port == null) throw new NullPointerException();    // was the port created?
      port.write('?');                                       // send ident char to teensy
    } 
    catch (Throwable e) {  // got errors?
      println("Serial port " + portName + " does not exist or is non-functional");
      exit();
    }

    delay(100);

    String line = port.readStringUntil(10);  // give me everything up to the linefeed

    if (line == null) {  //  no data back from the teensy? 
      println("Serial port " + portName + " is not responding.");
      println("Is it really a Teensy 3.0 running VideoDisplay?");
      exit();
    }

    String param[] = line.split(",");  // get the param's (which we don't really need)
    if (param.length != 12) { // didn't get 12 back?  bad news...
      println("Error: port " + portName + " did not respond to LED config query");
      exit();
    }

    println(portName + " SETUP!!");
    if (threadData) {
      t = new tThread(port);
      t.start();
    } 
    else {
      println(data.length);
    }
  }

  public void clear() {
    port.write('!');
    if (threadData) {
      t.done();
      t.interrupt();
    }
  }

  public int updateColor(int c) {
    int r = (c >> 16) & 0xFF;  // get the red
    int g = (c >> 8) & 0xFF;   // get the green
    int b = c & 0xFF;          // get the blue 

    r = PApplet.parseInt( map( r, 0, 255, 0, MAX_BRIGHTNESS ) );  // map red to max LED brightness
    g = PApplet.parseInt( map( g, 0, 255, 0, MAX_BRIGHTNESS ) );  // map green to max LED brightness
    b = PApplet.parseInt( map( b, 0, 255, 0, MAX_BRIGHTNESS ) );  // map blue to max LED brightness

    r = gammaTable[r][0];  // map red to gamma correction table
    g = gammaTable[g][1];  // map green to gamma correction table
    b = gammaTable[b][2];  // map blue to gamma correction table

    float pixel_watts = map(r + g + b, 0, 768, 0, 0.24f);  // get the wattage of the pixel
    watts += pixel_watts; // add pixel wattage to total wattage count (watts is added to WALL_WATTS in wall tab)

    return color(g, r, b, 255); // translate the 24 bit color from RGB to the actual order used by the LED wiring.  GRB is the most common.
  }

  // converts an image to OctoWS2811's raw data format.
  // The number of vertical pixels in the image must be a multiple
  // of 8.  The data array must be the proper size for the image.
  public void update() { 
    watts = 0;

    int offset = 3;
    int x, y, xbegin, xend, xinc, mask;
    int linesPerPin = wall.teensyImages[id].height / 8;
    int pixel[] = new int[8];

    boolean layout = true;

    for (y = 0; y < linesPerPin; y++) {
      if ((y & 1) == (layout ? 0 : 1)) {
        // even numbered rows are left to right
        xbegin = 0;
        xend = wall.teensyImages[id].width;
        xinc = 1;
      } 
      else {
        // odd numbered rows are right to left
        xbegin = wall.teensyImages[id].width - 1;
        xend = -1;
        xinc = -1;
      }
      for (x = xbegin; x != xend; x += xinc) {
        for (int i=0; i < 8; i++) {
          // fetch 8 pixels from the image, 1 for each pin
          pixel[i] = wall.teensyImages[id].pixels[x + (y + linesPerPin * i) * wall.teensyImages[id].width];
          pixel[i] = updateColor(pixel[i]);
        }
        // convert 8 pixels to 24 bytes
        for (mask = 0x800000; mask != 0; mask >>= 1) {
          byte b = 0;
          for (int i=0; i < 8; i++) {
            if ((pixel[i] & mask) != 0) b |= (1 << i);
          }
          data[offset++] = b;
        }
      }
    }
  }

  public void sendData() {
    port.write(data);  // send data over serial to teensy
  }

  public void send() {
    sendTime = 0;
    int stime = millis();
    update();

    data[0] = '*'; 
    data[1] = 0; 
    data[2] = 0;

    if (threadData) {
      t.send(data);
      sendTime = t.getTime();
    }
    else {
      sendData();
    }
    sendTime = millis() - stime;
    maxSend = max(sendTime, maxSend);
  }
}

class tThread extends Thread {
  Serial  port;
  int send_time;
  boolean running;
  boolean sendData;
  byte[] data;

  tThread(Serial port) {
    this.port = port;
    setDaemon(true);
    setPriority(3);
    //println(getPriority());
    running = false;
    sendData = false;
    send_time = 0;
  }

  public void start() {
    running = true;
    super.start();
  }

  public synchronized void send(byte[] data) {
    this.data = data;
    sendData = true;
  }

  public int getTime() {
    return send_time;
  }

  public void done() {
    running = false;
  }

  public void run() {
    while (running) {
      if (sendData) {
        int stime = millis();
        sendData = false;
        port.write(data);  // send data over serial to teensy
        send_time = millis() - stime;
      }
    }
  }
}





Comparator<PVector> PVectorByX;
Comparator<PVector> PVectorByY;
Comparator<PVector> PVectorByZ;

Comparator<User> UserByX;
Comparator<User> UserByY;
Comparator<User> UserByZ;
Comparator<User> UserByI;

int[] fibonacci = { 
  1, 1, 2, 3, 5, 8, 13, 21, 34, 55
};

public void setupUtils() {
  PVectorByX = new PVectorXComparator();
  PVectorByY = new PVectorYComparator();
  PVectorByZ = new PVectorZComparator();
  UserByX = new UserXComparator();
  UserByY = new UserYComparator();
  UserByZ = new UserZComparator();
  UserByI = new UserIComparator();
} 

// multiply a value to the fibonacci (kind of...)
public float fib( float v, float s, float e) {
  int i = round( map(v, s, e, 0, 9) );
  return v * fibonacci[i];
}

public int fib( int v, float s, float e) {
  int i = round( map(v, s, e, 0, 9) );
  return round( v * fibonacci[i] );
}

public PVector getSingleUser() {
  float x, y;
  if (kinectOn) {
    if (kinect.users != null && kinect.users.length > 0 && kinect.users[0].onScreen() ) {
      x = kinect.users[0].x; 
      y = kinect.users[0].y;
    } 
    else {
      x = buffer.width / 2; 
      y = buffer.height / 2;
    }
  }
  else {
    x = buffer.width / 2; 
    y = buffer.height / 2;
  }
  
  return new PVector(x,y,0);
  
}


// delay() removed so we have to make our own 
public void delay(int mil) {
  int d = millis();
  while (millis () - d < mil) {  
    // do nothing
  }
}

public String[] getFileNames(String dir, String ext) {
  String thisdir = sketchPath + "\\data\\" + dir;
  File file = new File(thisdir);
  String[] raw_names = file.list();


  int count = 0;
  for (int i = 0; i < raw_names.length; i++) {
    String[] parts = raw_names[i].split("\\.(?=[^\\.]+$)");
    if (parts[parts.length - 1].equals(ext) == true) count++;
  }

  String[] file_names = new String [count];
  count = 0;
  for (int i = 0; i < raw_names.length; i++) {
    String[] parts = raw_names[i].split("\\.(?=[^\\.]+$)");
    if (parts[parts.length - 1].equals(ext) == true) {
      file_names[count] = thisdir + "\\" + raw_names[i];
      count++;
    }
  }

  return file_names;
}

// maps color to volume with a min of 48
public int mapByVol(int rgb) {
  int tr = (rgb >> 16) & 0xFF;                         // get the red value of the color
  int tg = (rgb >> 8) & 0xFF;                          // get the green value of the color
  int tb =  rgb & 0xFF;                                // get the blue value of the color
  float r = map(audio.volume.value, 0, 100, 8, tr);  // map the volume to the redness of the color
  float g = map(audio.volume.value, 0, 100, 8, tg);  // map the volume to the greenness of the color
  float b = map(audio.volume.value, 0, 100, 8, tb);  // map the volume to the blueness of the color
  return color(r, g, b);                               // return the new color
}

// To sort PVectors by their X values.
class PVectorXComparator implements Comparator<PVector> {

  public int compare(PVector pv1, PVector pv2) {
    if (pv1.x < pv2.x) return -1;
    else return 1;
  }
}

// To sort PVectors by their Y values.
class PVectorYComparator implements Comparator<PVector> {

  public int compare(PVector pv1, PVector pv2) {
    if (pv1.y < pv2.y) return -1;
    else return 1;
  }
}

// To sort PVectors by their Z values.
class PVectorZComparator implements Comparator<PVector> {

  public int compare(PVector pv1, PVector pv2) {
    if (pv1.z < pv2.z) return -1;
    else return 1;
  }
}


// To sort Users by their X values.
class UserXComparator implements Comparator<User> {

  public int compare(User u1, User u2) {
    if ( !u1.isActive() )  return 1;
    if ( !u2.isActive() )  return -1;
    if (u1.x != u1.x)      return 1;  // u1.x is NaN
    if (u2.x != u2.x)      return -1; // u2.x is NaN
    if (u1.isSet == false) return 1;  // u1 is not active
    if (u2.isSet == false) return -1; // u2 is not active

    if (u1.x < u2.x) return -1;
    else return 1;
  }
}

// To sort Users by their Y values.
class UserYComparator implements Comparator<User> {

  public int compare(User u1, User u2) {
    if ( !u1.isActive() )  return 1;
    if ( !u2.isActive() )  return -1;
    if (u1.y != u1.y)      return 1;  // u1.x is NaN
    if (u2.y != u2.y)      return -1; // u2.x is NaN
    if (u1.isSet == false) return 1;  // u1 is not active
    if (u2.isSet == false) return -1; // u2 is not active

    if (u1.y < u2.y) return -1;
    else return 1;
  }
}

// To sort Users by their Z values.
class UserZComparator implements Comparator<User> {

  public int compare(User u1, User u2) {
    if ( !u1.isActive() )  return 1;
    if ( !u2.isActive() )  return -1;
    if (u1.z != u1.z)      return 1;  // u1.x is NaN
    if (u2.z != u2.z)      return -1; // u2.x is NaN
    if (u1.isSet == false) return 1;  // u1 is not active
    if (u2.isSet == false) return -1; // u2 is not active

    if (u1.z < u2.z) return -1;
    else return 1;
  }
}

// To sort Users by their Z values.
class UserIComparator implements Comparator<User> {

  public int compare(User u1, User u2) {
    if (u1.i < u2.i) return -1;
    else return 1;
  }
}

// COULD USE A REWRITE



// Wall Setup
final int COLUMNS = 160;             // the amount of LEDs per column (x)
final int ROWS    = 80;              // the amount of LEDs per row (y)
final int TOTAL   = COLUMNS * ROWS;  // the total amount of LEDs on the wall

final int MUTI = 6;

final int DEBUG_PIXEL_SIZE      = 3;  // size of each debug pixel
final int DEBUG_PIXEL_SPACING_X = 3;  // the X spacing for each debug pixel
final int DEBUG_PIXEL_SPACING_Y = 3;  // the X spacing for each debug pixel

final int DEBUG_REAL_PIXEL_SIZE_X = DEBUG_PIXEL_SIZE + DEBUG_PIXEL_SPACING_X; // the total X size of each debug pixel
final int DEBUG_REAL_PIXEL_SIZE_Y = DEBUG_PIXEL_SIZE + DEBUG_PIXEL_SPACING_Y; // the total Y size of each debug pixel

final int DEBUG_WINDOW_YSIZE = 220;                                       // the y size of the debug window
final int INFO_WINDOW_SIZE = 200;

final int DEBUG_WINDOW_START = ROWS * MUTI;
final int WINDOW_XSIZE = COLUMNS * MUTI;
final int WINDOW_YSIZE = DEBUG_WINDOW_START + DEBUG_WINDOW_YSIZE;
final int DEBUG_TEXT_X = WINDOW_XSIZE - INFO_WINDOW_SIZE + 10;

int SIM_DELAY = 3;  // simulate sending data to teensy's

VideoWall wall;

public void setupWall() {
  wall = new VideoWall();     // create the wall
  println("WALL SETUP ...");
}

class VideoWall {
  PImage[] teensyImages = new PImage [10];
  PGraphics send_buffer;

  VideoWall() {
    send_buffer = createGraphics(ROWS, COLUMNS, JAVA2D);
    send_buffer.hint(DISABLE_DEPTH_TEST);
    send_buffer.hint(DISABLE_DEPTH_MASK);
    send_buffer.hint(DISABLE_DEPTH_SORT);
    //send_buffer.smooth(4);
    send_buffer.beginDraw();
    send_buffer.background(0);
    send_buffer.endDraw();
    send_buffer.loadPixels();
    send_buffer.imageMode(CENTER);
    

    for (int i = 0; i < teensyImages.length; i++) {
      teensyImages[i] = createImage(80, 16, RGB);
      teensyImages[i].loadPixels();
    }
  }

  private void drawPixel(int x, int y, int c) {
    int screenX = (x * DEBUG_REAL_PIXEL_SIZE_X) + (DEBUG_REAL_PIXEL_SIZE_X / 2);
    int screenY = (y * DEBUG_REAL_PIXEL_SIZE_Y) + (DEBUG_REAL_PIXEL_SIZE_Y / 2);
    int r = (c >> 16) & 0xFF;  // get the red
    int g = (c >> 8) & 0xFF;   // get the green
    int b = c & 0xFF;          // get the blue 

    r = PApplet.parseInt( map( r, 0, 255, 0, MAX_BRIGHTNESS ) );  // map red to max LED brightness
    g = PApplet.parseInt( map( g, 0, 255, 0, MAX_BRIGHTNESS ) );  // map green to max LED brightness
    b = PApplet.parseInt( map( b, 0, 255, 0, MAX_BRIGHTNESS ) );  // map blue to max LED brightness
    
    float pixel_watts = map(r + g + b, 0, 768, 0, 0.24f); 
    
    WALL_WATTS += pixel_watts;
    
    fill( color(r,g,b) );
    rect(screenX, screenY, DEBUG_PIXEL_SIZE, DEBUG_PIXEL_SIZE);
  }

  public void display() {
    SIMULATE_TIME = 0;
    int stime = millis();
    pushStyle();
    rectMode(CENTER);
    noStroke();
    WALL_WATTS = 0;
    //buffer.loadPixels(); // load the current pixels
    for (int i = 0; i < TOTAL; i++) {
      int x = i % COLUMNS; 
      int y = i / COLUMNS;
      drawPixel(x, y, buffer.pixels[i]);
    }
    MAX_WATTS = max(MAX_WATTS, WALL_WATTS);
    popStyle();
    SIMULATE_TIME = millis() - stime;
    MAX_SIMULATE = max(MAX_SIMULATE, SIMULATE_TIME);
  }
  
  private void update() {
    // update the send buffer by adding the buffer image rotated for the led matrix
    
    send_buffer.beginDraw();
    send_buffer.pushMatrix();
    send_buffer.translate(40, 80);
    send_buffer.rotate(radians(90));
    send_buffer.image(buffer.get(), 0, 0);
    send_buffer.popMatrix();
    send_buffer.endDraw();
    //send_buffer.loadPixels();
    
    for (int i = 0; i < teensyImages.length; i++) {
      arrayCopy(send_buffer.pixels, i * (80 * 16), teensyImages[i].pixels, 0, 80 * 16);
      teensyImages[i].updatePixels();
    }
  }
    

  private void send() {
    WALL_WATTS = 0;  // reset the wattage tracking
    SEND_TIME = 0;

    // send data again to simulate 10 teensy's
    for (int i = 0; i < teensys.length; i++) {
      teensys[i].send();
      SEND_TIME += teensys[i].sendTime;
      WALL_WATTS += teensys[i].watts;
    }
    MAX_WATTS = max(MAX_WATTS, WALL_WATTS);
    MAX_SEND  = max(MAX_SEND, SEND_TIME);
  }

  public void draw() {
    TBUFFER_TIME = 0;
    int stime = millis();
    update();                      // update send buffer
    TBUFFER_TIME = millis() - stime;
    MAX_TBUFFER = max(MAX_TBUFFER, TBUFFER_TIME);
    
    if (USE_TEENSYS) send();         // send data
    else {
      if (delayOn) {
        delay(SIM_DELAY * 10);                  // or simulate sending of data
        SEND_TIME = SIM_DELAY * 10;
        MAX_SEND = SEND_TIME;
      }
    }
    if (simulateOn) display();  // show simulation of wall
  }
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "LEDWall" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

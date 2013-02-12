/*--------------------------------------------------------------------
 Processing code to control a large LED matrix wall. This code is 
 hardware specific geared to our burning man project for 2013. 
 
 It currently uses some of the following hardware:
 
 WS2811-based RGB LED strips
 MSGEQ7 chip for audio interaction
 Microsoft kinect for user interaction
 
 It also uses the following processing libraries:
 
 Toxiclibs        <http://toxiclibs.org/>
 blobDectection   <http://www.v3ga.net/processing/BlobDetection/>
 simpleOpenNI     <http://code.google.com/p/simple-openni/>
 
 If you have any questions about this code or our burning man project 
 you may email us at: 
 wall(aT)hunterluisi(doT)com
 
 Written by Hunter Luisi and Max Cooper
 
 --------------------------------------------------------------------
 This file is part of the Wall of Light project.
 
 It is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as
 published by the Free Software Foundation, either version 3 of
 the License, or (at your option) any later version.
 
 It is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with it.  If not, see
 <http://www.gnu.org/licenses/>.
 --------------------------------------------------------------------*/

// imports
import SimpleOpenNI.*;
//import processing.serial.*;

// Wall Setup
final int COLUMNS = 160;             // the amount of LEDs per column (x)
final int ROWS    = 80;              // the amount of LEDs per row (y)
final int TOTAL   = COLUMNS * ROWS;  // the total amount of LEDs on the wall

// Mode setup
Modes mode;

// Kinect Setup
Kinect kinect;

// frame buffer setup
final int FRAME_BUFFER_WIDTH  = 640;
final int FRAME_BUFFER_HEIGHT = 480;
FrameBuffers buffer;

// Debug Setup
final int DEBUG_PIXEL_SIZE      = 3;  // size of each debug pixel
final int DEBUG_PIXEL_SPACING_X = 3;  // the X spacing for each debug pixel
final int DEBUG_PIXEL_SPACING_Y = 6;  // the X spacing for each debug pixel

final int DEBUG_REAL_PIXEL_SIZE_X = DEBUG_PIXEL_SIZE + DEBUG_PIXEL_SPACING_X; // the total X size of each debug pixel
final int DEBUG_REAL_PIXEL_SIZE_Y = DEBUG_PIXEL_SIZE + DEBUG_PIXEL_SPACING_Y; // the total Y size of each debug pixel

final int DEBUG_WINDOW_XSIZE = COLUMNS * DEBUG_REAL_PIXEL_SIZE_X;           // the x size of the debug window
final int DEBUG_WINDOW_YSIZE = 200;                                       // the y size of the debug window
final int DEBUG_WINDOW_START = DEBUG_REAL_PIXEL_SIZE_Y * ROWS;

boolean DEBUG_SHOW_WALL  = true;                                    // show the wall on the computer screen wall?
boolean showText = true;


PImage smpte, test;

void setup() {
  // List all the available serial ports
  //println(Serial.list());

  // create the window based on the amount 
  // of leds, rows, columns, pixel size, 
  // debug space, etc..
  int x, y;
  x = DEBUG_WINDOW_XSIZE;
  if (DEBUG_SHOW_WALL) {
    y = (ROWS * DEBUG_REAL_PIXEL_SIZE_Y) + DEBUG_WINDOW_YSIZE;
  } 
  else {
    y = DEBUG_WINDOW_YSIZE;
  }
  size(x, y, P2D);  // create the window
  //noSmooth();

  buffer = new FrameBuffers();
  mode = new Modes();
  kinect = new Kinect(this);  //, SimpleOpenNI.RUN_MODE_MULTI_THREADED);
  kinect.update();

  smpte = loadImage("smpte_640x240.png");
  test  = loadImage("test_640x240.png");

}


void draw() {
  background(0);
  mode.run();
  drawDebug();
}

void drawDebug() {
  fill(100);
  rectMode(CORNER);
  rect(0, DEBUG_WINDOW_START, DEBUG_WINDOW_XSIZE, DEBUG_WINDOW_YSIZE);

  fill(255);
  text("FPS: " + frameRate, 10, DEBUG_WINDOW_START + 20);
  text("time check: " + (mode.check_time / 1000), 10, DEBUG_WINDOW_START + 35);
  //text("sx: " + mode.text_overlay.sx, 10, DEBUG_WINDOW_START + 50);
  //text("sy: " + mode.text_overlay.sy, 10, DEBUG_WINDOW_START + 65);
  //text("words: " + mode.text_overlay.words.length, 10, DEBUG_WINDOW_START + 80);
  //text("lines: " + mode.text_overlay.lines.size(), 10, DEBUG_WINDOW_START + 95);
}

void keyPressed() {
  switch(key) {

    // switch to TEST mode
  case '0':
    mode.set(mode.TEST);
    break;

  case '1':
    mode.set(mode.KRGB);
    break;

  case '2':
    mode.set(mode.KDEPTH);
    break;

  case '3':
    mode.set(mode.KSCENE);
    break;
    
  case 't':
    showText = !showText;
    break;

  }
}


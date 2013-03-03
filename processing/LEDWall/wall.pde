/*--------------------------------------------------------------------
 Receives an image, splits the image into parts, and sends those parts
 to the teensy's to be displayed.  Will also display to screen if 
 DEBUG_SHOW_WALL is true
 
 --------------------------------------------------------------------*/

// Wall Setup
final int COLUMNS = 160;             // the amount of LEDs per column (x)
final int ROWS    = 80;              // the amount of LEDs per row (y)
final int TOTAL   = COLUMNS * ROWS;  // the total amount of LEDs on the wall

final int DEBUG_PIXEL_SIZE      = 4;  // size of each debug pixel
final int DEBUG_PIXEL_SPACING_X = 6;  // the X spacing for each debug pixel
final int DEBUG_PIXEL_SPACING_Y = 6;  // the X spacing for each debug pixel

final int DEBUG_REAL_PIXEL_SIZE_X = DEBUG_PIXEL_SIZE + DEBUG_PIXEL_SPACING_X; // the total X size of each debug pixel
final int DEBUG_REAL_PIXEL_SIZE_Y = DEBUG_PIXEL_SIZE + DEBUG_PIXEL_SPACING_Y; // the total Y size of each debug pixel

final int DEBUG_WINDOW_XSIZE = COLUMNS * DEBUG_REAL_PIXEL_SIZE_X;         // the x size of the debug window
final int DEBUG_WINDOW_YSIZE = 200;                                       // the y size of the debug window
final int DEBUG_WINDOW_START = DEBUG_REAL_PIXEL_SIZE_Y * ROWS;

boolean DEBUG_SHOW_WALL  = true;  // show the wall on the computer screen wall?

VideoWall wall;

void setupWall() {
  wall = new VideoWall();
  println("WALL SETUP ...");
}

class VideoWall {
  PImage frame;

  VideoWall() {
  }

  void setFrame(PImage img) {
    if (img.width != COLUMNS || img.height != ROWS) {
      println("wrong size image sent to VideoWall!!");
      exit();
    }
    frame = img;
  }

  private void drawPixel(int x, int y, color c) {
    int screenX = (x * DEBUG_REAL_PIXEL_SIZE_X) + (DEBUG_REAL_PIXEL_SIZE_X / 2);
    int screenY = (y * DEBUG_REAL_PIXEL_SIZE_Y) + (DEBUG_REAL_PIXEL_SIZE_Y / 2);
    noStroke();
    smooth();
    fill(c);
    rectMode(CENTER);
    rect(screenX, screenY, DEBUG_PIXEL_SIZE, DEBUG_PIXEL_SIZE);
  }

  void displayScreen() {
    frame.loadPixels();
    background(0);
    for (int i = 0; i < TOTAL; i++) {
      int x = i % COLUMNS; 
      int y = i / COLUMNS;
      drawPixel(x, y, frame.pixels[i]);
    }
  }

  private void send() {
    // send image to teensy's here
  }

  void display() {
    send();
    if (DEBUG_SHOW_WALL) displayScreen();
  }
}


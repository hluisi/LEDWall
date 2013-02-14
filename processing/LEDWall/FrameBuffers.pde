/*--------------------------------------------------------------------
 The goal here is to create 2 different frame buffers:
 
 1st. The RAW full sized buffer that is used for drawing and 
 creating each frame.
 
 2nd. A small frame buffer that matches the size of the LED matrix.
 
 Because we only draw on the RAW buffer, it needs to be 
 PGrpahic object. But the small buffer can be PImages, thus 
 making it smaller and easier to deal with.
 
 TODO 
 breakdown the small buffer into even smaller images that will be sent 
 to each teensy via Serial
 
 
 --------------------------------------------------------------------*/

final int RAW_BUFFER_WIDTH  = FRAME_BUFFER_WIDTH;
final int RAW_BUFFER_HEIGHT = FRAME_BUFFER_HEIGHT;      
final int SMALL_BUFFER_WIDTH  = COLUMNS; 
final int SMALL_BUFFER_HEIGHT = ROWS;   

class FrameBuffers {

  PGraphics RAW;  // main buffer used for drawing each frame
  PImage SMALL;   // small image buffer the size of the LED Matrix
  
  boolean rawIsDrawing = false;  // has PGraphics beginDraw() been called?

  FrameBuffers() {
    RAW    = createGraphics(RAW_BUFFER_WIDTH, RAW_BUFFER_HEIGHT, P2D);    // create the RAW PGraphics object
    SMALL  = createImage(SMALL_BUFFER_WIDTH, SMALL_BUFFER_HEIGHT, RGB);   // create the first small image buffer
    RAW.noStroke();
    RAW.smooth();
  }

  // start drawing on the RAW PGraphics object
  void beginDraw() {
    RAW.beginDraw();       // allow drawing to the PGraphics object
    rawIsDrawing = true;   // set is drawing
  }

  // end drawing on the RAW PGraphics object
  void endDraw() {
    RAW.endDraw();         // stop drawing to PGraphics object
    rawIsDrawing = false;  // not drawing
  }
  
  // copy and resize the RAW buffer to the smaller (LED Wall) size
  void update() {
    if (rawIsDrawing) {  // make sure we called endDraw before copying and resizing the RAW buffer
      endDraw();
      println("forgot to end drawing before updating the buffers!!");
    }
    
    SMALL.copy(RAW, 0, 0, FRAME_BUFFER_WIDTH, FRAME_BUFFER_HEIGHT, 0, 0, SMALL_BUFFER_WIDTH, SMALL_BUFFER_HEIGHT);
  }

  // display on screen
  private void displayOnScreen(int x, int y, color c) {
    int screenX = (x * DEBUG_REAL_PIXEL_SIZE_X) + (DEBUG_REAL_PIXEL_SIZE_X / 2);
    int screenY = (y * DEBUG_REAL_PIXEL_SIZE_Y) + (DEBUG_REAL_PIXEL_SIZE_Y / 2);
    noStroke();
    smooth();
    fill(c);
    rectMode(CENTER);
    rect(screenX, screenY, DEBUG_PIXEL_SIZE, DEBUG_PIXEL_SIZE);
  }

  // send buffer to the LED wall
  void send() {

    SMALL.loadPixels(); // load color data into the image's pixel array
    // TODO
    // break down small image into smaller images via arrayCopy
    // then send small images via serial to each teensy
    for (int i = 0; i < TOTAL; i++) {
      if (DEBUG_SHOW_WALL) {  // display the pixel for debugging? 
        int x = i % COLUMNS;  
        int y = i / COLUMNS;
        displayOnScreen(x, y, SMALL.pixels[i]);
      }
    }
  }
}


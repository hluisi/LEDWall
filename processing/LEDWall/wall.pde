// COULD USE A REWRITE

// Wall Setup
final int COLUMNS = 160;             // the amount of LEDs per column (x)
final int ROWS    = 80;              // the amount of LEDs per row (y)
final int TOTAL   = COLUMNS * ROWS;  // the total amount of LEDs on the wall

final int DEBUG_PIXEL_SIZE      = 3;  // size of each debug pixel
final int DEBUG_PIXEL_SPACING_X = 3;  // the X spacing for each debug pixel
final int DEBUG_PIXEL_SPACING_Y = 3;  // the X spacing for each debug pixel

final int DEBUG_REAL_PIXEL_SIZE_X = DEBUG_PIXEL_SIZE + DEBUG_PIXEL_SPACING_X; // the total X size of each debug pixel
final int DEBUG_REAL_PIXEL_SIZE_Y = DEBUG_PIXEL_SIZE + DEBUG_PIXEL_SPACING_Y; // the total Y size of each debug pixel

final int DEBUG_WINDOW_YSIZE = 220;                                       // the y size of the debug window
final int INFO_WINDOW_SIZE = 200;



int WINDOW_XSIZE;  // the x size of the debug window
int WINDOW_YSIZE;  // the x size of the debug window
int DEBUG_TEXT_X;
int DEBUG_WINDOW_START;

int SEND_TIME;
int PROC_TIME;
int TOTAL_TIME; 



VideoWall wall;

void setupWall() {
  wall = new VideoWall();     // create the wall
  println("WALL SETUP ...");
}

class VideoWall {
  PImage[] teensyImages = new PImage [10];
  PGraphics send_buffer;

  VideoWall() {
    send_buffer = createGraphics(ROWS, COLUMNS, P3D);
    send_buffer.smooth(4);
    send_buffer.beginDraw();
    send_buffer.background(0);
    send_buffer.endDraw();
    send_buffer.hint(DISABLE_DEPTH_TEST);
    send_buffer.hint(DISABLE_DEPTH_MASK);

    for (int i = 0; i < teensyImages.length; i++) {
      teensyImages[i] = createImage(80, 16, RGB);
      teensyImages[i].loadPixels();
    }
  }

  private void drawPixel(int x, int y, color c) {
    int screenX = (x * DEBUG_REAL_PIXEL_SIZE_X) + (DEBUG_REAL_PIXEL_SIZE_X / 2);
    int screenY = (y * DEBUG_REAL_PIXEL_SIZE_Y) + (DEBUG_REAL_PIXEL_SIZE_Y / 2);
    int r = (c >> 16) & 0xFF;  // get the red
    int g = (c >> 8) & 0xFF;   // get the green
    int b = c & 0xFF;          // get the blue 

    r = int( map( r, 0, 255, 0, MAX_BRIGHTNESS ) );  // map red to max LED brightness
    g = int( map( g, 0, 255, 0, MAX_BRIGHTNESS ) );  // map green to max LED brightness
    b = int( map( b, 0, 255, 0, MAX_BRIGHTNESS ) );  // map blue to max LED brightness
    
    float pixel_watts = map(r + g + b, 0, 768, 0, 0.24); 
    
    WALL_WATTS += pixel_watts;
    
    noStroke();
    fill( color(r,g,b) );
    pushStyle();
    rectMode(CENTER);
    rect(screenX, screenY, DEBUG_PIXEL_SIZE, DEBUG_PIXEL_SIZE);
    popStyle();
  }

  void display() {
    WALL_WATTS = 0;
    buffer.loadPixels(); // load the current pixels
    for (int i = 0; i < TOTAL; i++) {
      int x = i % COLUMNS; 
      int y = i / COLUMNS;
      drawPixel(x, y, buffer.pixels[i]);
    }
    MAX_WATTS = max(MAX_WATTS, WALL_WATTS);
  }

  private void send() {
    // update the send buffer by adding the buffer image rotated for the led matrix
    send_buffer.beginDraw();
    send_buffer.pushMatrix();
    send_buffer.imageMode(CENTER);
    send_buffer.translate(send_buffer.width / 2, send_buffer.height / 2);
    send_buffer.rotate(radians(90));
    send_buffer.image(buffer.get(), 0, 0);
    send_buffer.popMatrix();
    send_buffer.endDraw();
    send_buffer.loadPixels();

    WALL_WATTS = 0;  // reset the wattage tracking
    SEND_TIME  = 0;
    PROC_TIME  = 0;
    TOTAL_TIME = 0;
    
    
    // set the teensy image array
    int stime = millis();
    for (int i = 0; i < teensyImages.length; i++) {
      arrayCopy(send_buffer.pixels, i * (80 * 16), teensyImages[i].pixels, 0, 80 * 16);
      teensyImages[i].updatePixels();

      if (i < TEENSY_TOTAL) {
        teensys[i].send();
        WALL_WATTS += teensys[i].watts;
        SEND_TIME += teensys[i].send_time;
        PROC_TIME += teensys[i].proc_time;
      }
    }
    
    // send data again to simulate 10 teensy's
    //for (int i = 0; i < teensys.length; i++) {
      //teensys[i].send();
      //SEND_TIME += teensys[i].send_time;
      //PROC_TIME += teensys[i].proc_time;
    //}
    
    TOTAL_TIME = millis() - stime;
    
    MAX_WATTS = max(MAX_WATTS, WALL_WATTS);
  }

  void draw() {
    //buffer.updatePixels();
    if (USE_TEENSYS) send();         // send data
    else delay(30);                  // or simulate sending of data
    if (SHOW_WALL) display();  // show simulation of wall
  }
}


import processing.opengl.*;

Buffer buffer;


void setupBuffer() {
  buffer = new Buffer(this); //new Buffer(this); //createGraphics(COLUMNS, ROWS, JAVA2D);
  
  println("BUFFER SETUP ...");
}

class Buffer extends PGraphicsJava2D {

  int max_brightness = 255;

  Buffer(PApplet app) {
    super();
    setParent(app);
    setPrimary(false);
    setSize(COLUMNS, ROWS);
  }

  void maxBrightness(int v) {
    max_brightness = v;
  }

  void endDraw() {
    super.endDraw();
    loadPixels();
    for (int i = 0; i < pixels.length; i++) {
      color argb = pixels[i];
      int a = (argb >> 24) & 0xFF;
      int r = (argb >> 16) & 0xFF;  
      int g = (argb >> 8) & 0xFF;   
      int b = argb & 0xFF;          
      a = int( map( a, 0, 255, 0, max_brightness ) );
      r = int( map( r, 0, 255, 0, max_brightness ) );
      g = int( map( g, 0, 255, 0, max_brightness ) );
      b = int( map( b, 0, 255, 0, max_brightness ) );
      pixels[i] = color(r, g, b, a);
    }
    updatePixels();
  }
}


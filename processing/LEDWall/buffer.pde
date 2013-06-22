
PGraphics buffer;
//Buffer buffer;

void setupBuffer() {
  //buffer = new Buffer(this); 
  buffer = createGraphics(COLUMNS, ROWS, P2D);
  //buffer.hint(DISABLE_DEPTH_TEST);
  buffer.smooth(4);
  buffer.loadPixels();

  println("BUFFER SETUP ...");
}

/*
class Buffer extends PGraphicsJava2D {

  int max_brightness = 128;
  float wattage = 0;
  float max_watts = 0;

  Buffer(PApplet app) {
    super();
    setParent(app);
    setPrimary(false);
    setSize(COLUMNS, ROWS);
    loadPixels();
  }

  void maxBrightness(int v) {
    max_brightness = v;
  }
  
  
  void endDraw() {
    super.endDraw();

    wattage = 0;
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
      
      r = gammaTable[r][0];
      g = gammaTable[g][1];
      b = gammaTable[b][2];
      
      pixels[i] = color(r, g, b, a);

      // watts
      float pixel_watts = map(r + g + b, 0, 768, 0, 0.24);
      wattage += pixel_watts;
    }
    max_watts = max(max_watts, wattage);
    updatePixels();
  } 
}

*/




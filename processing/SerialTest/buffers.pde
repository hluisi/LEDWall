PGraphics frameBuffer;
PGraphics teensyBuffer;
PImage[] teensyImages;
PFont df;

void setupBuffers() {
  df = createFont("Verdana-Bold", 32);
  frameBuffer  = createGraphics(COLUMNS, ROWS, P3D);     // used for creating the frame
  frameBuffer.smooth(4);
  frameBuffer.textAlign(CENTER, CENTER);
  frameBuffer.textFont(df);
  frameBuffer.beginDraw();
  frameBuffer.background(0);
  frameBuffer.endDraw();

  teensyBuffer = createGraphics(ROWS, COLUMNS, P3D);  // used to create images for teensy's 
  teensyBuffer.smooth(4);
  teensyBuffer.beginDraw();
  teensyBuffer.background(0);
  teensyBuffer.endDraw();

  teensyImages = new PImage [10];                        // need one image per teensy
  for (int i = 0; i < teensyImages.length; i++) {
    teensyImages[i] = createImage(TEENSY_WIDTH, TEENSY_HEIGHT, RGB);          // create the image
    teensyImages[i].loadPixels();                        // load it's pixels
  }
  println("buffers setup!");
}


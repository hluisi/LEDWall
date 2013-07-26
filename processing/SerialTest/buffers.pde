PGraphics frameBuffer;
PGraphics teensyBuffer;
PImage[] teensyImages;

void setupBuffers() {
  frameBuffer  = createGraphics(COLUMNS, ROWS, P3D);     // used for creating the frame
  frameBuffer.smooth(4);
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
    teensyImages[i] = createImage(80, 16, RGB);          // create the image
    teensyImages[i].loadPixels();                        // load it's pixels
  }
  println("buffers setup!");
}


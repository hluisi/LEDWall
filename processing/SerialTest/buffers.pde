PGraphics frameBuffer;
PGraphics teensyBuffer;
PImage[] teensyImages;

void setupBuffers() {
  frameBuffer  = createGraphics(COLUMNS, ROWS, P3D);     // used for creating the frame
  teensyBuffer = createGraphics(ROWS, COLUMNS, JAVA2D);  // used to create images for teensy's 
  teensyImages = new PImage [10];                        // need one image per teensy
  for (int i = 0; i < teensyImages.length; i++) {
    teensyImages[i] = createImage(80, 16, RGB);          // create the image
    teensyImages[i].loadPixels();                        // load it's pixels
  }
}


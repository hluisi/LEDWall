// move to LEDWall

PGraphics buffer;

void setupBuffer() {
  buffer = createGraphics(COLUMNS, ROWS, P2D);   //buffer.hint(DISABLE_DEPTH_TEST);
  buffer.smooth(4);
  buffer.loadPixels();
  println("BUFFER SETUP ...");
}



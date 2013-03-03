final int BUFFER_WIDTH  = 640;
final int BUFFER_HEIGHT = 320;

PGraphics buffer;


void setupBuffer() {
  buffer = createGraphics(BUFFER_WIDTH, BUFFER_HEIGHT, P3D);
  //buffer.beginDraw();
  //buffer.background(255,0,0);
  //buffer.endDraw();
  println("BUFFER SETUP ...");
}

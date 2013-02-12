class LED {
  int index;

  int X, Y, pixelsX, pixelsY;

  color argb;

  float Red; 
  float Green; 
  float Blue; 
  float Alpha;

  boolean isOn;

  LED(int _index) {
    index = _index;
    color tempColor = color(0, 255, 0, 255);
    set(tempColor);
    X = index % COLUMNS;
    Y = index / COLUMNS;
    pixelsX = (X * DEBUG_REAL_PIXEL_SIZE) + (DEBUG_REAL_PIXEL_SIZE / 2);
    pixelsY = (Y * DEBUG_REAL_PIXEL_SIZE) + (DEBUG_REAL_PIXEL_SIZE / 2);
  }

  void set(color _argb) {
    argb  = _argb;
    Alpha = (argb >> 24) & 0xFF; // alpha
    Red   = (argb >> 16) & 0xFF; // red
    Green = (argb >> 8) & 0xFF;  // green
    Blue  = argb & 0xFF;         // blue

    if (Alpha > 0) {
      isOn = true;
    } 
    else {
      isOn = false;
    }
  }

  void display() {
    fill(argb);
    rectMode(CENTER);
    rect(pixelsX, pixelsY, DEBUG_PIXEL_SIZE, DEBUG_PIXEL_SIZE);
  }
}


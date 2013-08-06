// COULD USE A REWRITE

ConcCircles circles;
SpecCity city;
Pulsar pulsar;

int CIRCLE_MODE = 0;

void setupCircles() {
  circles = new ConcCircles();
  city = new SpecCity();
  pulsar = new Pulsar();
  
  // controll name, text name, x, y, width, height, text size, value, move 2 tab
  createToggle("distriktOn", "distrikt", TAB_START + 20, DEBUG_WINDOW_START + 50, 50, 50, mFont, ControlP5.DEFAULT, city.dOn, DISPLAY_STR[DISPLAY_MODE_CITY]);
  
  createTextfield("setCitySpecMax", "LINES", TAB_MAX_WIDTH + 10, DEBUG_WINDOW_START+55, 50, 20, nf(city.SPEC_MAX,1), sFont, ControlP5.INTEGER, DISPLAY_STR[DISPLAY_MODE_CITY]);
  cp5.getController("setCitySpecMax").captionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE);
  createTextfield("setCityZ", "Z", TAB_MAX_WIDTH + 10, DEBUG_WINDOW_START+80, 50, 20, nf(city.Z,1), sFont, ControlP5.INTEGER, DISPLAY_STR[DISPLAY_MODE_CITY]);
  createTextfield("setCityLineMax", "HEIGHT", TAB_MAX_WIDTH + 70, DEBUG_WINDOW_START+65, 50, 30, nf(city.LINE_MAX,1), sFont, ControlP5.INTEGER, DISPLAY_STR[DISPLAY_MODE_CITY]);
  cp5.getController("setCityLineMax").captionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(5);
}

void distriktOn(boolean b) {
  city.dOn = b;
}

void setCitySpecMax(String valueString) {
  int specMax = int(valueString);
  city.SPEC_MAX = specMax;
  //movieSpeed.setMin(minSpeed);
  //movieSpeed.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(5);
  //movieSpeed.getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(5);
}

void setCityZ(String valueString) {
  int cityZ = int(valueString);
  city.Z = cityZ;
}

void setCityLineMax(String valueString) {
  int lineMax = int(valueString);
  city.LINE_MAX = lineMax;
}

void doCircles() {
  buffer.blendMode(ADD);
  doBackground();
  circles.draw();
  buffer.blendMode(BLEND);
}

void doPulsar() {
  buffer.blendMode(ADD);
  doBackground();
  pulsar.draw();
  buffer.blendMode(BLEND);
}

void doCity() {
  buffer.blendMode(ADD);
  doBackground();
  city.draw();
  buffer.blendMode(BLEND);
}


class ConcCircles {
  float r = 16;
  float theta = 0;
  float numCircles = 32;
  int rows = 8;
  PVector kinectUser;
  int maxSize;
  int size;

  ConcCircles() {
    maxSize = 32;
    kinectUser = new PVector();
  }

  color getCircleColor(int i) {
    if (audioOn) {
      int m = i % (audio.averageSpecs.length - 1);
      return color(audio.averageSpecs[1].grey, audio.averageSpecs[3].grey, audio.averageSpecs[m].grey);
    } else {
      float b = round( noise(zoff, yoff, xoff) * 255 );
      float g = round( noise(zoff, yoff) * 255 );
      float r = round( noise(zoff) * 255 );
      return color(r,g,b);
    }
  }
  
  int getCirlceSize(int i) {
    if (audioOn) {
      int m = i % (audio.averageSpecs.length - 1);
      return round( map(audio.averageSpecs[m].value + 10, 10, 110, 2, maxSize) );
    } else {
      return round( random(2, maxSize) );
    }
  }

  void updateTheta() {
    int speed;
    
    // is the audio on?
    if (audioOn) speed = audio.BPM + 1;
    else speed = round( random(100,200) );
    
    // update theta
    if (theta > 0) theta += 360 / numCircles / speed;
    else theta -= 360 / numCircles / speed;
  }

  void drawCircle(int n, int size) {
    float x = (r+16*n)*cos(theta) + kinectUser.x;
    float y = (r+16*n)*sin(theta) + kinectUser.y;

    buffer.ellipse(x, y, size, size);
  }

  void draw() {
    kinectUser = getSingleUser();

    for (int i = 0; i < rows ; i++) {
      buffer.fill( getCircleColor(i) );
      size = getCirlceSize(i);
      for (int n = 0; n < numCircles; n++) {
        drawCircle(n, size);
        updateTheta();
      }
    }
    
    if ( audioOn ) {
      if ( audio.isOnBeat() ) {
        float test = random(0, 1);
        if (test < 0.25) theta = random(theta * -1, theta);
        if (test > 0.75) theta *= -1;
      }
    } else {
      float test = random(0, 1);
      if (test < 0.1) theta = random(theta * -1, theta);
      if (test > 0.9) theta *= -1;
    }
  }
}



class SpecCity {

  PVector kinectUser;
  int LINE_MAX = 140;
  int SPEC_MAX = 220;
  int Z = -130;
  int distrikt;
  boolean dOn = false;

  SpecCity() {
    kinectUser     = new PVector();
  }
  
  void setDistrikt(int v) {
    distrikt = v;
  }

  void draw() {
    kinectUser = getSingleUser();
    //buffer.strokeWeight(1);
    buffer.pushMatrix();
    //buffer.translate(kinectUser.x, kinectUser.y);
    buffer.translate(80, 40);

    for (int i = 1; i <= SPEC_MAX + 5 ; i++) {
      // set the line color
      buffer.stroke(audio.fullSpecs[i].grey, audio.averageSpecs[1].grey, audio.averageSpecs[3].grey);
      int weight = round(map(audio.fullSpecs[i].value, 0, 100, 1, 4));
      buffer.strokeWeight(weight);

      int xR = i;
      int xL = i * -1;
      int yU = round( map(audio.fullSpecs[i].value, 0, 100, 2, LINE_MAX) );
      int yD = yU * -1;

      buffer.line(xL, 0, Z, xL, yU, Z);  // left side up
      buffer.line(xL, 0, Z, xL, yD, Z);  // left side down
      buffer.line(xR, 0, Z, xR, yU, Z);  // right side up
      buffer.line(xR, 0, Z, xR, yD, Z);  // right side down
    }
    
    if (dOn) {
      int c = round(map(audio.volume.value, 0, 100, 48, 255));
      buffer.fill(c);
      buffer.noStroke();
      buffer.translate(0, 0, -30);
      svgs[distrikt].draw(buffer);
    } //else LINE_MAX = 60;
    
    buffer.popMatrix();
  }
}

class Pulsar {
  color lineColor;
  float kx, ky;
  float Z = -5;
  PVector kinectUser;

  Pulsar() {
  }

  color setColor(int i) {
    int RED   = audio.averageSpecs[1].grey;
    int GREEN = audio.averageSpecs[3].grey;
    int BLUE  = audio.fullSpecs[i].grey;
    return color(RED, GREEN, BLUE);
  }

  void drawLine(float radius, float angle) {
    float x = kinectUser.x + ( radius * cos( radians(angle) ) );
    float y = kinectUser.y + ( radius * sin( radians(angle) ) );
    buffer.line(kinectUser.x, kinectUser.y, Z, x, y, Z);
  }

  void draw() {
    buffer.noFill();
    kinectUser = getSingleUser();

    for (int i = 0; i < (audio.fullSpecs.length / 2); i++) {    
      //buffer.strokeWeight(1);
      buffer.stroke( setColor(i) );
      int weight = round(map(audio.fullSpecs[i].value, 0, 100, 1, 4));
      buffer.strokeWeight(weight);

      float angle  = map(i, 0, (audio.fullSpecs.length - 1) / 4, 0, 180);
      float radius = map(audio.fullSpecs[i].value, 0, 100, 1, 720);
      float spin   = map(audio.volume.value, 0, 100, 0, 180);

      drawLine(radius, angle + spin);
      drawLine(radius, angle + 180 + spin);
    }
  }
}


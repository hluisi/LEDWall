ConcCircles circles;
SpecCity city;
Pulsar pulsar;

int CIRCLE_MODE = 0;

void setupCircles() {
  circles = new ConcCircles();
  city = new SpecCity();
  pulsar = new Pulsar(buffer.width/2,buffer.height/2);
}

void doCircles() {
  buffer.beginDraw();
  buffer.blendMode(ADD);
  buffer.background(audio.COLOR);
  
  circles.draw();
  
  buffer.blendMode(BLEND);

  kinect.updateUserBlack();
  buffer.image(kinect.buffer_image, 0, 0);
  buffer.endDraw();
}

void doPulsar() {
  buffer.beginDraw();
  buffer.blendMode(ADD);
  buffer.background(audio.COLOR);
  
  pulsar.draw();
  
  buffer.blendMode(BLEND);

  kinect.updateUserBlack();
  buffer.image(kinect.buffer_image, 0, 0);
  buffer.endDraw();
}

void doCity() {
  buffer.beginDraw();
  buffer.blendMode(ADD);
  buffer.background(audio.COLOR);
  
  city.draw();
  
  buffer.blendMode(BLEND);

  kinect.updateUserBlack();
  buffer.image(kinect.buffer_image, 0, 0);
  buffer.endDraw();
}


color getCircleColor(int i) {
  int RED   = int(map(audio.averageSpecs[1].value, 0, 100, 0, 255));
  int GREEN = int(map(audio.averageSpecs[3].value, 0, 100, 0, 255));
  int BLUE  = int(map(audio.averageSpecs[i].value, 0, 100, 0, 255));
  return color(RED, GREEN, BLUE, 255);
}

class ConcCircles {
  float r = 16;
  float theta = 0;
  float numCircles = 32;

  ConcCircles() {
  }

  void draw() {
    buffer.stroke(0);
    for (int i = 0; i < audio.averageSpecs.length - 1 ; i++) {
      for (int n = 0; n < numCircles; n++) {
        buffer.fill( getCircleColor(i) );
        float kx, ky;
        if (kinect.user_id != -1) {
          kx = kinect.user_center.x; 
          ky = kinect.user_center.y;
        } 
        else {
          kx = buffer.width / 2; 
          ky = buffer.height / 2;
        }
        float x = (r+16*n)*cos(theta) + kx;
        float y = (r+16*n)*sin(theta) + ky;
        int value = int(map(audio.averageSpecs[i].value + 10, 10, 110, 2, 32));
        buffer.ellipse(x, y, value, value);
        if ( audio.beat.isOnset() ) {
          float test = random(0, 1);
          if (test < 0.1) theta = random(theta * -1, theta);
          if (test > 0.75) theta *= -1;
        }
        if (theta > 0) theta += 360/numCircles/ (audio.BPM + 1);
        else theta -= 360/numCircles/ (audio.BPM + 1);
      }
    }
  }
}



class SpecCity {

  SpecCity() {
  }

  void draw() {
    for (int i = 0; i < (buffer.width / 2) ; i++) {
      int GREEN   = int(map(audio.averageSpecs[1].value, 0, 100, 0, 255));
      int BLUE = int(map(audio.averageSpecs[3].value, 0, 100, 0, 255));
      int RED  = int(map(audio.fullSpecs[i].value, 0, 100, 0, 255));
      int value_up = int(map(audio.fullSpecs[i].value, 0, 100, buffer.height / 3, 0));
      int value_down = int(map(audio.fullSpecs[i].value, 0, 100, buffer.height / 3, buffer.height));
      buffer.stroke(RED, GREEN, BLUE);
      buffer.line(i + (buffer.width / 2), buffer.height / 3, i + (buffer.width / 2), value_up);
      buffer.line(i + (buffer.width / 2), buffer.height / 3, buffer.width - i, value_down);
      buffer.line((buffer.width / 2) - i, buffer.height / 3, (buffer.width / 2) - i, value_up);
      buffer.line((buffer.width / 2) - i, buffer.height / 3, i, value_down);
    }
  }
}

class Pulsar {
  PVector location;
  int SpecStart = 0, SpecEnd = 256;
  int MIN, MAX;
  color lineColor;

  Pulsar(float x, float y) {
    location = new PVector(x, y);
    MIN = 1; MAX = 160;
  }
  
  void setMin(int i) {
    MIN = i;
  }
  
  void setMax(int i) {
    MAX = i;
  }
  
  void move(PVector loc) {
    location = loc;
  }
  
  color setColor(int i) {
    int RED   = int(map(audio.averageSpecs[1].value, 0, 100, 0, 255));
    int GREEN = int(map(audio.averageSpecs[3].value, 0, 100, 0, 255));
    int BLUE  = int(map(audio.fullSpecs[i].value, 0, 100, 0, 255));
    return color(RED, GREEN, BLUE);
  }
  
  void drawLine(float radius, float angle) {
    float x = location.x + ( radius * cos( radians(angle) ) );
    float y = location.y + ( radius * sin( radians(angle) ) );
    buffer.line(location.x, location.y, x , y);
  }

  void draw() {
    buffer.noFill();
    for (int i = 0; i < (audio.fullSpecs.length - 1) / 2 ; i++) {
      buffer.stroke( setColor(i) );

      float angle  = map(i, 0, (audio.fullSpecs.length - 1) / 8, 0, 180);
      float radius = map(audio.fullSpecs[i].value, 0, 100, 1, buffer.width);
      float spin   = map(audio.volume.value, 0, 100, 0, 360);
      
      drawLine(radius, angle + spin);
      drawLine(radius, angle + 180 + spin);
    }
  }
}


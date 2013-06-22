ConcCircles circles;
SpecCity city;
Pulsar pulsar;

int CIRCLE_MODE = 0;

void setupCircles() {
  circles = new ConcCircles();
  city = new SpecCity();
  pulsar = new Pulsar();
}

void doCircles() {
  buffer.blendMode(ADD);
  circles.draw();
}

void doPulsar() {
  buffer.blendMode(ADD);
  pulsar.draw();
}

void doCity() {
  buffer.blendMode(ADD);
  city.draw();
}

class ConcCircles {
  float r = 16;
  float theta = 0;
  float numCircles = 32;

  ConcCircles() {
  }

  color getCircleColor(int i) {
    int RED   = audio.averageSpecs[1].grey;
    int GREEN = audio.averageSpecs[3].grey;
    int BLUE  = audio.averageSpecs[i].grey;
    return color(RED, GREEN, BLUE);
  }

  void draw() {
    //buffer.stroke(0);
    //buffer.strokeWeight(3);
    for (int i = 0; i < audio.averageSpecs.length - 1 ; i++) {
      for (int n = 0; n < numCircles; n++) {
        buffer.fill( getCircleColor(i) );
        float kx, ky;
        if (kinect.currentUserNumber != -1) {
          kx = kinect.user_center.x; 
          ky = kinect.user_center.y - 12;
        } 
        else {
          kx = buffer.width / 2; 
          ky = buffer.height / 2;
        }
        float x = (r+16*n)*cos(theta) + kx;
        float y = (r+16*n)*sin(theta) + ky;
        int value = int(map(audio.averageSpecs[i].value + 10, 10, 110, 2, 32));
        buffer.ellipse(x, y, value, value);
        if ( audio.isOnBeat() ) {
          float test = random(0, 1);
          if (test < 0.1) theta = random(theta * -1, theta);
          if (test > 0.75) theta *= -1;
        }
        if (theta > 0) {
          theta += 360 / numCircles / (audio.BPM + 1);
        } 
        else {
          theta -= 360 / numCircles / (audio.BPM + 1);
        }
      }
    }
  }
}



class SpecCity {
  float kx, ky;
  SpecCity() {
  }

  void draw() {
    buffer.beginShape(); 
    buffer.fill(audio.colors.background); 
    buffer.strokeWeight(3);
    if (kinect.currentUserNumber != -1) {
      kx = kinect.user_center.x; 
      ky = kinect.user_center.y - 12;
    } 
    else {
      kx = buffer.width / 2; 
      ky = buffer.height / 2;
    }
    for (int i = 0; i < (buffer.width / 2) ; i++) {
      int GREEN = audio.averageSpecs[1].grey;
      int BLUE  = audio.averageSpecs[3].grey;
      int RED   = audio.fullSpecs[i].grey;
      int value_up = int(map(audio.fullSpecs[i].value, 0, 100, buffer.height / 2, 0));
      int value_down = int(map(audio.fullSpecs[i].value, 0, 100, buffer.height / 2, buffer.height));
      buffer.stroke(RED, GREEN, BLUE);


      //buffer.fill(RED, GREEN, BLUE);

      buffer.line((buffer.width / 2) + i, buffer.height / 2, (buffer.width / 2) + i, value_up);
      buffer.line((buffer.width / 2) - i, buffer.height / 2, (buffer.width / 2) - i, value_up);
      buffer.line((buffer.width / 2) + i, buffer.height / 2, (buffer.width / 2) + i, value_down);
      buffer.line((buffer.width / 2) - i, buffer.height / 2, (buffer.width / 2) - i, value_down);

      //buffer.vertex(i + (buffer.width / 2), buffer.height / 3); buffer.vertex(i + (buffer.width / 2), value_up);
      //buffer.vertex((buffer.width / 2) - i, buffer.height / 3); buffer.vertex((buffer.width / 2) - i, value_up);
      //buffer.vertex(i + (buffer.width / 2), buffer.height / 3); 
      //buffer.vertex(buffer.width - i, value_down);
      //buffer.vertex((buffer.width / 2) - i, buffer.height / 3); 
      //buffer.vertex(i, value_down);
    }
    buffer.endShape(CLOSE);

    //for (int i = 0; i < 160 - 1; i++) {
    //  buffer.line(i, (buffer.height / 2) + audio.in.left.get(i)*30, i + 1, (buffer.height / 2) + audio.in.left.get(i+1)*30);
    //  buffer.line(i, 60 + audio.in.mix.get(i)*20, i + 1, 60 + audio.in.mix.get(i+1)*20); 
    //}
  }
}

class Pulsar {
  color lineColor;
  float kx, ky;

  Pulsar() {
  }

  color setColor(int i) {
    int RED   = audio.averageSpecs[1].grey;
    int GREEN = audio.averageSpecs[3].grey;
    int BLUE  = audio.fullSpecs[i].grey;
    return color(RED, GREEN, BLUE);
  }

  void drawLine(float radius, float angle) {
    float x = kx + ( radius * cos( radians(angle) ) );
    float y = ky + ( radius * sin( radians(angle) ) );
    buffer.line(kx, ky, x, y);
  }

  void draw() {
    buffer.noFill();

    if (kinect.currentUserNumber != -1) {
      kx = kinect.user_center.x; 
      ky = kinect.user_center.y - 12;
    } 
    else {
      kx = buffer.width / 2; 
      ky = buffer.height / 2;
    }
    for (int i = 0; i < (audio.fullSpecs.length - 1) / 2; i++) {
      buffer.strokeWeight(3);
      buffer.stroke( setColor(i) );
      //buffer.stroke( kinect.user_color );

      float angle  = map(i, 0, (audio.fullSpecs.length - 1) / 4, 0, 180);
      float radius = map(audio.fullSpecs[i].value, 0, 100, 1, buffer.width*2);
      float spin   = map(audio.volume.value, 0, 100, 0, 180);

      drawLine(radius, angle + spin);
      drawLine(radius, angle + 180 + spin);
    }
    //buffer.filter(POSTERIZE, 16);
  }
}



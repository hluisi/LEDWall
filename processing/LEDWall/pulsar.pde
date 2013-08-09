Pulsar pulsar;

void setupPulsar() {
  pulsar = new Pulsar();
}

class Pulsar {
  color lineColor;
  float kx, ky;
  float Z = -5;
  PVector kinectUser;
  int maxSpecs;

  Pulsar() {
    maxSpecs = audio.fullSpecs.length / 2;
  }

  color setColor(int i) {
    int r = 0, g = 0, b = 0;
    /*
    int s = round(random(3));
    switch(s) {
      case 0:
        r = audio.averageSpecs[1].grey;
        g = audio.averageSpecs[3].grey;
        b = audio.fullSpecs[i].grey;
        break;
      
      case 1:
        b = audio.averageSpecs[1].grey;
        r = audio.averageSpecs[3].grey;
        g = audio.fullSpecs[i].grey;
        break;
      
      case 2:
        g = audio.averageSpecs[1].grey;
        b = audio.averageSpecs[3].grey;
        r = audio.fullSpecs[i].grey;
        break;
    }
    */
    r = audio.averageSpecs[1].grey;
    g = audio.averageSpecs[3].grey;
    b = audio.fullSpecs[i].grey;
    color c = getBright(color(r,g,b));
    return c;
  }

  void drawLine(float radius, float angle) {
    float x = kinectUser.x + ( radius * cos( radians(angle) ) );
    float y = kinectUser.y + ( radius * sin( radians(angle) ) );
    
    //buffer.pushMatrix();
    //buffer.rectMode(CORNERS);
    //buffer.translate(kinectUser.x, kinectUser.y, Z);
    //buffer.rect(0,0,x,y);
    
    if (kinectUser.x == 80 && kinectUser.y == 40)
      buffer.line(kinectUser.x, kinectUser.y, Z, x, y, 0);
    else
      buffer.line(kinectUser.x, kinectUser.y, Z, x, y, Z);
    //buffer.popMatrix();

  }

  void draw() {
    //buffer.blendMode(REPLACE);
    buffer.blendMode(ADD);
    doBackground();
    
    buffer.noFill();
    kinectUser = getSingleUser();

    for (int i = 0; i < maxSpecs; i++) {    
      //buffer.strokeWeight(1);
      //buffer.stroke(0);
      buffer.stroke( setColor(i) );
      buffer.fill(setColor(i));
      int weight = round(map(audio.fullSpecs[i].value, 0, 100, 1, 4));
      buffer.strokeWeight(weight);

      float angle  = map(i, 0, (audio.fullSpecs.length - 1) / 4, 0, 180);
      float radius = map(audio.fullSpecs[i].value, 0, 100, 1, 320);
      float spin   = map(audio.volume.value, 0, 100, 0, 180);

      drawLine(radius, angle + spin);
      drawLine(radius, angle + 180 + spin);
    }
    buffer.blendMode(BLEND);
  }
}

ConcCircles circles = new ConcCircles();

void doCircles() {
  buffer.beginDraw();
  buffer.blendMode(ADD);
  buffer.background(audio.COLOR);
  //buffer.fill(0, 8);
  //buffer.rect(0,0,buffer.width, buffer.height);
  
  circles.draw();
  kinect.updateUserBlack();
  buffer.blend(kinect.buffer_image,0,0,kinect.buffer_image.width,kinect.buffer_image.height,0,0,buffer.width,buffer.height,MULTIPLY);
  buffer.endDraw();
  buffer.blendMode(BLEND);
}

class ConcCircles {
  float r = 16;
  float theta = 0;
  float numCircles = 16;
  
  ConcCircles(){
  }
  
  void draw(){
    buffer.stroke(0);
    for (int i = 0; i < audio.averageSpecs.length - 1 ; i++) {
      for (int n = 0; n < numCircles; n++) {
        int RED   = int(map(audio.averageSpecs[1].value, 0, 100, 0, 255));
        int GREEN = int(map(audio.averageSpecs[3].value, 0, 100, 0, 255));
        int BLUE  = int(map(audio.averageSpecs[i].value, 0, 100, 0, 255));
        buffer.fill(RED, GREEN, BLUE, 255);
        float kx, ky;
        if (kinect.user_id != -1) {
          kx = kinect.user_center.x; ky = kinect.user_center.y;
        } else {
          kx = buffer.width / 2; ky = buffer.height / 2;
        }
        float x = (r+16*n)*cos(theta) + kx;
        float y = (r+16*n)*sin(theta) + ky;
        int value = int(map(audio.averageSpecs[i].value + 10, 10, 110, 1, 40));
        buffer.ellipse(x, y, value, value);
        if ( audio.beat.isOnset() ) {
          theta = random(theta * -1,theta);
        }
        theta += 360/numCircles/ (audio.BPM + 1);
      }
    }
  }
}



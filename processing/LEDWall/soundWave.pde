// NOT SURE, WAVE MODE?  


void doUserBg() {
  //buffer.blendMode(ADD);
  buffer.blendMode(REPLACE);
  
  doBackground();
  
  int total = audio.in.bufferSize() - 1;
  int z = -150;
  int y = (z * -1); 
  
  //buffer.stroke(0);
  //buffer.strokeWeight(0.5);
  buffer.noStroke();
  buffer.fill(colors.users[11]);
  
  buffer.pushMatrix();
  buffer.translate(80,40,z);
  
  buffer.beginShape();
  
  for (int i = 0; i < total; i += 5) {
    int x = 0 - (total / 2) + i;
    buffer.vertex(x, audio.in.mix.get(i)*y);
  }
  
  for ( int i = total; i >= 0; i -= 5) {
    int x = 0 - (total / 2) + i;
    buffer.vertex(x, (audio.in.mix.get(i)*y) * -1);
  }
  buffer.endShape(CLOSE);
  
  buffer.popMatrix();
  buffer.blendMode(BLEND);
}

void displayImage(PImage _image) {
  //buffer.blendMode(BLEND);
  if (_image.width != buffer.width && _image.height != buffer.height) {
    buffer.copy(_image, 0, 0, _image.width, _image.height, 0, 0, buffer.width, buffer.height);
  } 
  else {
    buffer.image(_image, 0, 0);
  }
}

void doTest() {
  displayImage(smpte);
}


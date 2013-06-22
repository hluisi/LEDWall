
void doUserBg() {
  buffer.background(audio.colors.background);
  buffer.blendMode(ADD);
  buffer.stroke(255);
  buffer.strokeWeight(2);
  for (int i = 0; i < 160 - 1; i++) {
    buffer.line(i, 40 + audio.in.mix.get(i)*60, i + 1, 40 + audio.in.mix.get(i+1)*60);
  }
  
}

void displayImage(PImage _image) {
  buffer.blendMode(BLEND);
  if (_image.width != buffer.width && _image.height != buffer.height) {
    buffer.copy(_image, 0, 0, _image.width, _image.height, 0, 0, buffer.width, buffer.height);
  } else {
    buffer.image(_image, 0, 0);
  }
}

void doTest() {
  displayImage(smpte);
}


void doBGColor() {
  color thisColor = audio.COLOR[COLOR_MODE]; //audio.COLORS[AUDIO_MODE];
  buffer.beginDraw();
  buffer.background(thisColor);
  buffer.endDraw();
}

void doUserAudio() {
  color thisColor = audio.COLOR[COLOR_MODE]; //audio.COLORS[AUDIO_MODE];
  kinect.updateUser(thisColor);
  buffer.beginDraw();
  buffer.background(0);
  buffer.image(kinect.current_image, 0, 0);
  //if (audio.VOLUME < 70) buffer.filter(INVERT);
  buffer.endDraw();
}

void doUserBg() {
  color thisColor = audio.COLOR[COLOR_MODE]; //audio.COLORS[AUDIO_MODE];
  kinect.updateUserBlack();
  buffer.beginDraw();
  buffer.background(thisColor);
  buffer.image(kinect.current_image, 0, 0);
  //if (audio.VOLUME < 70) buffer.filter(POSTERIZE,5);
  buffer.endDraw();
}

void displayImage(PImage _image) {
  PImage bufferImage = createImage(COLUMNS, ROWS, ARGB);
  bufferImage.copy(_image, 0, 0, _image.width, _image.height, 0, 0, bufferImage.width, bufferImage.height);
  buffer.beginDraw();
  buffer.image(bufferImage, 0, 0);
  buffer.endDraw();
}

void doTest() {
  displayImage(smpte);
}

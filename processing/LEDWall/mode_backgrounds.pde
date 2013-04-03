PImage image_buffer;

void doUserAudio() {
  //color thisColor = audio.COLOR; //audio.COLORS[AUDIO_MODE];
  kinect.setDepthImageColor(audio.COLOR);
  kinect.updateUser(audio.COLOR);
  buffer.beginDraw();
  buffer.background(0);
  buffer.image(kinect.buffer_image, 0, 0);
  //if (audio.VOLUME < 70) buffer.filter(INVERT);
  buffer.endDraw();
}

void doUserBg() {
  color thisColor = audio.COLOR; //audio.COLORS[AUDIO_MODE];
  kinect.updateUserBlack();
  buffer.beginDraw();
  buffer.background(thisColor);
  buffer.image(kinect.buffer_image, 0, 0);
  //if (audio.VOLUME < 70) buffer.filter(POSTERIZE,5);
  buffer.endDraw();
}

void displayImage(PImage _image) {
  
  image_buffer.copy(_image, 0, 0, _image.width, _image.height, 0, 0, image_buffer.width, image_buffer.height);
  buffer.beginDraw();
  buffer.background(0);
  buffer.image(image_buffer, 0, 0);
  buffer.endDraw();
}

void doTest() {
  displayImage(smpte);
}

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
  kinect.updateUserBlack();
  buffer.beginDraw();
  buffer.background(audio.COLOR);
  buffer.stroke(255);
  buffer.strokeWeight(1);
  for (int i = 0; i < 160 - 1; i++) {
    //buffer.line(i, (buffer.height / 2) + audio.in.left.get(i)*30, i + 1, (buffer.height / 2) + audio.in.left.get(i+1)*30);
    
    buffer.line(i, 40 + audio.in.mix.get(i)*60, i + 1, 40 + audio.in.mix.get(i+1)*60); 
  }
  buffer.noStroke();
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

import processing.video.*;

Movie m;
float mspeed;

void setupClips() {
  m = new Movie(this, "holly2.mov");
  m.loop();
  mspeed = 1.0;
}

void doClips() {
  buffer.beginDraw();
  buffer.background(audio.COLOR);
  //buffer.background(0);
  buffer.blendMode(ADD);
  if (m.available() == true) {
    m.read(); 
  } //else {
    //println("movie error!!");
    //exit();
  //}
  
  mspeed = map(audio.BPM, 0, 200, 0.25, 2.5);
  m.speed(mspeed);
  buffer.image(m, 0, 0, buffer.width, buffer.height);
  
  buffer.blendMode(BLEND);
  //kinect.updateUserBlack();
  //buffer.image(kinect.buffer_image, 0, 0);
  buffer.endDraw();
}

//void movieEvent( Movie m ) {
//  m.read();
//}

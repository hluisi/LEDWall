// ALWAYS NEEDS A REWRITE

void debugBack() {
  fill( 24 );
  rect(480, 0, WINDOW_XSIZE - 480, WINDOW_YSIZE - DEBUG_WINDOW_YSIZE);
  fill( 16 );     // background for top area
  rect(0, 240, WINDOW_XSIZE - 480, WINDOW_YSIZE - DEBUG_WINDOW_YSIZE - 240);
}

void debugWallImage() {
  image(buffer, 0, 0, 480, 240);
}

void debugKinectImages() {
  textFont(lFont);
  for (int i = 0; i < kinect.users.length && i < 12; i++) {
    image(kinect.users[i].img, 0, 240, 480, 240);
    textAlign(CENTER, CENTER);
    fill(255);
    text(kinect.users[i].i, (kinect.users[i].x*3), (kinect.users[i].y*3) + 240 );
    textAlign(LEFT, BASELINE);
    if (i < 12) text(nf(kinect.users[i].i, 2) + ": " + 
      nf(kinect.users[i].x, 3, 1) + "," +
      nf(kinect.users[i].y, 3, 1) + "," +
      nf(kinect.users[i].z, 3, 1), 490, 260 + (20 * i));
  }
}

void debugTeensyImages() {
  int tx =  520;
  int ty, v, m;
  fill(255);
  textFont(mFont);
  textAlign(LEFT, BASELINE);
  for (int i =0; i < wall.teensyImages.length; i++) {
    ty = 10 + (22 * i);
    text("T:" + i, tx - 25, ty + 12);
    image(wall.teensyImages[i], tx, ty);
    if (USE_TEENSYS) {
      v = teensys[i].sendTime;
      m = teensys[i].maxSend;
    } 
    else {
      v = SIM_DELAY;
      m = SIM_DELAY;
    }
    text(nf(v, 3) + " / " + nf(m, 3), tx + 80 + 10, ty + 12);
  }
}

void debugTimers() {
  textFont(lFont);
  textAlign(RIGHT, BASELINE);
  fill(255);
  text("FPS: " + nf(frameRate, 2, 1), 950, 20);
  if (audioOn) {
    text("BPM: " + nf(audio.BPM, 3), 950, 60);
    text("Vol: " + nf(audio.volume.value, 3), 950, 80);
  }
  
  text("Mode: " + nf(MODE_TIME,2) + "/" + nf(MAX_MODE,2), 950, 120);
  text("Audio: " + nf(AUDIO_TIME,2) + "/" + nf(MAX_AUDIO,2), 950, 140);
  text("Kinect: " + nf(KINECT_TIME,2) + "/" + nf(MAX_KINECT,2), 950, 160);
  text("User Map: " + nf(MAP_TIME,2) + "/" + nf(MAX_MAP,2), 950, 180);
  text("TBuffer: " + nf(TBUFFER_TIME,2) + "/" + nf(MAX_TBUFFER,2), 950, 200);
  text("Send: " + nf(SEND_TIME,2) + "/" + nf(MAX_SEND,2), 950, 220);
  
  text("Debug: " + nf(DEBUG_TIME,2) + "/" + nf(MAX_DEBUG,2), 950, 260);
  text("CP5: " + nf(CP5_TIME,2) + "/" + nf(MAX_CP5,2), 950, 280);
  text("Simulate: " + nf(SIMULATE_TIME,2) + "/" + nf(MAX_SIMULATE,2), 950, 300);
  
  //if (kinectOn) {
  //  text("USERS: " + nf(kinect.users.length,2), 950, 240);
  //}
}

void drawDebug() {
  pushStyle();         // push the style
  noStroke();          // turn off stroke
  debugBack();         // draw background
  debugWallImage();    // draw wall image
  debugKinectImages(); // draw kinect images

    debugTimers();
  debugTeensyImages(); // draw teensy images

  /*
  fill(cp5.getColor().getCaptionLabel());
   //text("Display Mode: " + DISPLAY_STR[DISPLAY_MODE], DEBUG_TEXT_X, DEBUG_WINDOW_START + 20);
   text("FPS: " + String.format("%.2f", frameRate), DEBUG_TEXT_X, DEBUG_WINDOW_START + 50);
   
   if (audioOn) {
   text("BASS: " + audio.bass.value, DEBUG_TEXT_X, DEBUG_WINDOW_START + 65); 
   text("MIDS: " + audio.mids.value, DEBUG_TEXT_X + 60, DEBUG_WINDOW_START + 65);
   text("TREB: " + audio.treb.value, DEBUG_TEXT_X + 120, DEBUG_WINDOW_START + 65);
   text("BPM: " + audio.BPM + "  count: " + audio.bpm_count + "  secs: " + audio.sec_count, DEBUG_TEXT_X, DEBUG_WINDOW_START + 80);
   text("dB: " + String.format("%.2f", audio.volume.dB), DEBUG_TEXT_X, DEBUG_WINDOW_START + 95);
   }
   
   if (wallOn) {
   text("WATTS: " + String.format("%.2f", WALL_WATTS), DEBUG_TEXT_X, DEBUG_WINDOW_START + 125);
   text("Max: "   + String.format("%.2f", MAX_WATTS), DEBUG_TEXT_X + 100, DEBUG_WINDOW_START + 125);
   }
   */

  popStyle();
}


// ALWAYS NEEDS A REWRITE

void drawDebugBack() {
  
  fill( 48, 0, 4 );
  
  rect(960, 0, 406, 202);
  
  fill( 64, 4, 8 );
  rect(960, 203, 229, WINDOW_YSIZE - DEBUG_WINDOW_YSIZE);
  //fill( 24 );
  rect(1190, 203, 200, WINDOW_YSIZE - DEBUG_WINDOW_YSIZE);
  
  textFont(lFont);
  textAlign(CENTER, CENTER);
  fill(255);
  if (USE_SOPENNI) text("KINECT USERS: " + nf(kinect.users.length,2), 1190, 10);
  textFont(mFont);
  text("USER X, Y, Z", 1085, 210);
}


void debugWallImage() {
  SIMULATE_TIME = 0;
  int stime = millis();
  tint(255, MAX_BRIGHTNESS);
  image(buffer, 0, 0, 960, 480);
  noTint();
  SIMULATE_TIME = millis() - stime;
  MAX_SIMULATE = max(MAX_SIMULATE, SIMULATE_TIME);
}

void debugKinectImages() {
  textFont(lFont);
  for (int i = 0; i < kinect.users.length && i < kinect.LIMIT; i++) {
    image(kinect.users[i].img, 963, 0, 400, 200);
    textAlign(CENTER, CENTER);
    fill(255);
    float x = kinect.users[i].x*2.5 + 963;
    float y = kinect.users[i].y*2.5;
    if (y < 201) {
      text(kinect.users[i].id, x, y);
    }
    textAlign(LEFT, BASELINE);
    if (i < 12) text(nf(kinect.users[i].id, 2) + ": " + 
      nf(kinect.users[i].x, 3, 1) + "," +
      nf(kinect.users[i].y, 3, 1) + "," +
      nf(kinect.users[i].z, 3, 2), 965, 240 + (20 * i));
  }
}

/*
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
 v = 0;
 m = 0;
 }
 text(nf(v, 3) + " / " + nf(m, 3), tx + 80 + 10, ty + 12);
 }
 }
 */

void debugTimers() {
  int x = WINDOW_XSIZE - 8;
  textFont(mFont);
  textAlign(CENTER, BASELINE);
  text("TIMERS", WINDOW_XSIZE - 85, 218);
  textFont(lFont);
  textAlign(RIGHT, BASELINE);
  fill(255);
  text("fps: " + nf(frameRate, 2, 2), x, 240);
  text("mode: " + nf(MODE_TIME, 2) + "/" + nf(MAX_MODE, 2), x, 260);
  text("bpm:    " + nf(audio.BPM, 3), x, 280);
  text("kinect: " + nf(KINECT_TIME, 2) + "/" + nf(MAX_KINECT, 2), x, 300);
  text("user map: " + nf(MAP_TIME, 2) + "/" + nf(MAX_MAP, 2), x, 320);
  text("t-buffer: " + nf(TBUFFER_TIME, 2) + "/" + nf(MAX_TBUFFER, 2), x, 340);
  text("send: " + nf(SEND_TIME, 2) + "/" + nf(MAX_SEND, 2), x, 360);
  text("debug: " + nf(DEBUG_TIME, 2) + "/" + nf(MAX_DEBUG, 2), x, 380);
  text("cp5: " + nf(CP5_TIME, 2) + "/" + nf(MAX_CP5, 2), x, 400);
  text("simulate: " + nf(SIMULATE_TIME, 2) + "/" + nf(MAX_SIMULATE, 2), x, 420);
  text(nf(WALL_WATTS, 4, 2) + "/" + nf(MAX_WATTS, 4, 2), x, 460);


  //if (audioOn) {
  //  text("BPM: " + nf(audio.BPM, 3), 950, 60);
  //  text("Vol: " + nf(audio.volume.value, 3), 950, 80);
  //}





  //if (kinectOn) {
  //  text("USERS: " + nf(kinect.users.length,2), 950, 240);
  //}
}

void drawDebug() {
  noStroke();          // turn off stroke

  if (!simulateOn) debugWallImage();
  drawDebugBack();
  if (USE_SOPENNI) debugKinectImages(); // draw kinect images


  debugTimers();
  //debugTeensyImages(); // draw teensy images

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

}


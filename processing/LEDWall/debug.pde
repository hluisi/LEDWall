

void drawDebug() {
  if (!DEBUG_SHOW_WALL) { // show the buffer
    wall_image.copy(buffer.get(), 0, 0, KINECT_WIDTH, KINECT_HEIGHT, 0, 0, COLUMNS*2, ROWS*2); 
    image(wall_image, (width / 2) - ( (COLUMNS*2) / 2), 0);
  }
  
  textSize(11);  
  fill(#313131);
  stroke(0);
  strokeWeight(1);
  rectMode(CORNER);
  rect(0, DEBUG_WINDOW_START, DEBUG_WINDOW_XSIZE, DEBUG_WINDOW_START + DEBUG_WINDOW_YSIZE);

  // fill text display background
  fill(#212121);
  //rect(5, DEBUG_WINDOW_START + 5, 200, 210);
  rect(DEBUG_WINDOW_XSIZE - 205, DEBUG_WINDOW_START + 5, 200, 210);

  fill(255);
  //text("Display Mode: " + DISPLAY_STR[DISPLAY_MODE], DEBUG_TEXT_X, DEBUG_WINDOW_START + 20);
  text("FPS: " + String.format("%.2f", frameRate), DEBUG_TEXT_X, DEBUG_WINDOW_START + 50);
  
  text("BASS: " + audio.bass.value, DEBUG_TEXT_X, DEBUG_WINDOW_START + 65); 
  text("MIDS: " + audio.mids.value, DEBUG_TEXT_X + 60, DEBUG_WINDOW_START + 65);
  text("TREB: " + audio.treb.value, DEBUG_TEXT_X + 120, DEBUG_WINDOW_START + 65);
  

  text("BPM: " + audio.BPM + "  count: " + audio.bpm_count + "  secs: " + audio.sec_count, DEBUG_TEXT_X, DEBUG_WINDOW_START + 80);
  
  text("dB: " + String.format("%.2f", audio.volume.dB), DEBUG_TEXT_X, DEBUG_WINDOW_START + 95);

  text("WATTS: " + String.format("%.2f", teensys[0].watts), DEBUG_TEXT_X, DEBUG_WINDOW_START + 125);
  text("Max: "   + String.format("%.2f", MAX_WATTS), DEBUG_TEXT_X + 100, DEBUG_WINDOW_START + 125);

  text("Clips speed: " + clips.current_speed, DEBUG_TEXT_X, DEBUG_WINDOW_START + 140);
  text("Users: " + kinect.numberOfUsers, DEBUG_TEXT_X, DEBUG_WINDOW_START + 170);

  //fill(#212121);

  //rect(DEBUG_WINDOW_XSIZE - 205, DEBUG_WINDOW_START + 5, 200, 210);
  /*
  for (int i = 0; i < wall.teensyImages.length; i++) {
    pushMatrix();
    int y = DEBUG_WINDOW_START + 14 + (i * 16);

    String temp = "Teensy " + i;
    fill(255);
    text(temp, DEBUG_WINDOW_XSIZE - 90 - textWidth(temp) - 5, y + (i * 4) + 12);

    translate(DEBUG_WINDOW_XSIZE - 90, y + (i * 4));

    image(wall.teensyImages[i], 0, 0);
    popMatrix();
  } */
}


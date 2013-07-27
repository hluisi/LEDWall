// STILL A TON TO ADD

import controlP5.*;

ControlP5 cp5;
Println console;
RadioButton r;
Toggle auto_mode_toggle;
Toggle map_user_toggle;
Toggle audio_back_toggle;
Slider bright;
Textlabel displayModeText;
Textlabel globalHeader;
Group g1, g2, g3;

void setupControl() {
  strokeWeight(1);
  stroke(0);
  cp5 = new ControlP5(this);

  g1 = cp5.addGroup("global_group")
    .setPosition(0, DEBUG_WINDOW_START)
      .setBackgroundHeight(DEBUG_WINDOW_YSIZE)
        .setWidth(200)
          .setBackgroundColor(color(#212121))
            .hideBar()
              ;

  globalHeader = cp5.addTextlabel("g_head")
    .setText("Modes")
      .setPosition(60, 0)
        .setColor(color(255))
          .setFont(createFont("Verdana-Bold", 22))
            .setGroup(g1)
              ;

  bright = cp5.addSlider("Brightness")
    .setSize(180, 25)
      .setPosition(10, DEBUG_WINDOW_YSIZE - 40)
        .setRange(0, 255)
          .setValue(192)
            .setColorForeground(color(255))
              .setColorBackground(color(#151515))
                .setColorActive(color(255, 255, 0))
                  .setSliderMode(Slider.FLEXIBLE)
                    .setHandleSize(20)
                      .setGroup(g1)
                        ;
  bright.captionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
  bright.captionLabel().setPaddingY(3);
  bright.valueLabel().align(ControlP5.RIGHT, ControlP5.CENTER);
  //bright.valueLabel().setPaddingY(3);

  r = cp5.addRadioButton("modeButton")
    .setPosition(15, 30)
      .setGroup(g1)
        .setSize(40, 20)
          .setColorBackground(color(#151515))
            .setColorForeground(color(#515151))
              .setColorActive(color(255))
                .setColorLabel(color(255))
                  .setItemsPerRow(3)
                    .setSpacingColumn(20)
                      .setSpacingRow(17)
                        .addItem("Test", 0)
                          .addItem("EQ", 1)
                            .addItem("UserBG", 2)
                              .addItem("Rainbow", 3)
                                .addItem("Shapes", 4)
                                  .addItem("Spin", 5)
                                    .addItem("Pulsar", 6)
                                      .addItem("City", 7)
                                        .addItem("Atari", 8)
                                          .addItem("Clips", 9)
                                            .activate(1)
                                              ;

  for (Toggle t:r.getItems()) {
    t.captionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
    t.captionLabel().setPaddingY(3);
  }

  displayModeText = cp5.addTextlabel("mode_text")
    .setPosition(200, DEBUG_WINDOW_START + 5)
      .setColor(color(255))
        .setFont(createFont("Georgia", 20));

  auto_mode_toggle = cp5.addToggle("auto_mode")
    .setPosition(225, DEBUG_WINDOW_START + 150)
      .setSize(40, 20)
        .setColorBackground(color(#151515))
          .setColorForeground(color(#515151))
            .setColorActive(color(255))
              .setColorLabel(color(255))
                .setValue(false)
                  .setMode(ControlP5.SWITCH)
                    ;

  auto_mode_toggle.captionLabel().setText("Auto Mode");

  map_user_toggle = cp5.addToggle("map_user")
    .setPosition(275, DEBUG_WINDOW_START + 150)
      .setSize(40, 20)
        .setColorBackground(color(#151515))
          .setColorForeground(color(#515151))
            .setColorActive(color(255))
              .setColorLabel(color(255))
                .setValue(false)
                  .setMode(ControlP5.SWITCH)
                    ;

  map_user_toggle.captionLabel().setText("User Map");

  audio_back_toggle = cp5.addToggle("audio_bg")
    .setPosition(325, DEBUG_WINDOW_START + 150)
      .setSize(40, 20)
        .setColorBackground(color(#151515))
          .setColorForeground(color(#515151))
            .setColorActive(color(255))
              .setColorLabel(color(255))
                .setValue(false)
                  .setMode(ControlP5.SWITCH)
                    ;

  audio_back_toggle.captionLabel().setText("BACK GND");
}

public void Brightness(int value) {
  max_brightness = value;
}

public void modeButton(int v) {
  if (v < 0) { 
    v = 1;
    r.activate(1);
  }
  DISPLAY_MODE = v;
}

void auto_mode(boolean theFlag) {
  if (theFlag==true) {
    AUTOMODE = true;
    println("Auto Mode: ON");
  } 
  else {
    AUTOMODE = false;
    println("Auto Mode: OFF");
  }
}

void map_user(boolean theFlag) {
  if (USE_KINECT) {
    if (theFlag==true) {
      kinect.mapUser = true;
      println("User Map: ON");
    } 
    else {
      kinect.mapUser = false;
      println("User Map: OFF");
    }
  }
}

void audio_bg(boolean theFlag) {
  if (theFlag==true) {
    AUDIO_BG_ON = true;
    println("Audio backgroung: ON");
  } 
  else {
    AUDIO_BG_ON = false;
    println("Audio background: OFF");
  }
}


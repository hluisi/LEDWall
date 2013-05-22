import controlP5.*;

ControlP5 cp5;
Println console;
RadioButton r;
Toggle amode;
Toggle mUser;
Slider bright;

void setupControl() {
  strokeWeight(1);
  stroke(0);
  cp5 = new ControlP5(this);

  bright = cp5.addSlider("Brightness")
    .setSize(400, 20)
      .setPosition(225, DEBUG_WINDOW_START + 100)
        .setRange(0, 255)
          .setValue(245)
            .setColorForeground(color(255))
              .setColorBackground(color(#212121))
                .setColorActive(color(255, 255, 0))
                  .setSliderMode(Slider.FLEXIBLE)
                    //.setHandleSize(10)
                    ;
  bright.captionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
  bright.captionLabel().setPaddingY(3);

  r = cp5.addRadioButton("modeButton")
    .setPosition(225, DEBUG_WINDOW_START + 10)
      .setSize(40, 20)
        .setColorBackground(color(#212121))
          .setColorForeground(color(#515151))
            .setColorActive(color(255))
              .setColorLabel(color(255))
                .setItemsPerRow(5)
                  .setSpacingColumn(50)
                    .setSpacingRow(20)
                      .addItem("Test", 0)
                        .addItem("EQ", 1)
                          .addItem("UserBG", 2)
                            .addItem("Wheel", 3)
                              .addItem("Balls", 4)
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

  amode = cp5.addToggle("auto_mode")
    .setPosition(225, DEBUG_WINDOW_START + 150)
      .setSize(40, 20)
        .setColorBackground(color(#212121))
          .setColorForeground(color(#515151))
            .setColorActive(color(255))
              .setColorLabel(color(255))
                .setValue(true)
                  .setMode(ControlP5.SWITCH)
                    ;

  amode.captionLabel().setText("Auto Mode");

  mUser = cp5.addToggle("map_user")
    .setPosition(275, DEBUG_WINDOW_START + 150)
      .setSize(40, 20)
        .setColorBackground(color(#212121))
          .setColorForeground(color(#515151))
            .setColorActive(color(255))
              .setColorLabel(color(255))
                .setValue(false)
                  .setMode(ControlP5.SWITCH)
                    ;

  mUser.captionLabel().setText("User Map");
}

public void Brightness(int value) {
  buffer.maxBrightness(value);
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
  } else {
    AUTOMODE = false;
    println("Auto Mode: OFF");
  }
}

void map_user(boolean theFlag) {
  if (theFlag==true) {
    kinect.mapUser = true;
    println("User Map: ON");
  } else {
    kinect.mapUser = false;
    println("User Map: OFF");
  }
}


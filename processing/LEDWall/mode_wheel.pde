Wheel wheel;

void setupWheel() {
  wheel = new Wheel();
  wheel.audioOff();
  println("WHEEL SETUP ...");
}

void doWheel() {
  //if (kinect.user1_center.x < 1 && kinect.user1_center.y < 1) kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_NONE);
  //if (kinect.user1_center.x == null) kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_NONE);
  wheel.setLocation(kinect.user_center.x, kinect.user_center.y );
  buffer.beginDraw();
  if (wheel.use_audio) {
    TColor thisColor = TColor.newARGB(aaudio.COLOR);
    thisColor.complement();
    kinect.updateUser(thisColor.toARGB());
  }
  else kinect.updateUserBlack();
  wheel.display();
  buffer.image(kinect.buffer_image, 0, 0);
  buffer.endDraw();
}


class Wheel {
  //PShape sun_shape;
  boolean use_audio;
  PVector location;                       // the location of the center of the wheel
  int last_cycle;                           // the last time the colors were cycled
  int cycle_time = 100;                // the time between cycling colors
  color[] colors = new color [8];
  color[] default_colors = {
    color(255, 0, 0), color(255, 128, 0), color(255, 255, 0), color(128, 255, 0), 
    color(0, 255, 0), color(0, 255, 128), color(0, 128, 255), color(0, 0, 255)
  };


  Wheel() {
    location = new PVector();
    resetColors();
    last_cycle = millis();
    use_audio = false;
  }

  private void cycleColors() {
    color saved = colors[0];
    for (int i = 0; i < (colors.length - 1); i++) {
      colors[i] = colors[i + 1];
    }
    colors[colors.length - 1] = saved;
  }

  private void cycleColors(color c) {
    for (int i = 0; i < (colors.length - 1); i++) {
      colors[i] = colors[i + 1];
    }
    colors[colors.length - 1] = c;
  }

  void resetColors() {
    arrayCopy(default_colors, colors);
  }

  void setLocation(float x, float y) {
    location.x = round(x);
    location.y = round(y);
  }

  void audioOn() {
    use_audio = true;
    resetColors();
    cycle_time = 50;
  }

  void audioOff() {
    use_audio = false;
    resetColors();
    cycle_time = 50;
  }

  private void check() {
    int cTime = millis();
    if (cTime - last_cycle > cycle_time) {
      //if (use_audio) cycleColors(audio.COLORS[AUDIO_MODE]);
      if (use_audio) cycleColors(aaudio.COLOR);
      else cycleColors();
      last_cycle = cTime;
    }
  }


  void display() {

    check();

    buffer.noStroke();


    for (int i = 0; i < 8; i++) {

      buffer.fill(colors[i]);
      buffer.quad(location.x, location.y, 0, i * 10, 0, (i + 1) * 10, location.x, location.y);
      buffer.quad(location.x, location.y, i * 20, 0, (i + 1) * 20, 0, location.x, location.y);

      int j = 7 - i;
      buffer.fill(colors[j]);
      buffer.quad(location.x, location.y, buffer.width, i * 10, buffer.width, (i + 1) * 10, location.x, location.y);
      buffer.quad(location.x, location.y, i * 20, buffer.height, (i + 1) * 20, buffer.height, location.x, location.y);
    }
  }
}


// COULD USE A REWRITE

Rainbow rainbow;

final String[] RAINBOW_STR = { 
  "WHEEL", "TUNNEL"
};

void setupRainbow() {
  rainbow = new Rainbow();
  rainbow.audioOff();
  println("RAINBOW SETUP ...");
}

void doRainbow() {
  //buffer.blendMode(BLEND);
  if (USE_KINECT) {
    if (kinect.users.length > 0 && kinect.users[0].onScreen()) {
      rainbow.setLocation(kinect.users[0].x, kinect.users[0].y );
    } 
    else {
      rainbow.setLocation(buffer.width / 2, buffer.height / 2 );
    }
  }
  else {
    rainbow.setLocation(buffer.width / 2, buffer.height / 2 );
  }
  rainbow.setCycle(audio.BPM);
  rainbow.display();
}


class Rainbow {
  final int MODE_WHEEL  = 0;
  final int MODE_TUNNEL = 1;
  final int TOTAL_MODES = 2;
  float horizontal = 0;
  float vertical = 0;
  float random_test = 0;
  int mode = 1;
  boolean use_audio;
  PVector location;                       // the location of the center of the wheel
  PVector size;
  PVector last_size;
  int last_cycle, bi;                           // the last time the colors were cycled
  int cycle_time = 100;                // the time between cycling colors
  color[] colors = new color [8];
  color[] default_colors = {
    color(255, 0, 0), color(255, 127, 0), color(255, 127, 0), color(127, 255, 0), 
    color(0, 255, 0), color(0, 255, 127), color(0, 127, 255), color(0, 0, 255)
  };


  Rainbow() {
    location = new PVector();
    size = new PVector();
    last_size = new PVector();
    resetColors();
    resetSize();
    last_cycle = millis();
    use_audio = false;
  }

  void resetSize() {
    size.set(buffer.width*3, buffer.height*6);
    last_size.set(size.x*1.1, size.y*1.1);
  }

  void setCycle(int t) {
    int temp = int(map(t, 1, 200, 172, 1));
    cycle_time = temp;
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
      if (use_audio) cycleColors(audio.colors.background); 
      else cycleColors();
      last_cycle = cTime;
    }

    if ( audio.isOnBeat() ) {
      random_test = random(0, 1);
      if (random_test < 0.65) {
        mode = round( random(TOTAL_MODES - 1) );
        println("RAINBOW - new mode: " + RAINBOW_STR[mode]);
        //if (mode == MODE_TUNNEL) {
        //  audioOn();
        //} else {
        //  audioOff();
        //}
      }
    }
  }

  void doWheel() {
    buffer.noStroke();
    //buffer.strokeWeight(0.5);

    for (int i = 0; i < colors.length; i++) {
      int rnd = round( random(-1,1) );
      //int h_spec = i + rnd;
      //int v_spec = i - 1 + rnd;
        
      //if (v_spec < 0) v_spec = colors.length - 1;
      //if (v_spec > colors.length) v_spec = 0;
      //if (h_spec < 0) h_spec = colors.length - 1;
      //if (h_spec > colors.length) h_spec = 0;
      
      //rnd = round( random(-1,1) );

      //horizontal = map(audio.averageSpecs[h_spec].value, 0, 100, 20, 5);
      //vertical   = map(audio.averageSpecs[v_spec].value, 0, 100, 10, 1);
      
      horizontal = map(audio.volume.value, 0, 100, 20, 10 + (rnd * 2) );
      vertical   = map(audio.volume.value, 0, 100, 10, 5 + rnd);

      buffer.fill( mapByVol( colors[i] ) );
      if ((i + rnd) % 2 == 0) buffer.fill( audio.colors.get(i) );
      buffer.triangle(location.x, location.y, 0, (i * 10) + vertical, 0, ((i + 1) * 10) - vertical);
      buffer.triangle(location.x, location.y, (i * 20) + horizontal, 0, ((i + 1) * 20) - horizontal, 0);

      bi = 7 - i;
      buffer.fill( mapByVol( colors[bi] ) );
      if ((i + rnd) % 2 == 0) buffer.fill( audio.colors.get(bi) );
      buffer.triangle(location.x, location.y, buffer.width, (i * 10) + vertical, buffer.width, ((i + 1) * 10) - vertical);
      buffer.triangle(location.x, location.y, (i * 20) + horizontal, buffer.height, ((i + 1) * 20) - horizontal, buffer.height);
    }
  }

  void doTunnel() {
    buffer.rectMode(CENTER);
    buffer.blendMode(BLEND);
    //buffer.noStroke();
    buffer.stroke(0);
    buffer.strokeWeight(1);

    buffer.pushMatrix();
    buffer.translate(location.x, location.y);
    //buffer.translate(buffer.width/2, buffer.height/2);

    for (int j = 0; j < 2; j++) {
      for (int i = 0; i < colors.length; i++) {
        int rnd = round( random(-1,1) );
        int h_spec = i + rnd;
        int v_spec = i - 1 + rnd;
        
        if (v_spec < 0) v_spec = colors.length - 1;
        if (v_spec > colors.length) v_spec = 0;
        if (h_spec < 0) h_spec = colors.length - 1;
        if (h_spec > colors.length) h_spec = 0;
        
        rnd = round( random(-1,1) );
        
        
        if ((i + rnd) % 2 == 0) {
          //buffer.fill(0);
          //buffer.fill(colors[i]);
          buffer.fill( audio.colors.get(i) );
          horizontal = map(audio.averageSpecs[h_spec].value, 0, 100, size.x, last_size.x + last_size.x);
          vertical   = map(audio.averageSpecs[v_spec].value, 0, 100, size.y, last_size.y + last_size.y);
        } else {
          //buffer.fill(0);
          buffer.fill( mapByVol( colors[i] ) );
          horizontal = map(audio.averageSpecs[h_spec].value, 0, 100, last_size.x, size.x);
          vertical   = map(audio.averageSpecs[v_spec].value, 0, 100, last_size.y, size.y);
        }
        buffer.rect(0, 0, horizontal, vertical);
        last_size.set(size.x, size.y);
        size.div(1.25);
      }
    }

    buffer.fill(0);
    buffer.rect(0, 0, size.x, size.y, 5);
    buffer.popMatrix();
    resetSize();
  }


  void display() {
    check();
    if (mode == MODE_WHEEL) doWheel();
    if (mode == MODE_TUNNEL) doTunnel();
    //doTunnel();
    buffer.noStroke();  // reset to no stroke
  }
}


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
  buffer.blendMode(ADD);
  rainbow.setLocation(kinect.user_center.x, kinect.user_center.y );
  rainbow.setCycle(audio.BPM);
  rainbow.display();
}


class Rainbow {
  final int MODE_WHEEL  = 0;
  final int MODE_TUNNEL = 1;
  final int TOTAL_MODES = 2;
  int mode = 1;
  boolean use_audio;
  PVector location;                       // the location of the center of the wheel
  PVector size;
  PVector last_size;
  int last_cycle;                           // the last time the colors were cycled
  int cycle_time = 100;                // the time between cycling colors
  color[] colors = new color [8];
  color[] default_colors = {
    color(128, 0, 0), color(128, 64, 0), color(128, 128, 0), color(64, 128, 0), 
    color(0, 128, 0), color(0, 128, 64), color(0, 64, 128), color(0, 0, 128)
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
    size.set(buffer.width*3,buffer.height*6);
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
      if (use_audio) cycleColors(audio.colors.background); else cycleColors();
      last_cycle = cTime;
    }
    
    if ( audio.isOnBeat() ) {
      float test = random(0, 1);
      if (test < 0.65) {
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
    buffer.blendMode(BLEND);
    //buffer.background(0);
    buffer.stroke(0);
    buffer.strokeWeight(0.5);
    //buffer.noStroke();
    
    
    for (int i = 0; i < 8; i++) {
      
      float horizontal = map(audio.BASS, 0, 100, 20, 10);
      float vertical   = map(audio.MIDS, 0, 100, 10, 5);
      
      buffer.fill(colors[i]);
      buffer.triangle(location.x, location.y, 0, (i * 10) + vertical, 0, ((i + 1) * 10) - vertical);
      buffer.triangle(location.x, location.y, (i * 20) + horizontal, 0, ((i + 1) * 20) - horizontal, 0);
      
      int j = 7 - i;
      buffer.fill(colors[j]);
      buffer.triangle(location.x, location.y, buffer.width, (i * 10) + vertical, buffer.width, ((i + 1) * 10) - vertical);
      buffer.triangle(location.x, location.y, (i * 20) + horizontal, buffer.height, ((i + 1) * 20) - horizontal, buffer.height);
      
    }
    
    buffer.blendMode(ADD);
    if (AUDIO_BG_ON) {
      buffer.fill(audio.colors.background); 
      buffer.rect(0,0,size.x,size.y);
    }
  }
  
  void doTunnel() {
    buffer.rectMode(CENTER);
    buffer.blendMode(BLEND);
    buffer.stroke(0);
    buffer.strokeWeight(0.5);
    //buffer.noStroke();
    buffer.pushMatrix();
    buffer.translate(location.x, location.y);
    //buffer.translate(buffer.width/2, buffer.height/2);
    
    for (int j = 0; j < 2; j++) {
      for (int i = 0; i < colors.length; i++) {
        buffer.fill(colors[i]);
        float h = map(audio.BASS, 0, 100, size.x, last_size.x);
        float v = map(audio.MIDS, 0, 100, size.y, last_size.y);
        //float x = map(i, 0, colors.length, 0, -10);
        //float y = map(i, 0, colors.length, 0, -15);
        buffer.rect(0,0,h,v,2.5);
        last_size.set(size.x, size.y);
        size.div(1.5);
      }
    }
    
    buffer.fill(0);
    buffer.rect(0,0,size.x,size.y,5);
    buffer.popMatrix();
    resetSize();
    buffer.blendMode(ADD);
    if (AUDIO_BG_ON) {
      buffer.fill(audio.colors.background); 
      buffer.rect(0,0,size.x,size.y);
    }
      
    
    
  }
    

  void display() {
    check();
    buffer.noStroke();
    
    if (mode == MODE_WHEEL) doWheel();
    if (mode == MODE_TUNNEL) doTunnel();

    
  }
}


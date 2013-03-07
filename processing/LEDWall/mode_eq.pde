EQ eq;

void setupEQ() {
  eq = new EQ();
  println("SETUP EQ ...");
}

void doEQ() {
  buffer.beginDraw();
  eq.display(AUDIO_MODE);
  buffer.endDraw();
}

class EQ {

  final int RAW      = 0;
  final int SMOOTHED = 1;
  final int BALANCED = 2;

  int audio_mode;

  PFont volumeFont, eqFont, audioFont, tFont;

  eqBar volume, eq0, eq1, eq2, eq3, eq4, eq5;
  valueBar c1, c2, c3, c4;
  textBar audio_label, volume_label, eq0_label, eq1_label, eq2_label, eq3_label, eq4_label, eq5_label;

  EQ() {
    audio_mode = 0;
    volumeFont = createFont("Impact", 10, true);  //"Verdana-Bold"
    eqFont     = createFont("Impact", 10, true);
    audioFont  = createFont("Verdana-Bold", 9, true);
    tFont      = createFont("Verdana-Bold", 10, true);
    
    audio_label = new textBar(80, 1, 160, 10, CENTER, TOP, audioFont);
    audio_label.setText("RAW LEVELS");
    audio_label.setColor(color(255));
    audio_label.setBgColor(color(65));
    audio_label.setCorners(0);
    audio_label.strokeOff();
    audio_label.bgOff();

    volume = new eqBar(150, 67, 16, 58, CENTER, BOTTOM, volumeFont);
    volume.VALUE.textColor(color(255,255));
    volume.VALUE.textOffset(11);
    volume.strokeOff();
    
    volume_label = new textBar(150, 2, 16, 58, CENTER, TOP, tFont);
    volume_label.setText("V O L U M E");
    volume_label.setColor(color(0,128));
    volume_label.bgOff();
    
    eq0 = new eqBar( 20, 63, 120, 8, LEFT, CENTER, eqFont);
    eq0.VALUE.textColor(color(255,255));
    eq0.VALUE.textOffset(19);
    eq0.strokeOff(); 
    
    eq0_label = new textBar(132, 63, 80, 10, RIGHT, CENTER, tFont);
    eq0_label.setText("63 Hz");
    eq0_label.setColor(color(0,128));
    eq0_label.bgOff();
    
    eq1 = new eqBar( 20, 53, 120, 8, LEFT, CENTER, eqFont);
    eq1.VALUE.textColor(color(255,255));
    eq1.VALUE.textOffset(19);
    eq1.strokeOff(); 
    
    eq1_label = new textBar(132, 53, 80, 10, RIGHT, CENTER, tFont);
    eq1_label.setText("160 Hz");
    eq1_label.setColor(color(0,128));
    eq1_label.bgOff();
    
    eq2 = new eqBar( 20, 43, 120, 8, LEFT, CENTER, eqFont);
    eq2.VALUE.textColor(color(255,255));
    eq2.VALUE.textOffset(19);
    eq2.strokeOff(); 
    
    eq2_label = new textBar(132, 43, 80, 10, RIGHT, CENTER, tFont);
    eq2_label.setText("400 Hz");
    eq2_label.setColor(color(0,128));
    eq2_label.bgOff();
    
    eq3 = new eqBar( 20, 33, 120, 8, LEFT, CENTER, eqFont);
    eq3.VALUE.textColor(color(255,255));
    eq3.VALUE.textOffset(19);
    eq3.strokeOff(); 
    
    eq3_label = new textBar(132, 33, 80, 10, RIGHT, CENTER, tFont);
    eq3_label.setText("1 kHz");
    eq3_label.setColor(color(0,128));
    eq3_label.bgOff();
    
    eq4 = new eqBar( 20, 23, 120, 8, LEFT, CENTER, eqFont);
    eq4.VALUE.textColor(color(255,255));
    eq4.VALUE.textOffset(19);
    eq4.strokeOff(); 
    
    eq4_label = new textBar(132, 23, 80, 10, RIGHT, CENTER, tFont);
    eq4_label.setText("2.5 kHz");
    eq4_label.setColor(color(0,128));
    eq4_label.bgOff();
    
    eq5 = new eqBar( 20, 13, 120, 8, LEFT, CENTER, eqFont);
    eq5.VALUE.textColor(color(255,255));
    eq5.VALUE.textOffset(19);
    eq5.strokeOff(); 
    
    eq5_label = new textBar(132, 13, 80, 10, RIGHT, CENTER, tFont);
    eq5_label.setText("6.25 kHz");
    eq5_label.setColor(color(0,128));
    eq5_label.bgOff();
    
    //eq1 = new eqBar(161, 225, 80, 190, CENTER, BOTTOM, eqFont);
    //eq2 = new eqBar(267, 225, 80, 190, CENTER, BOTTOM, eqFont);
    //eq3 = new eqBar(373, 225, 80, 190, CENTER, BOTTOM, eqFont);
    //eq4 = new eqBar(479, 225, 80, 190, CENTER, BOTTOM, eqFont);
    //eq5 = new eqBar(146, 66, 24, 55, CENTER, BOTTOM, eqFont);
    //c1 = new valueBar( 82, 275, 150, 40, CENTER, BOTTOM, colorFont);
    //c2 = new valueBar(240, 275, 150, 40, CENTER, BOTTOM, colorFont);
    //c3 = new valueBar(395, 275, 150, 40, CENTER, BOTTOM, colorFont);
    //c4 = new valueBar(550, 275, 150, 40, CENTER, BOTTOM, colorFont);

    
    
    //eq1.strokeOff(); 
    //eq2.strokeOff();
    //eq3.strokeOff(); 
    //eq4.strokeOff(); 
    //eq5.strokeOff();
    //c1.setColor(color(255, 0, 0));
    //c1.textColor(color(255));
    //c1.setCorners(0);
    //c1.setMAX(255);
    //c2.setColor(color(0, 255, 0));
    //c2.textColor(color(255));
    //c2.setCorners(0);
    //c2.setMAX(255);
    //c3.setColor(color(0, 0, 255));
    //c3.textColor(color(255));
    //c3.setCorners(0);
    //c3.setMAX(255);
    //c4.setColor(color(192, 192, 192));
    //c4.textColor(color(255));
    //c4.setCorners(0);
    //c4.setMAX(255);

    

    //c1.strokeOff(); 
    //c1.strokeBgOff(); 
   // c1.bgOn();
    //c2.strokeOff(); 
    //c2.strokeBgOff(); 
    //c2.bgOn();
    //c3.strokeOff(); 
    //c3.strokeBgOff(); 
    //c3.bgOn();
    //c4.strokeOff(); 
    //c4.strokeBgOff(); 
    //c4.bgOn();
  }

  void useRaw() {
    audio_mode = RAW;
    audio_label.setText("RAW LEVELS");
  }

  void useSmoothed() {
    audio_mode = SMOOTHED;
    audio_label.setText("SMOOTH LEVLES");
  }

  void useBalanced() {
    audio_mode = BALANCED;
    audio_label.setText("BALANCE LEVELS");
  }

  void show() {
    if (audio_mode == RAW) {
      //buffer.background(audio.RAW_COLOR);
      //c1.display(int(red(audio.RAW_COLOR)));
      //c2.display(int(green(audio.RAW_COLOR)));
      //c3.display(int(blue(audio.RAW_COLOR)));
      //c4.display(int(brightness(audio.RAW_COLOR)));
    } 
    else if (audio_mode == SMOOTHED) {
      //buffer.background(audio.SMOOTHED_COLOR);
      //c1.display(int(red(audio.SMOOTHED_COLOR)));
      //c2.display(int(green(audio.SMOOTHED_COLOR)));
      //c3.display(int(blue(audio.SMOOTHED_COLOR)));
      //c4.display(int(brightness(audio.SMOOTHED_COLOR)));
    } 
    else {
      //buffer.background(audio.BALANCED_COLOR);
      //c1.display(int(red(audio.BALANCED_COLOR)));
      //c2.display(int(green(audio.BALANCED_COLOR)));
      //c3.display(int(blue(audio.BALANCED_COLOR)));
      //c4.display(int(brightness(audio.BALANCED_COLOR)));
    }
    buffer.background(0);
    volume.display(audio.VOLUME);
    volume_label.display();
    eq0.display(audio.EQ_DATA[audio_mode][0]);
    eq0_label.display();
    eq1.display(audio.EQ_DATA[audio_mode][1]);
    eq1_label.display();
    eq2.display(audio.EQ_DATA[audio_mode][2]);
    eq2_label.display();
    eq3.display(audio.EQ_DATA[audio_mode][3]);
    eq3_label.display();
    eq4.display(audio.EQ_DATA[audio_mode][4]);
    eq4_label.display();
    eq5.display(audio.EQ_DATA[audio_mode][5]);
    eq5_label.display();
    audio_label.display();
  }

  void display(int _mode) {
    if (_mode != audio_mode) {
      if (_mode == 0) useRaw();
      if (_mode == 1) useSmoothed();
      if (_mode == 2) useBalanced();
    }
    show();
  }

  void display() {
    show();
  }
}


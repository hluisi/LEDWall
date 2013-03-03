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

  PFont volumeFont, eqFont, colorFont, tFont;

  eqBar volume, eq0, eq1, eq2, eq3, eq4, eq5;
  valueBar c1, c2, c3, c4;
  textBar eq_audio_type_label;

  EQ() {
    audio_mode = 0;
    volumeFont = createFont("Verdana-Bold", 32, true);
    eqFont     = createFont("Impact", 34, true);
    colorFont  = createFont("Impact", 40, true);
    tFont      = createFont("Impact", 28, true);

    volume = new eqBar(320, 300, 620, 30, CENTER, CENTER, volumeFont);
    eq0 = new eqBar( 55, 225, 80, 190, CENTER, BOTTOM, eqFont);
    eq1 = new eqBar(161, 225, 80, 190, CENTER, BOTTOM, eqFont);
    eq2 = new eqBar(267, 225, 80, 190, CENTER, BOTTOM, eqFont);
    eq3 = new eqBar(373, 225, 80, 190, CENTER, BOTTOM, eqFont);
    eq4 = new eqBar(479, 225, 80, 190, CENTER, BOTTOM, eqFont);
    eq5 = new eqBar(585, 225, 80, 190, CENTER, BOTTOM, eqFont);
    c1 = new valueBar( 82, 275, 150, 40, CENTER, BOTTOM, colorFont);
    c2 = new valueBar(240, 275, 150, 40, CENTER, BOTTOM, colorFont);
    c3 = new valueBar(395, 275, 150, 40, CENTER, BOTTOM, colorFont);
    c4 = new valueBar(550, 275, 150, 40, CENTER, BOTTOM, colorFont);

    volume.strokeOff();
    eq0.strokeOff(); 
    eq1.strokeOff(); 
    eq2.strokeOff();
    eq3.strokeOff(); 
    eq4.strokeOff(); 
    eq5.strokeOff();
    c1.setColor(color(255, 0, 0));
    c1.textColor(color(255));
    c1.setCorners(0);
    c1.setMAX(255);
    c2.setColor(color(0, 255, 0));
    c2.textColor(color(255));
    c2.setCorners(0);
    c2.setMAX(255);
    c3.setColor(color(0, 0, 255));
    c3.textColor(color(255));
    c3.setCorners(0);
    c3.setMAX(255);
    c4.setColor(color(192, 192, 192));
    c4.textColor(color(255));
    c4.setCorners(0);
    c4.setMAX(255);

    eq_audio_type_label = new textBar(320, 17, 630, 40, CENTER, CENTER, tFont);
    eq_audio_type_label.setText("RAW AUDIO LEVELS");
    eq_audio_type_label.setColor(color(255));
    eq_audio_type_label.bgOff();

    c1.strokeOff(); 
    c1.strokeBgOff(); 
    c1.bgOn();
    c2.strokeOff(); 
    c2.strokeBgOff(); 
    c2.bgOn();
    c3.strokeOff(); 
    c3.strokeBgOff(); 
    c3.bgOn();
    c4.strokeOff(); 
    c4.strokeBgOff(); 
    c4.bgOn();
  }

  void useRaw() {
    audio_mode = RAW;
    eq_audio_type_label.setText("RAW AUDIO LEVELS");
  }

  void useSmoothed() {
    audio_mode = SMOOTHED;
    eq_audio_type_label.setText("SMOOTHED AUDIO LEVELS");
  }

  void useBalanced() {
    audio_mode = BALANCED;
    eq_audio_type_label.setText("BALANCED AUDIO LEVELS");
  }

  void show() {
    if (audio_mode == RAW) {
      buffer.background(audio.RAW_COLOR);
      c1.display(int(red(audio.RAW_COLOR)));
      c2.display(int(green(audio.RAW_COLOR)));
      c3.display(int(blue(audio.RAW_COLOR)));
      c4.display(int(brightness(audio.RAW_COLOR)));
    } 
    else if (audio_mode == SMOOTHED) {
      buffer.background(audio.SMOOTHED_COLOR);
      c1.display(int(red(audio.SMOOTHED_COLOR)));
      c2.display(int(green(audio.SMOOTHED_COLOR)));
      c3.display(int(blue(audio.SMOOTHED_COLOR)));
      c4.display(int(brightness(audio.SMOOTHED_COLOR)));
    } 
    else {
      buffer.background(audio.BALANCED_COLOR);
      c1.display(int(red(audio.BALANCED_COLOR)));
      c2.display(int(green(audio.BALANCED_COLOR)));
      c3.display(int(blue(audio.BALANCED_COLOR)));
      c4.display(int(brightness(audio.BALANCED_COLOR)));
    }
    volume.display(audio.VOLUME);
    eq0.display(audio.EQ_DATA[audio_mode][0]);
    eq1.display(audio.EQ_DATA[audio_mode][1]);
    eq2.display(audio.EQ_DATA[audio_mode][2]);
    eq3.display(audio.EQ_DATA[audio_mode][3]);
    eq4.display(audio.EQ_DATA[audio_mode][4]);
    eq5.display(audio.EQ_DATA[audio_mode][5]);
    eq_audio_type_label.display();
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


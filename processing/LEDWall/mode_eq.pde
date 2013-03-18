EQ eq;

void setupEQ() {
  eq = new EQ();
  println("SETUP EQ ...");
}

void doEQ() {
  buffer.beginDraw();
  buffer.background(0);
  eq.display();
  buffer.endDraw();
}


class EQ {

  PFont volumeFont, eqFont, audioFont, tFont;

  eqBar volume; //, eq0, eq1, eq2, eq3, eq4, eq5, eq6, eq7, eq8;
  eqBar[] spec = new eqBar [9];

  EQ() {

    volumeFont = createFont("Impact", 10, true);  //"Verdana-Bold"
    eqFont     = createFont("Verdana-Bold", 10, true);
    tFont      = createFont("Verdana-Bold", 11, true);

    volume = new eqBar( buffer.width / 2, buffer.height - 6, buffer.width - 16, 10, CENTER, CENTER, tFont);
    volume.VALUE.textColor(color(0, 255));
    volume.VALUE.textOffset(19);
    volume.VALUE.setMax(100);
    //volume.setLabel("VOLUME");
    volume.strokeOff();

    int x = 16;

    for (int i = 0; i < 9; i++) {
      spec[i] = new eqBar( x, 60, 14, 58, CENTER, BOTTOM, eqFont);
      spec[i].VALUE.textColor(color(255, 255));
      spec[i].VALUE.textOffset(10);
      spec[i].VALUE.setMax(100);
      spec[i].strokeOff(); 
      spec[i].setLabelFont(tFont);
      spec[i].setLabelColor(color(0, 128));
      spec[i].setLabel(round(fft.getAverageCenterFrequency(i)) + " Hz");
      x += 16;
    }
  }

  void show() {

    //buffer.background(0);
    volume.display(aaudio.VOLUME);

    for (int i = 0; i < 9; i++) {
      spec[i].display(aaudio.AVERAGES[i]);
    }
  }

  void display() {
    show();
  }
}


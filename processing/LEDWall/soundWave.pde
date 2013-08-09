 

Wave wave;

Textfield wTotalBuff;
Textfield wZ;
Textfield wRez;

void setupWave() {
  wave = new Wave();
  
  wTotalBuff = 
    createTextfield("wSetTotal",                     // function name
                    "Total",                              // caption name
                    TAB_START + 20,                       // x postion
                    DEBUG_WINDOW_START + 40,              // y postion
                    100,                                   // width
                    100,                                   // height
                    nf(wave.total, 3),                   // starting value
                    lFont,                                // font
                    ControlP5.INTEGER,                    // input filter (BITFONT, DEFAULT, FLOAT, or INTEGER)
                    DISPLAY_STR[DISPLAY_MODE_WAVE]);    // tab
  
  wZ = 
    createTextfield("wSetZ",                     // function name
                    "Z",                              // caption name
                    TAB_START + 140,                       // x postion
                    DEBUG_WINDOW_START + 40,              // y postion
                    100,                                   // width
                    100,                                   // height
                    nf(wave.z, 3),                   // starting value
                    lFont,                                // font
                    ControlP5.INTEGER,                    // input filter (BITFONT, DEFAULT, FLOAT, or INTEGER)
                    DISPLAY_STR[DISPLAY_MODE_WAVE]);    // tab
  
  wRez = 
    createTextfield("wSetRez",                     // function name
                    "Rez",                              // caption name
                    TAB_START + 260,                       // x postion
                    DEBUG_WINDOW_START + 40,              // y postion
                    100,                                   // width
                    100,                                   // height
                    nf(wave.rez, 1),                   // starting value
                    lFont,                                // font
                    ControlP5.INTEGER,                    // input filter (BITFONT, DEFAULT, FLOAT, or INTEGER)
                    DISPLAY_STR[DISPLAY_MODE_WAVE]);    // tab
  
}

void wSetTotal(String valueString) {
  wave.setTotal( int(valueString) );
  wTotalBuff.setText( nf(wave.total,3) );
}

void wSetZ(String valueString) {
  int v = int(valueString);
  v *= -1;
  wave.z = v;
  wZ.setText(nf(v,3));
}

void wSetRez(String valueString) {
  wave.rez = int(valueString);
  //wZ.setText(nf(v,3));
}

class Wave {
  int total;
  int z = -154;
  int rez = 2;
  boolean useStroke = false;

  Wave() {
    total = audio.in.bufferSize() - 1;
  }

  void setTotal(int v) {
    if (v > audio.in.bufferSize() - 1) v = audio.in.bufferSize() - 1;
    if (v < 1) v = 1;
    total = v;
  }

  void draw() {
    //buffer.blendMode(ADD);
    buffer.blendMode(REPLACE);
    doBackground();
    int y = (z * -1); 

    if (useStroke) {
      buffer.stroke(0);
      buffer.strokeWeight(0.5);
    } else {
      buffer.noStroke();
    }
    
    buffer.fill(colors.users[11]);
    buffer.pushMatrix();
    buffer.translate(80, 40, z);

    buffer.beginShape();

    for (int i = 0; i < total; i += rez) {
      int x = 0 - (total / 2) + i;
      buffer.vertex(x, audio.in.mix.get(i)*y);
    }

    for ( int i = total; i >= 0; i -= rez) {
      int x = 0 - (total / 2) + i;
      buffer.vertex(x, (audio.in.mix.get(i)*y) * -1);
    }
    buffer.endShape(CLOSE);

    buffer.popMatrix();
    buffer.blendMode(BLEND);
  }
}







void displayImage(PImage _image) {
  //buffer.blendMode(BLEND);
  if (_image.width != buffer.width && _image.height != buffer.height) {
    buffer.copy(_image, 0, 0, _image.width, _image.height, 0, 0, buffer.width, buffer.height);
  } 
  else {
    buffer.image(_image, 0, 0);
  }
}

void doTest() {
  displayImage(smpte);
}


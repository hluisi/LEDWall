Spectrum spec;

Textfield specZ;

void setupSpectrum() {
   spec = new Spectrum();
  
  // controll name, text name, x, y, width, height, text size, value, move 2 tab
  createToggle("distriktOn", "distrikt", TAB_START + 20, DEBUG_WINDOW_START + 50, 50, 50, mFont, ControlP5.DEFAULT, spec.dOn, DISPLAY_STR[DISPLAY_MODE_SPEC]);
  
  createTextfield("setCitySpecMax", "LINES", TAB_MAX_WIDTH + 10, DEBUG_WINDOW_START+55, 50, 20, nf(spec.SPEC_MAX,1), sFont, ControlP5.INTEGER, DISPLAY_STR[DISPLAY_MODE_SPEC]);
  cp5.getController("setCitySpecMax").captionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE);
  specZ = createTextfield("setSpecZ", "Z", TAB_MAX_WIDTH + 10, DEBUG_WINDOW_START+80, 50, 20, nf(spec.Z,1), sFont, ControlP5.INTEGER, DISPLAY_STR[DISPLAY_MODE_SPEC]);
  createTextfield("setCityLineMax", "HEIGHT", TAB_MAX_WIDTH + 70, DEBUG_WINDOW_START+65, 50, 30, nf(spec.LINE_MAX,1), sFont, ControlP5.INTEGER, DISPLAY_STR[DISPLAY_MODE_SPEC]);
  cp5.getController("setCityLineMax").captionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(5);
}

void distriktOn(boolean b) {
  spec.dOn = b;
}

void setCitySpecMax(String valueString) {
  int specMax = int(valueString);
  spec.SPEC_MAX = specMax;
}

void setSpecZ(String valueString) {
  int v = int(valueString);
  v *= -1;
  spec.Z = v;
  specZ.setText(nf(v,3));
}

void setCityLineMax(String valueString) {
  int lineMax = int(valueString);
  spec.LINE_MAX = lineMax;
}


class Spectrum {

  PVector kinectUser;
  int LINE_MAX = 160;
  int SPEC_MAX = 40;
  int Z = -100;
  int distrikt;
  int W = 5;
  boolean dOn = false;

  Spectrum() {
    kinectUser     = new PVector();
  }
  
  void setDistrikt(int v) {
    distrikt = v;
  }

  void draw() {
    //buffer.blendMode(ADD);
    buffer.blendMode(REPLACE);
    buffer.rectMode(CENTER);
    doBackground();
    
    kinectUser = getSingleUser();
    buffer.noStroke();
    //buffer.stroke(0);
    //buffer.strokeWeight(0.5);

    for (int i = 1; i <= SPEC_MAX + 5 ; i++) {
      
      color c = getBright(color(audio.averageSpecs[1].grey, audio.averageSpecs[3].grey, audio.fullSpecs[i].grey));
      buffer.fill(c);

      int x = i * W;

      float H = map(audio.fullSpecs[i].value, 0, 100, 0.25, LINE_MAX) * 2;
      
      buffer.pushMatrix();
      buffer.translate(80 + x, 40, Z);
      buffer.rect(0,0,W,H);
      buffer.popMatrix();
      buffer.pushMatrix();
      buffer.translate(80 - x, 40, Z);
      buffer.rect(0,0,W,H);
      buffer.popMatrix();
    }
    
    if (dOn) {
      //int c = round(map(audio.mids.value, 0, 100, 127, 255));
      buffer.fill(255);
      buffer.noStroke();
      buffer.translate(80, 40, -30);
      svgs[distrikt].draw(buffer);
    } 
    
    buffer.blendMode(BLEND);
  }
}

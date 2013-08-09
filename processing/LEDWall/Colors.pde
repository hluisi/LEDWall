Colors colors;

void setupColors() {
  colors = new Colors();
}

// class uses audio.averageSpecs to map colors to different arrays
class Colors {
  color[] users;
  color[] reds;
  color[] greens;
  color[] blues;
  color background, grey;

  Colors() {
    reds   = new color [4];
    greens = new color [4];
    blues  = new color [4];
    users  = new color [12];
  }
  
  color colorMap(int r, int g, int b) {
    if (audioOn) {
      int RED   = audio.averageSpecs[r].grey;
      int GREEN = audio.averageSpecs[g].grey;
      int BLUE  = audio.averageSpecs[b].grey; 
      return color(RED, GREEN, BLUE);
    } else {
      b = round( noise(zoff, yoff, xoff) * 255 );
      g = round( noise(zoff, yoff) * 255 );
      r = round( noise(zoff) * 255 );
      return color(r,g,b);
    }
  }

  color colorMap(int r1, int r2, int g1, int g2, int b1, int b2) {
    int RED   = audio.averageSpecs[r1].grey + audio.averageSpecs[r1].grey / 2;
    int GREEN = audio.averageSpecs[g1].grey + audio.averageSpecs[g2].grey / 2;
    int BLUE  = audio.averageSpecs[b1].grey + audio.averageSpecs[b2].grey / 2; 
    return color(RED, GREEN, BLUE);
  }

  color colorMapBG(int r1, int r2, int g1, int g2, int b1, int b2) {
    int RED   = audio.averageSpecs[r1].grey + audio.averageSpecs[r1].grey / 6;
    int GREEN = audio.averageSpecs[g1].grey + audio.averageSpecs[g2].grey / 6;
    int BLUE  = audio.averageSpecs[b1].grey + audio.averageSpecs[b2].grey / 6; 
    return color(RED, GREEN, BLUE);
  }

  void updateBackground() {
    background = colorMapBG(0, 1, 2, 3, 4, 5);
  }

  void updateGrey() {
    int temp = audio.volume.value + 16;
    if (temp > MAX_BRIGHTNESS) temp = MAX_BRIGHTNESS;
    grey = color(temp);
  }

  void updateReds() {
    reds[0] = colorMap(0, 1, 2, 4, 3, 5);
    reds[1] = colorMap(0, 1, 3, 5, 2, 4);
    reds[2] = colorMap(0, 1, 4, 5, 2, 3);
    reds[3] = colorMap(0, 2, 1, 3, 4, 5);
  }

  void updateGreens() {
    greens[0] = colorMap(2, 3, 0, 1, 4, 5);
    greens[1] = colorMap(4, 5, 0, 1, 2, 3);
    greens[2] = colorMap(2, 4, 0, 1, 3, 5);
    greens[3] = colorMap(3, 5, 0, 1, 2, 4);
  }

  void updateBlues() {
    blues[0] = colorMap(2, 3, 4, 5, 0, 1);
    blues[1] = colorMap(4, 5, 2, 3, 0, 1);
    blues[2] = colorMap(2, 4, 3, 5, 0, 1);
    blues[3] = colorMap(3, 5, 2, 4, 0, 1);
  }

  void updateUsers() {
    users[0]  = getBright(reds[0]);
    users[1]  = getBright(greens[0]);
    users[2]  = getBright(blues[0]);
    users[3]  = getBright(reds[1]);
    users[4]  = getBright(greens[1]);
    users[5]  = getBright(blues[1]);
    users[6]  = getBright(reds[2]);
    users[7]  = getBright(greens[2]);
    users[8]  = getBright(blues[2]);
    users[9]  = getBright(reds[3]);
    users[10] = getBright(greens[3]);
    users[11] = getBright(blues[3]);
  }

  void update() {
    updateBackground();
    updateGrey();
    updateReds();
    updateGreens();
    updateBlues();
    updateUsers();
  }
  
  //color getBright(color c) {
  //  pushStyle();
  //  colorMode(HSB, 360, 255, 255);
  //  color tc = color(hue(c), 255, 255);
  //  popStyle();
  //  return tc;
  //}
    
}

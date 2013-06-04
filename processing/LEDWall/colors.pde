class Colors {
  color[] users;
  color[] reds;
  color[] greens;
  color[] blues;
  color background, grey;

  AudioSpectrum[] audioSpecs;

  Colors() {
    reds   = new color [4];
    greens = new color [4];
    blues  = new color [4];
    users  = new color [12];
  }

  color colorMap(int r1, int r2, int g1, int g2, int b1, int b2) {
    int RED   = audioSpecs[r1].grey + audioSpecs[r1].grey / 2;
    int GREEN = audioSpecs[g1].grey + audioSpecs[g2].grey / 2;
    int BLUE  = audioSpecs[b1].grey + audioSpecs[b2].grey / 2; 
    return color(RED, GREEN, BLUE);
  }
  
  color colorMapBG(int r1, int r2, int g1, int g2, int b1, int b2) {
    int RED   = audioSpecs[r1].grey + audioSpecs[r1].grey / 6;
    int GREEN = audioSpecs[g1].grey + audioSpecs[g2].grey / 6;
    int BLUE  = audioSpecs[b1].grey + audioSpecs[b2].grey / 6; 
    return color(RED, GREEN, BLUE);
  }

  void updateBackground() {
    background = colorMapBG(0, 1, 2, 3, 4, 5);
  }

  void updateGrey() {
    int temp = audio.volume.value + 16;
    if (temp > max_brightness) temp = max_brightness;
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
    users[0]  = reds[0];
    users[1]  = greens[0];
    users[2]  = blues[0];
    users[3]  = reds[1];
    users[4]  = greens[1];
    users[5]  = blues[1];
    users[6]  = reds[2];
    users[7]  = greens[2];
    users[8]  = blues[2];
    users[9]  = reds[3];
    users[10] = greens[3];
    users[11] = blues[3];
  }

  void update(AudioSpectrum[] specs) {
    audioSpecs = specs;
    updateBackground();
    updateGrey();
    updateReds();
    updateGreens();
    updateBlues();
    updateUsers();
  }
}


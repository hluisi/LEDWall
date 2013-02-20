class Sun {
  //PShape sun_shape;
  
  PVector location;
  PGraphics pg;
  int last_cycle;
  int cycle_time = 100;
  int last_set = millis();
  color[] colors = new color [8];
  color[] default_colors = {
    color(255, 0, 0), color(255, 128, 0), color(255, 255, 0), color(128, 255, 0), 
    color(0, 255, 0), color(0, 255, 128), color(0, 128, 255), color(0, 0, 255)
  };


  Sun(PGraphics b, float x, float y) {
    pg = b;
    location = new PVector(x, y);
    colors = default_colors;
    last_cycle = millis();
  }

  private void cycleColors() {
    color saved = colors[0];
    for (int i = 0; i < (colors.length - 1); i++) {
      colors[i] = colors[i + 1];
    }
    colors[colors.length - 1] = saved;
  }

  void setColors(color[] cs) {
    if (cs.length != 8) {
      println("Trying to set the Sun's color array with " + cs.length + " elements. Needs to be 8!");
      colors = default_colors;
    } 
    else {
      colors = cs;
    }
  }

  void setLocation(float x, float y) {
    location.x = round(x);
    location.y = round(y);
  }

  private void check() {
    int cTime = millis();
    if (cTime - last_cycle > cycle_time) {
      cycleColors();
      last_cycle = cTime;
    }
  }


  void display() {
    check();

    pg.noStroke();


    for (int i = 0; i < 8; i++) {

      pg.fill(colors[i]);
      pg.quad(location.x, location.y, 0, i * 40, 0, (i + 1) * 40, location.x, location.y);
      pg.quad(location.x, location.y, i * 80, 0, (i + 1) * 80, 0, location.x, location.y);

      int j = 7 - i;
      pg.fill(colors[j]);
      pg.quad(location.x, location.y, pg.width, i * 40, pg.width, (i + 1) * 40, location.x, location.y);
      pg.quad(location.x, location.y, i * 80, pg.height, (i + 1) * 80, pg.height, location.x, location.y);
    }
  }
}


IChing rune1, rune2;

float rtest = 0;

void setupIChing() {
  rune1 = new IChing(40, 18, 60, true);
  rune2 = new IChing(120, 18, 60, true);
}

void doIChing() {
  buffer.background(0);
  buffer.blendMode(BLEND);

  if ( audio.isOnBeat() ) {
    rtest = random(0, 1);
    if (rtest < 0.75) {
      rtest = random(0, 1);
      if (rtest < 0.3) {
        rune1.update();
      } 
      if (rtest > 0.6) {
        rune2.update();
      }
    }
  }

  rune1.display();
  rune2.display();
}

class IChing {
  boolean[] hexagram = new boolean [6];
  String meaning;

  float radius, half, third;
  int cindex = 0;
  boolean showText;

  PFont font;

  PVector location = new PVector();


  IChing(float x, float y, float r, boolean show) {
    set(2);

    updateLocation(x, y);
    setHexRadius(r);
    if (show) textOn();
    else textOff();
    font = createFont("Verdana-Bold", half / 2.25);
  }

  void updateLocation(float newX, float newY) {
    location.x = newX;
    location.y = newY;
  }

  void setHexRadius(float r) {
    radius = r;
    half = radius / 2;
    third = half / 3;
  }

  void textOn() {
    showText = true;
  }

  void textOff() {
    showText = false;
  }

  void setHex(boolean one, boolean two, boolean three, boolean four, boolean five, boolean six) {
    hexagram[0] = one;
    hexagram[1] = two;
    hexagram[2] = three;
    hexagram[3] = four;
    hexagram[4] = five;
    hexagram[5] = six;
  }

  // the hex1 hex2 hex3 for hex4

  void set(int value) {
    if (value < 1 || value > 64) value = 1;

    switch (value) {
    case 1: 
      setHex(true, true, true, true, true, true);
      meaning = "creative";
      break;
    case 2: 
      setHex(false, false, false, false, false, false);
      meaning = "receptive";
      break;
    case 3: 
      setHex(true, false, false, false, true, false);
      meaning = "sprouting";
      break;
    case 4:
      setHex(false, true, false, false, false, true);
      meaning = "folly";
      break;
    case 5:
      setHex(true, true, true, false, true, false);
      meaning = "waiting";
      break;
    case 6:
      setHex(false, true, false, true, true, true);
      meaning = "conflict";
      break;
    case 7:
      setHex(false, true, false, false, false, false);
      meaning = "leading";
      break;
    case 8:
      setHex(false, false, false, false, true, false);
      meaning = "union";
      break;
    case 9:
      setHex(true, true, true, false, true, true);
      meaning = "accumulating";
      break;
    case 10:
      setHex(true, true, false, true, true, true);
      meaning = "alertness";
      break;
    case 11:
      setHex(true, true, true, false, false, false);
      meaning = "pervading";
      break;
    case 12:
      setHex(false, false, false, true, true, true);
      meaning = "obstruction";
      break;
    case 13:
      setHex(true, false, true, true, true, true);
      meaning = "partnership";
      break;
    case 14:
      setHex(true, true, true, true, false, true);
      meaning = "independence";
      break;
    case 15:
      setHex(false, false, true, false, false, false);
      meaning = "modesty";
      break;
    case 16:
      setHex(false, false, false, true, false, false);
      meaning = "inducement";
      break;
    case 17:
      setHex(true, false, false, true, true, false);
      meaning = "following";
      break;
    case 18:
      setHex(false, true, true, false, false, true);
      meaning = "repairing";
      break;
    case 19:
      setHex(true, true, false, false, false, false);
      meaning = "approaching";
      break;
    case 20:
      setHex(false, false, false, false, true, true);
      meaning = "contemplation";
      break;
    case 21:
      setHex(true, false, false, true, false, true);
      meaning = "deciding";
      break;
    case 22:
      setHex(true, false, true, false, false, true);
      meaning = "embellishing";
      break;
    case 23:
      setHex(false, false, false, false, false, true);
      meaning = "flaying";
      break;
    case 24:
      setHex(true, false, false, false, false, false);
      meaning = "returning";
      break;
    case 25:
      setHex(true, false, false, true, true, true);
      meaning = "carefulness";
      break;
    case 26:
      setHex(true, true, true, false, false, true);
      meaning = "accumulation";
      break;
    case 27:
      setHex(true, false, false, false, false, true);
      meaning = "enlighten";
      break;
    case 28:
      setHex(false, true, true, true, true, false);
      meaning = "surpassing";
      break;
    case 29:
      setHex(false, true, false, false, true, false);
      meaning = "darkness";
      break;
    case 30:
      setHex(true, false, true, true, false, true);
      meaning = "attachment";
      break;
    case 31:
      setHex(false, false, true, true, true, false);
      meaning = "attraction";
      break;
    case 32:
      setHex(false, true, true, true, false, false);
      meaning = "perseverance";
      break;
    case 33:
      setHex(false, false, true, true, true, true);
      meaning = "withdrawing";
      break;
    case 34:
      setHex(true, true, true, true, false, false);
      meaning = "boldness";
      break;
    case 35:
      setHex(false, false, false, true, false, true);
      meaning = "expansion";
      break;
    case 36:
      setHex(true, false, true, false, false, false);
      meaning = "eclipse";
      break;
    case 37:
      setHex(true, false, true, false, true, true);
      meaning = "family";
      break;
    case 38:
      setHex(true, true, false, true, false, true);
      meaning = "antagonism";
      break;
    case 39:
      setHex(false, false, true, false, true, false);
      meaning = "hardship";
      break;
    case 40:
      setHex(false, true, false, true, false, false);
      meaning = "deliverance";
      break;
    case 41:
      setHex(true, true, false, false, false, true);
      meaning = "decrese";
      break;
    case 42:
      setHex(true, false, false, false, true, true);
      meaning = "increase";
      break;
    case 43:
      setHex(true, true, true, true, true, false);
      meaning = "separation";
      break;
    case 44:
      setHex(false, true, true, true, true, true);
      meaning = "encountering";
      break;
    case 45:
      setHex(false, false, false, true, true, false);
      meaning = "companionship";
      break;
    case 46:
      setHex(false, true, true, false, false, false);
      meaning = "ascending";
      break;
    case 47:
      setHex(false, true, false, true, true, false);
      meaning = "exhaustion";
      break;
    case 48:
      setHex(false, true, true, false, true, false);
      meaning = "renewal";
      break;
    case 49:
      setHex(true, false, true, true, true, false);
      meaning = "removal";
      break;
    case 50:
      setHex(false, true, true, true, false, true);
      meaning = "establish";
      break;
    case 51:
      setHex(true, false, false, true, false, false);
      meaning = "mobilizing";
      break;
    case 52:
      setHex(false, false, true, false, false, true);
      meaning = "immobility";
      break;
    case 53:
      setHex(false, false, true, false, true, true);
      meaning = "infiltration";
      break;
    case 54:
      setHex(true, true, false, true, false, false);
      meaning = "marrying";
      break;
    case 55:
      setHex(true, false, true, true, false, false);
      meaning = "achievement";
      break;
    case 56:
      setHex(false, false, true, true, false, true);
      meaning = "travel";
      break;
    case 57:
      setHex(false, true, true, false, true, true);
      meaning = "subtle";
      break;
    case 58:
      setHex(true, true, false, true, true, false);
      meaning = "overt";
      break;
    case 59:
      setHex(false, true, false, false, true, true);
      meaning = "dispersal";
      break;
    case 60:
      setHex(true, true, false, false, true, false);
      meaning = "discipline";
      break;
    case 61:
      setHex(true, true, false, false, true, true);
      meaning = "focused";
      break;
    case 62:
      setHex(false, false, true, true, false, false);
      meaning = "exeeding";
      break;
    case 63:
      setHex(true, false, true, false, true, false);
      meaning = "completion";
      break;
    case 64:
      setHex(false, true, false, true, false, true);
      meaning = "incompletion";
      break;
    }
  }

  void drawHex(float x, float y, boolean state) {
    buffer.rectMode(CENTER);
    if (state) {
      buffer.rect(x, y, radius, third / 2);
    } 
    else {
      buffer.rect(x - (half / 2), y, half - third, third / 2);
      buffer.rect(x + (half / 2), y, half - third, third / 2);
    }
  }

  void draw(float x, float y) {
    buffer.fill( kinect.getUserColor(cindex) );


    if (showText) {
      buffer.textFont(font, half / 2.25);
      buffer.textAlign(CENTER, CENTER);
      y += half / 2;
    }

    drawHex(x, y - ((third / 2) + (third * 2)), hexagram[5]);
    drawHex(x, y - ((third / 2) + third), hexagram[4]);
    drawHex(x, y - (third / 2), hexagram[3]);
    drawHex(x, y + (third / 2), hexagram[2]);
    drawHex(x, y + ((third / 2) + third), hexagram[1]);
    drawHex(x, y + ((third / 2) + (third * 2)), hexagram[0]);

    if (showText) {
      buffer.text( meaning, x, y + ((third / 2) + (third * 3)) );
    }
  }

  void update() {
    set( round(random(64 - 1)) );
    cindex = round( random(0, 11) );
  }

  void display() {
    draw(location.x, location.y);
  }
}


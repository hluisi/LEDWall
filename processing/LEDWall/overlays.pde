Overlay overlay;
Textfield inText;
Slider logoSlider;
Toggle textToggle;
Toggle logoToggle;
Toggle colorToggle;
MyColorPicker cp;

void setupOverlays() {
  overlay = new Overlay(CENTER, CENTER, mFont);
  
  // sets the min speed for the movies when mapped to BPM
  inText = createTextfield("doTextOverlay",                     // function name
                  "text input",                       // caption name
                  TAB_START + 20,               // x postion
                  WINDOW_YSIZE - 70,           // y postion
                  TAB_MAX_WIDTH - 100,                                // width
                  40,                                // height
                  overlay.txt,         // starting value
                  lFont,                             // font
                  ControlP5.DEFAULT,                   // input filter (BITFONT, DEFAULT, FLOAT, or INTEGER)
                  "Overlays");  // tab
  //inText.captionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE);
  cp5.getTooltip().register("doTextOverlay","Input overlay text here.");
  
  // toggle for controlling movie speed via the BPM
  textToggle = createToggle("showTextOverlay",                      // function name
               "ON/OFF",                         // button name
               WINDOW_XSIZE - 100,                  // x postion
               WINDOW_YSIZE - 70,              // y postion
               80,                                   // width
               40,                                   // height
               lFont,                                // font
               ControlP5.DEFAULT,                    // toggle type
               overlay.textOn,                         // starting value
               "Overlays");     // tab
  cp5.getTooltip().register("allowMovieBPM","Turn ON/OFF overlay text.");
  
  logoSlider = 
    createSlider("doLogoSlider",                         // function name
                 0,                                       // min
                 logos.length - 1,                         // max
                 overlay.current_logo,                          // starting value
                 TAB_START + 200,                          // x postion
                 WINDOW_YSIZE - 140,                      // y postion
                 TAB_MAX_WIDTH - 280,                           // width
                 40,                                      // height
                 logos[overlay.current_logo].name,                                // caption text
                 40,                                      // handle size
                 lFont,                                   // font
                 Slider.FLEXIBLE,                         // slider type
                 "Overlays");       // tab
  
  // toggle for controlling movie speed via the BPM
  logoToggle = createToggle("showLogoOverlay",                      // function name
               "ON/OFF",                         // button name
               WINDOW_XSIZE - 100,                  // x postion
               WINDOW_YSIZE - 140,              // y postion
               80,                                   // width
               40,                                   // height
               lFont,                                // font
               ControlP5.DEFAULT,                    // toggle type
               overlay.logoOn,                         // starting value
               "Overlays");     // tab
  cp5.getTooltip().register("allowMovieBPM","Turn ON/OFF overlay text.");
  
  // toggle for controlling movie speed via the BPM
  colorToggle = createToggle("mapColorToggle",                      // function name
               "MAP",                         // button name
               TAB_START + 200,                  // x postion
               DEBUG_WINDOW_START + 40,              // y postion
               80,                                   // width
               80,                                   // height
               lFont,                                // font
               ControlP5.DEFAULT,                    // toggle type
               overlay.mapColor,                         // starting value
               "Overlays");     // tab
  cp5.getTooltip().register("mapColorToggle","Turn ON/OFF color mapping.");
  
  cp = new MyColorPicker(cp5, "picker", lFont);
  cp.setPosition(TAB_START + 20, DEBUG_WINDOW_START + 40)
    .setColorValue(color(255, 255, 255, 255))
    .moveTo("Overlays");
  cp.setItemSize(110,40);
  
}

void doTextOverlay(String valueString) {
  overlay.set(valueString);
}

void showTextOverlay(boolean b) {
  overlay.textOn = b;
  if (overlay.textOn && overlay.logoOn) logoToggle.setState(false);
}

void doLogoSlider(int v) {
  overlay.current_logo = v;
  String name = logos[overlay.current_logo].name;
  logoSlider.setLabel(name);
}

void showLogoOverlay(boolean b) {
  overlay.logoOn = b;
  if (overlay.logoOn && overlay.textOn) textToggle.setState(false);
}

void mapColorToggle(boolean b) {
  overlay.mapColor = b;
  //if (overlay.logoOn && overlay.textOn) textToggle.setState(false);
}

void picker(int col) {
  overlay.setColor(col);
}

class Overlay {

  String txt;                 // overlay text
  String[] words;             // words in the text
  ArrayList<String> lines;    // lines of text
  PFont f;                    // font
  int fontHeight;             // font height
  int align_x, align_y;       // text align x & y
  int x = 80;
  int y = 40;
  int cMin = 32;
  boolean textOn;
  boolean logoOn;
  boolean mapColor;
  int current_logo = 0;
  color c;

  Overlay(int x, int y, PFont _f) {
    align_x = x;
    align_y = y;
    f = _f;
    lines = new ArrayList<String>();
    textOn = false;
    logoOn = false;
    mapColor = false;
    txt = ".";
    set("testing 1 2 3 4");
    c = color(255);
  }
  
  void setColor(color c) {
    this.c = c;
  }

  private boolean eq(String tt) {
    if (txt.equals(tt)) {
      return true;
    } 
    else {
      return false;
    }
  }
  
  void align(int x, int y) {
    align_x = x;
    align_y = y;
  }
  
  void alignX(int x) {
    align_x = x;
  }
  
  void alignY(int y) {
    align_y = y;
  }
    
  private void setupText() {
    buffer.textFont(f);
    fontHeight = int(buffer.textAscent() + buffer.textDescent());
    
    words = txt.split(" ");                         // split the test into a string array of words
    String current_line = new String();             // a string for creating a text line
    lines.clear();                                  // clear the arraylist of text lines

    for (int i = 0; i < words.length; i++) {        // loop through the words
      String test = current_line + words[i] + " ";  // add the current line and new word to the test string

                                                    // is the text width of test line greater then the width of the buffer??
      if (buffer.textWidth(test) + 10 > buffer.width) {   
        lines.add(current_line.trim());             // if it is, add the current line to the Array list of lines
        current_line = words[i] + " ";              // now reset the current line by adding the new word to it
        if (i == (words.length - 1)) {
          lines.add(current_line);
        }
      }
      else {
        current_line = test;                        // we still have more room, so make the test line into the current line
        if (i == (words.length - 1)) {              // check to see if we are on the last word
          lines.add(current_line);                  // if we are, then we are done, so add the current line to the arraylist
        }
      }
    }

    println(words);
  }

  void set(String _txt) {
    // does the new text equal the old text?
    if (eq(_txt)) {
      return;  // if so no need to setup the text
    } 
    else {
      txt = _txt;  // setup the new text
      setupText();
    }
  }

  private void drawText() {
    buffer.textFont(f);  // set the font
    buffer.stroke(0);
    buffer.strokeWeight(1);
    
    int sx = 0; int sy = 0;

    if (align_x == LEFT) {
      sx = 4;
    } 
    else if (align_x == CENTER) {
      sx = buffer.width / 2;
    } 
    else if (align_x == RIGHT) {
      sx = buffer.width - 4;
    }

    int textHeight = fontHeight * lines.size();

    if (align_y == TOP) {
      sy = 4;
    } 
    else if (align_y == CENTER) {
      sy = (buffer.height / 2) - (textHeight / 2);
    } 
    else if (align_y == BOTTOM) {
      sy = (buffer.height - textHeight) + 4;
    }

    buffer.textAlign(align_x, TOP);

    for (int i = 0; i < lines.size(); i++) {
      String thisLine = (String) lines.get(i);
      int y = (fontHeight * i) + sy;
      buffer.text(thisLine, sx, y);
    }
  }
  
  void drawLogo() {
    buffer.noStroke();
    buffer.pushMatrix();
    buffer.translate(x, y);
    logos[current_logo].draw(buffer);
    buffer.popMatrix();
  }

  void draw() {
    if (mapColor) {
      color m =  mapAlphaByVol(c);
      buffer.fill(m);
    } else {
      buffer.fill(c);
    }
    if (textOn) drawText();
    if (logoOn) drawLogo();
  }
}



class TextOverlay {

  String txt;                 // overlay text
  String[] words;             // words in the text
  ArrayList<String> lines;    // lines of text
  PFont f;                    // font
  int fontHeight;             // font height
  int alignX, alignY;         // text align x & y
  color c;                    // color 
  boolean textSet = false;    // is the text set?
  int sx = 0, sy = 0;
  boolean isOn = false;

  TextOverlay(int ax, int ay, PFont _f) {
    alignX = ax;
    alignY = ay;
    f = _f;
    txt = "1234567890";
    lines = new ArrayList<String>();
    c = color(255);
  }

  private boolean eq(String tt) {
    if (txt.equals(tt)) {
      return true;
    } 
    else {
      return false;
    }
  }
  
  private void setupText() {
    buffer.RAW.textFont(f);
    fontHeight = int(buffer.RAW.textAscent() + buffer.RAW.textDescent());
    
    words = txt.split(" ");               // split the test into a string array of words
    String current_line = new String();             // a string for creating a text line
    lines.clear();                        // clear the arraylist of text lines

    for (int i = 0; i < words.length; i++) {           // loop through the words
      String test = current_line + words[i] + " ";     // add the current line and new word to the test string

      // is the text width of test line greater then the width of the buffer??
      if (buffer.RAW.textWidth(test) + 10 > buffer.RAW.width) {   
        lines.add(current_line.trim());                // if it is, add the current line to the Array list of lines
        current_line = words[i] + " ";                 // now reset the current line by adding the new word to it
        if (i == (words.length - 1)) {
          lines.add(current_line);
        }
      }
      else {
        current_line = test;                           // we still have more room, so make the test line into the current line
        if (i == (words.length - 1)) {                   // check to see if we are on the last word
          lines.add(current_line);              // if we are, then we are done, so add the current line to the arraylist
        }
      }
    }

    textSet = true;
    //println(words);
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
  
  void setColor(color _c) {
    c = _c;
  }
  
  void setFont(PFont _f) {
    f = _f;
  }
  
  void on() {
    isOn = true;
  }
  
  void off() {
    isOn = false;
  }

  private void drawText() {
    buffer.RAW.textFont(f);  // set the font

    if (alignX == LEFT) {
      sx = 4;
    } 
    else if (alignX == CENTER) {
      sx = buffer.RAW.width / 2;
    } 
    else if (alignX == RIGHT) {
      sx = buffer.RAW.width - 4;
    }

    int textHeight = fontHeight * lines.size();

    if (alignY == TOP) {
      sy = 4;
    } 
    else if (alignY == CENTER) {
      sy = (buffer.RAW.height / 2) - (textHeight / 2);
    } 
    else if (alignY == BOTTOM) {
      sy = (buffer.RAW.height - textHeight) + 4;
    }

    buffer.RAW.textAlign(alignX, TOP);
    buffer.RAW.fill(c);

    for (int i = 0; i < lines.size(); i++) {
      String thisLine = (String) lines.get(i);
      int y = (fontHeight * i) + sy;
      buffer.RAW.text(thisLine, sx, y);
    }
  }

  void display() {
    if (textSet) {
      if(isOn) {
        drawText();
      }
    } 
    else {
      println("TextOverlay has no text to display!");
    }
  }
}


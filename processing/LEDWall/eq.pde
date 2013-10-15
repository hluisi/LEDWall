// NEEDS A REWRITE BIGTIME!!






class baseBar {
  float base_width;       // width of the Bar
  float base_height;      // height of the Bar
  float base_half_width;  // half of the width
  float base_half_height; // half of the height
  color base_color;       // color of the Bar
  color base_stroke;      // stroke of the Bar
  float base_weight;      // stroke weight of the Bar
  int base_align_x;       // X alignment (LEFT, CENTER, RIGHT)
  int base_align_y;       // Y alignment (TOP, CENTER, BOTTOM)
  int base_corners;       // rounded corner amount

  PVector location;       // the Bar's location
  PVector base_start;     // the start location for drawing the Bar
  PVector base_end;       // the end location for drawing the Bar

  boolean base_stroke_on; // is the stroke on or off?

  baseBar(float _x, float _y, float _width, float _height, int _align_x, int _align_y) {
    location = new PVector(_x, _y); // set starting location
    base_width   = _width;          // set width
    base_height  = _height;         // set height
    base_align_x = _align_x;        // set X alignment
    base_align_y = _align_y;        // set Y alignment
    defaults();                     // set the defaults
  }

  private void defaults() {
    base_start   = new PVector(); // create start drawing vector
    base_end     = new PVector(); // create end drawing vector
    base_color   = color(0);      // set base color to black
    base_stroke  = color(0);      // set base stroke to black
    base_weight  = 2;             // set base stroke to 2
    base_corners = 7;             // set conrner roundness to 7
    base_stroke_on = true;        // turn on stroke
  }

  void update() {
    base_half_width  = base_width  / 2;
    base_half_height = base_height / 2;

    if (base_align_x == LEFT && base_align_y == TOP) { 
      base_start.x = location.x;
      base_start.y = location.y;
      base_end.x   = location.x + base_width;
      base_end.y   = location.y + base_height;
    }

    if (base_align_x == CENTER && base_align_y == TOP) {
      base_start.x = location.x - base_half_width;
      base_start.y = location.y;
      base_end.x   = location.x + base_half_width;
      base_end.y   = location.y + base_height;
    }

    if (base_align_x == RIGHT && base_align_y == TOP) {
      base_start.x = location.x - base_width;
      base_start.y = location.y;
      base_end.x   = location.x;
      base_end.y   = location.y + base_height;
    }

    if (base_align_x == LEFT && base_align_y == CENTER) {
      base_start.x = location.x;
      base_start.y = location.y - base_half_height;
      base_end.x   = location.x + base_width;
      base_end.y   = location.y + base_half_height;
    }

    if (base_align_x == CENTER && base_align_y == CENTER) {
      base_start.x = location.x - base_half_width;
      base_start.y = location.y - base_half_height;
      base_end.x   = location.x + base_half_width;
      base_end.y   = location.y + base_half_height;
    }

    if (base_align_x == RIGHT && base_align_y == CENTER) {
      base_start.x = location.x - base_width;
      base_start.y = location.y - base_half_height;
      base_end.x   = location.x;
      base_end.y   = location.y + base_half_height;
    }

    if (base_align_x == LEFT && base_align_y == BOTTOM) {
      base_start.x = location.x;
      base_start.y = location.y - base_height;
      base_end.x   = location.x + base_width;
      base_end.y   = location.y;
    }

    if (base_align_x == CENTER && base_align_y == BOTTOM) {
      base_start.x = location.x - base_half_width;
      base_start.y = location.y - base_height;
      base_end.x   = location.x + base_half_width;
      base_end.y   = location.y;
    }

    if (base_align_x == RIGHT && base_align_y == BOTTOM) {
      base_start.x = location.x - base_width;
      base_start.y = location.y - base_height;
      base_end.x   = location.x;
      base_end.y   = location.y;
    }
  }

  void setAlign(int _align_x, int _align_y) {
    base_align_x = _align_x;
    base_align_y = _align_y;
  }

  void setCorners(int _v) {
    base_corners = _v;
  }

  void setWidth(float _w) {
    base_width = _w;
  }

  void setHeight(float _h) {
    base_height = _h;
  }

  void setColor(color _c) {
    base_color = _c;
  }

  void setStroke(color _s) {
    base_stroke = _s;
  }

  void setWeight(int _w) {
    base_weight = _w;
  }

  void strokeOn() {
    base_stroke_on = true;
  }

  void strokeOff() {
    base_stroke_on = false;
  }

  void move(float _x, float _y) {
    location.x = _x;
    location.y = _y;
  }

  void move(PVector _location) {
    location.x = _location.x;
    location.y = _location.y;
  }

  void drawBar() {
    buffer.rectMode(CORNERS);      // set rect mode to corners
    if (base_stroke_on) {
      buffer.stroke(base_stroke);
      buffer.strokeWeight(base_weight);
    } 
    else {
      buffer.noStroke();
    }
    buffer.fill(base_color);           // color bar to value level
    buffer.rect(base_start.x, base_start.y, base_end.x, base_end.y, base_corners);
    buffer.rectMode(CORNER);
  }

  void display(color _c) {
    setColor(_c);
    update();
    drawBar();
  }

  void display() {
    update();
    drawBar();
  }
}

class textBar extends baseBar {
  String   text_string, f;
  String[] words_array;
  ArrayList<String> line_list;    // lines of text
  float font_height;       // font height
  color text_color;
  PFont text_font;
  boolean text_is_set;
  boolean show_text;
  boolean show_bg;

  textBar(float _x, float _y, float _width, float _height, int _align_x, int _align_y, PFont _font) {
    super(_x, _y, _width, _height, _align_x, _align_y);
    text_font   = _font;
    text_color  = color(0);
    line_list  = new ArrayList<String>();
    text_string = "";
    show_text = true;
    show_bg = false;
  }

  void setText(String _text) {
    //if (text_string.equals(_text)) return; 
    text_string = _text;
    setupText();
  }

  private void setupText() {
    buffer.textFont(text_font);
    font_height = buffer.textAscent() + buffer.textDescent(); // figure out the font height
    words_array = text_string.split(" "); // split text into a string array of words
    String current_line = "";             // reset the current line string
    line_list.clear();                    // clear the lines list

    for (int i = 0; i < words_array.length; i++) {             // loop through the words
      if ((font_height * (line_list.size() + 1)) > base_height) break;
      String line_test = current_line + words_array[i] + " ";  // create a test string with the new word
      if (buffer.textWidth(line_test) + 10 > base_width) {     // test to see if new word fits inside the base bar
        line_list.add(current_line.trim());                    // if it is, add the current line to the line list
        current_line = words_array[i] + " ";                   // then make new current line with just the new word
        if (i == (words_array.length - 1)) {                   // now make sure we're not on the last word
          line_list.add(current_line);                         // if we are, then add that to the line list too
        }
      } 
      else {                                  // the line still fits inside the base bar
        current_line = line_test;             // so make the test line the current line
        if (i == (words_array.length - 1)) {  // again make sure we're not on the last word
          line_list.add(current_line);        // if we are, then add that to the line list too
        }
      }
    }
    text_is_set = true;
    //println(words_array);
    //println(font_height);
  }

  void setColor(color _c) {
    text_color = _c;
  }

  void setBgColor(color _c) {
    base_color = _c;
  }

  void bgOn() {
    show_bg = true;
  }

  void bgOff() {
    show_bg = false;
  }

  void setFont(PFont _font) {
    text_font = _font;
  }

  void on() {
    show_text = true;
  }

  void off() {
    show_text = false;
  }

  void drawText() {
    super.update();
    if (show_bg) super.drawBar();
    buffer.textFont(text_font);
    buffer.textAlign(base_align_x, base_align_y);

    float text_height = font_height * line_list.size();

    float start_y;
    if (base_align_y == BOTTOM) {
      start_y = location.y - text_height + font_height;
    } 
    else if (base_align_y == CENTER) {
      start_y = location.y - (text_height / 2) + (font_height / 2);
    } 
    else {
      start_y = location.y;
    }

    float start_x = 0;
    if (base_align_x == LEFT) {
      start_x = 2;
    }
    if (base_align_x == RIGHT) {
      start_x = -2;
    }

    // build a new string with all the line
    buffer.fill(text_color);
    for (int i = 0; i < line_list.size(); i++) {

      String thisLine = (String) line_list.get(i);
      float x = location.x + start_x;
      float y = start_y + (font_height * i);
      //println(y);
      buffer.text(thisLine, x, y);
    }
  }

  void display() {
    if (show_text) drawText();
  }
}

class valueBar extends baseBar {
  PFont   value_text_font; // font for value text
  int     value;           // value
  int     peak;            // the peak of the value
  int     MIN, MAX;        // the min and MAX values for mapping
  color   value_color;     // the color of the value bar
  color   value_stroke;    // the stroke color of the value bar
  int     value_weight;    // the stroke weight of the value bar
  float   text_height;
  color   text_color;      // the color of the value text 
  int     text_offset;     // offset text acording to alignment
  PVector value_start;     // the start location for drawing the value bar
  PVector value_end;       // the end location for drawing the value bar
  PVector peak_start;
  PVector peak_end;
  color   peak_color;
  int     peak_weight;
  boolean value_stroke_on; // is the stroke on for the value bar?
  boolean value_text_on;   // is the value text on?
  boolean base_bg_on;      // is the background on?
  boolean peak_on;

  valueBar(float _x, float _y, float _width, float _height, int _align_x, int _align_y, PFont _font) {
    super(_x, _y, _width, _height, _align_x, _align_y); // create the base bar
    super.defaults();                                   // do the base defaults;
    value_text_font   = _font;                          // set the text font
    defaults();                                         // set defaults
  }

  void defaults() {
    value = 0;    // default value of zero
    MIN   = 0;    // default min of zero
    MAX   = 1023; // default max of 1023

      value_color     = color(0); // default value bar color of black
    value_stroke    = color(0); // default value bar stroke of black
    value_weight    = 2;        // default value stroke weight of two
    text_color      = color(0); // default value text color of black
    text_offset     = 0;
    value_stroke_on = true;     // value stroke is on
    value_text_on   = true;     // value text is on

    value_start = new PVector(); // create value bar start vector
    value_end   = new PVector(); // create value bar end vector

      peak_start  = new PVector();
    peak_end    = new PVector();
    peak_color = color(0);
    peak_weight = 1;
    peak = 0;
    peak_on = false;
  }

  void update() {
    super.update();  // first up the base

      // start the value bar from the base bar vectors
    value_start.x = base_start.x;
    value_start.y = base_start.y;
    value_end.x   = base_end.x;
    value_end.y   = base_end.y;

    peak_start.x = base_start.x;
    peak_start.y = base_start.y;
    peak_end.x   = base_end.x;
    peak_end.y   = base_end.y;

    // mapping from the top left to the bottom right
    if (base_align_x == LEFT && base_align_y == TOP) {
      value_end.x = map(value, MIN, MAX, location.x, location.x + base_width);
      value_end.y = map(value, MIN, MAX, location.y, location.y + base_height);
      peak_end.x = map(peak, MIN, MAX, location.x, location.x + base_width);
      peak_start.y = map(peak, MIN, MAX, location.y, location.y + base_height);
      peak_end.y = peak_start.y;
    }
    // mapping from the top center to the bottom center
    if (base_align_x == CENTER && base_align_y == TOP) {
      value_end.y = map(value, MIN, MAX, location.y, location.y + base_height);
      peak_start.y = map(peak, MIN, MAX, location.y, location.y + base_height);
      peak_end.y = peak_start.y;
    }
    // mapping from the top right to the bottom left
    if (base_align_x == RIGHT && base_align_y == TOP) {
      value_start.x = map(value, MIN, MAX, location.x, location.x - base_width);
      value_end.y   = map(value, MIN, MAX, location.y, location.y + base_height);
      peak_start.x = map(peak, MIN, MAX, location.x, location.x - base_width);
      peak_start.y = map(peak, MIN, MAX, location.y, location.y + base_height);
      peak_end.y = peak_start.y;
    }
    // mapping from the center left to the center right
    if (base_align_x == LEFT && base_align_y == CENTER) {
      value_end.x = map(value, MIN, MAX, location.x, location.x + base_width);
      peak_start.x = map(peak, MIN, MAX, location.x, location.x + base_width);
      peak_end.x = peak_start.x;
    }
    // mapping from the center outward
    if (base_align_x == CENTER && base_align_y == CENTER) {

      if (base_width >= base_height) {
        value_start.x = map(value, MIN, MAX, location.x, location.x - base_half_width);
        value_end.x   = map(value, MIN, MAX, location.x, location.x + base_half_width);
        peak_start.x = map(peak, MIN, MAX, location.x, location.x - base_half_width);
        peak_end.x   = map(peak, MIN, MAX, location.x, location.x + base_half_width);
      }
      if (base_width <= base_height) {
        value_start.y = map(value, MIN, MAX, location.y, location.y - base_half_height);
        value_end.y   = map(value, MIN, MAX, location.y, location.y + base_half_height);
        peak_start.y = map(peak, MIN, MAX, location.y, location.y - base_half_height);
        peak_end.y   = map(peak, MIN, MAX, location.y, location.y + base_half_height);
      }
    }
    // mapping from the center right to the center left
    if (base_align_x == RIGHT && base_align_y == CENTER) {
      value_start.x = map(value, MIN, MAX, location.x, location.x - base_width);
      peak_start.x = map(peak, MIN, MAX, location.x, location.x - base_width);
      peak_end.x = peak_start.x;
    }
    // mapping from the bottom left to the top right
    if (base_align_x == LEFT && base_align_y == BOTTOM) {
      value_end.x   = map(value, MIN, MAX, location.x, location.x + base_width);
      value_start.y = map(value, MIN, MAX, location.y, location.y - base_height);
      peak_end.x   = map(peak, MIN, MAX, location.x, location.x + base_width);
      peak_start.y = map(peak, MIN, MAX, location.y, location.y - base_height);
      peak_end.y = peak_start.y;
    }
    // mapping from the bottom center to the top center
    if (base_align_x == CENTER && base_align_y == BOTTOM) {
      value_start.y = map(value, MIN, MAX, location.y, location.y - base_height);
      peak_start.y = map(peak, MIN, MAX, location.y, location.y - base_height);
      peak_end.y = peak_start.y;
    }
    // mapping from the bottom right to the top left
    if (base_align_x == RIGHT && base_align_y == BOTTOM) {
      value_start.x = map(value, MIN, MAX, location.x, location.x - base_width);
      value_start.y = map(value, MIN, MAX, location.y, location.y - base_height);
      peak_start.x = map(peak, MIN, MAX, location.x, location.x - base_width);
      peak_start.y = map(peak, MIN, MAX, location.y, location.y - base_height);
      peak_end.y = peak_start.y;
    }

    //peak_start.x = round(peak_start.x);  peak_end.x = round(peak_end.x);
    //peak_start.y = round(peak_start.y);  peak_end.y = round(peak_end.y);
  }

  private void setValue(int v) {
    value = v;
  }

  void setMin(int _v) {
    MIN = _v;
  }

  void setMax(int _v) {
    MAX = _v;
  }

  void textOn() {
    value_text_on = true;
  }

  void textOff() {
    value_text_on = false;
  }

  void textColor(color c) {
    text_color = c;
  }

  void setFont(PFont ff) {
    value_text_font = ff;
  }

  void bgOn() {
    base_bg_on = true;
  }

  void bgOff() {
    base_bg_on = false;
  }

  void setColor(color _c) {
    value_color = _c;
  }

  void setBgColor(color _c) {
    base_color = _c;
  }

  void setStroke(color _s) {
    value_stroke = _s;
  }

  void setBgStroke(color _s) {
    base_stroke = _s;
  }

  void setWeight(int _w) {
    value_weight = _w;
  }

  void setBgWeight(int _w) {
    base_weight = _w;
  }

  void strokeOn() {
    value_stroke_on = true;
  }

  void strokeBgOn() {
    base_stroke_on = true;
  }

  void strokeOff() {
    value_stroke_on = false;
  }

  void strokeBgOff() {
    base_stroke_on = false;
  }

  void textOffset(int _offset) {
    text_offset = _offset;
  }

  void setPeak(int p) {
    peak = p;
  }

  void setPeakColor (color c) {
    peak_color = c;
  }

  void setPeakWeight(int v) {
    peak_weight = v;
  }

  void peakOn() {
    peak_on = true;
  }

  void peakOff() {
    peak_on = false;
  }

  void drawText() {
    buffer.textFont(value_text_font);  // set the font
    text_height = buffer.textAscent() + buffer.textDescent();
    buffer.fill(text_color);     // set color for font
    buffer.textAlign(base_align_x, base_align_y);
    if (base_align_x == LEFT && base_align_y == TOP) {
      buffer.text(value, location.x - text_offset, location.y - text_offset);
    } 
    else if (base_align_x == CENTER && base_align_y == TOP) {
      buffer.text(value, location.x, location.y - text_offset);
    } 
    else if (base_align_x == RIGHT && base_align_y == TOP) {
      buffer.text(value, location.x + text_offset, location.y - text_offset);
    } 
    else if (base_align_x == LEFT && base_align_y == CENTER) {
      buffer.text(value, location.x - text_offset, location.y);
    } 
    else if (base_align_x == CENTER && base_align_y == CENTER) {
      buffer.text(value, location.x, location.y);
    } 
    else if (base_align_x == RIGHT && base_align_y == CENTER) {
      buffer.text(value, location.x + text_offset, location.y);
    } 
    else if (base_align_x == LEFT && base_align_y == BOTTOM) {
      buffer.text(value, location.x - text_offset, location.y + text_offset);
    } 
    else if (base_align_x == CENTER && base_align_y == BOTTOM) {
      buffer.text(value, location.x, location.y + text_offset);
    } 
    else {
      buffer.text(value, location.x + text_offset, location.y + text_offset);
    }
  }

  void drawBar() {
    buffer.rectMode(CORNERS);      // set rect mode to corners
    if (value_stroke_on) {
      buffer.stroke(value_stroke);
      buffer.strokeWeight(value_weight);
    } 
    else {
      buffer.noStroke();
    }
    buffer.fill(value_color);           // color bar to value level
    buffer.rect(value_start.x, value_start.y, value_end.x, value_end.y, base_corners);
    buffer.rectMode(CORNER);
    if (peak_on && peak > 4) {
      buffer.stroke(peak_color);
      buffer.strokeWeight(1);
      if (base_align_x == CENTER && base_align_y == CENTER) {
        if (base_width >= base_height) {
          buffer.line(peak_start.x, peak_start.y, peak_start.x, peak_end.y - 1);
          buffer.line(peak_end.x, peak_start.y, peak_end.x, peak_end.y - 1);
        }
        if (base_width <= base_height) {
          buffer.line(peak_start.x, peak_start.y, peak_end.x, peak_start.y);
          buffer.line(peak_start.x, peak_end.y, peak_end.x, peak_end.y);
        }
      } 
      else {
        buffer.line(peak_start.x, peak_end.y - 1, peak_end.x - 1, peak_end.y - 1);
      }
    }
  }

  void display() {
    update();
    if (base_bg_on) super.drawBar();
    drawBar();
    if (value_text_on) drawText();
  }

  void display(int v) {
    setValue(v);
    update();
    if (base_bg_on) super.drawBar();
    drawBar();
    if (value_text_on) drawText();
  }
}


class eqBar {
  baseBar RED, ORANGE, YELLOW, GREEN;
  valueBar VALUE;
  int eq_align_x, eq_align_y;
  int eq_value;
  float eq_x, eq_y, eq_width, eq_height;
  color eq_value_color;
  PFont eq_font;
  PFont label_font;
  String eq_label;
  color eq_label_color;
  boolean label_set;

  final float orange_cutoff = 0.9;
  final float yellow_cutoff = 0.75;
  final float green_cutoff = 0.5;

  eqBar(float _x, float _y, float _width, float _height, int _align_x, int _align_y, PFont _font) {
    eq_x       = _x;
    eq_y       = _y;
    eq_width   = _width;
    eq_height  = _height;
    eq_align_x = _align_x;
    eq_align_y = _align_y;
    eq_font    = _font;
    eq_label = "";
    label_set = false;
    init();
  }

  private void init() {
    eq_value_color = color(0, 255, 0);
    eq_label_color = color(0);

    VALUE = new valueBar(eq_x, eq_y, eq_width, eq_height, eq_align_x, eq_align_y, eq_font);
    VALUE.bgOff();
    VALUE.strokeOff();
    VALUE.setCorners(0);

    RED = new baseBar(eq_x, eq_y, eq_width, eq_height, eq_align_x, eq_align_y);
    RED.setColor(color(#641919));
    RED.setStroke(color(32));
    RED.setWeight(2);
    RED.strokeOn();
    RED.setCorners(0);

    ORANGE = new baseBar(eq_x, eq_y, eq_width, eq_height, eq_align_x, eq_align_y);
    ORANGE.setColor(color(#624212));
    ORANGE.strokeOff();
    ORANGE.setCorners(0);

    YELLOW = new baseBar(eq_x, eq_y, eq_width, eq_height, eq_align_x, eq_align_y);
    YELLOW.setColor(color(#625E12));
    YELLOW.strokeOff();
    YELLOW.setCorners(0);

    GREEN  = new baseBar(eq_x, eq_y, eq_width, eq_height, eq_align_x, eq_align_y);
    GREEN.setColor(color(#136212));
    GREEN.strokeOff();
    GREEN.setCorners(0);

    setWidth(eq_width);
    setHeight(eq_height);
  }

  void setWidth(float _w) {
    eq_width = _w;
    VALUE.setWidth(eq_width);
    RED.setWidth(eq_width);
    ORANGE.setWidth(eq_width);
    YELLOW.setWidth(eq_width);
    GREEN.setWidth(eq_width);

    if (eq_align_x != CENTER) {
      ORANGE.setWidth(eq_width * orange_cutoff);
      YELLOW.setWidth(eq_width * yellow_cutoff);
      GREEN.setWidth(eq_width * green_cutoff);
    }

    if (eq_align_x == CENTER && eq_width >= eq_height) {
      ORANGE.setWidth(eq_width * orange_cutoff);
      YELLOW.setWidth(eq_width * yellow_cutoff);
      GREEN.setWidth(eq_width * green_cutoff);
    }
  }

  void setHeight(float _h) {
    eq_height = _h;
    RED.setHeight(eq_height);
    VALUE.setHeight(eq_height);
    ORANGE.setHeight(eq_height);
    YELLOW.setHeight(eq_height);
    GREEN.setHeight(eq_height);

    if (eq_align_y != CENTER) {
      ORANGE.setHeight(eq_height * orange_cutoff);
      YELLOW.setHeight(eq_height * yellow_cutoff);
      GREEN.setHeight(eq_height * green_cutoff);
    }

    if (eq_align_y == CENTER && eq_height >= eq_width) {
      ORANGE.setHeight(eq_height * orange_cutoff);
      YELLOW.setHeight(eq_height * yellow_cutoff);
      GREEN.setHeight(eq_height * green_cutoff);
    }
  }

  void setAlign(int _align_x, int _align_y) {
    eq_align_x = _align_x;
    eq_align_y = _align_y;
    VALUE.setAlign(eq_align_x, eq_align_y);
    RED.setAlign(eq_align_x, eq_align_y);
    ORANGE.setAlign(eq_align_x, eq_align_y);
    YELLOW.setAlign(eq_align_x, eq_align_y);
    GREEN.setAlign(eq_align_x, eq_align_y);
  }

  void setWeight(int w) {
    RED.setWeight(w);
  }

  void setStroke(color c) {
    RED.setStroke(c);
  }

  void strokeOn() {
    RED.strokeOn();
  }

  void strokeOff() {
    RED.strokeOff();
  }

  void setValueColor(color _c) {
    eq_value_color = _c;
  }

  void setLabel(String _t) {
    eq_label = _t;
    label_set = true;
  }

  void clearLabel() {
    eq_label = "";
    label_set = false;
  }

  void setLabelColor(color _c) {
    eq_label_color = _c;
  }

  void setLabelFont(PFont ff) {
    label_font = ff;
  }

  void setFont(PFont ff) {
    eq_font = ff;
    VALUE.setFont(eq_font);
  }

  void setPeak(int p) {
    VALUE.setPeakColor( getColor(p) );
    VALUE.setPeak(p);
  }

  void move(float _x, float _y) {
    eq_x = _x;
    eq_y = _y;
    RED.location.x = eq_x;
    RED.location.y = eq_y;
    ORANGE.location.x = eq_x;
    ORANGE.location.y = eq_y;
    YELLOW.location.x = eq_x;
    YELLOW.location.y = eq_y;
    GREEN.location.x = eq_x;
    GREEN.location.y = eq_y;
    VALUE.location.x = eq_x;
    VALUE.location.y = eq_y;
  }

  void move(PVector newLoc) {
    eq_x = newLoc.x;
    eq_y = newLoc.y;
    RED.location.x = eq_x;
    RED.location.y = eq_y;
    ORANGE.location.x = eq_x;
    ORANGE.location.y = eq_y;
    YELLOW.location.x = eq_x;
    YELLOW.location.y = eq_y;
    GREEN.location.x = eq_x;
    GREEN.location.y = eq_y;
    VALUE.location.x = eq_x;
    VALUE.location.y = eq_y;
  }

  private color getColor(int v) {
    color return_color;
    if (v < VALUE.MAX * 0.5) {
      return_color = color(0, 255, 0); // less then half is green
    } 
    else if (v > VALUE.MAX * 0.5 && v < VALUE.MAX * 0.75) {
      return_color = color(255, 255, 0); // then yellow
    } 
    else if (v > VALUE.MAX * 0.75 && v < VALUE.MAX * 0.9) {
      return_color = color(229, 128, 0);  // then orange
    } 
    else {
      return_color = color(255, 0, 0);
    }
    return return_color;
  }

  private void updateColor() { 
    eq_value_color = getColor(eq_value);
  }

  void setValue(int _v) {
    eq_value = _v;
    VALUE.setValue(eq_value);
    updateColor();
    VALUE.setColor(eq_value_color);
  }

  void drawLabel() {
    buffer.textAlign(RED.base_align_x, CENTER);
    buffer.textFont(label_font);
    buffer.fill(eq_label_color);
    buffer.pushMatrix();
    buffer.translate(RED.location.x, RED.location.y);
    if (RED.base_align_y == BOTTOM) {
      buffer.rotate(radians(-90));
    } 
    else if (RED.base_align_y == TOP) {
      buffer.rotate(radians(-90));
    }

    float x = 0;
    if (RED.base_align_x == LEFT)   x = 3;
    if (RED.base_align_x == RIGHT)  x = -3;
    if (RED.base_align_x == CENTER && RED.base_align_y == BOTTOM) x = 3 + (buffer.textWidth(eq_label) / 2);
    if (RED.base_align_x == CENTER && RED.base_align_y == TOP) x = 0 - (buffer.textWidth(eq_label) / 2) - 3;
    buffer.text(eq_label, x, 0);
    buffer.popMatrix();
  }

  void drawAll() {
    RED.display();
    ORANGE.display();
    YELLOW.display();
    GREEN.display();
    VALUE.display(eq_value);
    if (label_set) drawLabel();
  }

  void display(int _v) {
    setValue(_v);
    drawAll();
  }

  void display() {
    drawAll();
  }
}


EQ eq;

void setupEQ() {
  eq = new EQ();
  println("SETUP EQ ...");
}

void doEQ() {
  buffer.blendMode(BLEND);
  buffer.background(0);
  eq.display();
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
    volume.VALUE.textOffset(0);
    volume.VALUE.setMax(100);
    volume.VALUE.setPeakWeight(1);
    volume.VALUE.peakOn();
    //volume.setLabel("VOLUME");
    volume.strokeOff();

    int x = 16;

    for (int i = 0; i < 9; i++) {
      spec[i] = new eqBar( x, 60, 14, 58, CENTER, BOTTOM, eqFont);
      spec[i].VALUE.textColor(color(255, 255));
      spec[i].VALUE.textOffset(10);
      spec[i].VALUE.setMax(100);
      spec[i].VALUE.setPeakWeight(1);
      spec[i].VALUE.peakOn();
      spec[i].strokeOff(); 
      spec[i].setLabelFont(tFont);
      spec[i].setLabelColor(color(0));
      spec[i].setLabel(round(audio.fft.getAverageCenterFrequency(i)) + " Hz");

      x += 16;
    }
  }

  void show() {

    //buffer.background(0);
    volume.setPeak(audio.volume.peak);
    volume.display(audio.volume.value);

    for (int i = 0; i < 9; i++) {
      spec[i].setPeak( audio.averageSpecs[i].peak );
      spec[i].display( audio.averageSpecs[i].value );
      //spec[i].display(audio.AVERAGES[i]);
    }
  }

  void display() {
    buffer.hint(DISABLE_DEPTH_TEST);
    show();
    buffer.hint(ENABLE_DEPTH_TEST);
  }
}


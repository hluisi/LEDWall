// STILL A TON TO ADD

import controlP5.*;

ControlP5 cp5;
final int TAB_START  = 200;
final int TAB_HEIGHT = 25;
int TAB_MAX_WIDTH;
int TAB_WIDTH;
PFont tabFont; // tab font   (12)
PFont sFont;   // small font (11)
PFont mFont;  // medium font (14)
PFont lFont; // large font   (20)
PFont xFont; // x-large font (40)

void setupControl() {
  tabFont = loadFont("Arial-BoldMT-12.vlw");
  sFont   = loadFont("Arial-BoldMT-11.vlw");
  mFont   = loadFont("Arial-BoldMT-14.vlw");
  lFont   = loadFont("Arial-BoldMT-20.vlw");
  xFont   = loadFont("Arial-BoldMT-40.vlw");
  
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  cp5.window().setPositionOfTabs(0, DEBUG_WINDOW_START);
  cp5.setColor(ControlP5.RED);
  
  TAB_MAX_WIDTH = WINDOW_XSIZE - TAB_START - 40;
  TAB_WIDTH = TAB_MAX_WIDTH / TOTAL_MODES;

  // create and setup the tabs
  setTab("default", DISPLAY_STR[0], 0, TAB_START - 5, TAB_HEIGHT, tabFont, false, true);

  for (int i = 1; i <= TOTAL_MODES; i++) {
    String name = DISPLAY_STR[i];
    cp5.addTab(name);
    setTab(name, name, i, TAB_WIDTH, TAB_HEIGHT, tabFont, true, false);
  }

  int b = MAX_BRIGHTNESS;
  
  // controler name, min, max, value, x, y, width, height, label, handle size, text size, type, move to tab
  createSlider("doSliderBrightness", 0, 255, b, TAB_START - 60, DEBUG_WINDOW_START + 35, 50, DEBUG_WINDOW_YSIZE - 60, "Brightness", 10, tabFont, Slider.FLEXIBLE, "default");

  createToggle("doToggleAutoOn", "Auto",  10, DEBUG_WINDOW_START + 35, 30, 30, sFont, ControlP5.DEFAULT, autoOn, "default");
  if (USE_MINIM) createToggle("doToggleAudioOn", "Audio",  50, DEBUG_WINDOW_START + 35, 30, 30, sFont, ControlP5.DEFAULT, audioOn, "default");
  if (USE_SOPENNI) createToggle("doToggleKinectOn", "Kinect",  90, DEBUG_WINDOW_START + 35, 30, 30, sFont, ControlP5.DEFAULT, kinectOn, "default");
  
  createToggle("doToggleScreenDebug", "Debug", 10, DEBUG_WINDOW_START + 95, 30, 30, sFont, ControlP5.DEFAULT, debugOn, "default");
  if (USE_MINIM) createToggle("doToggleAudioBackOn","Back", 50, DEBUG_WINDOW_START + 95, 30, 30, sFont, ControlP5.DEFAULT, aBackOn, "default");
  
  if (USE_SOPENNI) createToggle("doToggleUserMap", "User",  90, DEBUG_WINDOW_START + 95, 30, 30, sFont, ControlP5.DEFAULT, kinect.mapUser, "default");
  
  createToggle("doToggleSimulate", "Simulate Wall", 10, DEBUG_WINDOW_START + 155, 110, 40, tabFont, ControlP5.DEFAULT, simulateOn, "default");
}

Textfield createTextfield(String cN, String lN, int x, int y, int w, int h, String value, PFont f, int ty, String m2t) {
  Textfield tf = cp5.addTextfield(cN, x, y, w, h);
  
  tf.setPosition(x, y);
  tf.setText(value);
  tf.setSize(w, h);                                                  // set size to 50x50
  tf.setInputFilter(ty);
  tf.moveTo(m2t);
  tf.setAutoClear(false);
  tf.captionLabel().setFont(f);
  tf.valueLabel().setFont(f);
  tf.captionLabel().setText(lN);    
  tf.captionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE); // set alignment
  tf.valueLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  tf.setColorBackground(color(20,0,0));
  return tf;
}

// create a Slider controller
// controler name, min, max, value, x, y, width, height, label, handle size, text size, type, move to tab
Slider createSlider(String cN, float s, float e, float v, int x, int y, int w, int h, String lN, int hs, PFont tf, int ty, String m2t) {
  Slider sc = cp5.addSlider(cN, s, e, v, x, y, w, h);
  
  sc.getValueLabel().setFont(tf);
  sc.getCaptionLabel().setFont(tf);
  sc.setLabel(lN);
  sc.setHandleSize(hs);
  sc.setSliderMode(ty);
  sc.moveTo(m2t);
  sc.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(5);
  sc.getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(5);
  
  sc.captionLabel().toUpperCase(false);
  return sc;
}

Toggle createToggle(String controllerName, String textName, int x, int y, int w, int h, PFont tf, int tm, boolean value, String m2t) {
  Toggle tc = cp5.addToggle(controllerName);
  tc.setPosition(x, y);
  tc.setSize(w, h);                                                  // set size to 50x50
  tc.captionLabel().setFont(tf);
  tc.setMode(tm);
  tc.setValue(value);
  tc.captionLabel().toUpperCase(false);
  tc.captionLabel().setText(textName);                                 // set name
  tc.captionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE); // set alignment
  tc.moveTo(m2t);
  return tc;
}

void setTab(String cName, String tabName, int ID, int w, int h, PFont tf, boolean activate, boolean alwaysActive) {
  Tab tab = cp5.getTab(cName);            // get tab
  tab.captionLabel().setFont(tf);         // set tab font
  tab.setWidth(w);                        // set tab width
  tab.setHeight(h);                       // set tab height
  tab.setId(ID);                          // set tabs id
  tab.setAlwaysActive(alwaysActive);      // set tab as always active
  tab.activateEvent(activate);            // set tab as active
  tab.captionLabel().toUpperCase(false);  // allow lowercase text
  tab.setLabel(tabName);                  // set tab text
}

void doSliderBrightness(int v) {
  MAX_BRIGHTNESS = v;
}

void controlEvent(ControlEvent theEvent) {
  // tab?
  if ( theEvent.isTab() ) {
    int ID = theEvent.getTab().getId();
    if (ID > 0) DISPLAY_MODE = ID;
  }
}

// turn on auto mode
void doToggleAutoOn(boolean b) {
  autoOn = b;
}

// turn on debug
void doToggleScreenDebug(boolean b) {
  debugOn = b;
}

// turn on audio
void doToggleAudioOn(boolean b) {
  audioOn = b;
}

// turn on audio background
void doToggleAudioBackOn(boolean b) {
  aBackOn = b;
}

// turn on kinect
void doToggleKinectOn(boolean b) {
  kinectOn = b;
}

// turn on user depth mapping
void doToggleUserMap(boolean b) {
  kinect.mapUser = b;
}

// simulate wall
void doToggleSimulate(boolean b) {
  simulateOn = b;
}


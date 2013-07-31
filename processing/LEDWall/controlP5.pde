// STILL A TON TO ADD

import controlP5.*;

ControlP5 cp5;
final int TAB_START  = 150;
final int TAB_HEIGHT = 25;
int TAB_MAX_WIDTH;
int TAB_WIDTH;

void setupControl() {
  cp5 = new ControlP5(this);
  cp5.window().setPositionOfTabs(0, DEBUG_WINDOW_START);
  cp5.setColor(ControlP5.RED);
  
  TAB_MAX_WIDTH = WINDOW_XSIZE - INFO_WINDOW_SIZE - TAB_START - 40;
  TAB_WIDTH = TAB_MAX_WIDTH / TOTAL_MODES;

  // create and setup the tabs
  setTab("default", DISPLAY_STR[0], 0, TAB_START - 5, TAB_HEIGHT, 14, false, true);

  for (int i = 1; i <= TOTAL_MODES; i++) {
    String name = DISPLAY_STR[i];
    cp5.addTab(name);
    setTab(name, name, i, TAB_WIDTH, TAB_HEIGHT, 14, true, false);
  }

  int b = MAX_BRIGHTNESS;
  
  // controler name, min, max, value, x, y, width, height, label, handle size, text size, type, move to tab
  createSlider("doSliderBrightness", 0, 255, b, TAB_START - 60, DEBUG_WINDOW_START + 35, 50, DEBUG_WINDOW_YSIZE - 60, "Brightness", 10, 12, Slider.FLEXIBLE, "default");

  createToggle("doToggleAutoMode",    "Auto",  10, DEBUG_WINDOW_START + 35, 30, 30, 12, ControlP5.DEFAULT, AUTO_MODE,      "default");
  createToggle("doToggleUserMap",     "User",  50, DEBUG_WINDOW_START + 35, 30, 30, 12, ControlP5.DEFAULT, kinect.mapUser, "default");
  createToggle("doToggleAudioBack",   "Audio", 10, DEBUG_WINDOW_START + 95, 30, 30, 12, ControlP5.DEFAULT, AUDIO_BG_ON,    "default");
  createToggle("doToggleScreenDebug", "Debug", 50, DEBUG_WINDOW_START + 95, 30, 30, 12, ControlP5.DEFAULT, SCREEN_DEBUG,   "default");
}

Textfield createTextfield(String cN, String lN, int x, int y, int w, int h, String value, int ts, int ty, String m2t) {
  Textfield tf = cp5.addTextfield(cN, x, y, w, h);
  
  tf.setPosition(x, y);
  tf.setText(value);
  tf.setSize(w, h);                                                  // set size to 50x50
  tf.setInputFilter(ty);
  tf.moveTo(m2t);
  tf.setAutoClear(false);
  tf.captionLabel().getFont().setSize(ts);   
  tf.captionLabel().setText(lN);    
  tf.captionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE); // set alignment
  tf.valueLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  tf.setColorBackground(color(20,0,0));
  return tf;
}

// create a Slider controller
// controler name, min, max, value, x, y, width, height, label, handle size, text size, type, move to tab
Slider createSlider(String cN, float s, float e, float v, int x, int y, int w, int h, String lN, int hs, int ts, int ty, String m2t) {
  Slider sc = cp5.addSlider(cN, s, e, v, x, y, w, h);

  sc.setLabel(lN);
  sc.setHandleSize(hs);
  sc.setSliderMode(ty);
  sc.moveTo(m2t);
  sc.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(5);
  sc.getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(5);
  sc.getValueLabel().getFont().setSize(ts);
  sc.getCaptionLabel().getFont().setSize(ts);
  sc.captionLabel().toUpperCase(false);
  return sc;
}

Toggle createToggle(String controllerName, String textName, int x, int y, int w, int h, int ts, int tm, boolean value, String m2t) {
  Toggle tc = cp5.addToggle(controllerName);
  tc.setPosition(x, y);
  tc.setValue(value);
  tc.setSize(w, h);                                                  // set size to 50x50
  tc.setMode(tm);
  tc.captionLabel().setText(textName);                                 // set name
  tc.captionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE); // set alignment
  tc.captionLabel().getFont().setSize(ts);                             // set text size
  tc.captionLabel().toUpperCase(false);
  tc.moveTo(m2t);
  return tc;
}

void setTab(String cName, String tabName, int ID, int w, int h, int ts, boolean activate, boolean alwaysActive) {
  
  Tab tab = cp5.getTab(cName);                                 // get tab
  tab.setLabel(tabName);
  tab.setId(ID);                                                 // set id
  tab.setAlwaysActive(alwaysActive);
  tab.activateEvent(activate);                                       // set active
  tab.setHeight(h);                                             // set height
  tab.setWidth(w);                                       // set width
  tab.captionLabel().getFont().setSize(ts);                      // set label font size
  tab.captionLabel().align(ControlP5.CENTER, ControlP5.CENTER);  //set label font alignment
  tab.captionLabel().toUpperCase(false);
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

void doToggleAutoMode(boolean b) {
  AUTO_MODE = b;
}

void doToggleUserMap(boolean b) {
  kinect.mapUser = b;
}

void doToggleAudioBack(boolean b) {
  AUDIO_BG_ON = b;
}

void doToggleScreenDebug(boolean b) {
  SCREEN_DEBUG = b;
}


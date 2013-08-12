// ADD COMMENTS

import processing.video.*;

MovieClips movies;    // mode class
Slider movieSlider;   // movie selecting
Slider movieSpeed;    // movie speed
Textlabel mBPM, mSwitch;       // bpm
Textfield mSetSwitch;

void setupClips() {
  println("VIDEO CLIPS - starting setup...");
  movies = new MovieClips(this, "videos");
  
  // slider for chossing movies
  movieSlider = 
    createSlider("doMovieSlider",                    // function name
                 0,                                  // min
                 movies.clips.length - 1,            // max
                 movies.current,                     // starting value
                 TAB_START + 20,                     // x postion
                 WINDOW_YSIZE - 105,                 // y postion
                 TAB_MAX_WIDTH,                      // width
                 60,                                 // height
                 "Brightness",                       // starting caption
                 40,                                 // handle size
                 xFont,                              // font
                 Slider.FLEXIBLE,                    // slider type
                 DISPLAY_STR[DISPLAY_MODE_CLIPS]);   // tab
  cp5.getTooltip().register("doMovieSlider","Use to set different movie clips.");
  
  mSetSwitch =        
    createTextfield("setMovieSwitch",                       // function name
                    "Switch",                              // caption name
                    TAB_START + 30,                      // x postion
                    DEBUG_WINDOW_START + 50,              // y postion
                    100,                                   // width
                    50,                                   // height
                    nf(movies.switchValue, 1, 4),      // starting value
                    lFont,                                // font
                    ControlP5.FLOAT,                    // input filter (BITFONT, DEFAULT, FLOAT, or INTEGER)
                    DISPLAY_STR[DISPLAY_MODE_CLIPS]);    // tab
  cp5.getTooltip().register("setMovieSwitch","0.0001 to 0.9999");
  
  mSwitch = 
    createTextlabel("mShowSwitch",                      // function name
                    nf(movies.switchTest,1,4),                              // starting text
                    TAB_START + 20,                  // x postion
                    DEBUG_WINDOW_START + 130,         // y postion
                    color(255),                      // font color
                    xFont,                           // font
                    DISPLAY_STR[DISPLAY_MODE_CLIPS]);// tab
  cp5.getTooltip().register("mShowSwitch","The lower number the faster it will switch clips.");
  
  // toggle for turning on/off the random picking of clips
  createToggle("allowMovieSwitch",                   // function name
               "random",                             // button caption
               TAB_MAX_WIDTH - 660,                       // x postion
               DEBUG_WINDOW_START + 50,              // y postion
               100,                                   // width
               100,                                   // height
               lFont,                                // font
               ControlP5.DEFAULT,                    // toggle type
               movies.switchOn,                      // starting value
               DISPLAY_STR[DISPLAY_MODE_CLIPS]);     // tab
  cp5.getTooltip().register("allowMovieSwitch","Turn ON/OFF random switching of clips.");
  
  // toggle for turning on/off the random jumping to music of clips
  createToggle("allowMovieJumps",                    // function name
               "jump cuts",                              // button name
               TAB_MAX_WIDTH - 540,                       // x postion
               DEBUG_WINDOW_START + 50,              // y postion
               100,                                   // width
               100,                                   // height
               lFont,                                // font
               ControlP5.DEFAULT,                    // toggle type
               movies.jumpsOn,                       // starting value
               DISPLAY_STR[DISPLAY_MODE_CLIPS]);     // tab
  cp5.getTooltip().register("allowMovieJumps","Turn ON/OFF the beat jumping of clips.");
  
  // toggle for controlling movie speed via the BPM
  createToggle("allowMovieBPM",                      // function name
               "use bpm",                         // button name
               TAB_MAX_WIDTH - 420,                  // x postion
               DEBUG_WINDOW_START + 50,              // y postion
               100,                                   // width
               100,                                   // height
               lFont,                                // font
               ControlP5.DEFAULT,                    // toggle type
               movies.bpmOn,                         // starting value
               DISPLAY_STR[DISPLAY_MODE_CLIPS]);     // tab
  cp5.getTooltip().register("allowMovieBPM","Turn ON/OFF BPM mapping of the clips speed.");

  // sets the min speed for the movies when mapped to BPM
  createTextfield("setMinSpeed",                     // function name
                  "min speed",                       // caption name
                  TAB_MAX_WIDTH - 280,               // x postion
                  DEBUG_WINDOW_START + 55,           // y postion
                  80,                                // width
                  40,                                // height
                  nf(movies.minSpeed, 1, 0),         // starting value
                  lFont,                             // font
                  ControlP5.FLOAT,                   // input filter (BITFONT, DEFAULT, FLOAT, or INTEGER)
                  DISPLAY_STR[DISPLAY_MODE_CLIPS]);  // tab
  cp5.getController("setMinSpeed").captionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE);
  cp5.getTooltip().register("setMinSpeed","Set the min speed for the clips.");
  
  // sets the max speed for the movies when mapped to BPM
  createTextfield("setMaxSpeed",                     // function name
                  "max speed",                       // caption name
                  TAB_MAX_WIDTH - 280,               // x postion
                  DEBUG_WINDOW_START + 110,          // y postion
                  80,                                // width
                  40,                                // height
                  nf(movies.maxSpeed, 1, 0),         // starting value
                  lFont,                             // font
                  ControlP5.FLOAT,                   // input filter (BITFONT, DEFAULT, FLOAT, or INTEGER)
                  DISPLAY_STR[DISPLAY_MODE_CLIPS]);  // tab
  cp5.getTooltip().register("setMinSpeed","Set the max speed for the clips.");
  
  // displays the current BPM
  mBPM = 
    createTextlabel("mShowBPM",                      // function name
                    "",                              // starting text
                    TAB_MAX_WIDTH - 110,             // x postion
                    DEBUG_WINDOW_START + 35,         // y postion
                    color(255),                      // font color
                    xFont,                           // font
                    DISPLAY_STR[DISPLAY_MODE_CLIPS]);// tab
                    
  
  // slider for controlling movie speed
  movieSpeed =  
    createSlider("doMovieSpeed",                     // function name
                 movies.minSpeed,                    // min
                 movies.maxSpeed,                    // max
                 movies.speed,                       // starting value
                 TAB_MAX_WIDTH - 180,                // x postion
                 DEBUG_WINDOW_START + 75,           // y postion
                 320,                                // width
                 60,                                 // height
                 "Speed",                            // starting caption
                 20,                                 // handle size
                 lFont,                              // font
                 Slider.FLEXIBLE,                    // slider type
                 DISPLAY_STR[DISPLAY_MODE_CLIPS]);   // tab
  cp5.getTooltip().register("doMovieSpeed","Use to set the speed of the clips.");
  
  // sets the max bpm when fiquring out the clip speed 
  createTextfield("setMinBPM",                       // function name
                  "min bpm",                         // caption name
                  TAB_MAX_WIDTH + 160,               // x postion
                  DEBUG_WINDOW_START + 55,           // y postion
                  80,                                // width
                  40,                                // height
                  nf(movies.minBPM, 1),              // starting value
                  lFont,                             // font
                  ControlP5.INTEGER,                 // input filter (BITFONT, DEFAULT, FLOAT, or INTEGER)
                  DISPLAY_STR[DISPLAY_MODE_CLIPS]);  // tab
  cp5.getController("setMinBPM").captionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(5);
  cp5.getTooltip().register("setMinBPM","The min BPM for mapping the clip speed.");
  
  // sets the max speed for the movies when mapped to BPM
  createTextfield("setMaxBPM",                       // function name
                  "max bpm",                         // caption name
                  TAB_MAX_WIDTH + 160,               // x postion
                  DEBUG_WINDOW_START + 110,          // y postion
                  80,                                // width
                  40,                                // height
                  nf(movies.maxBPM, 1),              // starting value
                  lFont,                             // font
                  ControlP5.INTEGER,                 // input filter (BITFONT, DEFAULT, FLOAT, or INTEGER)
                  DISPLAY_STR[DISPLAY_MODE_CLIPS]);  // tab
  cp5.getTooltip().register("setMaxBPM","The max BPM for mapping the clip speed.");

  println("VIDEO CLIPS - setup finished!");
}


void doMovieSlider(int v) {
  movies.setClip(v);
}

void doMovieSpeed(float v) {
  if (!movies.bpmOn) movies.setSpeed(v);
}

void setMovieSwitch(String valueString) {
  movies.switchValue = float(valueString);
  if (movies.switchValue > 0.99) movies.switchValue = 0.9999;
  if (movies.switchValue < 0.01) movies.switchValue = 0.0001;
  mSetSwitch.setText(nf(movies.switchValue,1,4));
}

void setMinSpeed(String valueString) {
  float minSpeed  = float(valueString);
  movies.minSpeed = minSpeed;
  movieSpeed.setMin(minSpeed);
  movieSpeed.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(5);
  movieSpeed.getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(5);
}

void setMaxSpeed(String valueString) {
  float maxSpeed  = float(valueString);
  movies.maxSpeed = maxSpeed;
  movieSpeed.setMax(maxSpeed);
  movieSpeed.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(5);
  movieSpeed.getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(5);
}

void setMinBPM(String valueString) {
  int minBPM  = int(valueString);
  movies.minBPM = minBPM;
}

void setMaxBPM(String valueString) {
  int maxBPM  = int(valueString);
  movies.maxBPM = maxBPM;
}

void allowMovieSwitch(boolean b) {
  movies.switchOn = b;
}

void allowMovieJumps(boolean b) {
  movies.jumpsOn = b;
}

void allowMovieBPM(boolean b) {
  movies.bpmOn = b;
}



class MovieClips {
  float speed = 1.0;
  float minSpeed = 0.65;
  float maxSpeed = 1.25;
  int maxBPM = 130;
  int minBPM = 0;

  int current = 0;
  Movie[] clips;
  int switch_count = 0;
  int jump_count = 0;
  String[] names;
  float switchTest = 0.0;
  float switchValue = 0.75;

  boolean switchOn = true;
  boolean jumpsOn  = true;
  boolean bpmOn    = true;

  MovieClips(PApplet app, String dir) {
    String[] movie_files = getFileNames(dir, "mov");
    clips = new Movie [movie_files.length];
    names = new String [movie_files.length];

    for (int i = 0; i < clips.length; i++) {
      //String[] parts = movie_files[i].split(java.io.File.pathSeparatorChar);
      names[i] = movie_files[i].substring(movie_files[i].lastIndexOf("\\")+1);
      println("CLIPS - loading clip - " + i + ": " + names[i]);
      clips[i] = new Movie(app, movie_files[i]);
      clips[i].loop();
    }
  }

  void setClip(int v) {
    if (switch_count > 7) {
      switch_count = 0;
      int seed = round(random(frameCount));
      randomSeed(seed);
      //noiseSeed(seed);
    }
    
    current = v;
    cp5.getController("doMovieSlider").getCaptionLabel().setText(names[current]);
    switch_count++;
  }

  void setRandomClip() {
    int next = round( random(clips.length - 1) );
    //int next = round(noise(xoff) * (clips.length - 1));
    setClip(next);
    movieSlider.setValue(current);
    //cp5.getController("doMovieSlider").setValue(current);
  }

  void setSpeed(float v) {
    clips[current].speed(v);
    speed = v;
  }
  
  void doJump() {
    if (jump_count > 7) {
      jump_count = 0;
      int seed = round(random(frameCount));
      noiseSeed(seed);
    }
    float spot = noise(xoff) * clips[current].duration();
    clips[current].jump( spot );
    jump_count++;
  }

  void update() {
    // switch clips?
    if ( audio.isOnBeat() ) {
      switchTest = random(0, 1);
      if (switchTest > switchValue && switchOn) {
        setRandomClip();
        mSwitch.setColorValue(color(255,0,0));
      } 
      else {
        if (jumpsOn) doJump();
        mSwitch.setColorValue(color(255));
      }
    }

    // read the new frame
    if (clips[current].available() == true) {
      clips[current].read();
    }

    // set the speed of the next frame according to the current BPM
    if (bpmOn) {
      speed = map(audio.BPM, 0, maxBPM, minSpeed, maxSpeed);
      clips[current].speed(speed);
      movieSpeed.setValue(speed);
    }
  }

  void draw() {
    update();
    //buffer.blendMode(ADD);
    buffer.blendMode(SCREEN);
    //buffer.blendMode(LIGHTEST);
    doBackground();
    //buffer.background(0);
    
    buffer.noStroke();
    buffer.image(clips[current], 0, 0); //, buffer.width, buffer.height);
    buffer.blendMode(BLEND);
    
    mBPM.setText(nf(audio.BPM,3) + " BPM");
    mSwitch.setText( nf(movies.switchTest,1,4) );
  }
}


// ADD COMMENTS

import processing.video.*;

MovieClips movies;    // mode class
Slider movieSlider;   // movie selecting
Slider movieSpeed;    // movie speed

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
                 WINDOW_YSIZE - 100,                 // y postion
                 TAB_MAX_WIDTH,                      // width
                 60,                                 // height
                 "Brightness",                       // starting caption
                 40,                                 // handle size
                 lFont,                              // font
                 Slider.FLEXIBLE,                    // slider type
                 DISPLAY_STR[DISPLAY_MODE_CLIPS]);   // tab
  
  // slider for controlling movie speed
  movieSpeed =  
    createSlider("doMovieSpeed",                     // function name
                 movies.minSpeed,                    // min
                 movies.maxSpeed,                    // max
                 movies.speed,                       // starting value
                 TAB_MAX_WIDTH-220,                  // x postion
                 DEBUG_WINDOW_START+50,              // y postion
                 220,                                // width
                 50,                                 // height
                 "Speed",                            // starting caption
                 14,                                 // handle size
                 mFont,                              // font
                 Slider.FLEXIBLE,                    // slider type
                 DISPLAY_STR[DISPLAY_MODE_CLIPS]);   // tab
  
  // toggle for turning on/off the random picking of clips
  createToggle("allowMovieSwitch",                   // function name
               "Random",                             // button caption
               TAB_START + 20,                       // x postion
               DEBUG_WINDOW_START + 40,              // y postion
               50,                                   // width
               50,                                   // height
               mFont,                                // font
               ControlP5.DEFAULT,                    // toggle type
               movies.switchOn,                      // starting value
               DISPLAY_STR[DISPLAY_MODE_CLIPS]);     // tab
  
  // toggle for turning on/off the random jumping to music of clips
  createToggle("allowMovieJumps",                    // function name
               "Jumps",                              // button name
               TAB_START + 90,                       // x postion
               DEBUG_WINDOW_START + 40,              // y postion
               50,                                   // width
               50,                                   // height
               mFont,                                // font
               ControlP5.DEFAULT,                    // toggle type
               movies.jumpsOn,                       // starting value
               DISPLAY_STR[DISPLAY_MODE_CLIPS]);     // tab
  
  // toggle for controlling movie speed via the BPM
  createToggle("allowMovieBPM",                      // function name
               "BPM",                                // button name
               TAB_START + 160,                      // x postion
               DEBUG_WINDOW_START + 40,              // y postion
               50,                                   // width
               50,                                   // height
               mFont,                                // font
               ControlP5.DEFAULT,                    // toggle type
               movies.bpmOn,                         // starting value
               DISPLAY_STR[DISPLAY_MODE_CLIPS]);     // tab

  // sets the min speed for the movies when mapped to BPM
  createTextfield("setMinSpeed",                     // function name
                  "min speed",                       // caption name
                  TAB_MAX_WIDTH + 10,                // x postion
                  DEBUG_WINDOW_START+55,             // y postion
                  50,                                // width
                  20,                                // height
                  nf(movies.minSpeed, 1, 0),         // starting value
                  sFont,                             // font
                  ControlP5.FLOAT,                   // input filter (BITFONT, DEFAULT, FLOAT, or INTEGER)
                  DISPLAY_STR[DISPLAY_MODE_CLIPS]);  // tab
  cp5.getController("setMinSpeed").captionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE);
  
  // sets the max speed for the movies when mapped to BPM
  createTextfield("setMaxSpeed", "max speed", TAB_MAX_WIDTH + 10, DEBUG_WINDOW_START+80, 50, 20, nf(movies.maxSpeed, 1, 0), sFont, ControlP5.FLOAT, DISPLAY_STR[DISPLAY_MODE_CLIPS]);
  createTextfield("setMaxBPM", "max bpm", TAB_MAX_WIDTH + 70, DEBUG_WINDOW_START+65, 50, 30, nf(movies.maxBPM, 1), sFont, ControlP5.INTEGER, DISPLAY_STR[DISPLAY_MODE_CLIPS]);
  cp5.getController("setMaxBPM").captionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(5);

  println("VIDEO CLIPS - setup finished!");
}

void doClips() {
  movies.draw();
}

void doMovieSlider(int v) {
  movies.setClip(v);
}

void doMovieSpeed(float v) {
  if (!movies.bpmOn) movies.setSpeed(v);
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
  float minSpeed = 0.5;
  float maxSpeed = 1.0;
  int maxBPM = 130;
  int minBPM = 0;

  int current = 0;
  Movie[] clips;
  int switch_count = 0;
  int jump_count = 0;
  String[] names;

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
    }
    
    current = v;
    cp5.getController("doMovieSlider").getCaptionLabel().setText(names[current]);
    switch_count++;
  }

  void setRandomClip() {
    //int next = round( random(clips.length - 1) );
    int next = round(noise(yoff) * (clips.length - 1));
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
      float test = random(0, 1);
      if (test > 0.7 && switchOn) {
        setRandomClip();
      } 
      else {
        if (jumpsOn) doJump();
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
    doBackground();
    buffer.blendMode(ADD);
    buffer.noStroke();
    buffer.image(clips[current], 0, 0); //, buffer.width, buffer.height);
    buffer.blendMode(BLEND);
  }
}


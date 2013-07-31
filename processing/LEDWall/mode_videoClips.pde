// ADD COMMENTS

import processing.video.*;

MovieClips movies;
Toggle allowSwitch;
Toggle allowJumps;

void setupClips() {
  println("VIDEO CLIPS - starting setup...");
  movies = new MovieClips(this, "videos");

  int x = TAB_START + 10;
  int y = WINDOW_YSIZE + DEBUG_WINDOW_YSIZE - 80;
  int m = movies.clips.length - 1;

  // controler name, min, max, value, x, y, width, height, label, handle size, text size, type, move to tab
  createSlider("doMovieSlider", 0, m, movies.current, x, y, TAB_MAX_WIDTH + 20, 40, "Brightness", 20, 28, Slider.FLEXIBLE, DISPLAY_STR[DISPLAY_MODE_CLIPS]);
  createSlider("doMovieSpeed", movies.minSpeed, movies.maxSpeed, movies.speed, TAB_MAX_WIDTH-200, DEBUG_WINDOW_START+50, 180, 20, "Speed", 10, 12, Slider.FLEXIBLE, DISPLAY_STR[DISPLAY_MODE_CLIPS]);
  
  // controll name, text name, x, y, width, height, text size, value, move 2 tab
  createToggle("allowMovieSwitch", "Random", TAB_START + 10,  DEBUG_WINDOW_START + 50, 50, 50, 16, ControlP5.DEFAULT, movies.switchOn, DISPLAY_STR[DISPLAY_MODE_CLIPS]);
  createToggle("allowMovieJumps",  "Jump"  , TAB_START + 80,  DEBUG_WINDOW_START + 50, 50, 50, 16, ControlP5.DEFAULT, movies.jumpsOn , DISPLAY_STR[DISPLAY_MODE_CLIPS]);
  createToggle("allowMovieBPM",    "BPM"   , TAB_START + 140, DEBUG_WINDOW_START + 50, 50, 50, 16, ControlP5.DEFAULT, movies.bpmOn   , DISPLAY_STR[DISPLAY_MODE_CLIPS]);

  println("VIDEO CLIPS - setup finished!");
}

void doMovieSlider(int v) {
  movies.setClip(v);
  //cp5.getController("doMovieSlider").setValue(v);
}

void doMovieSpeed(float v) {
  if (!movies.bpmOn) movies.setSpeed(v);
  //cp5.getController("doMovieSpeed").setValue(v);
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

void doClips() {
  buffer.blendMode(ADD);
  movies.draw();
}

class MovieClips {
  float speed = 1.0;
  float minSpeed = 0.5;
  float maxSpeed = 1.25;
  int maxBPM = 130;
  
  int current = 0;
  Movie[] clips;
  int switch_count = 0;
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
    current = v;
    switch_count++;
    if (switch_count > 6) {
      switch_count = 0;
      int seed = int(random(frameCount));
      randomSeed(seed);
    }
    cp5.getController("doMovieSlider").getCaptionLabel().setText(names[current]);
  }
  
  void setRandomClip() {
    int next = round( random(clips.length - 1) );
    setClip(next);
    cp5.getController("doMovieSlider").setValue(current);
  }
  
  void setSpeed(float v) {
    clips[current].speed(v);
    speed = v;
  }
  
  void update() {
    // switch clips?
    if ( audio.isOnBeat() ) {
      float test = random(0, 1);
      if (test > 0.75 && switchOn) {
        setRandomClip();
      } else {
        if (jumpsOn) {
          float spot = noise(xoff) * clips[current].duration();
          clips[current].jump( spot );
        }
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
      cp5.getController("doMovieSpeed").setValue(speed);
    }
  }

  void draw() {
    update();
    buffer.image(clips[current], 0, 0, buffer.width, buffer.height);
  }
}


import processing.video.*;

MovieClips movies;

void setupClips() {
  movies = new MovieClips(this, "videos");
}

void doClips() {
  buffer.beginDraw();
  buffer.background(audio.COLOR);
  //buffer.background(0);
  buffer.blendMode(ADD);
  
  movies.draw();
  
  buffer.blendMode(BLEND);
  kinect.updateUserBlack();
  buffer.image(kinect.buffer_image, 0, 0);
  buffer.endDraw();
}


class MovieClips {
  float current_speed = 1.0;
  int current = 0;
  Movie[] clips;
  
  MovieClips(PApplet app, String dir) {
    String thisdir = sketchPath + "\\data\\" + dir;
    File file = new File(thisdir);
    String[] file_names = file.list();
    clips = new Movie [file_names.length];
    for (int i = 0; i < file_names.length; i++) {
      String[] fname = file_names[i].split("\\.(?=[^\\.]+$)");
      if (fname[fname.length - 1].equals("mov") == true) {
        String fullname = thisdir + "\\" + file_names[i];
        println("" + i + ": " + fullname);
        clips[i] = new Movie(app, fullname);
        clips[i].loop();
      }
    }
  }
  
  void update() {
    // switch clips?
    if ( audio.beat.isOnset() ) {
      float test = random(0, 1);
      if (test < 0.5) {
        current = int(random(clips.length - 1));
        println("new current: " + current);
      }
      else  {
        clips[current].jump( random( clips[current].duration() ) );
        println("jummped to: " + clips[current].time());
      }
    }
    
    // read the new frame
    if (clips[current].available() == true) {
      clips[current].read(); 
    }
    
    // set the speed of the next frame according to the current BPM
    current_speed = map(audio.BPM, 0, 200, 0.25, 2.0);
    clips[current].speed(current_speed);
  }
  
  void draw() {
    update();
    buffer.image(clips[current], 0, 0, buffer.width, buffer.height);
  }
}


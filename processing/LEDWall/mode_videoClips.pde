// ADD COMMENTS

import processing.video.*;

MovieClips clips;

void setupClips() {
  println("VIDEO CLIPS - starting setup...");
  clips = new MovieClips(this, "videos");
  println("VIDEO CLIPS - setup finished!");
}

void doClips() {
  buffer.blendMode(ADD);
  clips.draw();
}

class MovieClips {
  float current_speed = 1.0;
  int current = 0;
  Movie[] clips;
  int switch_count = 0;
  String[] names;

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

  void update() {
    // switch clips?
    if ( audio.isOnBeat() ) {
      float test = random(0, 1);
      if (test > 0.75) {
        int next = int( random(clips.length) );
        if (next >= clips.length) next--;
        current = next;
        println("CLIPS - new clip: " + names[current]);
        switch_count++;
      } 
      else {
        float spot = noise(xoff) * clips[current].duration();
        clips[current].jump( spot );
        println("  -  jummped to: " + clips[current].time());
      }
      if (switch_count > 6) {
        switch_count = 0;
        int seed = int(random(frameCount));
        randomSeed(seed);
        println("  -  new seed: " + seed);
      }
    }

    // read the new frame
    if (clips[current].available() == true) {
      clips[current].read();
    }

    // set the speed of the next frame according to the current BPM
    current_speed = map(audio.BPM, 0, 120, 0.5, 1);
    clips[current].speed(current_speed);
  }

  void draw() {
    update();
    buffer.image(clips[current], 0, 0, buffer.width, buffer.height);
  }
}


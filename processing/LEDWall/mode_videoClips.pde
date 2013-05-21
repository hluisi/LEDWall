import processing.video.*;

MovieClips movies;

void setupClips() {
  println("VIDEO CLIPS - starting setup...");
  movies = new MovieClips(this, "videos");
  println("VIDEO CLIPS - setup finished!");
}

void doClips() {
  kinect.updateUser();
  buffer.beginDraw();
  buffer.background(audio.COLOR);
  buffer.blendMode(ADD);
  
  movies.draw();
  
  buffer.blendMode(BLEND);

  buffer.image(kinect.buffer_image, 0, 0);
  buffer.endDraw();
}

class myMovie extends Movie {
  String name;
  
  myMovie(PApplet parent, String fullname, String shortname) {
    super(parent, fullname);
    name = shortname;
  }
}

class MovieClips {
  float current_speed = 1.0;
  int current = 0;
  myMovie[] clips;
  int switch_count = 0;
  String[] names;
  
  MovieClips(PApplet app, String dir) {
    String thisdir = sketchPath + "\\data\\" + dir;
    File file = new File(thisdir);
    String[] file_names = file.list();
    clips = new myMovie [file_names.length];
    
    int j = 0;
    for (int i = 0; i < file_names.length; i++) {
      String[] fname = file_names[i].split("\\.(?=[^\\.]+$)");
      if (fname[fname.length - 1].equals("mov") == true) {
        j++;
      }
    }
    clips = new myMovie [j];
    names = new String [j];
    
    j = 0;
    for (int i = 0; i < file_names.length; i++) {
      String[] fname = file_names[i].split("\\.(?=[^\\.]+$)");
      if (fname[fname.length - 1].equals("mov") == true) {
        names[j] = thisdir + "\\" + file_names[i];
        println("CLIPS - loading clip - " + i + ": " + names[j]);
        clips[j] = new myMovie(app, names[j], fname[0]);
        clips[j].loop();
        j++;
      }
    }
    //println(clips.length);
    //println(clips[clips.length - 1].name);
  }
  
  void update() {
    // switch clips?
    if ( audio.isOnBeat() ) {
      float test = random(0, 1);
      if (test < 0.65) {
        int next = int( random(clips.length) );
        if (next >= clips.length) next--;
        current = next;
        println("CLIPS - new clip: " + clips[current].name);
        switch_count++;
      }
      else  {
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
    current_speed = map(audio.BPM, 0, 200, 0.25, 2.0);
    clips[current].speed(current_speed);
  }
  
  void draw() {
    update();
    buffer.image(clips[current], 0, 0, buffer.width, buffer.height);
  }
}


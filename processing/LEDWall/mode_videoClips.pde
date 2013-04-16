import processing.video.*;

MovieClips movies;

void setupClips() {
  println("VIDEO CLIPS - starting setup...");
  movies = new MovieClips(this, "videos");
  println("VIDEO CLIPS - setup finished!");
}

void doClips() {
  buffer.beginDraw();
  buffer.background(audio.COLOR);
  //buffer.background(0);
  buffer.blendMode(ADD);
  
  movies.draw();
  
  buffer.blendMode(BLEND);
  kinect.updateUserBlack();
  //kinect.updateUser( getCircleColor( int( random(6) ) ) );
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
  float xoff = 0.0;
  myMovie[] clips;
  
  MovieClips(PApplet app, String dir) {
    String thisdir = sketchPath + "\\data\\" + dir;
    File file = new File(thisdir);
    String[] file_names = file.list();
    clips = new myMovie [file_names.length];
    for (int i = 0; i < file_names.length; i++) {
      String[] fname = file_names[i].split("\\.(?=[^\\.]+$)");
      if (fname[fname.length - 1].equals("mov") == true) {
        String fullname = thisdir + "\\" + file_names[i];
        println("" + i + ": " + fullname);
        clips[i] = new myMovie(app, fullname, fname[0]);
        clips[i].loop();
      }
    }
    println(clips.length);
  }
  
  void update() {
    // switch clips?
    if ( audio.beat.isOnset() ) {
      float test = random(0, 1);
      if (test < 0.5) {
        int next = int( noise(xoff) * (clips.length - 2) );
        current = next;
        println("CLIPS - new clip: " + clips[current].name);
        
      }
      else  {
        float spot = noise(xoff) * clips[current].duration();
        clips[current].jump( spot );
        println("  -  jummped to: " + clips[current].time());
      }
      xoff += 0.2;
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


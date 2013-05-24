Shape shapes;

void setupShapes() {
  println("VIDEO CLIPS - starting setup...");
  shapes = new Shape("shapes");
  println("VIDEO CLIPS - setup finished!");
}

class Shape {
  PShape[] svgs;
  int switch_count = 0;
  String[] names;
  final float SCALE = 0.15;

  Shape(String dir) {
    String thisdir = sketchPath + "\\data\\" + dir;
    File file = new File(thisdir);
    String[] file_names = file.list();
    String[] svg_names = new String [file_names.length];

    int j = 0;
    for (int i = 0; i < file_names.length; i++) {
      String[] fname = file_names[i].split("\\.(?=[^\\.]+$)");
      if (fname[fname.length - 1].equals("svg") == true) {
        svg_names[j] = thisdir + "\\" + file_names[i];
        j++;
      }
    }
    svgs = new PShape [j];

    for (int i = 0; i < svgs.length; i++) {
      println("SHAPES - loading shape - " + i + ": " + svg_names[i]);
      svgs[i] = loadShape(svg_names[i]);
      svgs[i].scale(SCALE);
      svgs[i].disableStyle();
      println( (svgs[i].width * SCALE) + ":" + (svgs[i].height * SCALE) );
    }
  }


  /*
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
   current_speed = map(audio.BPM, 0, 240, 0.25, 2.0);
   clips[current].speed(current_speed);
   }
   
   void draw() {
   update();
   buffer.image(clips[current], 0, 0, buffer.width, buffer.height);
   } */
}


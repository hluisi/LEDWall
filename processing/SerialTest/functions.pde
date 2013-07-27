import processing.video.*;

Movie movie;

// loads the test movie from the data directory
void setupMovie() {
  movie = new Movie(this, "test.mov");
  movie.loop();
}

// processing 2.0 removed the delay() command
// so we have to make our own 
void delay(int mil) {
  int d = millis();
  while (millis () - d < mil);
}

void clac_kBs() {
  kBs = kBs_tracker / 1000;
  kBs_tracker = 0;
  kBs_timer = millis();
  MAX_KBS = max(kBs, MAX_KBS);
}

// play the movie
void drawMovie() {
  if ( movie.available() ) { // got a new frame?
    movie.read();            // read it
  }
  frameBuffer.noStroke();
  frameBuffer.image(movie, 0, 0, frameBuffer.width, frameBuffer.height); // add movie image to frame buffer
}

// draw some random lines to push the CPU
// based on performance line rendering example
void drawLines() {
  for (int i = 0; i < 25000; i++) {
    float x0 = random( frameBuffer.width );
    float y0 = random( frameBuffer.height );
    float z0 = random(-100, 100);
    float x1 = random( frameBuffer.width );
    float y1 = random( frameBuffer.height );
    float z1 = random(-100, 100);
    frameBuffer.stroke( random(255), random(255), random(255), 32 ); // set random color
    frameBuffer.strokeWeight( random(5) );                          // set random line width
    frameBuffer.line(x0, y0, z0, x1, y1, z1);
  }
}

void drawComs() {
  if (SHOW_COMS) {
    for (int i = 0; i < teensys.length; i++) {
      String p = teensys[i].port_name;
      int y = round( (TEENSY_WIDTH / 2) + (textWidth(p) / 2) - 4);
      int x = (TEENSY_HEIGHT * i) - (TEENSY_HEIGHT / 2);
      frameBuffer.pushMatrix();
      frameBuffer.translate(x, y);
      frameBuffer.rotate( radians(-90) );
      frameBuffer.fill(255);
      frameBuffer.text(p, 0, 0);
      frameBuffer.popMatrix();
    }
  }
}

// Takes an image of the frame buffer, rotates it,  
// then divides it into images for the teensy.
void sendFrame() {
  
  // create the teensy buffer frame
  teensyBuffer.beginDraw();
  teensyBuffer.pushMatrix();
  teensyBuffer.imageMode(CENTER);
  teensyBuffer.translate(teensyBuffer.width / 2, teensyBuffer.height / 2);
  teensyBuffer.rotate( radians(90) );
  teensyBuffer.image(frameBuffer.get(), 0, 0);
  teensyBuffer.popMatrix();
  teensyBuffer.endDraw();
  teensyBuffer.loadPixels();

  // reset teensy watts
  WALL_WATTS = 0;

  // loop throught the teensy image array and set the images
  for (int i = 0; i < teensyImages.length; i++) {
    arrayCopy(teensyBuffer.pixels, i * (TEENSY_WIDTH * TEENSY_HEIGHT), teensyImages[i].pixels, 0, TEENSY_WIDTH * TEENSY_HEIGHT);
    teensyImages[i].updatePixels();

    if (i < TEENSY_TOTAL) {
      teensys[i].send(teensyImages[i]);
      WALL_WATTS  += teensys[i].watts;
      kBs_tracker += teensys[i].data.length;
    }
  }

  // simulate 10 teensy's of data?
  if (simulate_10 && simCount > 0) {
    int i = 0;
    int j = 0;
    while (j < simCount) {
      if (i < TEENSY_TOTAL) {
        int tsend  = teensys[i].send_time;
        int tproc  = teensys[i].proc_time;
        teensys[i].send(teensyImages[i]);
        WALL_WATTS  += teensys[i].watts;
        teensys[i].addSend(tsend);
        teensys[i].addProc(tproc);
        kBs_tracker += teensys[i].data.length;
        i++; 
        j++;
      } 
      else { 
        i = 0;
      }
    }
  }

  MAX_WATTS = max(MAX_WATTS, WALL_WATTS);
}


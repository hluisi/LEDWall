import processing.video.*;

int TSEND_TIME;   // the amount of millis it takes to send data to all the teensy
int TPROC_TIME;   // the amount of millis it takes to process pixels for the teensy
int FPROC_TIME;   // the amount of millis it takes to generate the frame buffer
int TOTAL_TIME;   // the amount of millis spent for each frame
float TSEND_AVRG;   // the average amount of millis it takes to send data to a single teensy
float TPROC_AVRG;   // the average amount of millis it takes to process pixels for a single teensy
float TOTAL_AVRG;   // the average amount of millis it takes to send & process data for a single teensy

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
  //frameBuffer.background(0, 10);
  //int amount = round( random(50000) );                            // amount of lines

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

  // reset teensy timers and watts
  TSEND_TIME = 0;
  TPROC_TIME = 0;
  WALL_WATTS = 0;

  // start total timer
  int stime = millis();

  // loop throught the teensy image array and set the images
  for (int i = 0; i < teensyImages.length; i++) {
    arrayCopy(teensyBuffer.pixels, i * (TEENSY_WIDTH * TEENSY_HEIGHT), teensyImages[i].pixels, 0, TEENSY_WIDTH * TEENSY_HEIGHT);
    teensyImages[i].updatePixels();

    if (i < TEENSY_TOTAL) {
      teensys[i].send(teensyImages[i]);
      WALL_WATTS  += teensys[i].watts;
      TSEND_TIME  += teensys[i].send_time;
      TPROC_TIME  += teensys[i].proc_time;
      kBs_tracker += teensys[i].data.length;
    }
  }

  TOTAL_TIME = millis() - stime;
  TSEND_AVRG = TSEND_TIME / 10.0;
  TPROC_AVRG = TPROC_TIME / 10.0;
  TOTAL_AVRG = TOTAL_TIME / 10.0;
  MAX_WATTS = max(MAX_WATTS, WALL_WATTS);
}




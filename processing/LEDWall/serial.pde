import processing.serial.*;

int sendingCount = 0;

final int TEENSY_TOTAL  = 2;
final int TEENSY_WIDTH  = 80;
final int TEENSY_HEIGHT = 16;

Teensy[] teensys = new Teensy [TEENSY_TOTAL];



void setupSerial() {
  println("starting teensy setup...");
  String[] list = Serial.list();
  delay(20);
  println("Serial Ports List:");
  println(list);
  
  // SETUP TEENSYs
  teensys[0] = new Teensy(this, "COM3", true);
  teensys[0].start();
  teensys[1] = new Teensy(this, "COM12", false);
  teensys[1].start();
  
  println();
  println("TEENSYS SETUP!!");
}


class Teensy extends Thread {

  boolean running;   // thread is running
  boolean sending;   // thread is sending
  boolean trigger;   // trigger sending data
  boolean isMaster;  // teensy is master
  PImage  image;     // image that will be sent to teensy
  byte[]  data;      // converted image data that gets sent
  Serial  port;      // serial port of the teensy
  String  portName;  // serial port name

  Teensy(PApplet parent, String pname, boolean master) {
    println("Setting up teensy: " + pname + " ...");
    data     = new byte[(TEENSY_WIDTH * TEENSY_HEIGHT * 3) + 3]; // setup the data array
    running  = false;  // are we runing?
    sending  = false;  // are we currently sending data?
    trigger  = false;  // should we send data now?
    isMaster = master; // are we the master teensy?  (used for display sync)
    portName = pname;  // set the port name

      // setup serial port
    try {
      port = new Serial(parent, portName, 115200);             // create the port
      if (port == null) throw new NullPointerException();    // was the port created?
      port.write('?');                                       // send ident char to teensy
    } 
    catch (Throwable e) {  // got errors?
      println("Serial port " + portName + " does not exist or is non-functional");
      exit();
    }

    delay(50); // wait a bit for teensy to send back ident data

    String line = port.readStringUntil(10);  // give me everything up to the linefeed

    if (line == null) {  //  no data back from the teensy? 
      println("Serial port " + portName + " is not responding.");
      println("Is it really a Teensy 3.0 running VideoDisplay?");
      exit();
    }

    String param[] = line.split(",");  // get the param's (which we don't really need)
    if (param.length != 12) { // didn't get 12 back?  bad news...
      println("Error: port " + portName + " did not respond to LED config query");
      exit();
    }

    println(portName + " SETUP!!");
  }

  // Overloading start
  void start() {
    println("Starting " + portName + " thread...");
    running = true;
    super.start();
    println(portName + " thread is running!");
  }

  void run() {
    if (trigger) {
      sending = true;  // we are sending data
      sendingCount++;  // raise the sending count
      sendData();      // send data
      trigger = false; // reset trigger
      sending = false; // done sending
      sendingCount--;  // lower the sending count
    }
  }

  void update() {
    image2data();  // convert image to data
  }

  void sendData() {
    update();        // update the image data
    if (isMaster) {  // are we the master?
      data[0] = '*';  
      int usec = (int)((1000000.0 / frameRate) * 0.75); // using processing's frameRate to fix timing
      data[1] = (byte)(usec);   // request the frame sync pulse
      data[2] = (byte)(usec >> 8); // at 75% of the frame time
    } else {
      data[0] = '%';  // others sync to the master board
      data[1] = 0;
      data[2] = 0;
    }

    port.write(data);  // send data over serial to teensy
    
  }

  void send(PImage img) {
    image = img;    // set the current image
    trigger = true;  // trigger thread
  }

  // image2data converts an image to OctoWS2811's raw data format.
  // The number of vertical pixels in the image must be a multiple
  // of 8.  The data array must be the proper size for the image.
  void image2data(/* PImage image, byte[] data, boolean layout */) {
    int offset = 3;
    int x, y, xbegin, xend, xinc, mask;
    int linesPerPin = image.height / 8;
    int pixel[] = new int[8];

    boolean layout = true;

    for (y = 0; y < linesPerPin; y++) {
      if ((y & 1) == (layout ? 0 : 1)) {
        // even numbered rows are left to right
        xbegin = 0;
        xend = image.width;
        xinc = 1;
      } else {
        // odd numbered rows are right to left
        xbegin = image.width - 1;
        xend = -1;
        xinc = -1;
      }
      for (x = xbegin; x != xend; x += xinc) {
        for (int i=0; i < 8; i++) {
          // fetch 8 pixels from the image, 1 for each pin
          pixel[i] = image.pixels[x + (y + linesPerPin * i) * image.width];
          pixel[i] = colorWiring(pixel[i]);
        }
        // convert 8 pixels to 24 bytes
        for (mask = 0x800000; mask != 0; mask >>= 1) {
          byte b = 0;
          for (int i=0; i < 8; i++) {
            if ((pixel[i] & mask) != 0) b |= (1 << i);
          }
          data[offset++] = b;
        }
      }
    }
  }

  // translate the 24 bit color from RGB to the actual
  // order used by the LED wiring.  GRB is the most common.
  int colorWiring(int c) {
    // return c;  // RGB
    return ((c & 0xFF0000) >> 8) | ((c & 0x00FF00) << 8) | (c & 0x0000FF); // GRB - most common wiring
  }
  
  // Our method that quits the thread
  void quit() {
    println("Quitting thread: " + portName + " ..."); 
    running = false;  // Setting running to false ends the loop in run()
    // IUn case the thread is waiting. . .
    interrupt();
  }
}

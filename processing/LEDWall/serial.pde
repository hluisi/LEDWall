import processing.serial.*;

int sendingCount = 0;

final int TEENSY_TOTAL  = 1;
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
  teensys[0] = new Teensy(this, 1, "COM15", true);
  
  //teensys[1] = new Teensy(this, 1, "COM14", false);
  //teensys[1].start();
  println("TEENSYS SETUP!!");
  println();
}

/*

 class Teensy {
 int id;
 Serial port;
 String portName;
 boolean isMaster;
 
 byte[]  ledData;      // converted image data that gets sent
 
 Teensy(PApplet p, int ID, String name, boolean master) {
 println("Setting up teensy: " + name + " ...");
 ledData = new byte[(TEENSY_WIDTH * TEENSY_HEIGHT * 3) + 3]; // setup the data array
 isMaster = master;
 portName = name;
 id = ID;
 
 try {
 port = new Serial(p, portName, 115200);           // create the port
 if (port == null) throw new NullPointerException();    // was the port created?
 port.write('?');                                       // send ident char to teensy
 }
 catch (Throwable e) {  // got errors?
 println("Serial port " + portName + " does not exist or is non-functional");
 exit();
 }
 
 delay(50); // wait for teensy to send back ident data
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
 println(param[0] + "x" + param[1] + " " + param[2]);
 //exit();
 println(portName + " SETUP!!");
 }
 
 // translate the 24 bit color from RGB to the actual
 // order used by the LED wiring.  GRB is the most common.
 int colorWiring(int c) {
 //return c;  // RGB
 return ((c & 0xFF0000) >> 8) | ((c & 0x00FF00) << 8) | (c & 0x0000FF); // GRB - most common wiring
 }
 
 void update() { 
 int offset = 3;
 int x, y, xbegin, xend, xinc, mask;
 int linesPerPin = wall.teensyImages[id].height / 8;
 int pixel[] = new int[8];
 
 boolean layout = true;
 
 for (y = 0; y < linesPerPin; y++) {
 if ((y & 1) == (layout ? 0 : 1)) {
 // even numbered rows are left to right
 xbegin = 0;
 xend = wall.teensyImages[id].width;
 xinc = 1;
 } else {
 // odd numbered rows are right to left
 xbegin = wall.teensyImages[id].width - 1;
 xend = -1;
 xinc = -1;
 }
 for (x = xbegin; x != xend; x += xinc) {
 for (int i=0; i < 8; i++) {
 // fetch 8 pixels from the image, 1 for each pin
 pixel[i] = wall.teensyImages[id].pixels[x + (y + linesPerPin * i) * wall.teensyImages[id].width];
 pixel[i] = colorWiring(pixel[i]);
 }
 // convert 8 pixels to 24 bytes
 for (mask = 0x800000; mask != 0; mask >>= 1) {
 byte b = 0;
 for (int i=0; i < 8; i++) {
 if ((pixel[i] & mask) != 0) b |= (1 << i);
 }
 ledData[offset++] = b;
 }
 }
 }
 }
 
 void send() {
 update();        // update the image data
 if (isMaster) {  // are we the master?
 ledData[0] = '*';  
 int usec = (int)((1000000.0 / frameRate) * 0.75); // using processing's frameRate to fix timing
 ledData[1] = (byte)(usec);   // request the frame sync pulse
 ledData[2] = (byte)(usec >> 8); // at 75% of the frame time
 } else {
 ledData[0] = '%';  // others sync to the master board
 ledData[1] = 0;
 ledData[2] = 0;
 }
 
 port.write(ledData);  // send data over serial to teensy
 
 }
 }
 
 */
class Teensy extends Thread {

  boolean running;  // thread is running
  boolean isMaster; // teensy is master
  boolean triggerSend; // start send
  int     id;       // id of the image that will be sent to teensy
  byte[]  data;     // converted image data that gets sent
  Serial  port;     // serial port of the teensy
  String  portName; // serial port name

  Teensy(PApplet parent, int ID, String name, boolean master) {
    println("Setting up teensy: " + name + " ...");
    data     = new byte[(TEENSY_WIDTH * TEENSY_HEIGHT * 3) + 3]; // setup the data array
    running  = false;   // are we runing?
    isMaster = master;  // are we the master teensy?  (used for display sync)
    portName = name;    // set the port name
    id       = ID;      // set the id 

    // setup serial port
    try {
      port = new Serial(parent, portName, 57600);           // create the port
      if (port == null) throw new NullPointerException();    // was the port created?
      port.write('?');                                       // send ident char to teensy
    } 
    catch (Throwable e) {  // got errors?
      println("Serial port " + portName + " does not exist or is non-functional");
      exit();
    }

    delay(50); // wait for teensy to send back ident data

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

  void clear() {
    for (int i = 0; i < data.length; i++) {
      data[i] = 0;
    }
    send();
  }
  
  // translate the 24 bit color from RGB to the actual
  // order used by the LED wiring.  GRB is the most common.
  int colorWiring(int c) {
    // return c;  // RGB
    return ((c & 0xFF0000) >> 8) | ((c & 0x00FF00) << 8) | (c & 0x0000FF); // GRB - most common wiring
  }

  // converts an image to OctoWS2811's raw data format.
  // The number of vertical pixels in the image must be a multiple
  // of 8.  The data array must be the proper size for the image.
  void update() { 
    int offset = 3;
    int x, y, xbegin, xend, xinc, mask;
    int linesPerPin = wall.teensyImages[id].height / 8;
    int pixel[] = new int[8];

    boolean layout = true;

    for (y = 0; y < linesPerPin; y++) {
      if ((y & 1) == (layout ? 0 : 1)) {
        // even numbered rows are left to right
        xbegin = 0;
        xend = wall.teensyImages[id].width;
        xinc = 1;
      } else {
        // odd numbered rows are right to left
        xbegin = wall.teensyImages[id].width - 1;
        xend = -1;
        xinc = -1;
      }
      for (x = xbegin; x != xend; x += xinc) {
        for (int i=0; i < 8; i++) {
          // fetch 8 pixels from the image, 1 for each pin
          pixel[i] = wall.teensyImages[id].pixels[x + (y + linesPerPin * i) * wall.teensyImages[id].width];
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
  
  void send() {
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

  // Overloading start
  void start() {
    running = true;
    println("Starting " + portName + " thread...");
    clear();
    super.start();
  }
  
  void trigger() {
    triggerSend = true;
  }

  void run() {
    while (running) {
      if (triggerSend) {
        triggerSend = false;
        sendingCount++;
        update();
        send(); 
        sendingCount--;
      }
    }
  }
  
  void quit() {
    println("Quitting thread: " + portName); 
    clear();
    running = false;  // Setting running to false ends the loop in run()
    // IUn case the thread is waiting. . .
    interrupt();
  }

}


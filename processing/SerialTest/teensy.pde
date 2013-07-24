import processing.serial.*;

final int TEENSY_WIDTH  = 80;
final int TEENSY_HEIGHT = 16;
final int BAUD_RATE = 921600; //115200;  // does nothing?

float WALL_WATTS = 0;
float MAX_WATTS = 0;

int[][] gammaTable;
int MAX_BRIGHTNESS = 255;

final int TEENSY_TOTAL  = 5;
//final int TEENSY_TOTAL  = 10;

final float RED_GAMMA = 2.1;
final float GREEN_GAMMA = 2.1;
final float BLUE_GAMMA = 2.1;

Teensy[] teensys = new Teensy [TEENSY_TOTAL];

// sets up the teensy objects
void setupTeensys() {
  println("Starting teensy setup...");
  println();
  String[] list = Serial.list();
  delay(20);
  println();
  println("Serial Ports List:");
  println(list);
  println();

  teensys[0] = new Teensy(this, "COM4");
  teensys[1] = new Teensy(this, "COM5");
  teensys[2] = new Teensy(this, "COM14");
  teensys[3] = new Teensy(this, "COM15");
  teensys[4] = new Teensy(this, "COM16");
  
  /*
  teensys[5] = new Teensy(this, "COM10");
  teensys[6] = new Teensy(this, "COM6");
  teensys[7] = new Teensy(this, "COM9");
  teensys[8] = new Teensy(this, "COM7");
  teensys[9] = new Teensy(this, "COM8");
  */

  setupGamma();

  println("TEENSY SETUP DONE!!");
  println();
}

// sets up the gamma corection lookup array
void setupGamma() {
  gammaTable = new int [256][3];
  float d;
  for (int i = 0; i < 256; i++) {
    d =  i / 255.0;
    gammaTable[i][0] = floor(255 * pow(d, RED_GAMMA) + 0.5);   // RED
    gammaTable[i][1] = floor(255 * pow(d, GREEN_GAMMA) + 0.5); // GREEN
    gammaTable[i][2] = floor(255 * pow(d, BLUE_GAMMA) + 0.5);  // BLUE
  }
}

class Teensy {
  float   watts;
  byte[]  data;        // converted image data that gets sent
  Serial  port;        // serial port of the teensy
  String  port_name;    // serial port name
  int send_time = 0;   // track send time
  int proc_time = 0;   // track image processing time
  int max_send = 0;
  int max_proc = 0;
  int led_width;       
  int led_height;    
  int lines_per_pin;
  boolean led_layout;

  Teensy(PApplet parent, String name) {
    println("Setting up teensy on " + name );
    println("===========================================================================================");

    port_name = name;

    try {
      port = new Serial(parent, port_name, BAUD_RATE);       // create the port
      if (port == null) throw new NullPointerException();    // was the port created?
      port.write('?');                                       // send ident char to teensy
    } 
    catch (Throwable e) {  // got errors?
      println("Serial port " + port_name + " does not exist or is non-functional");
      exit();
    }


    delay(20); // wait a bit for teensy to send the data

    String line = port.readStringUntil(10);  // give me everything up to the linefeed

    if (line == null) {  //  no data back from the teensy? 
      println("Serial port " + port_name + " is not responding.");
      println("Is it really a Teensy 3.0 running VideoDisplay?");
      exit();
    }

    String param[] = line.split(",");  // get the param's 
    if (param.length != 4) {          // didn't get 12 back?  bad news...
      println("Error: port " + port_name + " did not respond to LED config query");
      exit();
    } 
    else {
      // get the width and height
      led_width  = Integer.parseInt( param[0] );  // set the width
      led_height = Integer.parseInt( param[1] );  // set the height

      // make sure the width and height settings between processing and the teensy's match
      if ( led_width != TEENSY_WIDTH || led_height != TEENSY_HEIGHT) {
        println();
        println("Your proccessing and teensy settings do not match!!!");
        println("Processing: " + TEENSY_WIDTH + "x" + TEENSY_HEIGHT);
        println("Teensy:     " + led_width + "x" + led_height);
        exit();
      }

      led_layout    = (Integer.parseInt(param[2]) == 0);          // set the layout
      lines_per_pin = led_height / 8;                             // set the lines per pin
      data          = new byte[(led_width * led_height * 3) + 3]; // setup the data array

      // print teensy information 
      print("Found: " + led_width + "x" + led_height + ", using " + data.length + " bytes of data, ");
      print("with " + lines_per_pin + " strips per pin, using a ");
      if (led_layout) print("left->right ");
      else            print("right->left ");
      println("layout.");
    }
    println(port_name + " setup.");
    println();
  }

  // computes each pixel by:
  // 1. mapping the max brightness
  // 2. setting gamma corection
  // 3. calculating the wattage of the pixel
  // 4. setting the color order
  color processPixel(color c) {
    int r = (c >> 16) & 0xFF;  // get the red
    int g = (c >> 8) & 0xFF;   // get the green
    int b = c & 0xFF;          // get the blue 

    r = int( map( r, 0, 255, 0, MAX_BRIGHTNESS ) );  // map red to max LED brightness
    g = int( map( g, 0, 255, 0, MAX_BRIGHTNESS ) );  // map green to max LED brightness
    b = int( map( b, 0, 255, 0, MAX_BRIGHTNESS ) );  // map blue to max LED brightness

    r = gammaTable[r][0];  // set red to gamma correction table
    g = gammaTable[g][1];  // set green to gamma correction table
    b = gammaTable[b][2];  // set blue to gamma correction table

    float pixel_watts = map(r + g + b, 0, 768, 0, 0.24);  // get the wattage of the pixel
    watts += pixel_watts; // add pixel wattage to total wattage count (watts is added to WALL_WATTS in wall tab)

    return color(g, r, b); // translate the 24 bit color from RGB to the actual order used by the LED wiring.  GRB is the most common.
  }

  // Mostly your code. Added some error checking and timing
  // --------------------------------------------------------------
  // converts an image to OctoWS2811's raw data format.
  // The number of vertical pixels in the image must be a multiple
  // of 8.  The data array must be the proper size for the image.
  void update(PImage image) { 
    proc_time = 0;        // reset processing time
    watts = 0;            // reset watts
    int stime = millis(); // start processing time

    // check to make sure the image matches the teensy settings
    if (led_width * led_height != image.pixels.length) {
      println("The image you're trying send do not match your teensy settings!!");
      println("Image size: " + image.width + "x" + image.height);
      println("Teensy size" + led_width + "x" + led_height);
      exit();
    }

    int offset = 3;
    int x, y, xbegin, xend, xinc, mask;
    int pixel[] = new int[8];

    for (y = 0; y < lines_per_pin; y++) {
      if ((y & 1) == (led_layout ? 0 : 1)) {
        // even numbered rows are left to right
        xbegin = 0;
        xend = image.width;
        xinc = 1;
      } 
      else {
        // odd numbered rows are right to left
        xbegin = image.width - 1;
        xend = -1;
        xinc = -1;
      }
      for (x = xbegin; x != xend; x += xinc) {
        for (int i=0; i < 8; i++) {
          // fetch 8 pixels from the image, 1 for each pin
          pixel[i] = image.pixels[x + (y + lines_per_pin * i) * image.width];
          pixel[i] = processPixel(pixel[i]);
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
    proc_time = millis() - stime;
    max_proc = max(proc_time, max_proc);
  }

  void sendData() {
    send_time = 0;                  // reset send time
    int stime = millis();           // get the start time
    port.write(data);               // send data over serial to teensy
    send_time = millis() - stime;   // set the send time
    max_send = max(send_time, max_send);
  }

  void send(PImage image) {
    update(image);  // update data array

    // no sync, see "SimpleDisplay.ino" for more details
    data[0] = '#';  
    data[1] = 0; 
    data[2] = 0; 

    sendData();     // send the data array
  }
}


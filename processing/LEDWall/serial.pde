import processing.serial.*;

final int SERIAL_PORTS = 10;
final int SERIAL_WIDTH = 80;
final int SERIAL_HEIGHT = 16;


int portNumber = 0;

int errorCount = 0;
//boolean[] ledLayout = new boolean[SERIAL_PORTS];
byte[][] ledData =  new byte[10][(SERIAL_WIDTH * SERIAL_HEIGHT * 3) + 3];

Serial[] ledSerial;

void setupSerial() {
  println("SERIAL - starting setup...");
  ledSerial = new Serial[SERIAL_PORTS];
  String[] list = Serial.list();
  delay(20);
  println("Serial Ports List:");
  println(list);
  serialConfigure("COM3"); 
  if (errorCount > 0) exit();
  println();
  println("SERIAL SETUP ...");
}

// ask a Teensy board for its LED configuration, and set up the info for it.
void serialConfigure(String portName) {
  if (portNumber >= SERIAL_PORTS) {
    println("too many serial ports, please increase maxPorts");
    errorCount++;
    return;
  }
  try {
    ledSerial[portNumber] = new Serial(this, portName, 115200);
    if (ledSerial[portNumber] == null) throw new NullPointerException();
    ledSerial[portNumber].write('?');
  } 
  catch (Throwable e) {
    println("Serial port " + portName + " does not exist or is non-functional");
    errorCount++;
    return;
  }
  delay(50);
  String line = ledSerial[portNumber].readStringUntil(10);
  if (line == null) {
    println("Serial port " + portName + " is not responding.");
    println("Is it really a Teensy 3.0 running VideoDisplay?");
    errorCount++;
    return;
  }
  String param[] = line.split(",");
  if (param.length != 12) {
    println("Error: port " + portName + " did not respond to LED config query");
    errorCount++;
    return;
  }
  // only store the info and increase numPorts if Teensy responds properly
  //ledLayout[portNumber] = (Integer.parseInt(param[5]) == 0);
  portNumber++;
}

// image2data converts an image to OctoWS2811's raw data format.
// The number of vertical pixels in the image must be a multiple
// of 8.  The data array must be the proper size for the image.
void image2data(PImage image, byte[] data, boolean layout) {
  int offset = 3;
  int x, y, xbegin, xend, xinc, mask;
  int linesPerPin = image.height / 8;
  int pixel[] = new int[8];
  
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


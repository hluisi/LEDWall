import processing.serial.*;

Serial myPort;   // Serial port of the teensy running the MSGEQ libiray
int lf = 10;     // Line feed character
String in_string = ""; // Serial port in string

void setupSerial() {
  println();
  String thisPort = Serial.list()[0];
  myPort = new Serial(this, thisPort, 115200); 
  myPort.bufferUntil(lf);  // buffer untill line feed
  println();
  println("SERIAL SETUP ...");
}

void serialEvent(Serial p) {
  //println(p.port);
  in_string = p.readString();
  audio.update(in_string);
}

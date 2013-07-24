#include <OctoWS2811.h>

#define LED_WIDTH      80   // number of LEDs horizontally
#define LED_HEIGHT     16   // number of LEDs vertically (must be multiple of 8)
#define LED_LAYOUT     0    // 0 = even rows left->right, 1 = even rows right->left

#define BAUD_RATE 921600 //115200  does nothing???

const int ledsPerStrip = LED_WIDTH * LED_HEIGHT / 8;

DMAMEM int displayMemory[ledsPerStrip*6];
int drawingMemory[ledsPerStrip*6];
elapsedMicros elapsedUsecSinceLastFrameSync = 0;
int timer;

boolean receiving_data = false;
boolean last_data_state = receiving_data;
boolean ledToggle = HIGH;

const int config = WS2811_800kHz; // color config is on the PC side

OctoWS2811 leds(ledsPerStrip, displayMemory, drawingMemory, config);

void setup() {
  pinMode(13, OUTPUT);
  pinMode(12, INPUT_PULLUP); 
  Serial.setTimeout(50);
  Serial.begin(BAUD_RATE);
  leds.begin();
  leds.show();
  timer = millis();
}

void loop() {
  // if we're not receiving data, blink the teensy LED
  if (!receiving_data) {
    checkBlink();
  }
  
  // if we've gone from receiving data to no data, clear the LEDs
  if (last_data_state != receiving_data) {
    last_data_state = receiving_data;  // set the last state
    if (!receiving_data) clearLeds();  // gone from data to no data? 
  }
  
  
  int startChar = 0;            // we set to zero to check if data is coming
  if (Serial.available() > 0) { // are we receiving data?
    startChar = Serial.read();  // if so get the first byte
  }
  
  // when the video application asks, give it all our info
  // for error checking
  if (startChar == '?') {
    Serial.print(LED_WIDTH);
    Serial.write(',');
    Serial.print(LED_HEIGHT);
    Serial.write(',');
    Serial.print(LED_LAYOUT);
    Serial.write(',');
    Serial.print(0);
    Serial.println();
    
  // we have image data
  } else if (startChar == '#') {
    receiving_data = true;
    
    unsigned int unusedField = 0;
    int count = Serial.readBytes((char *)&unusedField, 2);
    if (count != 2) return;
    count = Serial.readBytes((char *)drawingMemory, sizeof(drawingMemory));
    if (count == sizeof(drawingMemory)) {
      digitalWrite(13, HIGH);
      leds.show();
      digitalWrite(13, LOW);
    }
    
  
  // we want the leds cleared
  } else if (startChar == '!') {
    clearLeds();
  
  // no data or junk data
  } else if (startChar >= 0) {
    receiving_data = false;
    if (startChar > 0) Serial.flush();  // junk data, discard unknown characters
  }
}

void clearLeds() {
  // set all pixels to BLACK.  
  digitalWrite(13, HIGH);
  for (int x = 0; x < ledsPerStrip; x++) {
    for (int y = 0; y < 8; y++) {
      leds.setPixel(x + y*ledsPerStrip, 0x000000);
    }
  }
  leds.show();
}

void checkBlink() {
  if (millis() - timer > 1000) {
    ledToggle = !ledToggle;
    digitalWrite(13, ledToggle);
    timer = millis();
  }
} 


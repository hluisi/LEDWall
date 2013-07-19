

#include <OctoWS2811.h>

// The actual arrangement of the LEDs connected to this Teensy 3.0 board.
// LED_HEIGHT *must* be a multiple of 8.  When 16, 24, 32 are used, each
// strip spans 2, 3, 4 rows.  LED_LAYOUT indicates the direction the strips
// are arranged.  If 0, each strip begins on the left for its first row,
// then goes right to left for its second row, then left to right,
// zig-zagging for each successive row.
#define LED_WIDTH      80   // number of LEDs horizontally
#define LED_HEIGHT     16   // number of LEDs vertically (must be multiple of 8)
#define LED_LAYOUT     0    // 0 = even rows left->right, 1 = even rows right->left

// The portion of the video image to show on this set of LEDs.  All 4 numbers
// are percentages, from 0 to 100.  For a large LED installation with many
// Teensy 3.0 boards driving groups of LEDs, these parameters allow you to
// program each Teensy to tell the video application which portion of the
// video it displays.  By reading these numbers, the video application can
// automatically configure itself, regardless of which serial port COM number
// or device names are assigned to each Teensy 3.0 by your operating system.
//#define VIDEO_XOFFSET  0
//#define VIDEO_YOFFSET  0       // display entire image
//#define VIDEO_WIDTH    100
//#define VIDEO_HEIGHT   100

//#define VIDEO_XOFFSET  0
//#define VIDEO_YOFFSET  0     // display upper half
//#define VIDEO_WIDTH    100
//#define VIDEO_HEIGHT   50

#define VIDEO_XOFFSET  0
#define VIDEO_YOFFSET  0    // display lower half
#define VIDEO_WIDTH    80
#define VIDEO_HEIGHT   16


const int ledsPerStrip = LED_WIDTH * LED_HEIGHT / 8;

DMAMEM int displayMemory[ledsPerStrip*6];
int drawingMemory[ledsPerStrip*6];
elapsedMicros elapsedUsecSinceLastFrameSync = 0;

const int config = WS2811_800kHz; // color config is on the PC side

OctoWS2811 leds(ledsPerStrip, displayMemory, drawingMemory, config);

void setup() {
  pinMode(13, OUTPUT);
  Serial.setTimeout(50);
  Serial.begin(57600);
  leds.begin();
  leds.show();
}

void loop() {

  int startChar = Serial.read();
  
  if (startChar == '#') {
    digitalWrite(13, HIGH);
    unsigned int unusedField = 0;
    int count = Serial.readBytes((char *)&unusedField, 2);
    if (count != 2) return;
    count = Serial.readBytes((char *)drawingMemory, sizeof(drawingMemory));
    if (count == sizeof(drawingMemory)) {
      leds.show();
    }
    digitalWrite(13, LOW);
    
  } else if (startChar == '?') {
    // when the video application asks, give it all our info
    // for easy and automatic configuration
    Serial.print(LED_WIDTH);
    Serial.write(',');
    Serial.print(LED_HEIGHT);
    Serial.write(',');
    Serial.print(LED_LAYOUT);
    Serial.write(',');
    Serial.print(0);
    Serial.write(',');
    Serial.print(0);
    Serial.write(',');
    Serial.print(VIDEO_XOFFSET);
    Serial.write(',');
    Serial.print(VIDEO_YOFFSET);
    Serial.write(',');
    Serial.print(VIDEO_WIDTH);
    Serial.write(',');
    Serial.print(VIDEO_HEIGHT);
    Serial.write(',');
    Serial.print(0);
    Serial.write(',');
    Serial.print(0);
    Serial.write(',');
    Serial.print(0);
    Serial.println();

  } else if (startChar >= 0) {
    // discard unknown characters
  }
}


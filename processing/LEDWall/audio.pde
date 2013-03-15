
import toxi.color.*;
import toxi.color.theory.*;
import toxi.util.datatypes.*;

int AUDIO_MODE = 0;

final int AUDIO_MODE_RAW = 0;
final int AUDIO_MODE_SMOOTHED = 1;
final int AUDIO_MODE_BALANCED = 2;

final int BASS = 0;
final int MIDS = 1;
final int TREB = 2;

int COLOR_MODE = 0;

final int COLOR_RAW        = 0;
final int COLOR_SMOOTH     = 1;
final int COLOR_BRIGHT     = 2;
final int COLOR_COMPLEMENT = 3;
final int COLOR_INVERT     = 4;

Audio audio;

void setupAudio() {
  audio = new Audio();
  println("AUDIO SETUP ...");
}

class Audio {

  volatile int[][] EQ_DATA = new int [3][6]; // int mapped audio eq data 
  volatile int VOLUME = 0;                   // audio volume
  volatile int[][] RANGES = new int [3][3];  // bass, mid, and treble
  volatile int[] COLOR = new int [4];

  int LAST_UPDATE = 0;
  int UPDATE_CHECK = 0;

  Audio() {
    // I would make this a static class if processing wasn't so picky about them
  }

  void update(String serial_string) {
    String[] data_string = splitTokens(serial_string);

    for (int i = 0; i < data_string.length - 1; i++) {
      int x = i / 6;
      int y = i % 6;
      EQ_DATA[x][y] = int(data_string[i]);
      //println("X:" + x + " Y:" + y + " I:" + i);
    }
    VOLUME = int(data_string[data_string.length - 1]);  // volume is always last
    updateColor();
    int NOW = millis();
    UPDATE_CHECK = NOW - LAST_UPDATE;
    LAST_UPDATE = NOW;
  }
  
  private void setColors() {
    // map rgb to bass, mids, treb
    float r = map(RANGES[AUDIO_MODE][BASS], 64, 1023, 0, 1);  // map bass to red
    float g = map(RANGES[AUDIO_MODE][MIDS], 64, 1023, 0, 1);  // map mid to green
    float b = map(RANGES[AUDIO_MODE][TREB], 64, 1023, 0, 1);  // map treb to blue
    // create a raw Tcolor use for ref
    TColor raw_color = TColor.newRGB(r,g,b);
    // set the raw color to the color array
    COLOR[COLOR_RAW] = raw_color.toARGB();
    
    // create the smooth color from the raw rgb values
    TColor smooth_color = TColor.newRGB(r,g,b);
    
    // how close to white is the color
    if (smooth_color.saturation() < 0.3) {
      smooth_color.setHue(smooth_color.getClosestHue().getHue());
      //smooth_color.setBrightness(raw_color.brightness());
      //smooth_color.setSaturation(1);
    }
    
    COLOR[COLOR_SMOOTH] = smooth_color.toARGB();
    
    TColor bright_color = TColor.newRGB(r,g,b);
    bright_color = bright_color.analog(bright_color.saturation(), 0.0);
    COLOR[COLOR_BRIGHT] = bright_color.toARGB();
    
    //audio_color.setBrightness(bright);
    
    TColor complement_color = TColor.newRGB(r,g,b);
    complement_color = complement_color.getComplement();
    
    COLOR[COLOR_COMPLEMENT] = complement_color.toARGB();
    
    //audio_color.setHue(hue);
    //audio_color.setSaturation(sat);
    //audio_color.invert();
    
    //COLOR[COLOR_INVERT] = audio_color.toARGB();
    
    
    
  }

  private void updateColor() {
    float r, g, b;
    
    // RAW EQ DATA
    RANGES[0][BASS] = (EQ_DATA[0][0] + EQ_DATA[0][1]) / 2; // create the bass range
    RANGES[0][MIDS] = (EQ_DATA[0][2] + EQ_DATA[0][3]) / 2; // create mid range
    RANGES[0][TREB] = (EQ_DATA[0][4] + EQ_DATA[0][5]) / 2; // create treb range
    
    // SMOOTHED EQ DATA
    RANGES[1][BASS] = (EQ_DATA[1][0] + EQ_DATA[1][1]) / 2; // create the bass range
    RANGES[1][MIDS] = (EQ_DATA[1][2] + EQ_DATA[1][3]) / 2; // create mid range
    RANGES[1][TREB] = (EQ_DATA[1][4] + EQ_DATA[1][5]) / 2; // create treb range
    
    // BALANCED EQ DATA
    RANGES[2][BASS] = (EQ_DATA[2][0] + EQ_DATA[2][1]) / 2; // create the bass range
    RANGES[2][MIDS] = (EQ_DATA[2][2] + EQ_DATA[2][3]) / 2; // create mid range
    RANGES[2][TREB] = (EQ_DATA[2][4] + EQ_DATA[2][5]) / 2; // create treb range
    
    setColors();
    
  }
}



import toxi.color.*;
import toxi.color.theory.*;
import toxi.util.datatypes.*;

int AUDIO_MODE = 0;

final int AUDIO_MODE_RAW = 0;
final int AUDIO_MODE_SMOOTHED = 1;
final int AUDIO_MODE_BALANCED = 2;

final int BASS = 0;
final int MIDD = 1;
final int TREB = 2;

int COLOR_MODE = 0;

final int COLOR_MODE_AUDIO   = 0;
final int COLOR_MODE_NOWHITE = 1;
final int COLOR_MODE_NOBLACK = 2;


MSGEQ audio;

void setupAudio() {
  audio = new MSGEQ();
  println("AUDIO SETUP ...");
}

class MSGEQ {

  volatile int[][] EQ_DATA = new int [3][6];     // int mapped data
  volatile int VOLUME = 0;
  volatile int[][] RANGES = new int [3][3];
  volatile int[] COLOR = new int [3];

  int LAST_UPDATE = 0;
  int UPDATE_CHECK = 0;

  volatile color COLOR_AUDIO, COLOR_NOWHITE, COLOR_NOBLACK;  // used for creating color from the audio data  

  MSGEQ() {
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
    float r = map(RANGES[AUDIO_MODE][BASS], 0, 1023, 0, 255);  // map bass to red
    float g = map(RANGES[AUDIO_MODE][MIDD], 0, 1023, 0, 255);  // map mid to green
    float b = map(RANGES[AUDIO_MODE][TREB], 0, 1023, 0, 255);  // map treb to blue
    
    COLOR_AUDIO = color(r,g,b);
    COLOR[0] = COLOR_AUDIO;
    
    int _eq0 = int(map(audio.EQ_DATA[AUDIO_MODE][0], 0, 1023, 0, 60));
    int _eq1 = int(map(audio.EQ_DATA[AUDIO_MODE][1], 0, 1023, 0, 60));
    int _eq2 = int(map(audio.EQ_DATA[AUDIO_MODE][1], 0, 1023, 0, 60));
    int _eq3 = int(map(audio.EQ_DATA[AUDIO_MODE][3], 0, 1023, 0, 60));
    int _eq4 = int(map(audio.EQ_DATA[AUDIO_MODE][4], 0, 1023, 0, 60));
    int _eq5 = int(map(audio.EQ_DATA[AUDIO_MODE][5], 0, 1023, 0, 60));
    
    int color_shift = _eq0 + _eq1 + _eq2 + _eq3 + _eq4 + _eq5;
    
    color_shift = constrain(color_shift, 0, 360);
    
    TColor col = TColor.newRGB(0,0,255);
    col.rotateRYB(color_shift);
    col.setBrightness(map(audio.VOLUME, 0, 1023, 0, 1));
    COLOR_NOWHITE = col.toARGB();
    COLOR[1] = COLOR_NOWHITE;
    col.setBrightness(map(audio.VOLUME, 0, 1023, 1, 0));
    
    if (audio.VOLUME < 90) {
      COLOR_NOBLACK = color(int(map(audio.VOLUME, 0, 90, 128, 32)));
    } else {
      COLOR_NOBLACK = col.toARGB();
    }
    COLOR[2] = COLOR_NOBLACK;
    
    
    
  }

  private void updateColor() {
    float r, g, b;
    
    // RAW EQ DATA
    RANGES[0][BASS] = (EQ_DATA[0][0] + EQ_DATA[0][1]) / 2; // create the bass range
    RANGES[0][MIDD] = (EQ_DATA[0][2] + EQ_DATA[0][3]) / 2; // create mid range
    RANGES[0][TREB] = (EQ_DATA[0][4] + EQ_DATA[0][5]) / 2; // create treb range
    
    // SMOOTHED EQ DATA
    RANGES[1][BASS] = (EQ_DATA[1][0] + EQ_DATA[1][1]) / 2; // create the bass range
    RANGES[1][MIDD] = (EQ_DATA[1][2] + EQ_DATA[1][3]) / 2; // create mid range
    RANGES[1][TREB] = (EQ_DATA[1][4] + EQ_DATA[1][5]) / 2; // create treb range
    
    // BALANCED EQ DATA
    RANGES[2][BASS] = (EQ_DATA[2][0] + EQ_DATA[2][1]) / 2; // create the bass range
    RANGES[2][MIDD] = (EQ_DATA[2][2] + EQ_DATA[2][3]) / 2; // create mid range
    RANGES[2][TREB] = (EQ_DATA[2][4] + EQ_DATA[2][5]) / 2; // create treb range
    
    setColors();
    
  }
}


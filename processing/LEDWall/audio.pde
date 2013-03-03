int AUDIO_MODE = 0;

final int AUDIO_MODE_RAW = 0;
final int AUDIO_MODE_SMOOTHED = 1;
final int AUDIO_MODE_BALANCED = 2;

MSGEQ audio;

void setupAudio() {
  audio = new MSGEQ();
  println("AUDIO SETUP ...");
}

class MSGEQ {

  volatile int[][] EQ_DATA = new int [3][6];     // int mapped data
  volatile int VOLUME = 0;
  volatile color[] COLORS = new color [3];

  int LAST_UPDATE = 0;
  int UPDATE_CHECK = 0;

  volatile color RAW_COLOR, SMOOTHED_COLOR, BALANCED_COLOR;  // used for creating color from the audio data  

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

  private void updateColor() {
    float r, g, b;
    r = map((EQ_DATA[0][0] + EQ_DATA[0][1]) / 2, 0, 1023, 0, 255);
    g = map((EQ_DATA[0][2] + EQ_DATA[0][3]) / 2, 0, 1023, 0, 255);
    b = map((EQ_DATA[0][4] + EQ_DATA[0][5]) / 2, 0, 1023, 0, 255);
    RAW_COLOR = color(r, g, b);
    COLORS[0] = color(r, g, b);
    r = map((EQ_DATA[1][0] + EQ_DATA[1][1]) / 2, 0, 1023, 0, 255);
    g = map((EQ_DATA[1][2] + EQ_DATA[1][3]) / 2, 0, 1023, 0, 255);
    b = map((EQ_DATA[1][4] + EQ_DATA[1][5]) / 2, 0, 1023, 0, 255);
    SMOOTHED_COLOR = color(r, g, b);
    COLORS[1] = color(r, g, b);
    r = map((EQ_DATA[2][0] + EQ_DATA[2][1]) / 2, 0, 1023, 0, 255);
    g = map((EQ_DATA[2][2] + EQ_DATA[2][3]) / 2, 0, 1023, 0, 255);
    b = map((EQ_DATA[2][4] + EQ_DATA[2][5]) / 2, 0, 1023, 0, 255);
    BALANCED_COLOR = color(r, g, b);
    COLORS[2] = color(r, g, b);
  }
}


import ddf.minim.*;
import ddf.minim.analysis.*;
import toxi.color.*;
import toxi.color.theory.*;
import toxi.util.datatypes.*;

Minim minim;
AudioInput in;
FFT fft;
AverageListener aaudio;

void setupMinim() {
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 512);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.logAverages(9,1);
  fft.window(FFT.HAMMING);
  aaudio = new AverageListener(fft, in);
  //println("Avg size: " + fft.avgSize());
  for(int i = 0; i < fft.avgSize(); i++) {
    println("i:" + i + "  f:" + fft.getAverageCenterFrequency(i) );
    //println("i:" + i + "  f:" + fft.indexToFreq(i));
  }
  println(fft.getBandWidth());
  println(fft.timeSize());
}

//void updateMinim() {
//  fft.forward(in.mix);
//}

void minimTest() {
  buffer.beginDraw();
  buffer.rectMode(CORNERS);
  buffer.background(aaudio.COLOR);
  buffer.fill(255,0,0);
  buffer.stroke(0);
  float w = buffer.width / 9;
  w += w / 22;
  for(int i = 0; i < fft.avgSize() - 3; i++) {
    float v = (20*((float)Math.log10(fft.getAvg(i+2))));
    float h = map(v, -45, 30, buffer.height, 0);
    buffer.rect(i*w, buffer.height, (i*w) + w, h);
  }
  
  //if ( beat.isRange(3,5,2) ) {
  //  buffer.noStroke();
  //  buffer.fill(0,255,0,128);
  //  buffer.ellipse(40,40, 40, 40);
  //}
  
  buffer.stroke(255);
  for (int i = 0; i < 160 - 1; i++) {
    buffer.line(i, 20 + in.left.get(i)*30, i + 1, 20 + in.left.get(i+1)*30);
    buffer.line(i, 60 + in.right.get(i)*30, i + 1, 60 + in.right.get(i+1)*30);
  }
  buffer.endDraw();
}

void stop()
{
  // always close Minim audio classes when you are done with them
  in.close();
  minim.stop();
  kinect.close();
  
  super.stop();
}


class AverageListener implements AudioListener {
  private FFT fft;
  private AudioInput in;
  //private float[] mapped_averages;
  public int[] AVERAGES;
  public color COLOR;// = new int [4];
  public int BASS, MIDS, TREB, VOLUME, RED, GREEN, BLUE;
  
  AverageListener(FFT fft, AudioInput in) {
    this.in = in;
    this.in.mute();
    this.in.addListener(this);
    this.fft = fft;
    
    //mapped_averages = new float [fft.avgSize()];
    AVERAGES = new int [fft.avgSize()];
    //COLOR = color(0);
    BASS = 0;
    MIDS = 0;
    TREB = 0;
    VOLUME = 0;
    RED = 0;
    GREEN = 0;
    BLUE = 0;
  }
  
  private int mapdB(float value) {
    float db_value = 20*((float)Math.log10(value));           // convert to dB
    float float_value = map(db_value,-45,30,0,100);           // map dB to value
    int int_value = int(constrain(round(float_value),0,100)); // constrain it
    return int_value;                                         // return it
  }
  
  private void mapAverages() {
    for ( int i = 0; i < AVERAGES.length; i++) {   
      AVERAGES[i] = mapdB(fft.getAvg(i));                   
    }
  }
  
  private void mapRanges() {
    VOLUME = mapdB(in.mix.level());
    BASS = round((AVERAGES[0] + AVERAGES[1] + AVERAGES[2] + AVERAGES[3]) / 4);
    MIDS = round((AVERAGES[5] + AVERAGES[6] + AVERAGES[7]) / 3);
    TREB = round((AVERAGES[8] + AVERAGES[9] + AVERAGES[10]) / 3); 
  }
  
  private void mapColors() {
    int w1 = int(map(BASS, 0, 100, 0, 120));
    int w2 = int(map(MIDS, 0, 100, 0, 120));
    int w3 = int(map(TREB, 0, 100, 0, 120));
    float b = map(w1+w2+w3, 0, 300, 0, 1);
    
    TColor raw = new TColor(TColor.BLUE);
    raw = raw.getRotatedRYB(w1+w2+w3);
    raw.setBrightness(b);
    COLOR = raw.toARGB();
    
    //pushStyle();
    //colorMode(HSB, 360, 100, 100, 100);
    //COLOR = color(w1+w2+w3,100,b);
    //colorMode(RGB, 255, 255, 255, 255);
    //popStyle();
    
    //RED   = int(map(BASS, 0, 100, 0, 255));
    //GREEN = int(map(MIDS, 0, 100, 0, 255));
    //BLUE  = int(map(TREB, 0, 100, 0, 255));
    //COLOR = color(RED, GREEN, BLUE);
    //TColor raw_color = TColor.newARGB(color(RED, GREEN, BLUE));
    //if (raw_color.saturation() < 0.2) {
    //  raw_color.setHue(raw_color.getClosestHue().getHue());
    //}
    //COLOR = raw_color.toARGB();
    //TColor raw = TColor.newRGB(0,0,1);
    //int v0 = int(map(AVERAGES[0], 0, 100, 0, 36));
    //int v1 = int(map(AVERAGES[1], 0, 100, 0, 36));
    //int v2 = int(map(AVERAGES[2], 0, 100, 0, 36));
    //int v3 = int(map(AVERAGES[3], 0, 100, 0, 36));
    //int v4 = int(map(AVERAGES[4], 0, 100, 0, 36));
    //int v5 = int(map(AVERAGES[5], 0, 100, 0, 36));
    //int v6 = int(map(AVERAGES[6], 0, 100, 0, 36));
    //int v7 = int(map(AVERAGES[7], 0, 100, 0, 36));
    //int v8 = int(map(AVERAGES[8], 0, 100, 0, 36));
    //int v9 = int(map(AVERAGES[9], 0, 100, 0, 36));
    //raw.rotateRYB(v0 + v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9);
    //float bright = map(BASS + MIDS + TREB, 0, 300, 0, 1);
    //raw.setBrightness(bright);
    //COLOR = raw.toARGB();
    
  }
  
  void calcAverages() {
    AVERAGES[0] = mapdB(fft.calcAvg(0,2));
    ///AVERAGES[1] = mapdB(fft.calcAvr(3, 12));
  }
    
  void samples(float[] samps) {
    fft.forward(in.mix.toArray());
    mapAverages();
    mapRanges();
    mapColors();
  }
  
  void samples(float[] sampsL, float[] sampsR) {
    fft.forward(in.mix.toArray());
    mapAverages();
    mapRanges();
    mapColors();
  }
  
}

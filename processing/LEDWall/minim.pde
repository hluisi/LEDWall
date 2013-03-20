import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import toxi.color.*;
import toxi.color.theory.*;
import toxi.util.datatypes.*;

Minim minim;
AudioInput in;
FFT fft;
BeatDetect beat;
AverageListener audio;


void setupMinim() {
  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO, 512);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.logAverages(63,1);
  fft.window(FFT.HANN);
  beat = new BeatDetect();
  beat.setSensitivity(320);
  audio = new AverageListener(fft, in, beat);
  //println("Avg size: " + fft.avgSize());
  for(int i = 0; i < fft.avgSize(); i++) {
    println("i:" + i + "  f:" + round(fft.getAverageCenterFrequency(i)) );
    //println("i:" + i + "  f:" + fft.indexToFreq(i));
  }
  println(fft.getBandWidth());
  println(fft.timeSize());
}

void minimTest() {
  buffer.beginDraw();
  buffer.rectMode(CORNERS);
  buffer.background(audio.COLOR);
  
  float w = buffer.width / 9;
  w += w / 22;
  for(int i = 0; i < fft.avgSize(); i++) {
    buffer.fill(255,0,0);
    buffer.stroke(0);
    float h = map(audio.AVERAGES[i], 0, 255, buffer.height, 0);
    buffer.rect(i*w, buffer.height, (i*w) + w, h);
    buffer.fill(255);
    buffer.text(audio.AVERAGES[i], w, height - 5);
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

void stop() {
  
  kinect.close();
  
  // always close Minim audio classes when you are done with them
  in.close();
  minim.stop();
  
  
  super.stop();
}


class AverageListener implements AudioListener {
  private FFT fft;
  private AudioInput in;
  private BeatDetect beat;
  public int[] AVERAGES;
  //public float[] DIFF;
  private float[] RAW;
  public color COLOR;// = new int [4];
  public int BASS, MIDS, TREB, VOLUME, RED, GREEN, BLUE;
  public float spectrumGain = 1.5;
  private int last_update = millis();
  public int BPM = 0;
  public int bpm_count = 0, sec_count = 0;
  private int[] bpms = new int [15];
  
  
  AverageListener(FFT fft, AudioInput in, BeatDetect beat) {
    this.in = in;
    this.in.mute();
    this.in.addListener(this);
    this.fft = fft;
    this.beat = beat;
    
    //mapped_averages = new float [fft.avgSize()];
    RAW = new float [fft.avgSize()];
    //DIFF = new float [fft.avgSize()];
    AVERAGES = new int [fft.avgSize()];
    COLOR = color(0);
    BASS = 0;
    MIDS = 0;
    TREB = 0;
    VOLUME = 0;
    RED = 0;
    GREEN = 0;
    BLUE = 0;
    for (int i = 0; i < bpms.length; i++) bpms[i] = 0;
  }
  
  //private int mapdB(float value) {
    //float db_value = 20*((float)Math.log10(value));           // convert to dB
    //float float_value = map(db_value,-45,30,0,100);           // map dB to value
    //int int_value = int(constrain(round(float_value),0,100)); // constrain it
  //  int int_value = int(constrain(round(value*spectrumScale),0,255));
   // return int_value;                                         // return it
  //}
  
  private void mapAverages() {
    for ( int i = 0; i < RAW.length; i++) {
      RAW[i] = fft.getAvg(i);
      int value = round(map(RAW[i]*spectrumGain,0,30,0,100));
      value = int(constrain(value,0,100));
      AVERAGES[i] = value;      
    }
    //float raw_max = max(RAW);
    //for ( int i = 0; i < RAW.length; i++) {
    //  DIFF[i] = map(RAW[i], 0, raw_max, 0, 255);
    //}
    
  }
  
  private void mapRanges() {
    VOLUME = round(map(in.mix.level()*256,0,256,0,100));
    BASS = round((RAW[0] + RAW[1] + RAW[2]) / 3);
    MIDS = round((RAW[3] + RAW[4] + RAW[5]) / 3);
    TREB = round((RAW[6] + RAW[7] + RAW[8]) / 3); 
    
  }
  
  private void mapColors() {
    RED   = round(map((RAW[0] + RAW[1] + RAW[2]) / 3, 0, 30, 0, 255));
    GREEN = round(map((RAW[3] + RAW[4] ) / 2, 0, 30, 0, 255));
    BLUE  = round(map((RAW[5] + RAW[6]) / 2, 0, 30, 0, 255)); 
    
    COLOR = color(RED,GREEN,BLUE);
  }
  
  private void mapBPM() {
    int check = millis();
    if (check - last_update > 1000) {
      if (sec_count == bpms.length) {
        sec_count = 0;
      }
      bpms[sec_count] = bpm_count;
      bpm_count = 0;
      sec_count++;
      BPM = (bpms[0]  + bpms[1]  + bpms[2]  + bpms[3]  + bpms[4] + 
             bpms[5]  + bpms[6]  + bpms[8]  + bpms[8]  + bpms[9] + 
             bpms[10] + bpms[11] + bpms[12] + bpms[13] + bpms[14]) * 4;
      last_update = check;
      //println(bpms);
    }
    
    if ( beat.isOnset() ) bpm_count++;
    
  }
  
  boolean isOnBeat() {
    if ( beat.isOnset() ) return true;
    else return false;
  }
    
  void samples(float[] samps) {
    fft.forward(in.mix.toArray());
    beat.detect(in.mix.toArray());
    mapAverages();
    mapRanges();
    mapColors();
    mapBPM();
  }
  
  void samples(float[] sampsL, float[] sampsR) {
    fft.forward(in.mix.toArray());
    beat.detect(in.mix.toArray());
    mapAverages();
    mapRanges();
    mapColors();
    mapBPM();
  }
  
}

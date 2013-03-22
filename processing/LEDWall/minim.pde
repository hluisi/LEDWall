import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import toxi.color.*;
import toxi.color.theory.*;
import toxi.util.datatypes.*;

Minim minim;
AverageListener audio;

void setupMinim() {
  minim = new Minim(this);
  audio = new AverageListener();
  for (int i = 0; i < audio.fft.avgSize(); i++) {
    println("i:" + i + "  f:" + round(audio.fft.getAverageCenterFrequency(i)) );
  }
}

class AverageListener implements AudioListener {
  public AudioInput in;     // audio input
  public FFT fft;           // FFT 
  public BeatDetect beat;   // beat detect

  public color COLOR;
  public int BASS, MIDS, TREB, RED, GREEN, BLUE;

  private int last_update = millis();
  public int BPM = 0;
  public int bpm_count = 0, sec_count = 0;
  private int[] bpms = new int [15];
  AudioSpectrum[] spectrums;
  AudioSpectrum volume;

  AverageListener() {
    in = minim.getLineIn(Minim.MONO, 512);           // create the audio in 
    in.mute();                                       // mute it
    //in.setGain(5);
    in.addListener(this);                            // add this object to listen to the audio in
    fft = new FFT(in.bufferSize(), in.sampleRate()); // create the FFT
    fft.logAverages(63, 1);                           // config the averages 
    fft.window(FFT.HAMMING);                            // shape the FFT buffer window using the HANN method
    beat = new BeatDetect();                         // create a new beat detect 
    beat.setSensitivity(280);                        // set it's sensitivity
    
    spectrums = new AudioSpectrum [ fft.avgSize() ];
    for (int i = 0; i < spectrums.length; i++) {
      spectrums[i] = new AudioSpectrum();
    }
    volume = new AudioSpectrum();
    
    COLOR = color(0);
    BASS = 0;
    MIDS = 0;
    TREB = 0;
    RED = 0;
    GREEN = 0;
    BLUE = 0;
    for (int i = 0; i < bpms.length; i++) bpms[i] = 0;
  }

  private void mapAverages() {
    for ( int i = 0; i < spectrums.length; i++) {
      spectrums[i].set( fft.getAvg(i) );
    }
    volume.set( in.mix.level()*100 );
  }

  private void mapRanges() {
    BASS = round((spectrums[0].value  + spectrums[1].value  + spectrums[2].value ) / 3);
    MIDS = round((spectrums[3].value  + spectrums[4].value  + spectrums[5].value ) / 3);
    TREB = round((spectrums[6].value  + spectrums[7].value  + spectrums[8].value ) / 3);
  }

  private void mapColors() {
    RED   = round(map(( spectrums[0].value + spectrums[1].value ) / 2, 0, 100, 0, 255));
    GREEN = round(map(( spectrums[2].value + spectrums[3].value ) / 2, 0, 100, 0, 255));
    BLUE  = round(map(( spectrums[4].value + spectrums[5].value ) / 2, 0, 100, 0, 255)); 

    COLOR = color(RED, GREEN, BLUE);
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
    }

    if ( beat.isOnset() ) bpm_count++;
  }

  boolean isOnBeat() {
    if ( beat.isOnset() ) return true;
    else return false;
  }

  void close() {
    in.close();
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
    volume.set( in.mix.level() );
  }
}

class AudioSpectrum {
  //final int MAXIMUM_RAW_LEVEL  = 32; // maxium level coming in (guessed from tests)
  final int SMOOTH_BUFFER_SIZE = 3;  // the length of the smooth array
  final int FRAME_TRIGGER      = 60; // how many frames must the peak and low values 
  
  float raw_peak = 0;    // the peak or max level of the spectrum
  float max_peak = 0;
  float raw_base = 9999;    // the base or lowest level of the spectrum
  float raw    = 0;    // the raw level of the spectrum
  //float raw_smoothed = 0;  // the smoothed over time level of the spectrum 
  //float raw_equalized = 0; // the level equalized or mapped between the base and peak levels
  float dB = 0; 
  float spectrumGain = 1.5;

  //float[] smooth_buffer = new float [SMOOTH_BUFFER_SIZE];  // buffer for the smoothed level
  
  int value = 0;
  int peak = 0;

  int peak_count = 0, smooth_count = 0;  // counters for peak, base, and smooth

  boolean lowerPeak = false;  // are we lowering the peak?

  AudioSpectrum() {
    // setup the smooth buffer
    //for (int i = 0; i < smooth_buffer.length; i++) {
    //  smooth_buffer[i] = 0;
    //}
  }

  void set(float v) {
    
    raw = v * spectrumGain; // set raw
    
    
    float peak_check = max(raw_peak, raw); // get the max peak level
    if (peak_check < 1) peak_check = 1;
    
    raw_base = min(raw_base, raw);             // set the min base level

    if (peak_check == raw_peak) peak_count++; // if peak is the same as last time, inc the peak counter
    
    
    
    raw_peak = peak_check;  // now that we know if its the same or not, set it
    max_peak = max(max_peak, raw_peak);

    if (peak_count > FRAME_TRIGGER) {  // is our peak count higher the the trigger?
      lowerPeak = true; // start trying to lower the peak
      peak_count = 0;   // and reset the peak counter
    }

    if (lowerPeak == true && raw < raw_peak) { // should we lower the peak?
      raw_peak -= 0.5;
    } 
    else if (lowerPeak == true && raw >= raw_peak) { // should we stop trying to lower the peak?
      lowerPeak = false;
    }
    
    //if (smooth_count == smooth_buffer.length) smooth_count = 0; // carry over to the start of the smooth buffer with new values
    //smooth_buffer[smooth_count] = raw; // add raw to the smooth buffer
    
    //float smooth = 0;
    //for ( int i = 0; i < smooth_buffer.length; i++) { // add all the values together in the smooth buffer
    //  smooth += smooth_buffer[i];
    //}
    //raw_smoothed = smooth / smooth_buffer.length; // the smoothed value is the sum of all the values in the 
                                              // buffer divided by the size of the buffer
    //raw_equalized = map(raw_smoothed, raw_base, raw_peak, 0, max_peak); // map the eqalize the smoothed level
    //if (raw_equalized < 0) raw_equalized = 0;
    
    dB = 20*((float)Math.log10(raw)); 
    
    value = int(map(raw,  0, max_peak, 0, 100));
    value = int(constrain(value, 0, 100));
    peak  = int(map(raw_peak, 0, max_peak, 0, 100));
    peak = int(constrain(peak, 0, 100));
    
    raw_base += 0.25; // keep trying to raise the base level a small amount every loop 
    max_peak -= 0.05;
    if (max_peak < 24) max_peak = 24;
  }
}


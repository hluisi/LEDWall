// NEED TO ADD COMMENTS

// USING BETA VERSION OF MINIM!!

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

Minim minim;
AverageListener audio;

void setupMinim() {
  minim = new Minim(this);
  audio = new AverageListener();
}

class AverageListener implements AudioListener {
  AudioInput in;     // audio input
  FFT fft;           // FFT 
  BeatDetect beat;   // beat detect

  boolean gotBeat = false, gotMode = false, gotKinect = false;

  int last_update = millis();
  int BPM = 0, check = 0;
  int bpm_count = 0, sec_count = 0;
  int[] bpms = new int [15];
  AudioSpectrum[] averageSpecs, fullSpecs;
  AudioSpectrum volume, bass, mids, treb;
  //Colors colors;

  AverageListener() {
    in = minim.getLineIn(Minim.MONO, 512);           // create the audio in 
    in.mute();                                       // mute it
    in.addListener(this);                            // add this object to listen to the audio in
    fft = new FFT(in.bufferSize(), in.sampleRate()); // create the FFT
    fft.logAverages(63, 1);                          // config the averages 
    fft.window(FFT.HAMMING);                         // shape the FFT buffer window using the HAMMING method
    beat = new BeatDetect();                         // create a new beat detect 
    beat.setSensitivity(280);                        // set it's sensitivity

    averageSpecs = new AudioSpectrum [ fft.avgSize() ];
    fullSpecs = new AudioSpectrum [ fft.specSize() ];
    for (int i = 0; i < averageSpecs.length; i++) averageSpecs[i] = new AudioSpectrum("" + fft.getAverageCenterFrequency(i) + " Hz");
    for (int i = 0; i < fullSpecs.length; i++) fullSpecs[i] = new AudioSpectrum("" + fft.indexToFreq(i) + " Hz");

    volume = new AudioSpectrum("Volume");
    bass   = new AudioSpectrum("Bass");
    mids   = new AudioSpectrum("Mids");
    treb   = new AudioSpectrum("Treb");

    colors = new Colors();

    for (int i = 0; i < bpms.length; i++) bpms[i] = 0;
  }

  void mapSpectrums() {
    for ( int i = 0; i < averageSpecs.length; i++) averageSpecs[i].set( fft.getAvg(i) );
    for ( int i = 0; i < fullSpecs.length; i++) fullSpecs[i].set( fft.getBand(i) );
  }

  void mapRanges() {
    bass.set( (averageSpecs[0].value + averageSpecs[1].value) / 2 );
    mids.set( (averageSpecs[2].value + averageSpecs[3].value) / 2 );
    treb.set( (averageSpecs[4].value + averageSpecs[5].value) / 2 );
    volume.set( in.mix.level()*100 );
  }

  //void mapColors() {
  //  colors.update();
  //}

  void mapBPM() {

    // do we have a beat?
    if ( beat.isOnset() ) {
      bpm_count++; 
      gotBeat = true; 
      gotMode = true; 
      gotKinect = true;
    }

    check = millis();
    if (check - last_update > 1000) {
      if (sec_count == bpms.length) {
        sec_count = 0;
      }
      bpms[sec_count] = bpm_count;
      sec_count++;

      BPM = 0;
      for (int i = 0; i < bpms.length; i++) BPM += bpms[i];
      BPM *= 4;

      bpm_count = 0;
      last_update = check;
    }
  }

  boolean isOnBeat() {
    if ( gotBeat ) {
      gotBeat = false;
      return true;
    } 
    else return false;
  }

  boolean isOnMode() {
    if ( gotMode ) {
      gotMode = false;
      return true;
    } 
    else return false;
  }

  boolean isOnKinect() {
    if ( gotKinect ) {
      gotKinect = false;
      return true;
    } 
    else return false;
  }

  void close() {
    in.close();
  }

  void update(float[] samples) {
    int stime = millis();
    AUDIO_TIME = 0;
    fft.forward(samples);
    beat.detect(samples);
    mapSpectrums();
    mapRanges();
    //mapColors();
    mapBPM();
    AUDIO_TIME = millis() - stime;
    MAX_AUDIO = max(MAX_AUDIO, AUDIO_TIME);
  }



  void samples(float[] samps) {
    if (audioOn) update(samps);
  }

  void samples(float[] sampsL, float[] sampsR) {
    if (audioOn) update(sampsL);
  }
}

class AudioSpectrum {
  final int FRAME_TRIGGER = 40; // how many frames must pass before changing the peak and low values 
  String name;                  // the name of the audio spectrum
  float raw_peak = 0;           // the peak or max level of the spectrum
  float max_peak = 0;           // the current max peak level
  float raw_base = 9999;        // the base or lowest level of the spectrum
  float raw      = 0;           // the raw level of the spectrum
  float dB = 0;                 // current db of the level
  float spectrumGain = 1.5;     // the gain of the level.  No idea id this is right, but it seems to work 
  byte value = 0;               // raw value mapped from 0 to 100
  byte peak = 0;                // current peak
  byte grey = 0;                // level mapped from 0 to 255
  int peak_count = 0;           // counter for smooth
  int smooth_count = 0;         // counter for peak
  float peak_check = 0;         // count before max peak is lowered
  boolean lowerPeak = false;    // are we lowering the peak?

  AudioSpectrum(String name) {
    this.name = name;
  }

  void set(float v) {

    raw = v * spectrumGain; // set raw

    peak_check = max(raw_peak, raw); // get the max peak level
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

    dB = 20*((float)Math.log10(raw)); 

    grey  = (byte) round(map(raw, 0, max_peak, 0, 255));
    grey  = (byte) constrain(grey, 0, 255);

    value = (byte) round(map(raw, 0, max_peak, 0, 100));
    value = (byte) constrain(value, 0, 100);

    peak  = (byte) round(map(raw_peak, 0, max_peak, 0, 100));
    peak  = (byte) constrain(peak, 0, 100);

    raw_base += 0.25; // keep trying to raise the base level a small amount every loop 
    max_peak -= 0.05;
    if (max_peak < 24) max_peak = 24;
  }
}





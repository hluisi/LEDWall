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
  Colors colors;

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
    for (int i = 0; i < averageSpecs.length; i++) averageSpecs[i] = new AudioSpectrum();
    for (int i = 0; i < fullSpecs.length; i++) fullSpecs[i] = new AudioSpectrum();

    volume = new AudioSpectrum();
    bass   = new AudioSpectrum();
    mids   = new AudioSpectrum();
    treb   = new AudioSpectrum();

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

  void mapColors() {
    colors.update();
  }

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
    fft.forward(samples);
    beat.detect(samples);
    mapSpectrums();
    mapRanges();
    mapColors();
    mapBPM();
  }



  void samples(float[] samps) {
    update(samps);
  }

  void samples(float[] sampsL, float[] sampsR) {
    //update();
  }
}

class AudioSpectrum {
  final int FRAME_TRIGGER = 60; // how many frames must the peak and low values 

  float raw_peak = 0;           // the peak or max level of the spectrum
  float max_peak = 0;           // the current max peak level
  float raw_base = 9999;        // the base or lowest level of the spectrum
  float raw    = 0;             // the raw level of the spectrum

  float dB = 0;                 // current db of the level
  float spectrumGain = 1.5;     // the gain of the level.  No idea id this is right, but it seems to 
  // work have spending many hours of tail and error on it. 

  int value = 0;                // raw value mapped from 0 to 100
  int peak = 0;                 // current peak

  int peak_count = 0;            // counter for smooth
  int smooth_count = 0;         // counter for peak

  int grey = 0;                 // level mapped from 0 to 255

  float peak_check = 0;         // count before max peak is lowered

  boolean lowerPeak = false;    // are we lowering the peak?

  AudioSpectrum() {
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

    grey  = round(map(raw, 0, max_peak, 0, 255));
    grey  = (int) constrain(grey, 0, 255);

    value = round(map(raw, 0, max_peak, 0, 100));
    value = (int) constrain(value, 0, 100);

    peak  = round(map(raw_peak, 0, max_peak, 0, 100));
    peak  = (int) constrain(peak, 0, 100);

    raw_base += 0.25; // keep trying to raise the base level a small amount every loop 
    max_peak -= 0.05;
    if (max_peak < 24) max_peak = 24;
  }
}


// class uses audio.averageSpecs to map colors to different arrays
class Colors {
  color[] users;
  color[] reds;
  color[] greens;
  color[] blues;
  color background, grey;

  Colors() {
    reds   = new color [4];
    greens = new color [4];
    blues  = new color [4];
    users  = new color [12];
  }

  color colorMap(int r1, int r2, int g1, int g2, int b1, int b2) {
    int RED   = audio.averageSpecs[r1].grey + audio.averageSpecs[r1].grey / 2;
    int GREEN = audio.averageSpecs[g1].grey + audio.averageSpecs[g2].grey / 2;
    int BLUE  = audio.averageSpecs[b1].grey + audio.averageSpecs[b2].grey / 2; 
    return color(RED, GREEN, BLUE);
  }

  color colorMapBG(int r1, int r2, int g1, int g2, int b1, int b2) {
    int RED   = audio.averageSpecs[r1].grey + audio.averageSpecs[r1].grey / 6;
    int GREEN = audio.averageSpecs[g1].grey + audio.averageSpecs[g2].grey / 6;
    int BLUE  = audio.averageSpecs[b1].grey + audio.averageSpecs[b2].grey / 6; 
    return color(RED, GREEN, BLUE);
  }

  void updateBackground() {
    background = colorMapBG(0, 1, 2, 3, 4, 5);
  }

  void updateGrey() {
    int temp = audio.volume.value + 16;
    if (temp > max_brightness) temp = max_brightness;
    grey = color(temp);
  }

  void updateReds() {
    reds[0] = colorMap(0, 1, 2, 4, 3, 5);
    reds[1] = colorMap(0, 1, 3, 5, 2, 4);
    reds[2] = colorMap(0, 1, 4, 5, 2, 3);
    reds[3] = colorMap(0, 2, 1, 3, 4, 5);
  }

  void updateGreens() {
    greens[0] = colorMap(2, 3, 0, 1, 4, 5);
    greens[1] = colorMap(4, 5, 0, 1, 2, 3);
    greens[2] = colorMap(2, 4, 0, 1, 3, 5);
    greens[3] = colorMap(3, 5, 0, 1, 2, 4);
  }

  void updateBlues() {
    blues[0] = colorMap(2, 3, 4, 5, 0, 1);
    blues[1] = colorMap(4, 5, 2, 3, 0, 1);
    blues[2] = colorMap(2, 4, 3, 5, 0, 1);
    blues[3] = colorMap(3, 5, 2, 4, 0, 1);
  }

  void updateUsers() {
    users[0]  = reds[0];
    users[1]  = greens[0];
    users[2]  = blues[0];
    users[3]  = reds[1];
    users[4]  = greens[1];
    users[5]  = blues[1];
    users[6]  = reds[2];
    users[7]  = greens[2];
    users[8]  = blues[2];
    users[9]  = reds[3];
    users[10] = greens[3];
    users[11] = blues[3];
  }

  void update() {
    updateBackground();
    updateGrey();
    updateReds();
    updateGreens();
    updateBlues();
    updateUsers();
  }

  color get(int i) {
    color rtn_color;
    if (i < 0 || i > 11) rtn_color = grey;
    else rtn_color = users[i];

    if ( brightness(rtn_color) < 16 ) { 
      return color(brightness(audio.colors.grey) + 32);
    } 
    else {
      return rtn_color;
    }
  }
    
}


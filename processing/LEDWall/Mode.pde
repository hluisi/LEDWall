
// a static class for tracking wall modes
class Mode {
  
  int PREVIOUS;
  int CURRENT;
  int start_time;
  
  Mode(int start_mode) {
    PREVIOUS = -1;
    CURRENT = start_mode;
    start_time = millis();
  }
  
  // change the current mode
  void set(int cm) {
    PREVIOUS = CURRENT;    // save the current mode
    CURRENT  = cm;         // set current to new mode
    start_time = millis(); // save start time
  }
  
}

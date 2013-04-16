import controlP5.*;

ControlP5 cp5;
Textarea myTextarea;
Println console;

void setupControl() {
  strokeWeight(1);
  stroke(0);
  cp5 = new ControlP5(this);
  
  cp5.addKnob("Brightness")
    .setPosition( 10, height - 65)
    .setRange(0,255)
    .setValue(255)
    .setRadius(20)
    .setDragDirection(Knob.HORIZONTAL)
    .setColorForeground(color(255))
    .setColorBackground(color(#212121))
    .setColorActive(color(255,255,0))
  ;
  
  myTextarea = cp5.addTextarea("txt")
    .setPosition(210, DEBUG_WINDOW_START + 5)
    .setSize(435, 210)
    .setFont(createFont("", 11))
    .setLineHeight(14)
    .setColor(color(200))
    .setColorBackground(color(#111111))
    .setColorForeground(color(255, 100));
  ;

  console = cp5.addConsole(myTextarea);//
}

public void Brightness(int value) {
  buffer.maxBrightness(value);
}



//void controlEvent(ControlEvent theControlEvent) {
  //if(theControlEvent.isFrom("Brightness")) {
    
    //buffer.maxBrightness( int(theControlEvent.getController().getValue()) );
    
    //colorMin = int(theControlEvent.getController().getArrayValue(0));
    //colorMax = int(theControlEvent.getController().getArrayValue(1));
    //println("range update, done.");
  //}
  
//}


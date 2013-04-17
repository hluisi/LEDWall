import controlP5.*;

ControlP5 cp5;
//Textarea myTextarea;
Println console;
RadioButton r;

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
  
  r = cp5.addRadioButton("modeButton")
        .setPosition(225, DEBUG_WINDOW_START + 10)
        .setSize(40,20)
        .setColorBackground(color(#212121))
        .setColorForeground(color(#515151))
        .setColorActive(color(255))
        .setColorLabel(color(255))
        .setItemsPerRow(5)
        .setSpacingColumn(50)
        .setSpacingRow(20)
        .addItem("Test", 0)
        .addItem("EQ", 1)
        .addItem("UserBG", 2)
        .addItem("Wheel", 3)
        .addItem("Balls", 4)
        .addItem("Spin", 5)
        .addItem("Pulsar", 6)
        .addItem("City", 7)
        .addItem("Atari", 8)
        .addItem("Clips", 9)
        .activate(1)
  ;
  
  for(Toggle t:r.getItems()) {
     t.captionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
     t.captionLabel().setPaddingY(3);
  }
    
  
  /*
  myTextarea = cp5.addTextarea("txt")
    .setPosition(210, DEBUG_WINDOW_START + 5)
    .setSize(435, 210)
    .setFont(createFont("", 11))
    .setLineHeight(14)
    .setColor(color(200))
    .setColorBackground(color(#111111))
    .setColorForeground(color(255, 100));
  ;
  console = cp5.addConsole(myTextarea);
  */

  
}

public void Brightness(int value) {
  buffer.maxBrightness(value);
}

public void modeButton(int v) {
  DISPLAY_MODE = v;
}

//void controlEvent(ControlEvent theControlEvent) {
  //if(theControlEvent.isFrom("Brightness")) {
    
    //buffer.maxBrightness( int(theControlEvent.getController().getValue()) );
    
    //colorMin = int(theControlEvent.getController().getArrayValue(0));
    //colorMax = int(theControlEvent.getController().getArrayValue(1));
    //println("range update, done.");
  //}
  
//}


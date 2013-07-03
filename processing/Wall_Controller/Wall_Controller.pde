/*

 * Check for bluetooth
 * connect to wall
 * request current settings
 * get image
 
 */

import android.util.DisplayMetrics;
DisplayMetrics metrics;

import android.bluetooth.BluetoothAdapter;
import android.content.Intent;

BluetoothAdapter bluetooth;

String density;
String dpi;
String w;
String h;

boolean btOn;

PFont font;

// Gives the result of trying to turn bluetooth on
@Override
protected void onActivityResult(int requestCode, int resultCode, Intent data) {
  if (requestCode==0) {
    if (resultCode == RESULT_OK) {
      btOn = true; // bluetooth is on
    } 
    else {
      btOn = false; // couldn't get the user to turn on bluetooth
    }
  }
}

//void ToastMessage(String txt) {
//  Toast message = Toast.makeText(getApplicationContext(), textToDisplay, Toast.LENGTH_LONG);
//  message.setGravity(Gravity.CENTER, 0, 0);
//  message.show();
//}

void setupBlueTooth() {
  // setup bluetooth
  bluetooth = BluetoothAdapter.getDefaultAdapter();

  if (!bluetooth.isEnabled()) {
    Intent requestBluetooth = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
    startActivityForResult(requestBluetooth, 0);
  } 
  else {
    btOn = true;
  }

  // setuo toast
}


void setup() {
  size(displayWidth, displayHeight);
  orientation(LANDSCAPE);
  smooth();

  setupBlueTooth();

  metrics = new DisplayMetrics();
  getWindowManager().getDefaultDisplay().getMetrics( metrics );

  density = "Density: " + metrics.density;
  dpi = "DPI: " + metrics.densityDpi;
  w = "Width: " + width;
  h = "Height: " + height;

  font = loadFont("Verdana-32.vlw");
  textFont(font, 32);

  //textSize(32);
  println( PFont.list() );
}

void draw() {
  if (bluetooth.isEnabled()) {
    background(10, 255, 30);
  } 
  else {
    background(255, 10, 30);
  }
  fill(0);
  textAlign(CENTER);
  text(density, width/2, 300);
  text(dpi, width/2, 360);
  text(w, width/2, 420);
  text(h, width/2, 480);

  ellipse(mouseX, mouseY, 150, 150);
}


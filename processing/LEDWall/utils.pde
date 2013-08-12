
import java.util.Arrays;
import java.util.Comparator;

Comparator<PVector> PVectorByX;
Comparator<PVector> PVectorByY;
Comparator<PVector> PVectorByZ;

Comparator<User> UserByX;
Comparator<User> UserByY;
Comparator<User> UserByZ;
Comparator<User> UserByI;

int[] fibonacci = { 
  1, 2, 3, 5, 8, 13, 21, 34, 55, 89
};

void setupUtils() {
  PVectorByX = new PVectorXComparator();
  PVectorByY = new PVectorYComparator();
  PVectorByZ = new PVectorZComparator();
  UserByX = new UserXComparator();
  UserByY = new UserYComparator();
  UserByZ = new UserZComparator();
  UserByI = new UserIComparator();
} 

void doBackground() {
  if (aBackOn) buffer.background(colors.background); 
  else buffer.background(0);
}

// multiply a value to the fibonacci (kind of...)
float fib( float v, float s, float e) {
  int i = round( map(v, s, e, 0, 9) );
  return fibonacci[i];
}

int fib( int v, float s, float e) {
  int i = round( map(v, s, e, 0, 9) );
  return fibonacci[i];
}

color getBright(color c) {
  colorMode(HSB, 360, 255, 255);
  c = color(hue(c), 255, 255);
  colorMode(RGB, 255, 255, 255, 255);
  return c;
}

PVector getSingleUser() {
  float x, y;
  if (kinectOn) {
    if (kinect.users != null && kinect.users.length > 0 && kinect.users[0].onScreen() ) {
      x = kinect.users[0].x; 
      y = kinect.users[0].y;
    } 
    else {
      x = buffer.width / 2; 
      y = buffer.height / 2;
    }
  }
  else {
    x = buffer.width / 2; 
    y = buffer.height / 2;
  }
  
  return new PVector(x,y,0);
  
}


// delay() removed so we have to make our own 
void delay(int mil) {
  int d = millis();
  while (millis () - d < mil) {  
    // do nothing
  }
}

String[] getFileNames(String dir, String ext) {
  String thisdir = sketchPath + "/data/" + dir;
  File file = new File(thisdir);
  String[] raw_names = file.list();


  int count = 0;
  for (int i = 0; i < raw_names.length; i++) {
    String[] parts = raw_names[i].split("\\.(?=[^\\.]+$)");
    if (parts[parts.length - 1].equals(ext) == true) count++;
  }

  String[] file_names = new String [count];
  count = 0;
  for (int i = 0; i < raw_names.length; i++) {
    String[] parts = raw_names[i].split("\\.(?=[^\\.]+$)");
    if (parts[parts.length - 1].equals(ext) == true) {
      file_names[count] = thisdir + "/" + raw_names[i];
      count++;
    }
  }

  return file_names;
}

// maps color to volume with a min of 48
color mapByVol(color rgb) {
  int tr = (rgb >> 16) & 0xFF;                         // get the red value of the color
  int tg = (rgb >> 8) & 0xFF;                          // get the green value of the color
  int tb =  rgb & 0xFF;                                // get the blue value of the color
  float r = map(audio.volume.value, 0, 100, 8, tr);  // map the volume to the redness of the color
  float g = map(audio.volume.value, 0, 100, 8, tg);  // map the volume to the greenness of the color
  float b = map(audio.volume.value, 0, 100, 8, tb);  // map the volume to the blueness of the color
  return color(r, g, b);                               // return the new color
}

// To sort PVectors by their X values.
class PVectorXComparator implements Comparator<PVector> {

  public int compare(PVector pv1, PVector pv2) {
    if (pv1.x < pv2.x) return -1;
    else return 1;
  }
}

// To sort PVectors by their Y values.
class PVectorYComparator implements Comparator<PVector> {

  public int compare(PVector pv1, PVector pv2) {
    if (pv1.y < pv2.y) return -1;
    else return 1;
  }
}

// To sort PVectors by their Z values.
class PVectorZComparator implements Comparator<PVector> {

  public int compare(PVector pv1, PVector pv2) {
    if (pv1.z < pv2.z) return -1;
    else return 1;
  }
}


// To sort Users by their X values.
class UserXComparator implements Comparator<User> {

  public int compare(User u1, User u2) {
    if ( !u1.isActive() )  return 1;
    if ( !u2.isActive() )  return -1;
    if (u1.x != u1.x)      return 1;  // u1.x is NaN
    if (u2.x != u2.x)      return -1; // u2.x is NaN
    if (u1.isSet == false) return 1;  // u1 is not active
    if (u2.isSet == false) return -1; // u2 is not active

    if (u1.x < u2.x) return -1;
    else return 1;
  }
}

// To sort Users by their Y values.
class UserYComparator implements Comparator<User> {

  public int compare(User u1, User u2) {
    if ( !u1.isActive() )  return 1;
    if ( !u2.isActive() )  return -1;
    if (u1.y != u1.y)      return 1;  // u1.x is NaN
    if (u2.y != u2.y)      return -1; // u2.x is NaN
    if (u1.isSet == false) return 1;  // u1 is not active
    if (u2.isSet == false) return -1; // u2 is not active

    if (u1.y < u2.y) return -1;
    else return 1;
  }
}

// To sort Users by their Z values.
class UserZComparator implements Comparator<User> {

  public int compare(User u1, User u2) {
    if ( !u1.isActive() )  return 1;
    if ( !u2.isActive() )  return -1;
    if (u1.z != u1.z)      return 1;  // u1.x is NaN
    if (u2.z != u2.z)      return -1; // u2.x is NaN
    if (u1.isSet == false) return 1;  // u1 is not active
    if (u2.isSet == false) return -1; // u2 is not active

    if (u1.z > u2.z) return -1;
    else return 1;
  }
}

// To sort Users by their Z values.
class UserIComparator implements Comparator<User> {

  public int compare(User u1, User u2) {
    if (u1.i < u2.i) return -1;
    else return 1;
  }
}


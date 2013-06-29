
import java.util.Arrays;
import java.util.Comparator;

Comparator<PVector> PVectorByX;
Comparator<PVector> PVectorByY;
Comparator<PVector> PVectorByZ;

Comparator<User> UserByX;
Comparator<User> UserByY;
Comparator<User> UserByZ;
Comparator<User> UserByI;

void setupUtils() {
  PVectorByX = new PVectorXComparator();
  PVectorByY = new PVectorYComparator();
  PVectorByZ = new PVectorZComparator();
  UserByX = new UserXComparator();
  UserByY = new UserYComparator();
  UserByZ = new UserZComparator();
  UserByI = new UserIComparator();
} 

String[] getFileNames(String dir, String ext) {
  String thisdir = sketchPath + "\\data\\" + dir;
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
      file_names[count] = thisdir + "\\" + raw_names[i];
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
  float r = map(audio.volume.value, 48, 255, 48, tr);  // map the volume to the redness of the color
  float g = map(audio.volume.value, 48, 255, 48, tg);  // map the volume to the greenness of the color
  float b = map(audio.volume.value, 48, 255, 48, tb);  // map the volume to the blueness of the color
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

    if (u1.z < u2.z) return -1;
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


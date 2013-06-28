// ADD COMMENTS

import java.util.Arrays;
import java.util.Comparator;

Comparator<PVector> PVectorByX = new PVectorXComparator();
Comparator<PVector> PVectorByY = new PVectorYComparator();
Comparator<PVector> PVectorByZ = new PVectorZComparator();

Comparator<User> UserByX = new UserXComparator();
Comparator<User> UserByY = new UserYComparator();
Comparator<User> UserByZ = new UserZComparator();
Comparator<User> UserByI = new UserIComparator();


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


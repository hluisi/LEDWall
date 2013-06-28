// DONE WITH REWRITE, STILL NEEDS A FEW COMMENTS


import SimpleOpenNI.*;
import java.util.Map;


final int KINECT_WIDTH  = 640;
final int KINECT_HEIGHT = 320;

PImage transparent;
MyKinect kinect;
volatile HashMap<Integer, User> userHash;

void setupKinect() {
  println("KINECT - starting setup...");

  transparent = createImage(KINECT_WIDTH, KINECT_HEIGHT, ARGB);
  transparent.loadPixels();
  for (int i = 0; i < transparent.pixels.length; i++) {
    transparent.pixels[i] = color(0, 0, 0, 0);
  }
  transparent.updatePixels();

  SimpleOpenNI.start();
  kinect  = new MyKinect(this); 
  kinect.context.update();
  userHash = new HashMap<Integer, User>();

  println("KINECT - setup finished!");
}


public void onNewUser(int userId) {
  println("KINECT - onNewUser - found new user: " + userId);
  println(" - starting pose detection");
  kinect.context.requestCalibrationSkeleton(userId, true);
  userHash.put( userId, new User(userId) );
  println(" - added user " + userId + " to hash table");
  userHash.get(userId).setActive(true);
  userHash.get(userId).update();
}

public void onLostUser(int userId) {
  println("KINECT - onLostUser - lost user: " + userId);
  userHash.remove(userId);
}

public void onExitUser(int userId) {
  println("KINECT - onExitUser - user " + userId + " has exited.");
  userHash.get(userId).setActive(false);
  //println(" - stopping pose detection");
  //kinect.stopPoseDetection(userId);
}

public void onReEnterUser(int userId) {
  println("KINECT - onReEnterUser - user " + userId + " has come back.");
  kinect.context.requestCalibrationSkeleton(userId, true);
  userHash.get(userId).setActive(true);
  //userHash.get(userId).update();


  println(" - starting pose detection");
}


public void onStartCalibration(int userId) {
  println("KINECT - onStartCalibration - starting calibration on user: " + userId);
}

public void onEndCalibration(int userId, boolean successfull) {
  if (successfull) {
    println("KINECT - onEndCalibration - calibration for user " + userId + " was successfull!");
    kinect.context.startTrackingSkeleton(userId);
    userHash.get(userId).setSkeleton(true);
  } 
  else {
    println("KINECT - onEndCalibration - calibration for user " + userId + " has failed!!!");
    userHash.get(userId).setSkeleton(false);
    //println(" - Trying pose detection");
    //kinect.startPoseDetection("Psi", userId);
  }
}

public void onStartPose(String pose, int userId) {
  println("KINECT - onStartPose - userId: " + userId + ", pose: " + pose);

  if (pose.equals("Psi") == true) {
    println(" - stoping pose detection");
    kinect.context.stopPoseDetection(userId); 
    kinect.context.requestCalibrationSkeleton(userId, true);
  }
}

public void onEndPose(String pose, int userId) {
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}


class MyKinect {
  SimpleOpenNI context;         // kinect context
  User[] users;                 // array of user locations
  PImage userImage, depthImage; // user and depth images
  int[] userMap;                // an array of user numbers on a per pixel level
  boolean mapUser = false;      // map the user color to the depth image

    MyKinect(PApplet parent) {
    context = new SimpleOpenNI(parent, SimpleOpenNI.RUN_MODE_MULTI_THREADED);  // init the kinect
    defaults();                     // setup defaults
  }

  private void defaults() {
    userImage = createImage(COLUMNS, ROWS, ARGB);                  // create the user image (size of the wall)
    depthImage = createImage(KINECT_WIDTH, KINECT_HEIGHT, ARGB);   // create depth image (size of the kinect image)
    userImage.loadPixels();   // load the image's pixels
    depthImage.loadPixels();  

    // enable depth
    if (context.enableDepth() == false) {  // enable the depth image
      println("KINECT - ERROR opening the depthMap! Is the kinect connected?!?!");
      exit();
      return;
    }

    // enable user
    if (context.enableUser(SimpleOpenNI.SKEL_PROFILE_NONE) == false) {  // enable user tracking
      println("KINECT - ERROR opening the userMap! Is the kinect connected?!?!");
      exit();
      return;
    }

    //alternativeViewPointDepthToImage();  // fit the depth image to the kinect's RGB image
    context.setMirror(true);             // turn on mirroring
  }

  void updateUsersArray() {
    for (Map.Entry u : userHash.entrySet() ) {  // loop through the user hash table
      userHash.get( u.getKey() ).update();
    }
    users = userHash.values().toArray( new User [userHash.size()] );  // set the users array
    Arrays.sort(users, UserByZ);               // sort the users array by z distance (UserByZ comparator found in utils)
  }

  void updateUsersImage() {
    if (mapUser) {                        // are we mapping the user's depth?
      depthImage = context.depthImage();    // if so get the latest depth image
      depthImage.loadPixels();
    }

    userMap = context.getUsersPixels(SimpleOpenNI.USERS_ALL);  // get the userMap (it's n 2D array of user numbers for each pixel)

    // loop through the users and set their image pixels
    for (int i = 0; i < KINECT_WIDTH * KINECT_HEIGHT; i++) {          // loop through the part of the user map 
      User this_user = userHash.get(userMap[i]);                      // get the current user
      if (this_user != null) {                                        // do we have a user?
        if (mapUser) {                                                // do we map the user's brightness?
          int tr = (this_user.c >> 16) & 0xFF;                        // get the red value of the user's color
          int tg = (this_user.c >> 8) & 0xFF;                         // get the green value of the user's color
          int tb =  this_user.c & 0xFF;                               // get the blue value of the user's color
          float depth_brightness = brightness(depthImage.pixels[i]);  // get the brightness from the user depth image
          float r = map(depth_brightness, 0, 255, 0, tr);             // map brightness from depth image to the red of the user color
          float g = map(depth_brightness, 0, 255, 0, tg);             // map brightness from depth image to the green of the user color
          float b = map(depth_brightness, 0, 255, 0, tb);             // map brightness from depth image to the blue of the user color
          this_user.setPixel(i, color(r, g, b) );                       // set user's pixel using new color
        } 
        else {
          this_user.setPixel(i);                                      // set user's pixel using the user's own color
        }
      }
    }
  }

  void update() {
    context.update();    // update the kinect
    updateUsersArray();  // update the user array
    updateUsersImage();  // update user images
  }

  void drawImages() {
    for (int i = 0; i < users.length; i++) {
      users[i].updatePixels();
      buffer.image(users[i].img, 0, 0);
    }
  }

  void draw() {
    update();
    drawImages();
  }

  void close() {
    context.close();
  }
}

class User extends PVector {
  int i;
  boolean active;
  boolean skeleton;
  boolean isSet;
  PImage img, buffer_image;
  int colorIndex;
  color c;

  User(int i, float x, float y, float z) {
    super(x, y, z);
    this.i = i;
    setup();
  }

  User(int i, float x, float y) {
    super(x, y);
    this.i = i;
    setup();
  }

  User(int i) {
    super();
    this.i = i;
    setup();
  }

  void setup() {
    buffer_image = createImage(KINECT_WIDTH, KINECT_HEIGHT, ARGB);
    buffer_image.loadPixels();
    arrayCopy(transparent.pixels, buffer_image.pixels);
    buffer_image.updatePixels();
    img = createImage(COLUMNS, ROWS, ARGB);
    img.loadPixels();
    colorIndex = i % 12;
  }

  void resetPixels() {
    arrayCopy(transparent.pixels, buffer_image.pixels);
    buffer_image.updatePixels();
  }

  void setPixel(int index, color new_color) {
    if (index > 0 && index < buffer_image.pixels.length) {
      buffer_image.pixels[index] = new_color;
    }
  }

  void setPixel(int index) {
    if (index > 0 && index < buffer_image.pixels.length) {
      buffer_image.pixels[index] = c;
    }
  }

  void updatePixels() {
    buffer_image.updatePixels();
    img.copy(buffer_image, 0, 0, KINECT_WIDTH, KINECT_HEIGHT, 0, 0, COLUMNS, ROWS);
  }

  boolean onScreen() {
    return isSet;
  }

  boolean isActive() {
    return active;
  }

  void setActive(boolean a) {
    active = a;
  }

  boolean hasSkeleton() {
    return skeleton;
  }

  void setSkeleton(boolean a) {
    skeleton = a;
  }

  void setIndex(int i) {
    this.i = i;
  }

  int index() {
    return i;
  }

  void setColor() {
    c = audio.colors.get(colorIndex);
  }

  void update() {
    PVector realWorld = new PVector();
    PVector projWorld = new PVector();

    if ( kinect.context.getCoM(i, realWorld) && active == true ) {        // try to set real world location
      kinect.context.convertRealWorldToProjective(realWorld, projWorld);  // convert real world to projected world
      projWorld.x /= 4; // the kinect X size is 640 pixels, so divide by 4 to fit on the wall's 160 pixels
      projWorld.y /= 6; // the kinect Y size is 480 pixels, so divide by 4 to fit on the wall's 80 pixels
      projWorld.z /= 4; // because i can... 
      set(projWorld);   // set the vector
      if ( x != x || y != y || z != z) {    // check for NaN
        isSet = false;  // got NaN so we're not set
      } 
      else {
        resetPixels();
        setColor();
        isSet = true;   // everything is set
      }
    } 
    else {
      isSet = false;    // couldn't get CoM so nothing is set.
    }
  }
}





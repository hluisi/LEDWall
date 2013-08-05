// DONE WITH REWRITE, STILL NEEDS A FEW COMMENTS

import SimpleOpenNI.*;  // import simple open ni
import java.util.Map;   // import hash map

final int KINECT_WIDTH  = 640;  // the x size of the kinect's depth image
final int KINECT_HEIGHT = 320;  // the y size of the kinect's depth image 
// the y is really 480, but we need a 2:1 format of the image

PImage transparent;  // a transparent image used to reset the user images       
Kinect kinect;     // the kinect object

volatile HashMap<Integer, User> userHash; // user hash map

////////////////////////////////////////////////////////
// Kinect setup function - setupKinect
////////////////////////////////////////////////////////
// setup the kinect
void setupKinect() {
  println("SETUP - setting up KINECT...");
  transparent = createImage(KINECT_WIDTH, KINECT_HEIGHT, ARGB); // create the transparent image
  transparent.loadPixels();                                     // load it's pixels
  for (int i = 0; i < transparent.pixels.length; i++) {         // loop through the image pixels
    transparent.pixels[i] = color(0, 0, 0, 0);                  // and set them all to transparent
  }
  transparent.updatePixels();                                   // finalize (update) the image pixels
  SimpleOpenNI.start();                      // tell simpleOpenNI to start
  kinect  = new Kinect(this);                // create the kinect object
  kinect.context.update();                   // updating the kinect now helps things to load faster 
  userHash = new HashMap<Integer, User>();   // init the user hash table
}

////////////////////////////////////////////////////////
// Kinect object class - Kinect
////////////////////////////////////////////////////////
// This class sets up and creates the main kinect object
class Kinect {
  SimpleOpenNI context;         // kinect context
  User[] users;                 // an array of users (this class tracks user locations and creates user images)
  int[] depthMap;               // depth image used for mapping user depths
  int[] userMap;                // an array of user numbers on a per pixel level
  boolean mapUser = false;      // map the user color to the depth image

    Kinect(PApplet parent) {
    context = new SimpleOpenNI(parent, SimpleOpenNI.RUN_MODE_MULTI_THREADED);  // init the kinect
    //context = new SimpleOpenNI(parent, SimpleOpenNI.RUN_MODE_SINGLE_THREADED);  // init the kinect
    defaults();                     // setup defaults
  }

  private void defaults() {

    // enable depth
    if (context.enableDepth() == false) {  // enable the depth image
      println("KINECT - ERROR opening the depthMap! Is the kinect connected?!?!");
      exit();
      return;
    }

    //context.enableRGB();

    // enable user
    if (context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL) == false) {  // enable user tracking
      println("KINECT - ERROR opening the userMap! Is the kinect connected?!?!");
      exit();
      return;
    }

    //alternativeViewPointDepthToImage();  // fit the depth image to the kinect's RGB image
    context.setMirror(true);             // turn on mirroring
  }

  synchronized void updateUsersArray() {
    for (Map.Entry u : userHash.entrySet() ) {  // loop through the user hash table
      User thisUser = userHash.get( u.getKey() );
      if ( thisUser != null ) {
        if ( thisUser.isActive() ) {
          thisUser.update();
        } 
        else {
          //thisUser.resetPixels();
          thisUser.isSet = false;
        }
      }
    }
    users = userHash.values().toArray( new User [userHash.size()] );  // set the users array
    Arrays.sort(users, UserByZ);               // sort the users array by z distance (UserByZ comparator found in utils)
  }

  void updateUsersImage() {
    if (mapUser) depthMap = context.depthMap();
    userMap  = context.getUsersPixels(SimpleOpenNI.USERS_ALL);  // get the userMap (it's n 2D array of user numbers for each pixel)

    // loop through the users and set their image pixels
    for (int i = 0; i < KINECT_WIDTH * KINECT_HEIGHT; i++) {          // loop through the part of the user map 
      User thisUser = userHash.get(userMap[i]);                       // get the current user
      if ( thisUser != null && thisUser.isActive() && thisUser.onScreen() ) {                // do we have a user?
        if (mapUser) thisUser.setPixel(i, depthMap[i]); 
        else thisUser.setPixel(i, 0);         // set user's pixel using the user's own color
      }
    }
  }


  void update() {
    context.update();    // update the kinect
    updateUsersArray();  // update the user array
    updateUsersImage();  // update user images
  }

  void drawImages() {
    buffer.pushStyle();
    for (int i = 0; i < users.length; i++) {
      if ( users[i].onScreen() ) {
        users[i].updatePixels(mapUser);
        buffer.image(users[i].img, 0, 0);
        buffer.fill(255);
        if (debugOn) buffer.text(users[i].i, users[i].x, users[i].y);
      }
    }
    buffer.fill(255);
    if (debugOn) {
      buffer.textAlign(CENTER, CENTER);
      buffer.text(users.length, COLUMNS - 5, ROWS - 7);
    }
    buffer.popStyle();
  }

  void draw() {
    update();
    drawImages();
  }

  void close() {
    context.close();
  }
}

class User {
  float x = 0.0;
  float y = 0.0;
  float z = 0.0;
  PVector realWorld;
  PVector projWorld;
  PVector headJoint;
  int i;
  boolean active;
  boolean skeleton;
  boolean isSet;
  PImage img, userImage;
  int[] depthMap;
  int depthMAX, depthMIN;
  int colorIndex;
  color c;

  User(int i) {
    this.i = i;
    setup();
  }

  void setup() {
    userImage = createImage(KINECT_WIDTH, KINECT_HEIGHT, ARGB);
    userImage.loadPixels();
    arrayCopy(transparent.pixels, userImage.pixels);
    userImage.updatePixels();
    img = createImage(COLUMNS, ROWS, ARGB);
    img.loadPixels();
    colorIndex = i % 12;
    depthMap = new int [userImage.pixels.length];
    depthMAX = 0;
    depthMIN = 9000;
    realWorld = new PVector();
    projWorld = new PVector();
    headJoint = new PVector();
  }

  void resetPixels() {
    arrayCopy(transparent.pixels, userImage.pixels);
    userImage.updatePixels();
    depthMAX = 0;
    depthMIN = 9000;
  }

  void setPixel(int index, int depth) {
    if (index > 0 && index < userImage.pixels.length) {
      userImage.pixels[index] = c;
      depthMap[index] = depth;
      depthMAX = max(depth, depthMAX);
      depthMIN = min(depth, depthMIN);
    }
  }

  void copyImage() {
    userImage.updatePixels();
    img.copy(userImage, 0, 0, KINECT_WIDTH, KINECT_HEIGHT, 0, 0, COLUMNS, ROWS);
  }
  
  void updatePixels(boolean mapDepth) {
    if (mapDepth) {
      MAP_TIME = 0;
      int stime = millis();
      pushStyle();
      colorMode(HSB, 360, 1.0, 1.0);
      color tc = color(hue(c), 1.0, 1.0);
      popStyle();
      int tr = (tc >> 16) & 0xFF;  // get the red value of the user's color
      int tg = (tc >> 8) & 0xFF;   // get the green value of the user's color
      int tb =  tc & 0xFF;         // get the blue value of the user's color
      
      for (int i = 0; i < userImage.pixels.length; i++) {
        if (userImage.pixels[i] == 0) continue;
        float r = map(depthMap[i], depthMAX, depthMIN, 16, tr);  // map brightness from depth image to the red of the user color
        float g = map(depthMap[i], depthMAX, depthMIN, 16, tg);  // map brightness from depth image to the green of the user color
        float b = map(depthMap[i], depthMAX, depthMIN, 16, tb);  // map brightness from depth image to the blue of the user color
        userImage.pixels[i] = color(r,g,b);
      }
      MAP_TIME = millis() - stime;
      MAX_MAP = max(MAX_MAP, MAP_TIME);
    }
    copyImage();
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

  void updateCoM(PVector projected) {
    // set the user location based on the wall size
    x = projected.x / 4;  // div by 4 because the wall is 4 times 
    y = projected.y / 4;  // smaller then the kinect user image
    z = projected.z / 4;    // bring things closer.  May want to remove this
    
    // check make sure we have real numbers
    if ( x != x || y != y || z != z) {    // checking for NaN
      isSet = false;  // got NaN so we're not set
    } else { // all is good
      resetPixels();
      setColor();
      isSet = true;
    }
  }

  void update() {
    

    if ( kinect.context.getCoM(i, realWorld) ) {        // try to set center of mass real world location
      // let's try to get the head joint, which is better then the CoM
      
      float confidence = kinect.context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_HEAD, headJoint);
      if (confidence < 0.5) {
        // not very good, so lets use the CoM
        skeleton = false; // bad skeleton, bad!
        kinect.context.convertRealWorldToProjective(realWorld, projWorld);  // convert real world to projected world
        updateCoM(projWorld);
      } 
      else { 
        skeleton = true; // good skeley, good boy!
        kinect.context.convertRealWorldToProjective(headJoint, projWorld);  // convert real world to projected world
        updateCoM(projWorld);
      }
      
    } 
    else {
      isSet = false;    // couldn't get CoM so nothing is set.
    }
  }
}


////////////////////////////////////////////////////////
// Kinect User Callback - onNewUser
////////////////////////////////////////////////////////
// called when a new user is found
public void onNewUser(int userId) {
  println("KINECT - onNewUser - found new user: " + userId);
  println(" - starting pose detection");

  kinect.context.requestCalibrationSkeleton(userId, true); // try to auto calibrate user skeleton 
  userHash.put( userId, new User(userId) );                // create new user object and add it to the user hash map
  userHash.get(userId).setActive(true);                    // set the user object as active (so it will be updated)
  userHash.get(userId).update();                           // update the user
}

////////////////////////////////////////////////////////
// Kinect User Callback - onLostUser
////////////////////////////////////////////////////////
// called when user can't be found for 10 seconds. The file
// may be found (PrimeSense\SensorKinect\Data\GlobalDefaultsKinect.ini)
public void onLostUser(int userId) {
  println("KINECT - onLostUser - lost user: " + userId);
  userHash.get(userId).setActive(false);    // set user to non-active status (won't be updated)
  userHash.remove(userId);                  // remove user from the hash table
}

////////////////////////////////////////////////////////
// Kinect User Callback - onExitUser
////////////////////////////////////////////////////////
// called when user leaves the tracking area
public void onExitUser(int userId) {
  println("KINECT - onExitUser - user " + userId + " has exited.");
  userHash.get(userId).setActive(false);    // set user to non-active status (won't be updated)

  // save for now, may want to do pose detection
  //println(" - stopping pose detection");
  //kinect.stopPoseDetection(userId);
}

////////////////////////////////////////////////////////
// Kinect User Callback - onReEnterUser
////////////////////////////////////////////////////////
// called when the user re-enter's the tacking area
public void onReEnterUser(int userId) {
  println("KINECT - onReEnterUser - user " + userId + " has come back.");
  println(" - starting pose detection");
  kinect.context.requestCalibrationSkeleton(userId, true);  // try to auto calibrate user skeleton again
  userHash.get(userId).setActive(true);                     // set to active again (so it will be updated)
}

////////////////////////////////////////////////////////
// Kinect User Callback - onStartCalibration
////////////////////////////////////////////////////////
// called when OpenNi starts the user's skeleton calibration process.
// This can be done from onStartPose to tell OpenNI that the user
// has started a calibration pose, or automaticly by adding true to the
// requestCalibrationSkeleton(userId, true) method.  
public void onStartCalibration(int userId) {
  println("KINECT - onStartCalibration - starting calibration on user: " + userId);
}

////////////////////////////////////////////////////////
// Kinect User Callback - onEndCalibration
////////////////////////////////////////////////////////
// called when OpenNi has ended the skeleton calibration process. 
// it's successfull or it wasn't and you can try using pose detection
// calibrate the skeleton.   
public void onEndCalibration(int userId, boolean successfull) {
  if (successfull) {
    println("KINECT - onEndCalibration - calibration for user " + userId + " was successfull!");
    kinect.context.startTrackingSkeleton(userId); // start tracking skeleton
  } 
  else {
    println("KINECT - onEndCalibration - calibration for user " + userId + " has failed!!!");

    // try standard calibration pose, but it will keep trying util you
    // tell it to stop via the stopPoseDetection(userId) method. 
    //println(" - Trying pose detection");
    //kinect.startPoseDetection("Psi", userId);
  }
}

////////////////////////////////////////////////////////
// Kinect User Callback - onStartPose
////////////////////////////////////////////////////////
// called when OpenNi thinks its found the start of a pose called from
// the startPoseDetection method. You can stop there or start looking
// for the end of the pose, etc...
public void onStartPose(String pose, int userId) {
  println("KINECT - onStartPose - userId: " + userId + ", pose: " + pose);

  if (pose.equals("Psi") == true) {
    println(" - stoping 'Psi' pose detection");
    kinect.context.stopPoseDetection(userId); 
    kinect.context.requestCalibrationSkeleton(userId, true);
  }
}

////////////////////////////////////////////////////////
// Kinect User Callback - onStartPose
////////////////////////////////////////////////////////
// found the end of a pose. Don't forget to stop the pose detection!
public void onEndPose(String pose, int userId) {
  println("onEndPose - userId: " + userId + ", pose: " + pose);
  kinect.context.stopPoseDetection(userId);
}


// DONE WITH REWRITE, STILL NEEDS A FEW COMMENTS


import SimpleOpenNI.*;  // import simple open ni
import java.util.Map;   // import hash map

final boolean USE_KINECT = true;

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

  if (USE_KINECT) {
    SimpleOpenNI.start();                      // tell simpleOpenNI to start
    kinect  = new Kinect(this);                // create the kinect object
    kinect.context.update();                   // updating the kinect now helps things to load faster 
    userHash = new HashMap<Integer, User>();   // init the user hash table
  }
}

////////////////////////////////////////////////////////
// Kinect object class - Kinect
////////////////////////////////////////////////////////
// This class sets up and creates the main kinect object
class Kinect {
  SimpleOpenNI context;         // kinect context
  User[] users;                 // an array of users (this class tracks user locations and creates user images)
  PImage depthImage;            // depth image used for mapping user depths
  int[] userMap;                // an array of user numbers on a per pixel level
  boolean mapUser = false;      // map the user color to the depth image

    Kinect(PApplet parent) {
    context = new SimpleOpenNI(parent, SimpleOpenNI.RUN_MODE_MULTI_THREADED);  // init the kinect
    //context = new SimpleOpenNI(parent, SimpleOpenNI.RUN_MODE_SINGLE_THREADED);  // init the kinect
    defaults();                     // setup defaults
  }

  private void defaults() {
    //userImage = createImage(COLUMNS, ROWS, ARGB);                  // create the user image (size of the wall)
    depthImage = createImage(KINECT_WIDTH, KINECT_HEIGHT, ARGB);   // create depth image (size of the kinect image)
    //userImage.loadPixels();   // load the image's pixels
    depthImage.loadPixels();  

    // enable depth
    if (context.enableDepth() == false) {  // enable the depth image
      println("KINECT - ERROR opening the depthMap! Is the kinect connected?!?!");
      exit();
      return;
    }

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
        } else {
          thisUser.resetPixels();
          thisUser.isSet = false;
        }
      }
    }
    users = userHash.values().toArray( new User [userHash.size()] );  // set the users array
    Arrays.sort(users, UserByZ);               // sort the users array by z distance (UserByZ comparator found in utils)
  }

  void updateUsersImage() {
    if (mapUser) {                        // are we mapping the user's depth?
      depthImage = context.depthImage();    // if so get the latest depth image
      //depthImage.loadPixels();
    }

    userMap = context.getUsersPixels(SimpleOpenNI.USERS_ALL);  // get the userMap (it's n 2D array of user numbers for each pixel)

    // loop through the users and set their image pixels
    for (int i = 0; i < KINECT_WIDTH * KINECT_HEIGHT; i++) {          // loop through the part of the user map 
      User thisUser = userHash.get(userMap[i]);                       // get the current user
      if ( thisUser != null && thisUser.isActive() && thisUser.onScreen() ) {                // do we have a user?
        if (mapUser) {                                                // do we map the user's brightness?
          int tr = (thisUser.c >> 16) & 0xFF;                         // get the red value of the user's color
          int tg = (thisUser.c >> 8) & 0xFF;                          // get the green value of the user's color
          int tb =  thisUser.c & 0xFF;                                // get the blue value of the user's color
          float depth_brightness = brightness(depthImage.pixels[i]);  // get the brightness from the user depth image
          float r = map(depth_brightness, 0, 255, 0, tr);             // map brightness from depth image to the red of the user color
          float g = map(depth_brightness, 0, 255, 0, tg);             // map brightness from depth image to the green of the user color
          float b = map(depth_brightness, 0, 255, 0, tb);             // map brightness from depth image to the blue of the user color
          thisUser.setPixel(i, color(r, g, b) );                      // set user's pixel using new color
        } else {
          thisUser.setPixel(i);                                       // set user's pixel using the user's own color
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
      if ( users[i].onScreen() ) {
        users[i].updatePixels();
        buffer.image(users[i].img, 0, 0);
        buffer.noStroke();
        buffer.fill(255);
        buffer.text(users[i].i, users[i].x, users[i].y);
      }
    }
    buffer.text(users.length, COLUMNS - 20, ROWS - 20);
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
  
  void updateCoM(PVector projected, boolean isHead) {
    // set the user location based on the wall size
    if (isHead) {        // are we tracking the head?
      projected.x /= 4;  // div by 4 because the wall is 4 times 
      projected.y /= 4;  // smaller then the kinect user image
    } else {             // no head, so track CoM
      projected.x /= 4;  // why 6 for y? because we cut off the last third of the kinect's
      projected.y /= 6;  // user image so we need to move the center of mass up a bit.
    }
    projected.z /= 6;    // bring things closer.  May want to remove this
    
    set(projected);      // set the super PVector
    
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
    PVector realWorld = new PVector();
    PVector projWorld = new PVector();

    if ( kinect.context.getCoM(i, realWorld) ) {        // try to set center of mass real world location
      // let's try to get the head joint, which is better then the CoM
      PVector headJoint = new PVector();
      float confidence = kinect.context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_HEAD, headJoint);
      if (confidence < 0.5) {
        // not very good, so lets use the CoM
        skeleton = false; // bad skeleton, bad!
        kinect.context.convertRealWorldToProjective(realWorld, projWorld);  // convert real world to projected world
        updateCoM(projWorld, false);
      } else { 
        skeleton = true; // good skeley, good boy!
        kinect.context.convertRealWorldToProjective(headJoint, projWorld);  // convert real world to projected world
        updateCoM(projWorld, true);
      }
    } else {
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
  } else {
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




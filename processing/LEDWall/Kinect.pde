import SimpleOpenNI.*;

final int KINECT_WIDTH  = 640;
final int KINECT_HEIGHT = 320;
final int KINECT_X_START = 0;
final int KINECT_X_END = KINECT_WIDTH;
final int KINECT_Y_START = 80;
final int KINECT_Y_END = 400;

Kinect kinect;


void setupKinect() {
  println("KINECT - starting setup...");
  kinect  = new Kinect(this, SimpleOpenNI.RUN_MODE_MULTI_THREADED); 

  //kinect  = new Kinect(this,SimpleOpenNI.RUN_MODE_SINGLE_THREADED);
  kinect.update();
  println("KINECT - setup finished!");
}


public void onNewUser(int userId) {
  println("KINECT - onNewUser - found new user: " + userId);
  //println(" - starting pose detection");
  //kinect.requestCalibrationSkeleton(userId, true);
}

public void onLostUser(int userId) {
  println("KINECT - onLostUser - lost user: " + userId);
}

public void onExitUser(int userId) {
  println("KINECT - onExitUser - user " + userId + " has exited.");
  //println(" - stopping pose detection");
  //kinect.stopPoseDetection(userId);
}

public void onReEnterUser(int userId) {
  println("KINECT - onReEnterUser - user " + userId + " has come back.");
  //kinect.requestCalibrationSkeleton(userId, true);
  //println(" - starting pose detection");
}


public void onStartCalibration(int userId) {
  println("KINECT - onStartCalibration - starting calibration on user: " + userId);
}

public void onEndCalibration(int userId, boolean successfull) {
  if (successfull) {
    println("KINECT - onEndCalibration - calibration for user " + userId + " was successfull!");
    kinect.startTrackingSkeleton(userId);
  } else {
    println("KINECT - onEndCalibration - calibration for user " + userId + " has failed!!!");
    println(" - Trying pose detection");
    kinect.startPoseDetection("Psi", userId);
  }
}

public void onStartPose(String pose, int userId) {
  println("KINECT - onStartPose - userId: " + userId + ", pose: " + pose);

  if (pose.equals("Psi") == true) {
    println(" - stoping pose detection");
    kinect.stopPoseDetection(userId); 
    kinect.requestCalibrationSkeleton(userId, true);
  }
}

public void onEndPose(String pose, int userId) {
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}

class Kinect extends SimpleOpenNI {

  PVector user_center = new PVector();

  int[] depth_map;
  int[] user_map;
  int currentUserNumber = -1;
  int numberOfUsers = 0;

  color user_color = color(0);

  boolean mapUser = false;

  PImage buffer_image, depth_image, user_image;

  Kinect(PApplet parent) {
    super(parent);
    defaults();
  }

  Kinect(PApplet parent, int runMode) {
    super(parent, runMode);
    defaults();
  }

  private void defaults() {
    buffer_image = createImage(COLUMNS, ROWS, ARGB);

    // enable depth
    if (enableDepth() == false) {
      println("KINECT - ERROR opening the depthMap! Is the kinect connected?!?!");
      exit();
      return;
    } else {
      depth_image = createImage(KINECT_WIDTH, KINECT_HEIGHT, ARGB);
      depth_image.loadPixels();
      println("KINECT - depth enabled!");
    }

    // enable user
    if (enableUser(SimpleOpenNI.SKEL_PROFILE_NONE) == false) {
      println("KINECT - ERROR opening the userMap! Is the kinect connected?!?!");
      exit();
      return;
    } else {
      user_image = createImage(KINECT_WIDTH, KINECT_HEIGHT, ARGB);
      user_image.loadPixels();
      println("KINECT - user enabled!");
    }

    alternativeViewPointDepthToImage();
    mirrorOn();
  }

  void mirrorOn() {
    setMirror(true);
    println("KINECT - mirroring is now ON ...");
  }

  void mirrorOff() {
    setMirror(false);
    println("KINECT - mirroring is now OFF ...");
  }

  color getUserColor(int index) {
    if ( index >= 12 || brightness(audio.colors.background) < 16 ) {
      return color(brightness(audio.colors.grey) + 16);
    } else {
      return audio.colors.users[index];
    }
  }

  void updateUsers() {
    numberOfUsers = getNumberOfUsers();
    if (numberOfUsers > 0) {
      currentUserNumber = -1;
      user_map = getUsersPixels(SimpleOpenNI.USERS_ALL);

      int user_red = 0, user_green = 0, user_blue = 0;

      if (mapUser) {
        depth_image = depthImage();
      }

      for (int i = 0; i < user_image.pixels.length; i++) {
        if (user_map[i] != 0) {
          currentUserNumber = max(user_map[i], currentUserNumber); // make this better
          int thisUser = user_map[i];

          color c = getUserColor(thisUser);

          if (mapUser) {
            user_red   = (c >> 16) & 0xFF; 
            user_green = (c >> 8) & 0xFF;   
            user_blue  = c & 0xFF;
            float depth_brightness = brightness(depth_image.pixels[i]);
            float r = map(depth_brightness, 0, 255, 0, user_red);
            float g = map(depth_brightness, 0, 255, 0, user_green);
            float b = map(depth_brightness, 0, 255, 0, user_blue);
            user_image.pixels[i] = color(r, g, b);
          } else {
            user_image.pixels[i] = c;
          }
        } else {
          user_image.pixels[i] = color(0, 0, 0, 0);
        }
      }
      user_image.updatePixels();
      buffer_image.copy(user_image, 0, 0, KINECT_WIDTH, KINECT_HEIGHT, 0, 0, COLUMNS, ROWS);
    } 

    if (currentUserNumber == -1) {
      user_center.x = buffer.width / 2; 
      user_center.y = buffer.height / 2;
    } else {
      PVector temp = new PVector();
      if (getCoM(currentUserNumber, temp)) {
        convertRealWorldToProjective(temp, user_center);
        user_center.x /= 4; 
        user_center.y /= 4;
      } else {
        user_center.x = buffer.width / 2; 
        user_center.y = buffer.height / 2;
      }
    }
  }

  void update() {
    super.update();
    //updateColors();
    updateUsers();
  }
}


import SimpleOpenNI.*;

final int KINECT_WIDTH = 640;
final int KINECT_HEIGHT = 480;
final int BUFFER_WIDTH  = 640;
final int BUFFER_HEIGHT = 320;

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
  final int KINECT_X_START = 0;
  final int KINECT_X_END = BUFFER_WIDTH;
  final int KINECT_Y_START = 0;
  final int KINECT_Y_END = BUFFER_HEIGHT;

  int mode = 0;

  final int MODE_DEPTH      = 0;
  final int MODE_USERSBLACK = 1;
  final int MODE_USERSCOLOR = 2;
  final int MODE_USERSSKELL = 3;
  final int MODE_HANDS      = 4;


  PVector user_center = new PVector();

  int[] depth_map;
  int[] user_map;
  int user_id = -1;
  int rc = 0;

  color user_color = color(0);

  color[] usercolors = new color [12];

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
      depth_image = createImage(BUFFER_WIDTH, BUFFER_HEIGHT, ARGB);
      println("KINECT - depth enabled!");
    }

    // enable user
    if (enableUser(SimpleOpenNI.SKEL_PROFILE_NONE) == false) {
      println("KINECT - ERROR opening the userMap! Is the kinect connected?!?!");
      exit();
      return;
    } else {
      user_image = createImage(BUFFER_WIDTH, BUFFER_HEIGHT, ARGB);
      println("KINECT - user enabled!");
    }

    //alternativeViewPointDepthToImage();
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

  void setUserColors() {
    // map gray
    int temp = audio.volume.value + 32;
    if (temp > buffer.max_brightness) temp = buffer.max_brightness;
    usercolors[0] = color(temp);

    // map red and green
    int RED   = audio.averageSpecs[1].gray;
    int GREEN = audio.averageSpecs[3].gray;
    int BLUE  = audio.averageSpecs[5].gray;

    color test = color(RED, GREEN, BLUE);

    if (brightness(test) > 16) {
      usercolors[1]  = color(RED, GREEN, audio.averageSpecs[5].gray);
      usercolors[2]  = color(audio.averageSpecs[4].gray, GREEN, BLUE);
      usercolors[3]  = color(RED, audio.averageSpecs[4].gray, BLUE);
      usercolors[4]  = color(RED, GREEN, audio.averageSpecs[4].gray);
      usercolors[5]  = color(audio.averageSpecs[2].gray, GREEN, BLUE);
      usercolors[6]  = color(RED, audio.averageSpecs[2].gray, BLUE);
      usercolors[7]  = color(RED, GREEN, audio.averageSpecs[2].gray);
      usercolors[8]  = color(audio.averageSpecs[0].gray, GREEN, BLUE);
      usercolors[9]  = color(RED, audio.averageSpecs[0].gray, BLUE);
      usercolors[10] = color(RED, GREEN, audio.averageSpecs[0].gray);
      usercolors[11] = usercolors[0];
    } else {
      java.util.Arrays.fill(usercolors, usercolors[0]);
    }
  }

  void updateUsers() {
    if (getNumberOfUsers() > 0) {
      user_id = -1;
      user_map = getUsersPixels(SimpleOpenNI.USERS_ALL);

      user_image.loadPixels();

      int user_red = 0, user_green = 0, user_blue = 0;

      if (mapUser) {
        depth_image = depthImage();
      }

      for (int i = 0; i < user_image.pixels.length; i++) {
        if (user_map[i] != 0) {
          user_id = max(user_map[i], user_id);
          int current_user = user_map[i];

          if ( user_map[i] >= 11 ) current_user = 11;

          color c = usercolors[current_user];

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
            user_image.pixels[i] = color(c);
          }
        } else {
          user_image.pixels[i] = color(0, 0, 0, 0);
        }
      }
      user_image.updatePixels();
      buffer_image.copy(user_image, 0, 0, BUFFER_WIDTH, BUFFER_HEIGHT, 0, 0, COLUMNS, ROWS);
    } 

    if (user_id == -1) {
      user_center.x = buffer.width / 2; 
      user_center.y = buffer.height / 2;
    } else {
      PVector temp = new PVector();
      if (getCoM(user_id, temp)) {
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
    setUserColors();
    updateUsers();
  }
}


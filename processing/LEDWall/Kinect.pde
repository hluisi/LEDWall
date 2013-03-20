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

void doKinect() {
  kinect.setDepthImageColor(audio.COLOR);
  kinect.bufferDepth();
  buffer.beginDraw();
  buffer.background(0);
  buffer.pushStyle();
  //buffer.tint(audio.COLOR[COLOR_MODE]);
  buffer.image(kinect.buffer_image, 0, 0);
  buffer.popStyle();
  buffer.endDraw();
  //kinect.display();
}


public void onNewUser(int userId) {
  println("KINECT - onNewUser - found new user: " + userId);
  println(" - starting pose detection");
  kinect.requestCalibrationSkeleton(userId, true);
}

public void onLostUser(int userId) {
  println("KINECT - onLostUser - lost user: " + userId);
  
  
}

public void onExitUser(int userId) {
  println("KINECT - onExitUser - user " + userId + " has exited.");
  println(" - stopping pose detection");
  kinect.stopPoseDetection(userId);
}

public void onReEnterUser(int userId) {
  println("KINECT - onReEnterUser - user " + userId + " has come back.");
  kinect.requestCalibrationSkeleton(userId, true);
  println(" - starting pose detection");
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
  final int MODE_IRCAMERA   = 1;
  final int MODE_USERSCOLOR = 2;
  final int MODE_USERSBLACK = 3;
  final int MODE_USERSSKELL = 4;
  final int MODE_HANDS      = 5;


  PVector user_center = new PVector();

  int[] depth_map;
  int[] user_map;
  int user_id = -1;

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
    } 
    else {
      depth_image = createImage(BUFFER_WIDTH, BUFFER_HEIGHT, ARGB);
      println("KINECT - depth enabled!");
    }

    // enable IR
    //if (enableIR() == false) {
    //  println("KINECT - ERROR opening the IR Camera! Is the kinect connected?!?!");
    //  exit();
    //  return;
    //} 
    //else {
      //depth_image = createImage(BUFFER_WIDTH, BUFFER_HEIGHT, ARGB);
    //  println("KINECT - IR enabled!");
    //}

    // enable user
    if (enableUser(SimpleOpenNI.SKEL_PROFILE_ALL) == false) {
      println("KINECT - ERROR opening the userMap! Is the kinect connected?!?!");
      exit();
      return;
    } 
    else {
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

  void setDepthImageColor(color c) {
    int r = (c >> 16) & 0xFF;  // Faster way of getting red(argb)
    int g = (c >> 8) & 0xFF;   // Faster way of getting green(argb)
    int b = c & 0xFF;          // Faster way of getting blue(argb)

    super.setDepthImageColor(r, g, b);
  }

  //void updateUser() {


  void updateSingle(color c, boolean map_depth) {
    if (getNumberOfUsers() > 0) {
      user_id = -1;
      user_map = getUsersPixels(SimpleOpenNI.USERS_ALL);
      depth_map = depthMap();

      user_image.loadPixels();
      for (int i = 0; i < user_image.pixels.length; i++) {
        if (user_map[i] != 0) {
          user_id = max(user_map[i], user_id);
          if (map_depth) {
            float bright = brightness(depthImage().pixels[i]);
            float r = map(bright, 0, 255, 0, red(c));
            float g = map(bright, 0, 255, 0, green(c));
            float b = map(bright, 0, 255, 0, blue(c));
            user_image.pixels[i] = color(r, g, b);
          } 
          else {
            user_image.pixels[i] = color(c);
          }
        }
        else {
          user_image.pixels[i] = color(0, 0, 0, 0);
        }
      }
      user_image.updatePixels();
      buffer_image.copy(user_image, 0, 0, BUFFER_WIDTH, BUFFER_HEIGHT, 0, 0, COLUMNS, ROWS);
    } 

    if (user_id == -1) {
      user_center.x = buffer.width / 2; 
      user_center.y = buffer.height / 2;
    } 
    else {
      PVector temp = new PVector();
      if (getCoM(user_id, temp)) {
        convertRealWorldToProjective(temp, user_center);
        user_center.x /= 4; 
        user_center.y /= 4;
      } 
      else {
        user_center.x = buffer.width / 2; 
        user_center.y = buffer.height / 2;
      }
    }
  }

  void updateUser(color c) {
    update();
    updateSingle(c, true);
  }

  void updateUserBlack() {
    update();
    updateSingle(color(0), false);
  }

  void updateUserAudio() {
    update();
    updateSingle(audio.COLOR, false);
  }



  //void bufferUserColor() {


  void bufferIR() {
    update();
    buffer_image.copy(irImage(), 0, 0, BUFFER_WIDTH, BUFFER_HEIGHT, 0, 0, COLUMNS, ROWS);
  }

  void bufferDepth() {
    update();
    buffer_image.copy(depthImage(), 8, 4, BUFFER_WIDTH, BUFFER_HEIGHT, 0, 0, COLUMNS, ROWS);
  }

  //void update() {
  //super.update();
  //if (mode == MODE_DEPTH) bufferDepth();
  //}

  void display() {
    //displayDepth();
  }
}


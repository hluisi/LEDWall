import SimpleOpenNI.*;

final int KINECT_WIDTH = 640;
final int KINECT_HEIGHT = 480;
final int BUFFER_WIDTH  = 640;
final int BUFFER_HEIGHT = 320;

Kinect kinect;

void setupKinect() {
  kinect  = new Kinect(this,SimpleOpenNI.RUN_MODE_MULTI_THREADED); 
  kinect.update();
  println("KINECT SETUP ...");
}

void doKinect() {
  kinect.display();
}

void onNewUser(int userId) {
  println("New User Detected - userId: " + userId);
  //if (kinect.getNumberOfUsers() > 1) kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_NONE);
  //float[] mtest;
  //kinect.getUserCoordsys(mtest);
  //println(mtest);
}

void onLostUser(int userId) {
  println("User Lost - userId: " + userId);
}

void onExitUser(int userId) {
  println("User " + userId + " is off screen");
}

class Kinect extends SimpleOpenNI {
  final int KINECT_X_START = 0;
  final int KINECT_X_END = BUFFER_WIDTH;
  final int KINECT_Y_START = 0;
  final int KINECT_Y_END = BUFFER_HEIGHT;

  PVector user_center = new PVector();

  int[] depth_map;
  int[] user_map;
  int user_id = 99999;

  PImage current_image, depth_image, user_image;

  Kinect(PApplet parent) {
    super(parent);
    setup();
  }

  Kinect(PApplet parent, int runMode) {
    super(parent, runMode);
    setup();
  }

  private void setup() {
    current_image = createImage(COLUMNS, ROWS, ARGB);
    depth_image   = createImage(KINECT_X_END, KINECT_Y_END, ARGB);
    user_image    = createImage(KINECT_X_END, KINECT_Y_END, ARGB);
    enableDepth();
    println(depthHeight());
    enableUser(SimpleOpenNI.SKEL_PROFILE_NONE);
    //alternativeViewPointDepthToImage();
    setMirror(true);
  }


  void updateSingle(color c, boolean map_depth) {
    if (getNumberOfUsers() > 0) {
      user_id = 99999;
      user_map = getUsersPixels(SimpleOpenNI.USERS_ALL);
      depth_map = depthMap();

      user_image.loadPixels();
      for (int i = 0; i < user_image.pixels.length; i++) {
        if (user_map[i] != 0) {
          user_id = min(user_map[i], user_id);
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
      current_image.copy(user_image, 0, 0, BUFFER_WIDTH, BUFFER_HEIGHT, 0, 0, COLUMNS, ROWS);
    } 

    if (user_id == 99999) {
      user_center.x = buffer.width / 2; 
      user_center.y = buffer.height / 2;
    } 
    else {
      PVector temp = new PVector();
      getCoM(user_id, temp);
      convertRealWorldToProjective(temp, user_center);
      user_center.x /= 4; 
      user_center.y /= 4;
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
    updateSingle(audio.COLOR[COLOR_MODE], false);
  }

  void drawCurrent() {
    buffer.beginDraw();
    buffer.image(current_image, 0, 0);
    buffer.endDraw();
  }

  void updateDepth() {
    update();
    depthImage().updatePixels();
    //println(depthImage().height);
    arrayCopy(depthImage().pixels, depth_image.pixels, depth_image.pixels.length);
    depth_image.updatePixels();
    //depth_image = depthImage();
  }

  void displayDepth() {
    updateDepth();
    current_image.copy(depth_image, 0, 0, BUFFER_WIDTH, BUFFER_HEIGHT, 0, 0, COLUMNS, ROWS);
    drawCurrent();
  }

  void display() {
    displayDepth();
  }
}


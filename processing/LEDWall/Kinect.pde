import SimpleOpenNI.*;

final int KINECT_WIDTH = 640;
final int KINECT_HEIGHT = 480;

int KINECT_MODE = 0;

final int KINECT_MODE_RGB     = 0;
final int KINECT_MODE_DEPTH = 1;
//final int KINECT_MODE_USER_BLACK = 2;
//final int KINECT_MODE_USER_AUDIO = 3;


Kinect kinect;

void setupKinect() {
  kinect  = new Kinect(this, SimpleOpenNI.RUN_MODE_MULTI_THREADED); 
  kinect.update();
  println("KINECT SETUP ...");
}

void doKinect() {
  kinect.display();
}

//void onNewUser() {
//kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_NONE);
//}

class Kinect extends SimpleOpenNI {
  final int KINECT_X_START = 0;
  final int KINECT_X_END = BUFFER_WIDTH;
  final int KINECT_Y_START = 0;
  final int KINECT_Y_END = BUFFER_HEIGHT;

  PVector user1_center = new PVector();

  int[] scene_map;
  int[] user_map;
  int user_id;

  PImage current_image, rgb_image, depth_image, user_image;

  Kinect(PApplet parent) {
    super(parent);
    setup();
  }

  Kinect(PApplet parent, int runMode) {
    super(parent, runMode);
    setup();
  }

  private void setup() {
    current_image = createImage(KINECT_X_END, KINECT_Y_END, ARGB);
    rgb_image     = createImage(KINECT_X_END, KINECT_Y_END, ARGB);
    depth_image   = createImage(KINECT_X_END, KINECT_Y_END, ARGB);
    user_image    = createImage(KINECT_X_END, KINECT_Y_END, ARGB);
    enableDepth();
    enableRGB();
    enableUser(SimpleOpenNI.SKEL_PROFILE_NONE);
    //alternativeViewPointDepthToImage();
    setMirror(true);
  }

  void useRBG() {
    KINECT_MODE = KINECT_MODE_RGB;
  }

  void useDepth() {
    KINECT_MODE = KINECT_MODE_DEPTH;
  }

  void updateSingle(color c, boolean map_depth) {
    if (getNumberOfUsers() > 0) {
      PVector temp = new PVector();
      getCoM(1, temp);
      convertRealWorldToProjective(temp, user1_center);
      user_map = getUsersPixels(SimpleOpenNI.USERS_ALL);

      user_image.loadPixels();
      for (int i = 0; i < user_image.pixels.length; i++) {
        if (user_map[i] != 0) {
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
      current_image = user_image;
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
    updateSingle(audio.COLORS[AUDIO_MODE], false);
  }

  void drawCurrent() {
    buffer.beginDraw();
    buffer.image(current_image, 0, 0);
    buffer.endDraw();
  }

  void updateRGB() {
    rgbImage().updatePixels();
    arrayCopy(rgbImage().pixels, rgb_image.pixels, rgb_image.pixels.length);
    rgb_image.updatePixels();
  }

  void displayRGB() {
    updateRGB();
    current_image = rgb_image;
    drawCurrent();
  }

  void updateDepth() {
    depthImage().updatePixels();
    arrayCopy(depthImage().pixels, depth_image.pixels, depth_image.pixels.length);
    depth_image.updatePixels();
  }

  void displayDepth() {
    updateDepth();
    current_image = depth_image;
    drawCurrent();
  }

  private void doMode() {
    update();
    if (KINECT_MODE == KINECT_MODE_RGB) displayRGB();
    if (KINECT_MODE == KINECT_MODE_DEPTH) displayDepth();
  }

  void display(int _mode) {
    if (_mode != KINECT_MODE) KINECT_MODE = _mode;
    doMode();
  }

  void display() {
    doMode();
  }
}


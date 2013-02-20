class Kinect extends SimpleOpenNI {
  final int X_START = 0;
  final int X_END = 640;
  final int Y_START = 0;
  final int Y_END = FRAME_BUFFER_HEIGHT;
  PVector user_start = new PVector();
  PVector user_end = new PVector();
  PVector user_center = new PVector();
  PVector user_size = new PVector();
  int[] scene_map;
  
  PImage current;

  Kinect(PApplet parent) {
    super(parent);
    setup();
  }
  
  Kinect(PApplet parent, int runMode) {
    super(parent, runMode);
    setup();
  }
  
  private void setup() {
    current = createImage(X_END, Y_END, ARGB);
    enableDepth();
    enableRGB();
    enableScene();
    //alternativeViewPointDepthToImage();
    setMirror(true);
  }

  PImage rgbImage() {
    PImage img = super.rgbImage(); //.get(X_START, Y_START, X_END, Y_END);
    img.updatePixels();
    arrayCopy(img.pixels, current.pixels, current.pixels.length);
    current.updatePixels();
    return current;
  }

  PImage depthImage() {
    PImage img = super.depthImage(); //.get(X_START, Y_START, X_END, Y_END);
    arrayCopy(img.pixels, current.pixels, current.pixels.length);
    current.updatePixels();
    return current;
  }
  
  PImage sceneImage() {
    PImage img = super.sceneImage(); //.get(X_START, Y_START, X_END, Y_END);
    arrayCopy(img.pixels, current.pixels, current.pixels.length);
    current.updatePixels();
    
    scene_map = sceneMap();
    for (int i = 0; i < current.pixels.length; i++) {
      if (scene_map[i] == 0) {
        current.pixels[i] = color(0);
      }
    }
    current.updatePixels();
    return current;
  }

  PImage singleImage() {
    PImage img = super.sceneImage(); //.get(X_START, Y_START, X_END, Y_END);
    arrayCopy(img.pixels, current.pixels, current.pixels.length);
    current.updatePixels();
    
    scene_map = sceneMap();
    user_start = new PVector(X_END,Y_END);
    user_end = new PVector();
    
    for (int i = 0; i < current.pixels.length; i++) {
      int x = i % X_END;
      int y = i / X_END;
      if (scene_map[i] == 0) {
        current.pixels[i] = color(0,0,0,0);
      } else if (scene_map[i] == 1) {
        current.pixels[i] = color(0);
        user_start.x = min(x,user_start.x);
        user_start.y = min(y,user_start.y);
        user_end.x = max(x,user_end.x);
        user_end.y = max(y,user_end.y);
      } else {
        current.pixels[i] = color(0,0,0,0);
      }
    }
    
    user_size = new PVector(user_end.x - user_start.x, user_end.y - user_start.y);
    
    user_center = new PVector(user_start.x + (user_size.x / 2), user_start.y + (user_size.y / 2));
    
    current.updatePixels();
    return current;
  }
}


class Kinect extends SimpleOpenNI {
  final int X_START = 0;
  final int X_END = 640;
  final int Y_START = 0;
  final int Y_END = FRAME_BUFFER_HEIGHT;
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
    current = createImage(X_END, Y_END, RGB);
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
        current.pixels[i] = color(0,0,0,0);
      }
    }
    
    current.updatePixels();
    return current;
  }
}


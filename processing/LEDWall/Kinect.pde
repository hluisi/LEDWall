class Kinect extends SimpleOpenNI {
  final int X_START = 0;
  final int X_END = 640;
  final int Y_START = 0;
  final int Y_END = FRAME_BUFFER_HEIGHT;
  int[] sceneMap;

  Kinect(PApplet parent) {
    super(parent);
    enableDepth();
    enableRGB();
    enableScene();
    //alternativeViewPointDepthToImage();
    setMirror(true);
  }

  PImage rgbImage() {
    PImage img = super.rgbImage().get(X_START, Y_START, X_END, Y_END);
    return img;
  }

  PImage depthImage() {
    PImage img = super.depthImage().get(X_START, Y_START, X_END, Y_END);
    return img;
  }

  PImage sceneImage() {
    PImage img = super.sceneImage().get(X_START, Y_START, X_END, Y_END);
    sceneMap = super.sceneMap();
    img.loadPixels();
    for (int i = 0; i < sceneMap.length; i++) {
      if (sceneMap[i] == 0) {
        img.pixels[i] = color(0,0,0,0);
      }
    }
    img.updatePixels();
    return img;
  }
}


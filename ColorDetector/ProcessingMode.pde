final float DEFAULT_THRESHOLD_INCREMENT = 0.05f;
final float DEFAULT_BLOB_SIZE_INCREMENT = 0.01f;


public abstract class ProcessingMode {

  // The feed that will be analyzed. We abstract it into a PImage so we don't need to care whether it came from the Camera or from a Video
  PImage feed;

  // The current frame after pre processing, i.e., resize, color selection and binarization
  PImage preProcessedFrame;
  
  // The resolution the blob detection will be made at
  int resH = 80;
  int resV = 60;

  // We are going to look for this color
  float targetHue        = 0.02f;
  float targetSaturation = 0.75f;
  float targetBrightness = 0.21f;

  // The target color will be included if it is within this tolerance level
  float targetTolerance = 0.1;

  
  // The Blob Scanner
  BlobDetection bd;

  // The minimum size for a blob to count
  float minBlobSize = 0.03f;


  // TUIO communication
  Comm comm;


  public void start() {
    // Set up a callback for when a blob is detected. This way we can discard blobs that are too small
    bd.activeCustomFilter(this);
  }
  
  public void stop() {
  }


  public abstract PImage acquire();

  public void preProcess() {

    // We ensure that this buffer exists and is valid
    if (preProcessedFrame == null ||
      preProcessedFrame.width != resH ||
      preProcessedFrame.height != resV
      ) {
      preProcessedFrame = null;
      preProcessedFrame = createImage(resH, resV, RGB); // Perhaps can be optimized by using ALPHA instead
      println("Rebuilding pre processed frame");
    }
    
    preProcessedFrame.copy(feed, 0, 0, feed.width, feed.height,
                           0, 0, preProcessedFrame.width, preProcessedFrame.height);


    preProcessedFrame.loadPixels();

    int rgb;
    int r, g, b;
    float[] hsb;
    float h, s, br;


    for (int i = 0; i < preProcessedFrame.pixels.length; i++) {

      // Get the color
      rgb = preProcessedFrame.pixels[i];

      // Get individual RGB color components from the pixels color
      // (check "http://processing.org/reference/rightshift.html" on the reference)
      r = (rgb >> 16) & 0xFF;
      g = (rgb >> 8) & 0xFF;
      b = rgb & 0xFF;

      // Convert the color to HSB, to facilitate color comparison
      // (check "http://docs.oracle.com/javase/1.4.2/docs/api/java/awt/Color.html")
      hsb = Color.RGBtoHSB(r, g, b, null);

      // The individual HSB components
      h = hsb[0];
      s = hsb[1];
      br = hsb[2];


      // Test if the found color is similar enough to the color we are looking for
      // If it's not, the pixel should be black
      preProcessedFrame.pixels[i] = 0x00000000;

      if ( isWithinTolerance(h, targetHue) &&
        isWithinTolerance(s, targetSaturation) &&
        isWithinTolerance(br, targetBrightness)
        ) {
        // If the color is within range, the pixel will be white
        preProcessedFrame.pixels[i] = 0xFFFFFFFF;
      }
    }

    preProcessedFrame.updatePixels();
  }
  
  
  
  public void detectBlobs() {  
    bd.computeBlobs(preProcessedFrame.pixels);
    
    // Send touch information by OSC
    if(comm != null && comm.enabled) {
      for(int i = 0; i < bd.getBlobNb(); i++) {
        comm.send(
          bd.getBlob(i).x,
          bd.getBlob(i).y
        );
      }
    }
  }
  
  public boolean newBlobDetectedEvent(Blob b) {
    //println(b.w + " " + b.h + " " + b.x + " " + b.y);
    
    if(b.w > minBlobSize && b.h > minBlobSize) {
      return true;
    }
    return false;
  }
  

  private boolean isWithinTolerance(float value, float reference) {

    if (value > reference-targetTolerance && value < reference+targetTolerance) {
      return true;
    }

    return false;
  }



  // Set the color to track
  public void setTargetColor(color rgb) {

    int r = (rgb >> 16) & 0xFF;
    int g = (rgb >> 8) & 0xFF;
    int b = rgb & 0xFF;

    float[] hsb = Color.RGBtoHSB(r, g, b, null);

    targetHue = hsb[0];
    targetSaturation = hsb[1];
    targetBrightness = hsb[2];

    println("\n========================");
    println("New Target Color");
    println("RGB: (" + r + ", " + g + ", " + b + ")");
    println("HSB: (" + (targetHue*360) + ", " + (targetSaturation*100) + ", " + (targetBrightness*100) +")");
    println("========================\n");
  }
  
  
  public void setDetectionResolution(int resH, int resV) {
    this.resH = resH; this.resV = resV;
    bd = null;
    bd = new BlobDetection(resH, resV);
    
    println("NOT WORKING. Currently this breaks the detection");
  }
  
  
  
  public void setTolerance(float newTolerance) {
    newTolerance = constrain(newTolerance, 0, 1);
    targetTolerance = newTolerance;
    
    println("New Tolerance: " + targetTolerance);
  }
  
  public void increaseTolerance(float amount) {
    setTolerance( targetTolerance + amount );
  }
  
  
  
  public void setMinBlobSize(float newMinSize) {
    newMinSize = constrain(newMinSize, 0, 1);
    minBlobSize = newMinSize;
    
    println("New MinBlobSize: " + minBlobSize);
  }
  
  public void increaseMinBlobSize(float amount) {
    setMinBlobSize( minBlobSize + amount );
  }
  
  
  public void toggleOSCComm() {
    comm.setEnable(!comm.enabled);
  }
  
  public boolean isOSCCommEnabled() {
    return comm.enabled;
  }





  public void drawFeed(int x, int y, int w, int h) {
    image(feed, x, y, w, h);
  }

  public void drawPreProcessedFrame(int x, int y, int w, int h) {
    image(preProcessedFrame, x, y, w, h);
  }
  
  public void drawBlobs(int x, int y, int w, int h) {
    
    if(bd.getBlobNb() == 0) {
      return;
    }
    
    fill(255, 0, 0, 100);
    Blob b;
    
    for(int i = 0; i < bd.getBlobNb(); i++) {
      
      b = bd.getBlob(i);
      
      ellipse (
        b.x * w + x,
        b.y * h + y,
        b.w * w,
        b.h * h
      );
      
    }
  }
  
  
  public String printoutBlobs() {
    
    String output = "";
    
    for(int i = 0; i < bd.getBlobNb(); i++) {
      output += i + ": " + bd.getBlob(i) + "\n";
    }
    
    println(output);
    
    return output;
  }
  
  
}

public class MovieMode extends ProcessingMode {

  private Movie movieFeed;

  MovieMode(PApplet parent, String movieName) {
    movieFeed = new Movie(parent, movieName);
    feed = movieFeed;
    
    bd = new BlobDetection (resH, resV);
    bd.setPosDiscrimination(true);
    bd.setThreshold(0.8f);
    
    comm = new Comm(parent);
  }

  public void start() {
    super.start();
    movieFeed.play();
    movieFeed.loop();
  }

  public void stop() {
    super.stop();
    movieFeed.stop();
  }


  public PImage acquire() {

    if (movieFeed.available() == true) {
      movieFeed.read();
    }
    return movieFeed;
  }
}




public class CameraMode extends ProcessingMode {

  private Capture cameraFeed;

  CameraMode(PApplet parent, int feedW, int feedH) {
    cameraFeed = new Capture(parent, feedW, feedH);
    feed = cameraFeed;
    
    bd = new BlobDetection (resH, resV);
    bd.setPosDiscrimination(true);
    bd.setThreshold(0.8f);
    
    comm = new Comm(parent);
  }

  public void start() {
    super.start();
    cameraFeed.start();
  }

  public void stop() {
    super.stop();
    cameraFeed.stop();
  }


  public PImage acquire() {

    if (cameraFeed.available()) {
      cameraFeed.read();
    }

    return feed;
  }
}
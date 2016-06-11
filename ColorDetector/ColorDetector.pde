/**
 * Color Detector
 * by Jorge Nuno Coutinho
 *
 * A colored blob detector made in Processing
 * It detects blobs of a specified color in a video feed (movie or camera) and sends them over OSC
 *
 * Built as part of an interactive installation: RoRoD
 * https://www.behance.net/gallery/RoRoD/11769933
 *
 *
 * In a nutshell:
 * - We obtain an image feed (movie or camera)
 * - We process it by:
 *   - resizing it to have less data to process
 *   - comparing each pixel to the reference color
 *   - binarizing the image: white if it matches the target color, and black if it doesn't
 * - Then we run it by a blob detector
 * - And send the detected blob's coordinates over OSC
 *
 *
 * This project has been available for quite some time now in openProcessing
 * http://www.openprocessing.org/sketch/64788
 *
 * The project makes little sense in a web environment, though, and it was sorely in need of an update anyway.
 * Hence this version 2, released in the hope it can be useful. Enjoy!
 */


/**
 * Right-click any point of the window to set the target color
 *
 * SPACE to turn on/off the live preview
 *
 * m to toggle between Movie mode and Camera mode
 * q and w to increase and decrease the tolerance in the color's detection
 * a and s to increase and decrease the minimum blob size (blob's smaller than this value are ignored)
 * t to toggle OSC communication on/off
 *
 */



// Processing's video library for movie loading / use the camera
import processing.video.*;

// Java's Color class. Used to convert between RGB and HSB colorspaces
import java.awt.Color;

// Blob detection library by Julien 'v3ga' Gachadoat
// http://www.v3ga.net/processing/BlobDetection/index-page-home.html
import blobDetection.*;

// oscP5 library by Andreas Schlegel
// http://www.sojamo.de/libraries/oscP5/
import oscP5.*;
import netP5.*;



// The size in pixels for the camera feed
// Ensure that this resolution is supported by your camera by running the "Libraries/Video/Capture/GettingStartedCapture" example
int feedW = 160;
int feedH = 120;

// If true the real time preview will be shown in the app.
// Preview can be deactivated for that extra oomph
boolean LIVE_PREVIEW = true;

// The detector works with both the camera and a video file
// Hit "m" to switch between modes
ProcessingMode currentMode;
MovieMode movieMode;
CameraMode cameraMode;



void setup() {
  size(480, 240);

  movieMode = new MovieMode(this, "movie.mov");
  cameraMode = new CameraMode(this, feedW, feedH);

  // By default we start in Movie Mode
  currentMode = movieMode;
  // But we can start in Camera Mode too
  // currentMode = cameraMode;
  
  currentMode.start();
}



float processingTime;

void draw() {

  background(127);
  
  // Measure processing time
  processingTime = millis();
  
  
  if (currentMode != null) {
    currentMode.acquire();
    currentMode.preProcess();
    currentMode.detectBlobs();

    if(LIVE_PREVIEW) {
      // The video unaltered feed
      currentMode.drawFeed(320, 0, 160, 120);
      // The video feed after our preprocessing (resize, color selection and binarization)
      currentMode.drawPreProcessedFrame(0, 0, 320, 240);
      // The blobs detected on the feed
      currentMode.drawBlobs(0, 0, 320, 240);
    }
  }
   
   
   fill(255);
   textAlign(LEFT);
   text(frameRate, 320+textSpacingX, 120+textSpacingY);
   text((millis() - processingTime) + "ms", 320+textSpacingX, 120+textSpacingY*2);
   text("TUIO: " + (currentMode.isOSCCommEnabled() ? "On" : "Off"), 320+textSpacingX, 120+textSpacingY*3 );
}

int textSpacingX = 6;
int textSpacingY = 12;



void mousePressed() {

  // Track the right-clicked color
  if (mouseButton == RIGHT) {
    color c = get(mouseX, mouseY);
    movieMode.setTargetColor(c);
    cameraMode.setTargetColor(c);
  }
}


void keyPressed() {


  // SWITCH CAMERA<->MOVIE MODE
  if (key == 'm' || key == 'M') {
    currentMode.stop();
    currentMode = (currentMode == movieMode) ? cameraMode : movieMode;
    currentMode.start();
  }
  
  // Change color tolerance values
  if (key == 'w' || key == 'W') {
    movieMode.increaseTolerance(DEFAULT_THRESHOLD_INCREMENT);
    cameraMode.increaseTolerance(DEFAULT_THRESHOLD_INCREMENT);
  }
  
  if (key == 'q' || key == 'Q') {
    movieMode.increaseTolerance(-DEFAULT_THRESHOLD_INCREMENT);
    cameraMode.increaseTolerance(-DEFAULT_THRESHOLD_INCREMENT);
  }
  
  
  // Change minimum blob size values
  if (key == 's' || key == 'S') {
    movieMode.increaseMinBlobSize(DEFAULT_BLOB_SIZE_INCREMENT);
    cameraMode.increaseMinBlobSize(DEFAULT_BLOB_SIZE_INCREMENT);
  }
  
  if (key == 'a' || key == 'A') {
    movieMode.increaseMinBlobSize(-DEFAULT_BLOB_SIZE_INCREMENT);
    cameraMode.increaseMinBlobSize(-DEFAULT_BLOB_SIZE_INCREMENT);
  }
  
  
  /*
  // Changing the processing resolution at runtime is not working
  if(key == 't') {
    movieMode.setDetectionResolution(160,120);
    cameraMode.setDetectionResolution(160,120);
  }*/
  
  if(key == 't' || key == 'T') {
    movieMode.toggleOSCComm();
    cameraMode.toggleOSCComm();
  }
  
  
  if(key == ' ') {
    LIVE_PREVIEW = !LIVE_PREVIEW;
  }
  
}
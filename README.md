Color Detector
by Jorge Nuno Coutinho

Color Blob Detector built with Processing 
It detects blobs of a specified color in a video feed (movie or camera) and sends them over OSC
 
Built as part of an interactive installation: RoRoD
https://www.behance.net/gallery/RoRoD/11769933
 
 
In a nutshell:
  - We obtain an image feed (movie or camera)
  - We process it by:
    - resizing it to have less data to process
    - comparing each pixel to the reference color
    - binarizing the image: white if it matches the target color, and black if it doesn't
  - Then we run it by a blob detector
  - And send the detected blob's coordinates over OSC
 
 
This project has been available for quite some time now in openProcessing
http://www.openprocessing.org/sketch/64788
 
The project makes little sense in a web environment, though, and it was sorely in need of an update anyway.
Hence this version 2, released in the hope it can be useful. Enjoy!


The project requires the following libraries, present in the Contributions Manager:
  - Blob detection library by Julien 'v3ga' Gachadoat
    http://www.v3ga.net/processing/BlobDetection/index-page-home.html
	
  - oscP5 by Andreas Schlegel
    http://www.sojamo.de/libraries/oscP5/
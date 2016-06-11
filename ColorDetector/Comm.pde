

// This class handles the OSC communication
// Check the oscP5 library's documentation for more info

class Comm {

  OscP5 oscP5;
  NetAddress target;

  OscMessage msg;

  boolean enabled = false;
  int sID; // Session ID. Goes up with every new blob

  Comm(PApplet p) {

    oscP5 = new OscP5(p, 3334); // OSC Messages are received in this port // Not used
    target = new NetAddress("127.0.0.1", 3333); // OSC Messages are sent to this port

    sID = 0;
  }


  void send(float x, float y) {

    if(enabled) {
      sID++; // Session ID. Goes up with every new blob
      
      // We use "/tuio/2Dcur" as specified in the TUIO protocol, making this detector compatible with TUIO
      // (check "http://www.tuio.org/?specification")
      // 2D Interactive Surface
      msg = new OscMessage("/tuio/2Dcur");
      msg.add("set"); // Message Format
      msg.add(sID); // Session ID. Goes up with every new blob
      msg.add(x); msg.add(y); // Normalized position
      msg.add(0f); msg.add(0f); // Velocity // Not used
      msg.add(0f); // Motion Acceleration // Not used
      
      // Send the message
      oscP5.send(msg, target);
    }
  }
  
  // Activate/Deactivate TUIO
  void setEnable(boolean b) {
    enabled = b;
  }
  
}
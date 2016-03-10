import processing.serial.*;
import oscP5.*;
import netP5.*;


OscP5 oscP5;
NetAddress myBroadcastLocation;
float previousValue;


Serial myPort;

void setup () {
  size(300, 300);
  oscP5 = new OscP5(this, 5001);
  myBroadcastLocation = new NetAddress("127.0.0.1", 5000);
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 9600);
  myPort.bufferUntil('\n');
  previousValue = -1;
  background(0);
}
void draw () {
}

void serialEvent (Serial myPort) {
  String inString = myPort.readStringUntil('\n');
  if (inString != null) {
    inString = trim(inString);
    float inByte = float(inString);
    float value = map(inByte, 0, 1023, 0, 1);
    // The signal from Arduino is not totally accurate
    if ( 0.002 < abs(previousValue-value) || value == 0 || value == 1 )
    {
      if ( value != previousValue )
      {
        println(value);
        OscMessage myOscMessage = new OscMessage("/millumin/layer/opacity/1");
        myOscMessage.add(value*100);
        oscP5.send(myOscMessage, myBroadcastLocation);
        previousValue = value;
      }
    }
  }
}


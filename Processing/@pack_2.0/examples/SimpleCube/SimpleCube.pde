import codeanticode.syphon.*;
import oscP5.*;
import netP5.*;


PGraphics canvas;
SyphonServer server;
OscP5 oscP5;
NetAddress myBroadcastLocation;
float factor;


void setup()
{
  // DISPLAY SETUP
  size(640, 480, P3D);
  canvas = createGraphics(640, 480, P3D);
  // SYPHON SETUP
  server = new SyphonServer(this, "Processing Cube");
  // OSC SETUP
  oscP5 = new OscP5(this, 5001);
  myBroadcastLocation = new NetAddress("127.0.0.1", 5000);
  factor = 1;
}


// RENDER AND SEND TO SYPHON
void draw()
{
  canvas.beginDraw();
  canvas.background(127, 127*factor, 127*factor);
  canvas.lights();
  canvas.translate(width/2, height/2);
  canvas.rotateX(frameCount * 0.01);
  canvas.rotateY(frameCount * 0.01);  
  canvas.box(150);
  canvas.endDraw();
  image(canvas, 0, 0);
  server.sendImage(canvas);
}


// SEND ORDER TO MILLUMIN
void mouseMoved()
{
  OscMessage myOscMessage = new OscMessage("/millumin/layer/opacity/0");
  myOscMessage.add(100*mouseX/width);
  oscP5.send(myOscMessage, myBroadcastLocation);
}


// RECEIVE ORDER FROM MILLUMIN
void oscEvent(OscMessage theOscMessage)
{
  if ( theOscMessage.addrPattern().equals("/millumin/layer/scale/0") )
  {
    factor = theOscMessage.get(0).floatValue()/100;
  }
}

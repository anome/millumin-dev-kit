import codeanticode.syphon.*;
import oscP5.*;
import netP5.*;


PGraphics canvas;
SyphonServer server;
OscP5 oscP5;
NetAddress myBroadcastLocation;
float factor;
boolean shouldSendMouse; 

void setup()
{
  // DISPLAY SETUP
  size(400, 400, P3D);
  canvas = createGraphics(400, 400, P3D);
  initTheScene();
  // SYPHON SETUP
  server = new SyphonServer(this, "Processing Cube");
  factor = 0.5;
  // OSC SETUP
  oscP5 = new OscP5(this, 8000);
  myBroadcastLocation = new NetAddress("127.0.0.1", 1234);
}


// RENDER AND SEND TO SYPHON
void draw()
{
  canvas.beginDraw();
  renderTheScene();
  canvas.endDraw();
  image(canvas, 0, 0);
  server.sendImage(canvas);
  if ( shouldSendMouse )
  {
    shouldSendMouse = false;
    OscMessage myOscMessage = new OscMessage("/millumin/selectedLayer/opacity");
    myOscMessage.add((float)mouseX/width);
    oscP5.send(myOscMessage, myBroadcastLocation);
  }
}


// SEND ORDER TO MILLUMIN
void mouseMoved()
{
  shouldSendMouse = true;
}


// RECEIVE ORDER FROM MILLUMIN
void oscEvent(OscMessage theOscMessage)
{
  if( theOscMessage.addrPattern().equals("/millumin/selectedLayer/scale") )
  {
    print(" addrpattern: "+theOscMessage.addrPattern());
    print(" typetag: "+theOscMessage.typetag());
    factor = theOscMessage.get(0).floatValue();
    print(" ");
    println(factor);
  }
}



















//--------------------------------------



/*
 *
 * Sketch based on Chinchbug work
 * http://www.openprocessing.org/sketch/43338
 *
 */


int halfW, halfH, quarterW, quarterH;
segment s[];
int cnt;

void initTheScene()
{
  //setup some constants
  halfW = width/2; 
  quarterW = width/4;
  halfH = height/2; 
  quarterH = height/4;
  cnt = 64;
  //setup segments
  s = new segment[cnt];
  for (int i=0; i<cnt; i++)
  {
    s[i] = new segment(i);
  }
}

void renderTheScene()
{
  background(0);
  // SKY
  float f = pow( factor, 3 );
  float r1 = 5*f + (1-f)*128;
  float g1 = 16*f + (1-f)*224;
  float b1 = 20*f + (1-f)*255;
  float r2 = 15*f + (1-f)*255;
  float g2 = 48*f + (1-f)*255;
  float b2 = 64*f + (1-f)*255;
  canvas.beginShape(POLYGON);
  canvas.fill(r1, g1, b1);
  canvas.vertex(0, 0);
  canvas.fill(r2, g2, b2);
  canvas.vertex(width, 0);
  canvas.fill(r1, g1, b1);
  canvas.vertex(width, height);
  canvas.vertex(0, height);
  canvas.endShape(CLOSE);
  // GRASS
  for (int i=0; i<cnt; i++)
  {
    s[i].check();
  }
}







//================================================================

class segment
{
  PVector base; //position of the segment base (the middle of the base, actually)
  float heartbeat; //used with perlin noise for smooth position changes
  float spd; //how fast the heartbeat changes (which translates to how fast the segment moves)
  int num; //keeps track of the order for color gradients
  float baseW;
  //--------------------------------------
  segment(int orderNum) {
    spd = random(0.5, 1.); //keeping it slowish
    heartbeat = random(2000); //start off somewhere random
    base = new PVector(random(width), height); //base never changes
    num = orderNum; //nab the order num
    baseW = random(10, 20);//sqrt(baseDir.y/2); //the base is supposed to thicken as the segment shortens
  }
  //--------------------------------------
  void check() {
    PVector pos = new PVector( //this is the tip of segment
      noise(heartbeat*0.005, 0)*halfW + base.x - quarterW, 
      noise(0, (heartbeat + 1000)*0.005)*height);
    PVector posDir = new PVector( //this the bezier control point for the tip
      noise((heartbeat + 2000)*0.005, 0)*halfW + pos.x - quarterW, 
      noise(0, (heartbeat + 3000)*0.005)*halfH + pos.y - quarterH);
    PVector baseDir = new PVector(base.x, height - (height - pos.y)*0.5); //base control point

    //putting it all together...
    float f = pow( factor, 3 );
    float r = 0*f + (1-f)*0;
    float g = 80*f + (1-f)*170;
    float b = 64*f + (1-f)*108;
    canvas.fill(num*r/cnt, num*g/cnt, num*b/cnt);
    canvas.stroke(0, 0, 0, 0);
    canvas.beginShape(POLYGON);
    canvas.vertex(base.x-baseW, base.y);
    canvas.bezierVertex(base.x-baseW, baseDir.y, posDir.x, posDir.y, pos.x, pos.y);
    canvas.bezierVertex(posDir.x, posDir.y, base.x+baseW, baseDir.y, base.x+baseW, base.y);
    canvas.endShape(CLOSE);

    heartbeat+=spd; //thump-thump
  }
  //--------------------------------------
}
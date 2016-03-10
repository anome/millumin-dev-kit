import javax.media.opengl.*;
import processing.opengl.*;
import oscP5.*;
import netP5.*;
import jsyphon.*;


JSyphonServer mySyphon;
PGraphicsOpenGL pgl;
GL gl;
int[] texID;
OscP5 oscP5;
NetAddress myBroadcastLocation;
float factor;


void setup()
{
  // DISPLAY SETUP
  size(640, 480, OPENGL);
  pgl = (PGraphicsOpenGL) g;
  gl = pgl.gl;
  // SYPHON SETUP
  initSyphon(gl, "Processing Cube");
  // OSC SETUP
  oscP5 = new OscP5(this, 5001);
  myBroadcastLocation = new NetAddress("127.0.0.1", 5000);
  factor = 1;
}


// RENDER AND SEND TO SYPHON
void draw()
{
  background(127, 127*factor, 127*factor);
  lights();
  translate(width/2, height/2);
  rotateX(frameCount * 0.01);
  rotateY(frameCount * 0.01);  
  box(150);
  renderTexture(pgl.gl);
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






// ================================



void initSyphon(GL gl, String theName)
{
    // INIT SYPHON
    if(mySyphon!=null)
    {
      mySyphon.stop();
    }
    mySyphon = new JSyphonServer();
    mySyphon.initWithName(theName);
    // INIT TEXTURE FOR SYPHON
    texID = new int[1];
    gl.glGenTextures(1, texID, 0);
    gl.glBindTexture(gl.GL_TEXTURE_RECTANGLE_EXT, texID[0]);
    gl.glTexImage2D(gl.GL_TEXTURE_RECTANGLE_EXT, 0, gl.GL_RGBA8, width, height, 0, gl.GL_RGBA, gl.GL_UNSIGNED_BYTE, null);
} 

void renderTexture(GL gl)
{
  gl.glBindTexture(gl.GL_TEXTURE_RECTANGLE_EXT, texID[0]);
  gl.glCopyTexSubImage2D(gl.GL_TEXTURE_RECTANGLE_EXT, 0, 0, 0, 0, 0, width, height);
  mySyphon.publishFrameTexture(texID[0], gl.GL_TEXTURE_RECTANGLE_EXT, 0, 0, width, height, width, height, false);
}

public void stop()
{
  disposeSyphon();
}

void disposeSyphon() {
  // DELETE TEXTURE
  gl.glDeleteTextures(1, texID, 0);
  // STOP TEXTURE
  if(mySyphon != null)
  {
    mySyphon.stop();
  }
}

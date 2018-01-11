// A simple ripple effect. Click on the image to produce a ripple
// Original author: radio79
// Adapted by : Philippe Chaurand
// Original algorithm on http://www.neilwallis.com/java/water.html

import codeanticode.syphon.*;

PGraphics canvas;
SyphonServer server;
PImage img;
Ripple ripple;

void setup() {
  img = loadImage("image.jpg");
  // DISPLAY SETUP
  size(600, 450, P3D);
  frameRate(60);
  canvas = createGraphics(600, 450, P3D);
  // SYPHON SETUP
  server = new SyphonServer(this, "Ripple");
  // RIPPLE
  ripple = new Ripple();
}

void draw() {
  // RENDERING RIPPLE
  canvas.beginDraw();
  canvas.loadPixels();
  img.loadPixels();
  for (int loc = 0; loc < width * height; loc++) {
    canvas.pixels[loc] = ripple.col[loc];
  }
  canvas.updatePixels();
  ripple.newframe();
  canvas.endDraw();
  // DISPLAY
  image(canvas, 0, 0);
  // SYPHON
  server.sendImage(canvas);
}

void mouseDragged() {
  for (int j = mouseY - ripple.riprad; j < mouseY + ripple.riprad; j++) {
    for (int k = mouseX - ripple.riprad; k < mouseX + ripple.riprad; k++) {
      if (j >= 0 && j < height && k>= 0 && k < width) {
        ripple.ripplemap[ripple.oldind + (j * width) + k] += 512;
      }
    }
  }
}








class Ripple {
  int i, a, b;
  int oldind, newind, mapind;
  short ripplemap[]; // the height map
  int col[]; // the actual pixels
  int riprad;
  int rwidth, rheight;
  int ttexture[];
  int ssize;

  Ripple() {
    // constructor
    riprad = 3;
    rwidth = width >> 1;
    rheight = height >> 1;
    ssize = width * (height + 2) * 2;
    ripplemap = new short[ssize];
    col = new int[width * height];
    ttexture = new int[width * height];
    oldind = width;
    newind = width * (height + 3);
  }



  void newframe() {
    // update the height map and the image
    i = oldind;
    oldind = newind;
    newind = i;

    i = 0;
    mapind = oldind;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        short data = (short)((ripplemap[mapind - width] + ripplemap[mapind + width] +
          ripplemap[mapind - 1] + ripplemap[mapind + 1]) >> 1);
        data -= ripplemap[newind + i];
        data -= data >> 5;
        if (x == 0 || y == 0) // avoid the wraparound effect
          ripplemap[newind + i] = 0;
        else
          ripplemap[newind + i] = data;

        // where data = 0 then still, where data > 0 then wave
        data = (short)(1024 - data);

        // offsets
        a = ((x - rwidth) * data / 1024) + rwidth;
        b = ((y - rheight) * data / 1024) + rheight;

        //bounds check
        if (a >= width)
          a = width - 1;
        if (a < 0)
          a = 0;
        if (b >= height)
          b = height-1;
        if (b < 0)
          b=0;

        col[i] = img.pixels[a + (b * width)];
        mapind++;
        i++;
      }
    }
  }
}
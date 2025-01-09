/*
  template.ino
  Created by Anomes, 2016.
  Creative Commons Attribution-NonCommercial 4.0 International Public License
*/

#include <Arduino.h>
#include <MilluminStream.h>



MilluminStream stream("MyArduino");



////////////////////////////////////////////////////////////////////////////////
// Initialisation
void setup()
{
  // We setup MilluminStream
  stream.setup();

  // TODO
  // Your setting up your code...
}



////////////////////////////////////////////////////////////////////////////////
// Loop
void loop()
{
  // First, we need to update MilluminStream
  stream.update();

  // TODO
  // browse some inteligence...
  // add data to the current frame...

  // Finally we send just one frame with all our values
  stream.sendFrame();
}

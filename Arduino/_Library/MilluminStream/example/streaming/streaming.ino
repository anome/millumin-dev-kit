/*
  streaming.ino
  Created by Anomes, 2016.
  Creative Commons Attribution-NonCommercial 4.0 International Public License
*/

#include <Arduino.h>
#include <MilluminStream.h>



////////////////////////////////////////////////////////////////////////////////
// Initialisation
void setup()
{
  // We setup MilluminStream
  MilluminStream::setup();

  // pin A0 as input to stream its sensor value
  pinMode(A0, INPUT);

  // pin D3 as input to stream its sensor value
  pinMode(3, INPUT_PULLUP);
}



////////////////////////////////////////////////////////////////////////////////
// Loop
void loop()
{
  // First, we need to update MilluminStream
  MilluminStream::update();

  // Then, we stream pin A0
  MilluminStream::sendAnalogForID(0); // Add the value of A0 pin to the frame

  // Then, we stream pin D3
  MilluminStream::sendDigitalForID(3); // Add the value of D3 pin to the frame

  // Stream a custom value
  uint16_t variable = random(0, 255);
  MilluminStream::sendVariableForID(0, variable); // Add a custom value to the frame

  // Finally we send just one frame with all our values
  MilluminStream::sendFrame();
}

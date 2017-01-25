/*
  listening.ino
  Created by Anomes, 2016.
  Creative Commons Attribution-NonCommercial 4.0 International Public License
*/

#include <Arduino.h>
#include <MilluminStream.h>

// This the the input callback function
// MilluminStream automatically handle A and D key value
// A is for analogic input
// D is for digital input
// Other key are handle in this method
void onInputValue(uint8_t key, uint8_t index, uint16_t value)
{
  //TODO
  // handle personnal input...
}



////////////////////////////////////////////////////////////////////////////////
// Initialisation
void setup()
{
  // We setup MilluminStream
  MilluminStream::setup();

  // We set the callback if we need to use servo
  MilluminStream::setInputCallback(onInputValue);

  // We initialise each pin we need to use
  // MilluminStream will automatically update the pin
  pinMode(13, OUTPUT); // pin D13 is OUTPUT because we use it to light a led
}



////////////////////////////////////////////////////////////////////////////////
// Loop
void loop()
{
  // First, we need to update MilluminStream
  MilluminStream::update();

  // Finally we send just one frame with all our values
  MilluminStream::sendFrame();
}

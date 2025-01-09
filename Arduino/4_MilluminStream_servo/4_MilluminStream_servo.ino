/*
  4_MilluminStream_servo.ino
  Created by Anomes, 2016.
  Creative Commons Attribution-NonCommercial 4.0 International Public License
*/

#include <Arduino.h>
#include <MilluminStream.h>



////////////////////////////////////////////////////////////////////////////////
// Use this only if you need to handle some servo
#include <Servo.h>
static Servo servo;



MilluminStream stream("MyArduino");



// This the the input callback function
// MilluminStream automatically handle A and D key value
// A is for analogic input
// D is for digital input
// Other key are handle in this method
// Here, we use it to handle servo input
void onInputValue(uint8_t key, uint8_t index, uint16_t value)
{
  // if the key is 'S', we update the adequate servo
  if( key == 'S' )
  {
    servo.write(value);
  }
}



////////////////////////////////////////////////////////////////////////////////
// Initialisation
void setup()
{
  // We setup MilluminStream
  stream.setup();

  // We set the callback if we need to use servo
  stream.setInputCallback(onInputValue);

  // We attach the first servo to pin D3
  servo.attach(3);
}



////////////////////////////////////////////////////////////////////////////////
// Loop
void loop()
{
  // First, we need to update MilluminStream
  stream.update();

  // Finally we send just one frame with all our values
  stream.sendFrame();
}

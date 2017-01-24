#include <Arduino.h>
#include <MilluminStream.h>



////////////////////////////////////////////////////////////////////////////////
// Use this only if you need to handle some servo
#include <Servo.h>
#define NUMBER_OF_SERVO 1 // Edit this value to change the number of servo you need
static Servo servo[NUMBER_OF_SERVO];

// This the the callback function to update the servo
void onInputValue(uint8_t key, uint8_t index, uint16_t value)
{
  // if the key is 'S', we update the adequate servo
  if( key == 'S' )
  {
    servo[index].write(value);
  }
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
  pinMode(13, OUTPUT); // pin D13 is out because we use it to light a led
  pinMode(A0, INPUT);  // pin A0 is input because we use it to stream an ir captor

  // We attach the first servo to pin D3
  servo[0].attach(3);
}



////////////////////////////////////////////////////////////////////////////////
// Loop
void loop()
{
  // First, we need to update MilluminStream
  MilluminStream::update();

  // Then, we stream data
  MilluminStream::sendAnalogForID(1); // Add the value of A1 pin to the frame

  // Stream a random value
  uint16_t variable = random(0, 255);
  MilluminStream::sendVariableForID(0, variable); // Add a custom value to the frame

  // Finally we send just one frame with all our values
  MilluminStream::sendFrame();
}

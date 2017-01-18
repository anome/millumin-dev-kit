#include <Arduino.h>
#include <PacketSerial.h>
#include <MilluminStream.h>

void setup()
{
  MilluminStream::setup();
}

void loop()
{
  MilluminStream::update();
  uint16_t variable = random(0, 255);
  MilluminStream::sendVariableForID(0, variable);
  MilluminStream::sendFrame();
}


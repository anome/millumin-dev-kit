/*
  5_MilluminStream_wifi.ino
  Created by Anomes, 2025.
  Creative Commons Attribution-NonCommercial 4.0 International Public License
*/

#include <Arduino.h>
#include <MilluminStreamWifi.h>



#define WIFI_SSID "my_wifi_ssid"
#define WIFI_PASSWORD "my_wifi_password"
#define REMOTE_IP "my_millumin_ip"



// We use a MilluminStreamWifi instead of a MilluminStream. Only work with Arduino R4 Wifi
MilluminStreamWifi stream("MyArduino");



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
#if defined(WIFI_SSID) && defined(WIFI_PASSWORD)  && defined(REMOTE_IP)
  stream.setupWifi(WIFI_SSID, WIFI_PASSWORD, REMOTE_IP);
#endif

  // We setup MilluminStream
  stream.setup();

  // We set the callback if we want to handle personal input
  stream.setInputCallback(onInputValue);

  // pin A0 as input to stream its sensor value
  pinMode(A0, INPUT);

  // pin D3 as input to stream its sensor value
  pinMode(3, INPUT_PULLUP);

  // We initialise each pin we need to use
  // MilluminStream will automatically update the pin
  pinMode(13, OUTPUT); // pin D13 is OUTPUT because we use it to light a led
}



////////////////////////////////////////////////////////////////////////////////
// Loop
void loop()
{
  // First, we need to update MilluminStream
  stream.update();

  // Then, we stream pin A0
  stream.sendAnalogForID(0); // Add the value of A0 pin to the frame

  // Then, we stream pin D3
  stream.sendDigitalForID(3); // Add the value of D3 pin to the frame

  // Stream a custom value
  uint16_t variable = random(0, 255);
  stream.sendVariableForID(0, variable); // Add a custom value to the frame

  // Finally we send just one frame with all our values
  stream.sendFrame();
}

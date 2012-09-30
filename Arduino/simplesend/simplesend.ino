#include <SPI.h>
#include <Ethernet.h>
#include <ArdOSC.h>

byte myMac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte myIp[] = { 192, 168, 0, 12 }; 
int destPort = 5000;
byte destIp[] = { 192, 168, 0, 11 };
OSCClient client;
OSCMessage global_mes;
float opacity = 0.0;


void setup()
{
  Ethernet.begin(myMac, myIp);
}


void loop()
{
  global_mes.setAddress(destIp, destPort);
  global_mes.beginMessage("/millumin/layer/opacity/1");
  global_mes.addArgFloat(opacity);
  client.send(&global_mes);
  global_mes.flush();
  delay(500);
  opacity += 1;
}




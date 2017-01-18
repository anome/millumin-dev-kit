
#define BAUDRATE 9600

#include <Arduino.h>
#include <PacketSerial.h>

typedef void (*InputCallback)(uint8_t key, uint8_t index, uint16_t value);
typedef void (*BufferCallback)(const uint8_t* buffer, size_t size);

namespace MilluminStream
{
  void setup();
  void setLoopIdleTime(int loopIdleTime);
  int getLoopIdleTime();
  void setInputCallback(InputCallback callback);
  void setBufferCallback(BufferCallback callback);
  void update();
  void onPacket(const uint8_t* buffer, size_t size);
  void sendVariableForID(char id, uint16_t variable);
  void sendAnalogForID(char id);
  void sendDigitalForID(char id);
  void sendFrame();
}

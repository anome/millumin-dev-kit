#include "MilluminStream.h"

PacketSerial serial;
namespace MilluminStream
{
  #define BUFFER_SIZE 254
  static uint8_t buffer[BUFFER_SIZE];
  static int bufferIndex;
  static int loopIdleTime;
  static InputCallback inputCallback;
  static BufferCallback bufferCallback;

  void clearBuffer()
  {
    bufferIndex = 1;
    buffer[0] = 'F';
    memset(buffer+1, '\0', BUFFER_SIZE-1);
  }

  void setup()
  {
    clearBuffer();
    serial.setPacketHandler(&onPacket);
    serial.begin(BAUDRATE);
    loopIdleTime = 8;
  }
    
  void setLoopIdleTime(int idleTime)
  {
    loopIdleTime = idleTime;
  }
    
  int getLoopIdleTime()
  {
    return loopIdleTime;
  }

  void setInputCallback(InputCallback callback)
  {
    inputCallback = callback;
  }

  void setBufferCallback(BufferCallback callback)
  {
    bufferCallback = callback;
  }

  void update()
  {
    if( loopIdleTime > 0 )
    {
      delay(loopIdleTime);
    }
    serial.update();
  }

  void onPacket(const uint8_t* buffer, size_t size)
  {
    uint8_t tmp[size];
    memcpy(tmp, buffer, size);
    if(tmp[0]=='F')//frame querry from Millumin
    {
      sendFrame();
    }
    else if(tmp[0]=='f')//frame reception from Millumin (will update Arduino outputs)
    {
      int i = 1;
      while(i<size)
      {
        uint8_t key = tmp[i++];
        uint8_t index = tmp[i++];
        uint8_t hByte = tmp[i++];
        uint8_t lByte = tmp[i++];
        uint16_t value = word(hByte, lByte);
        if(key=='D')
        {
          if( value > 0 )
          {
            digitalWrite(index, HIGH);
          }
          else
          {
            digitalWrite(index, LOW);
          }
        }
        else if(key=='A')
        {
          analogWrite(index, value);
        }
        else if( inputCallback )
        {
          inputCallback(key, index, value);
        }
      }
    }
    else if(tmp[0]=='I')//Arduino NickName querry
    {
      uint8_t reply []= {'I','M','I','L','L','U','M','I','N'};
      serial.send(reply, 9);
    }
    else if( bufferCallback )
    {
      bufferCallback(buffer, size);
    }
  }

  void sendFrame()
  {
    if( bufferIndex > 1 )
    {
      serial.send(buffer, bufferIndex);
      clearBuffer();
    }
  }

  void sendVariableForID(char id, uint16_t variable)
  {
    if( bufferIndex+4 < BUFFER_SIZE)
    {
      buffer[bufferIndex++] = 'V';
      buffer[bufferIndex++] = id;
      buffer[bufferIndex++] = lowByte(variable);
      buffer[bufferIndex++] =  highByte(variable);
    }
  }

  void sendAnalogForID(char id)
  {
    if( bufferIndex+4 < BUFFER_SIZE)
    {
      uint16_t value = analogRead(id);
      buffer[bufferIndex++] = 'A';
      buffer[bufferIndex++] = id;
      buffer[bufferIndex++] = lowByte(value);
      buffer[bufferIndex++] =  highByte(value);
    }
  }

  void sendDigitalForID(char id)
  {
    if( bufferIndex+3 < BUFFER_SIZE)
    {
      uint8_t byte = digitalRead(id);
      buffer[bufferIndex++] = 'D';
      buffer[bufferIndex++] = id;
      buffer[bufferIndex++] = byte;
    }
  }
}

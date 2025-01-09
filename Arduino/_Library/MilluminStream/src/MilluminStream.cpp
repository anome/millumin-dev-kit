/*
 MilluminStream.cpp
 MilluminStream is a small, efficient, library that
 allows Arduinos to send and receive serial data
 packets with Millumin.
 Created by Anomes, 2016.
 Creative Commons Attribution-NonCommercial 4.0 International Public License
 */

#include "MilluminStream.h"



void MilluminStream::clearBuffer()
{
    bufferIndex = 0;
    buffer[bufferIndex++] = 'F';
    buffer[bufferIndex++] = deviceId.length();
    if( deviceId.length() > 0 )
    {
        memcpy(buffer+bufferIndex, deviceId.c_str(), deviceId.length());
        bufferIndex += deviceId.length();
    }
    memset(buffer+bufferIndex, '\0', BUFFER_SIZE-bufferIndex);
}

void MilluminStream::onPacket(const uint8_t* buffer, size_t size)
{
    uint8_t tmp[size];
    memcpy(tmp, buffer, size);
    if(tmp[0]=='F')//frame querry from Millumin
    {
        sendFrame();
    }
    else if(tmp[0]=='f')//frame reception from Millumin (will update Arduino outputs)
    {
        size_t i = 1;
        bool validSerial = false;
        uint8_t serialLength = tmp[i++];
        if( serialLength == deviceId.length() )
        {
            if( serialLength > 0 )
            {
                char *serialBuffer = (char*)malloc(sizeof(char)*serialLength + 1);
                memcpy(serialBuffer, tmp+i, serialLength*sizeof(char));
                serialBuffer[serialLength] = 0;
                String askedSerial(serialBuffer);
                i += serialLength;
                validSerial = askedSerial.equals(deviceId);
                free(serialBuffer);
            }
            else
            {
                validSerial = true;
            }
        }
        
        if( validSerial )
        {
            while(i<size)
            {
                uint8_t key = tmp[i++];
                uint8_t index = tmp[i++];
                uint8_t hByte = tmp[i++];
                uint8_t lByte = tmp[i++];
                uint16_t value = word(lByte, hByte);
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
    }
    else if(tmp[0]=='I')//Arduino NickName querry
    {
        sendName();
    }
    else if( bufferCallback )
    {
        bufferCallback(buffer, size);
    }
}

void onPacketWithSender(const void* sender, const uint8_t* buffer, size_t size)
{
    MilluminStream *self = (MilluminStream*)sender;
    self->onPacket(buffer, size);
}

void MilluminStream::setup()
{
    clearBuffer();
    if( enableSerial )
    {
        serial.setPacketHandler(onPacketWithSender, this);
        serial.begin(BAUDRATE);
    }
}

void MilluminStream::setupWifi(char *ssid, char *pass, char *ip)
{
}

void MilluminStream::setLoopIdleTime(int idleTime)
{
    loopIdleTime = idleTime;
}

int MilluminStream::getLoopIdleTime()
{
    return loopIdleTime;
}

void MilluminStream::setInputCallback(InputCallback callback)
{
    inputCallback = callback;
}

void MilluminStream::setBufferCallback(BufferCallback callback)
{
    bufferCallback = callback;
}

void MilluminStream::update()
{
    if( loopIdleTime > 0 )
    {
        delay(loopIdleTime);
    }
    
    sendFrame();
    if( enableSerial )
    {
        serial.update();
    }
}

void MilluminStream::sendVariableForID(char id, uint16_t variable)
{
    if( bufferIndex+4 < BUFFER_SIZE)
    {
        buffer[bufferIndex++] = 'V';
        buffer[bufferIndex++] = id;
        buffer[bufferIndex++] = lowByte(variable);
        buffer[bufferIndex++] =  highByte(variable);
    }
}

void MilluminStream::sendAnalogForID(char id)
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

void MilluminStream::sendDigitalForID(char id)
{
    if( bufferIndex+3 < BUFFER_SIZE)
    {
        uint8_t byte = digitalRead(id);
        buffer[bufferIndex++] = 'D';
        buffer[bufferIndex++] = id;
        buffer[bufferIndex++] = byte;
    }
}

bool MilluminStream::hasData()
{
    if( deviceId.length() > 0 )
    {
        return bufferIndex > 2+deviceId.length();
    }
    else
    {
        return bufferIndex > 1;
    }
}

void MilluminStream::sendFrame()
{
    if( hasData() )
    {
        if( enableSerial )
        {
            serial.send(buffer, bufferIndex);
        }
        clearBuffer();
    }
}

void MilluminStream::sendName()
{
    if( enableSerial )
    {
        serial.send((const uint8_t*)deviceId.c_str(), deviceId.length());
    }
}

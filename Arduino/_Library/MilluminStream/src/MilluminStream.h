/*
 MilluminStream.h
 MilluminStream is a small, efficient, library that
 allows Arduinos to send and receive serial data
 packets with Millumin.
 Created by Anomes, 2016.
 Creative Commons Attribution-NonCommercial 4.0 International Public License
 */


#ifndef MILLUMIN_STREAM_H_
#define MILLUMIN_STREAM_H_



#include <Arduino.h>
#include <PacketSerial.h>



#define MILLUMIN_STREAM_DEFAULT_IDLE_TIME 16
#define BAUDRATE 9600
#define BUFFER_SIZE 264



typedef void (*InputCallback)(uint8_t key, uint8_t index, uint16_t value);
typedef void (*BufferCallback)(const uint8_t* buffer, size_t size);



class MilluminStream
{
protected:
    String deviceId;
    bool enableSerial = true;
    PacketSerial serial;
    uint8_t buffer[BUFFER_SIZE];
    size_t bufferIndex = 0;
    int loopIdleTime = MILLUMIN_STREAM_DEFAULT_IDLE_TIME;
    InputCallback inputCallback;
    BufferCallback bufferCallback;
    
    void clearBuffer();
    bool hasData();
    virtual void sendName();
    
public:
    void onPacket(const uint8_t* buffer, size_t size);
    
public:
    MilluminStream(String deviceId = "") : deviceId(deviceId) {}
    
    //////////////////////////////////////////////////////////////////////////////
    // Initialize MilluminStream.
    // Set the baudrate to 9600.
    // Must be call in setup().
    void setup();
    virtual void setupWifi(char *ssid, char *pass, char *remoteIP);
    
    //////////////////////////////////////////////////////////////////////////////
    // Get and set idle time in millisecond between two loop.
    // Default value is 16 millisecond.
    void setLoopIdleTime(int loopIdleTime);
    int getLoopIdleTime();
    
    //////////////////////////////////////////////////////////////////////////////
    // Set the callback that will handle keys that MilluminStream doesn't understand in the frame.
    // MilluminStream automatically handle A and D key value.
    // A is for analogic input,
    // D is for digital input.
    // Other key are handle in this method.
    // It is typically used to handle servo.
    void setInputCallback(InputCallback callback);
    
    //////////////////////////////////////////////////////////////////////////////
    // Set the callback for packet that arn't understood by MilluminStream.
    // If the packet begins by :
    // F : ask MilluminStream to send the current frame,
    // f : MilluminStream decode the packet as a frame,
    // I : MilluminStream send its name.
    // Other value are handle in the bufferCallback.
    void setBufferCallback(BufferCallback callback);
    
    //////////////////////////////////////////////////////////////////////////////
    // Update MilluminStream.
    // Should be called at the begining of loop().
    // Apply a delay of the duration of the idle time.
    virtual void update();
    
    //////////////////////////////////////////////////////////////////////////////
    // Add a custom variable to the final frame.
    void sendVariableForID(char id, uint16_t variable);
    
    //////////////////////////////////////////////////////////////////////////////
    // Update the finale frame with the value of the analog pin.
    void sendAnalogForID(char id);
    
    //////////////////////////////////////////////////////////////////////////////
    // Update the finale frame with the value of the digital pin.
    void sendDigitalForID(char id);
    
    //////////////////////////////////////////////////////////////////////////////
    // Send the final frame.
    virtual void sendFrame();
};

#endif

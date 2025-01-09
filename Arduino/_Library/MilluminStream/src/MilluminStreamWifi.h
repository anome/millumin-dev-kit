/*
 MilluminStream.h
 MilluminStream is a small, efficient, library that
 allows Arduinos to send and receive serial data
 packets with Millumin.
 Created by Anomes, 2025.
 Creative Commons Attribution-NonCommercial 4.0 International Public License
 */


#ifndef MILLUMIN_STREAM_WIFI_H_
#define MILLUMIN_STREAM_WIFI_H_

#include "MilluminStream.h"

#ifdef ARDUINO_UNOR4_WIFI
#include <WiFiS3.h>



class MilluminStreamWifi : public MilluminStream
{
protected:
    bool isWifi = false;
    int status = WL_IDLE_STATUS;
    unsigned int localPort = 2390;      // local port to listen on
    uint8_t packetBuffer[BUFFER_SIZE]; //buffer to hold incoming packet
    uint8_t decodedBuffer[BUFFER_SIZE]; //buffer to hold incoming packet
    WiFiUDP Udp;
    IPAddress remoteIP;
    
    virtual void sendName() override;
    
public:
    MilluminStreamWifi(String serialId = "") : MilluminStream(serialId) {}
    virtual void setupWifi(char *ssid, char *pass, char *remoteIP) override;
    virtual void update() override;
    virtual void sendFrame() override;
};

#endif
#endif

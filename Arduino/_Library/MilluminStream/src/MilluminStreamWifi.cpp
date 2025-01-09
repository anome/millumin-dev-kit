/*
 MilluminStream.h
 MilluminStream is a small, efficient, library that
 allows Arduinos to send and receive serial data
 packets with Millumin.
 Created by Anomes, 2025.
 Creative Commons Attribution-NonCommercial 4.0 International Public License
 */

#include "MilluminStreamWifi.h"

#if defined(ARDUINO_UNOR4_WIFI)



void MilluminStreamWifi::setupWifi(char *ssid, char *pass, char *ip)
{
    // check for the WiFi module:
    if (WiFi.status() == WL_NO_MODULE) {
        Serial.println("Communication with WiFi module failed!");
        // don't continue
        while (true);
    }
    
    String fv = WiFi.firmwareVersion();
    if (fv < WIFI_FIRMWARE_LATEST_VERSION) {
        Serial.println("Please upgrade the firmware");
    }
    
    // attempt to connect to WiFi network:
    while (status != WL_CONNECTED) {
        Serial.print("Attempting to connect to SSID: ");
        Serial.println(ssid);
        // Connect to WPA/WPA2 network. Change this line if using open or WEP network:
        status = WiFi.begin(ssid, pass);
        
        // wait 10 seconds for connection:
        delay(10000);
    }
    
    // if you get a connection, report back via serial:
    Udp.beginMulticast(IPAddress(224, 0, 0, 222), localPort);
    remoteIP = IPAddress(ip);
    isWifi = true;
    enableSerial = false;
}

void MilluminStreamWifi::update()
{
    MilluminStream::update();
    if( isWifi )
    {
        // if there's data available, read a packet
        int packetSize = Udp.parsePacket();
        if( packetSize )
        {
            // read the packet into packetBuffer
            int len = Udp.read(packetBuffer, 255);
            int decodedSize = COBS::decode(packetBuffer, packetSize, decodedBuffer);
            onPacket(decodedBuffer, decodedSize);
        }
    }
}

void MilluminStreamWifi::sendFrame()
{
    if( isWifi )
    {
        Udp.beginPacket(remoteIP, localPort);
        uint8_t _encodeBuffer[COBS::getEncodedBufferSize(bufferIndex)];
        
        size_t numEncoded = COBS::encode(buffer,
                                         bufferIndex,
                                         _encodeBuffer);
        Udp.write(_encodeBuffer, numEncoded);
        Udp.endPacket();
    }
    MilluminStream::sendFrame();
}

void MilluminStreamWifi::sendName()
{
    if( isWifi )
    {
        uint8_t _encodeBuffer[COBS::getEncodedBufferSize(deviceId.length())];
        size_t numEncoded = COBS::encode((const uint8_t*)deviceId.c_str(),
                                         deviceId.length(),
                                         _encodeBuffer);
        
        // send a reply, to the IP address and port that sent us the packet we received
        Udp.beginPacket(remoteIP, localPort);
        Udp.write(_encodeBuffer, numEncoded);
        Udp.endPacket();
    }
    MilluminStream::sendName();
}

#endif

//This example uses this syphon implementation : https://github.com/Hperigo/Cinder-Syphon

#include "cinder/app/App.h"
#include "cinder/gl/Texture.h"
#include "cinder/app/RendererGl.h"
#include "cinder/Rand.h"
#include "cinder/Color.h"
#include "cinder/gl/gl.h"

#include "cinder/Log.h"

#include "Syphon.h"
#include "Osc.h"

#include <list>

using namespace ci;
using namespace ci::app;
using namespace std;
using Receiver = osc::ReceiverUdp;
using Sender = osc::SenderUdp;
using protocol = asio::ip::udp;

#define WIDTH 800
#define HEIGHT 600
const std::string destinationHost = "127.0.0.1";
const uint16_t destinationPort = 1234;
const uint16_t localPort = 3333;

class MilluminApp : public App {
public:
    MilluminApp();
    void setup();
    void update();
    void draw();
    
    void onSendError( asio::error_code error );
    
    Receiver listener;
    Sender sender;
    
    std::string host;
    int port;
    float circleSize = 0.5;
    float scale = 100;
    
    reza::syphon::Server server; //each item to publish requires a different server
};

MilluminApp::MilluminApp()
: listener(localPort), sender( 3334, destinationHost, destinationPort )
{
}

void MilluminApp::setup()
{
    server.setName("Cinder Screen"); // set a name for each item to be published
    listener.setListener("/millumin/selectedLayer/opacity", [&](const osc::Message &msg)
                         {
                             circleSize = msg[0].flt();
                         });
    try
    {
        sender.bind();
        listener.bind();
    }
    catch (const osc::Exception &ex)
    {
        CI_LOG_E("Error binding: " << ex.what() << " val: " << ex.value());
        quit();
    }
    
    listener.listen( [](asio::error_code error, protocol::endpoint endpoint) -> bool
                    {
                        if (error)
                        {
                            CI_LOG_E("Error Listening: " << error.message() << " val: " << error.value() << " endpoint: " << endpoint);
                            return false;
                        }
                        else
                        {
                            return true;
                        }
                    });
    
}

void MilluminApp::update()
{
    scale += 1;
    osc::Message msg( "/millumin/selectedLayer/scale" );
    msg.append( float(int(scale)%1000/1000.0) );
    sender.send( msg, std::bind( &MilluminApp::onSendError, this, std::placeholders::_1 ) );
}

void MilluminApp::draw()
{
    
    gl::clear();
    vec2 syphonSize = { WIDTH,HEIGHT };
    server.bind( syphonSize );
    gl::clear( Color( 0.2f, 0.2f, 0.2f ) );
    gl::drawSolidCircle( getWindowCenter(), circleSize*200 );
    server.unbind();
    server.publishScreen(); //publish the screen
    
}

void MilluminApp::onSendError( asio::error_code error )
{
    if( error ) {
        CI_LOG_E( "Error sending: " << error.message() << " val: " << error.value() );
        try {
            sender.close();
        }
        catch( const osc::Exception &ex ) {
            CI_LOG_EXCEPTION( "Cleaning up socket: val -" << ex.value(), ex );
        }
        quit();
    }
}


auto settingsFunc = [](App::Settings *settings)
{
    settings->setWindowSize( WIDTH, HEIGHT );
};

CINDER_APP(MilluminApp, RendererGl, settingsFunc)


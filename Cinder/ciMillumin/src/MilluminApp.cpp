#include "cinder/app/AppBasic.h"
#include "cinder/gl/Texture.h"
#include "cinder/Rand.h"
#include "cinder/Color.h"
#include "cinder/gl/gl.h"

#include "cinderSyphon.h"
#include "OscSender.h"
#include "OscListener.h"

#include <list>

using namespace ci;
using namespace ci::app;
using namespace std;

#define WIDTH 800
#define HEIGHT 600


class spiral : public AppBasic {
	
public:
	spiral() {
		limit = 10.0f;
		resolution = 0.1f;
	}
	
	void set(float _limit, float _resolution){
		limit = _limit;
		resolution = _resolution;
	}
	
	void calc(){
		Vec2f here;
		
		for(float t = 0.0f; t <= limit; t += resolution){
			here.x = t * cos(t);
			here.y = t * sin(t);
			mSpiral.push_back(here);
		}
	}
	
	void draw(){
		glEnableClientState(GL_VERTEX_ARRAY);
		glVertexPointer(2, GL_FLOAT, 0, &mSpiral[0].x);
		glDrawArrays(GL_LINE_STRIP, 0, mSpiral.size());
		glDisableClientState(GL_VERTEX_ARRAY);
	}
    
	vector<Vec2f> mSpiral;
	float limit;
	float resolution;
};










class MilluminApp : public AppBasic {
public:
	void prepareSettings( Settings *settings );
	void keyDown( KeyEvent event );
	void mouseDown( MouseEvent event );
	void mouseUp( MouseEvent event );
	void mouseMove( MouseEvent event );
	void mouseDrag( MouseEvent event );
	void setup();
	void update();
	void draw();
	
	void randomizeSurface(Surface* inputSurface);
    
	
	osc::Listener listener;
	osc::Sender sender;
	std::string host;
	int port;
    
    
	gl::Texture mTex; // the texture to be published
	Surface mSurface; // a surface to manipulate
	spiral archimedes; // our spiral
	float mRot; // our changing rotation
	
	syphonServer mScreenSyphon; //each item to publish requires a different server
	syphonServer mTextureSyphon;
	
	syphonClient mClientSyphon; //our syphon client
};

void MilluminApp::prepareSettings( Settings *settings )
{
	settings->setWindowSize(WIDTH,HEIGHT);
	settings->setFrameRate(60.f);
}

void MilluminApp::setup()
{
	listener.setup(5001);
	host = "127.0.0.1";
	port = 5000;
	sender.setup(host, port);
    
    
	mTex = gl::Texture(200, 100); //create our texture to publish
	mSurface = Surface8u(200, 100, false); //create a surface to manipulate
	randomizeSurface(&mSurface); //randomize our surface
	mTex.update(mSurface); //tell the texture about our changes
	
	archimedes.set(100.f, 0.6f); //set up and calculate our spiral
	archimedes.calc();
	mRot = 0.f;
	
	mScreenSyphon.setName("Cinder Screen"); // set a name for each item to be published
	mTextureSyphon.setName("Cinder Texture");
	
	mClientSyphon.setup();
    
	// in order for this to work, you must run simple server from the testapps directory
	// any other syphon item you create would work as well, just change the name
    mClientSyphon.setApplicationName("Simple Server");
    mClientSyphon.setServerName("");
	
	mClientSyphon.bind();
}

void MilluminApp::update()
{
	while (listener.hasWaitingMessages()) {
		osc::Message message;
		listener.getNextMessage(&message);
		console() << "New message received" << std::endl;
		console() << "Address: " << message.getAddress() << std::endl;
		console() << "Num Arg: " << message.getNumArgs() << std::endl;
		for (int i = 0; i < message.getNumArgs(); i++) {
			console() << "-- Argument " << i << std::endl;
			console() << "---- type: " << message.getArgTypeName(i) << std::endl;
			if (message.getArgType(i) == osc::TYPE_INT32){
				try {
					console() << "------ value: "<< message.getArgAsInt32(i) << std::endl;
				}
				catch (int value) {
					console() << "------ value through exception: "<< value << std::endl;
				}
				
			}else if (message.getArgType(i) == osc::TYPE_FLOAT){
				try {
					console() << "------ value: " << message.getArgAsFloat(i) << std::endl;
				}
				catch (float val) {
					console() << "------ value trough exception: " << val << std::endl;
				}
                mRot += 1.f;
			}else if (message.getArgType(i) == osc::TYPE_STRING){
				try {
					console() << "------ value: " << message.getArgAsString(i).c_str() << std::endl;
				}
				catch (std::string str) {
					console() << "------ value: " << str << std::endl;
				}
			}
		}
	}
	osc::Message message;
	message.addFloatArg(  (cos(getElapsedSeconds()) / 2.0f + .5f)*100.f  );
	message.setAddress("/millumin/selectedLayer/opacity");
	message.setRemoteEndpoint(host, port);
	sender.sendMessage(message);
    
    
	if(getElapsedFrames() % 2 == 0) // for those of us with slower computers
		randomizeSurface(&mSurface);
	mTex.update(mSurface);
	mRot += 0.2f;
}

void MilluminApp::draw()
{    
	gl::enableAlphaBlending();
	gl::clear( Color( 0.1f, 0.1f, 0.1f ) );

	//draw our spiral
	gl::pushModelView();
	gl::translate(Vec2f(getWindowWidth()/2, getWindowHeight()/2));
	gl::rotate(mRot);
	gl::scale(Vec3f(4.f, 4.f, 1.f));
	gl::color(ColorA(1.f, 0.f, 0.f, 1.f));
	archimedes.draw();
	gl::popModelView();
	
	//draw our publishable texture
	if(mTex){
		gl::color(ColorA(1.f, 1.f, 1.f, 1.f));
		gl::draw(mTex);
	}
	
	mScreenSyphon.publishScreen(); //publish the screen
	mTextureSyphon.publishTexture(&mTex); //publish our texture
	
	//anything that we draw after here will not be published
	
	mClientSyphon.draw(Vec2f(300.0f, 0.0f)); //draw our client image
}

void MilluminApp::randomizeSurface(Surface* inputSurface)
{
	Surface::Iter inputIter( inputSurface->getIter() );
	while( inputIter.line() ) {
		while( inputIter.pixel() ) {
			inputIter.r() = Rand::randInt(0, 255);
			inputIter.g() = Rand::randInt(0, 255);
			inputIter.b() = Rand::randInt(0, 255);
		}
	}
}

void MilluminApp::keyDown( KeyEvent event )
{
	//
}

void MilluminApp::mouseDown( MouseEvent event )
{
	//
}

void MilluminApp::mouseUp( MouseEvent event )
{
	//
}

void MilluminApp::mouseMove( MouseEvent event )
{
	//
}

void MilluminApp::mouseDrag( MouseEvent event )
{
	//
}

CINDER_APP_BASIC( MilluminApp, RendererGl )


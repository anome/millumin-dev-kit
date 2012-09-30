#include "ofMain.h"
#include "ofxSyphon.h"
#include "ofxOsc.h"

class MilluminApp : public ofBaseApp {
	
public:
	
	void setup();
	void update();
	void draw();
	
	void keyPressed(int key);
	void mouseMoved(int x, int y);
	
	float 	counter;
	bool	bSmooth;
    
    
    ofxOscSender sender;
    ofxOscReceiver receiver;
	
    ofTexture tex;
    
	ofxSyphonServer mainOutputSyphonServer;
	ofxSyphonServer individualTextureSyphonServer;
	
	ofxSyphonClient mClient;
};


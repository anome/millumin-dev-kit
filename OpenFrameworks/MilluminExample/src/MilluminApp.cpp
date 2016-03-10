#include "MilluminApp.h"

const int width = 800;
const int height = 600;

//--------------------------------------------------------------
void MilluminApp::setup(){
	counter = 0;
	ofSetCircleResolution(50);
	
    //ofBackground(0,0,0);
    
	
    bSmooth = false;
	ofSetWindowTitle("Millumin Example");
    
    
    
	sender.setup("127.0.0.1", 5000);
    receiver.setup(5001);
    
	mainOutputSyphonServer.setName("Screen Output");
	individualTextureSyphonServer.setName("Texture Output");

	mClient.setup();
    
    mClient.setApplicationName("Simple Server");
    mClient.setServerName("");
	
    tex.allocate(width, height, GL_RGBA);    
    
	ofSetFrameRate(60); // if vertical sync is off, we can go a bit fast... this caps the framerate at 60fps.
}

//--------------------------------------------------------------
void MilluminApp::update(){
	counter = counter + 0.033f;
	while(receiver.hasWaitingMessages()){
		// get the next message
		ofxOscMessage m;
		receiver.getNextMessage(&m);
        
		// check for mouse moved message
		if(m.getAddress() == "/mouse/position"){
			// both the arguments are int32's
			mouseX = m.getArgAsInt32(0);
			mouseY = m.getArgAsInt32(1);
		}
		// check for mouse button message
		else if(m.getAddress() == "/mouse/button"){
			// the single argument is a string
			//mouseButtonState = m.getArgAsString(0);
		}
		else{
			// unrecognized message: display on the bottom of the screen
			string msg_string;
			msg_string = m.getAddress();
			msg_string += ": ";
			for(int i = 0; i < m.getNumArgs(); i++){
				// get the argument type
				msg_string += m.getArgTypeName(i);
				msg_string += ":";
				// display the argument - make sure we get the right type
				if(m.getArgType(i) == OFXOSC_TYPE_INT32){
					msg_string += ofToString(m.getArgAsInt32(i));
				}
				else if(m.getArgType(i) == OFXOSC_TYPE_FLOAT){
					msg_string += ofToString(m.getArgAsFloat(i));
				}
				else if(m.getArgType(i) == OFXOSC_TYPE_STRING){
					msg_string += m.getArgAsString(i);
				}
				else{
					msg_string += "unknown";
				}
			}
			// add to the list of strings to display
            cout << "msg : " << msg_string << "\n";
			//timers[current_msg_string] = ofGetElapsedTimef() + 5.0f;
            //cout << "msg : " << (current_msg_string + 1) % NUM_MSG_STRINGS << "\n";
		}
        
	}
}

//--------------------------------------------------------------
void MilluminApp::draw(){
	
    // Clear with alpha, so we can capture via syphon and composite elsewhere should we want.
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
	//--------------------------- circles
	//let's draw a circle:
	ofSetColor(255,130,0);
	float radius = 50 + 10 * sin(counter);
	ofFill();		// draw "filled shapes"
	ofCircle(100,400,radius);
	
	// now just an outline
	ofNoFill();
	ofSetHexColor(0xCCCCCC);
	ofCircle(100,400,80);
	
	// use the bitMap type
	// note, this can be slow on some graphics cards
	// because it is using glDrawPixels which varies in
	// speed from system to system.  try using ofTrueTypeFont
	// if this bitMap type slows you down.
	ofSetHexColor(0x000000);
	ofDrawBitmapString("circle", 75,500);
	
	
	//--------------------------- rectangles
	ofFill();
	for (int i = 0; i < 200; i++){
		ofSetColor((int)ofRandom(0,255),(int)ofRandom(0,255),(int)ofRandom(0,255));
		ofRect(ofRandom(250,350),ofRandom(350,450),ofRandom(10,20),ofRandom(10,20));
	}
	ofSetHexColor(0x000000);
	ofDrawBitmapString("rectangles", 275,500);
	
	//---------------------------  transparency
	ofSetHexColor(0x00FF33);
	ofRect(100,150,100,100);
	// alpha is usually turned off - for speed puposes.  let's turn it on!
	ofEnableAlphaBlending();
	ofSetColor(255,0,0,127);   // red, 50% transparent
	ofRect(150,230,100,33);
	ofSetColor(255,0,0,(int)(counter * 10.0f) % 255);   // red, variable transparent
	ofRect(150,170,100,33);
	ofDisableAlphaBlending();
	
	ofSetHexColor(0x000000);
	ofDrawBitmapString("transparency", 110,300);
	
	//---------------------------  lines
	// a bunch of red lines, make them smooth if the flag is set
	
	if (bSmooth){
		ofEnableSmoothing();
	}
	
	ofSetHexColor(0xFF0000);
	for (int i = 0; i < 20; i++){
		ofLine(300,100 + (i*5),500, 50 + (i*10));
	}
	
	if (bSmooth){
		ofDisableSmoothing();
	}
	
    ofSetColor(255,255,255);
	ofDrawBitmapString("lines\npress 's' to toggle smoothness", 300,300);
    
    // draw static into our one texture.
    unsigned char pixels[200*100*4];
    
    for (int i = 0; i < 200*100*4; i++)
    {
        pixels[i] = (int)(255 * ofRandomuf());
    }
    tex.loadData(pixels, 200, 100, GL_RGBA);
    
    tex.draw(50, 50);
    
    
	// Syphon Stuff
    
    ofSetColor(255, 255, 255);

    ofEnableAlphaBlending();
    
    mClient.draw(50, 50);    
    
	mainOutputSyphonServer.publishScreen();
    
    individualTextureSyphonServer.publishTexture(&tex);
    
    ofDrawBitmapString("Note this text is not captured by Syphon since it is drawn after publishing.\nYou can use this to hide your GUI for example.", 150,500);    
}

//--------------------------------------------------------------
void MilluminApp::mouseMoved(int x, int y){
	ofxOscMessage m;
	m.setAddress("/millumin/selectedLayer/opacity");
	m.addFloatArg( x*100.f/width );
	sender.sendMessage(m);
}

//--------------------------------------------------------------
void MilluminApp::keyPressed  (int key){
	if (key == 's'){
		bSmooth = !bSmooth;
	}
}

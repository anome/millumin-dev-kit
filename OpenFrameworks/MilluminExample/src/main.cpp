#include "ofMain.h"
#include "ofAppGlutWindow.h"
#include "ofApp.h"


int main( ){
    ofAppGlutWindow window;
	ofSetupOpenGL(&window, 800,600, OF_WINDOW);
	ofRunApp( new ofApp() );
}

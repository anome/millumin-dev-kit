#pragma once

#include "cinder/app/App.h"
#include "cinder/gl/Texture.h"
#include "ServerDirectory.h"

namespace reza { namespace syphon {

typedef std::shared_ptr<class Client> ClientRef;
class Client
{
public:
    static ClientRef create()
    {
        return ClientRef( new Client() );
    }

    ~Client();
	
    void setup();
	
    void set( const ServerDescription& serverDescription );
    void set( const std::string& serverName, const std::string& appName );
    
	void setApplicationName( const std::string& appName );
    void setServerName( const std::string& serverName );
	
    void bind();
    void unbind();
    
	void draw( glm::vec2 origin, glm::vec2 drawSize );
	void draw( glm::vec2 origin );
    void draw( float x, float y, float w, float h );
    void draw( float x, float y );
    
    int getWidth();
    int getHeight();
    const glm::vec2& getSize();
    
    const std::string& getApplicationName();
    const std::string& getServerName();
    
protected:
    Client();

	void* mClient;
    void* mLatestImage;
	ci::gl::TextureRef mTex;
	int mWidth, mHeight;
	bool mSetup;
	std::string mAppName, mServerName;
};

} } // namespace reza::syphon

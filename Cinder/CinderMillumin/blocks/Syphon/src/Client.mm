#import <Syphon/Syphon.h>
#import "SyphonNameboundClient.h"

#include "Client.h"
#include "cinder/gl/gl.h"

using namespace reza::syphon;

Client::Client() : mSetup(false)
{

}

Client::~Client()
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
    [(SyphonNameboundClient*)mClient release];
    mClient = nil;
    
    [pool drain];
}

void Client::setup()
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	mClient = [[SyphonNameboundClient alloc] init];
	mSetup = true;
    [pool drain];
}

void Client::set( const ServerDescription& server )
{
    set( server.mServerName, server.mAppName );
}

void Client::set( const std::string& serverName, const std::string& appName )
{
    if( mSetup ) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
        NSString *nsAppName = [NSString stringWithCString:appName.c_str() encoding:[NSString defaultCStringEncoding]];
        NSString *nsServerName = [NSString stringWithCString:appName.c_str() encoding:[NSString defaultCStringEncoding]];
        
        [(SyphonNameboundClient*)mClient setAppName:nsAppName];
        [(SyphonNameboundClient*)mClient setName:nsServerName];
        
        mAppName = appName;
        mServerName = serverName;
        
        [pool drain];
    }
}

void Client::setApplicationName( const std::string& appName )
{
    if( mSetup ) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
        NSString *name = [NSString stringWithCString:appName.c_str() encoding:[NSString defaultCStringEncoding]];

        [(SyphonNameboundClient*)mClient setAppName:name];
        
        mAppName = appName;
		
        [pool drain];
    }
    
}
void Client::setServerName( const std::string& serverName )
{
    if( mSetup ) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
        NSString *name = [NSString stringWithCString:serverName.c_str() encoding:[NSString defaultCStringEncoding]];
        
        if( [name length] == 0 ) { name = nil; }
        [(SyphonNameboundClient*)mClient setName:name];
        
        mServerName = serverName;
		
        [pool drain];
    }    
}

void Client::bind()
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
    if( mSetup ) {
     	[(SyphonNameboundClient*)mClient lockClient];
        SyphonClient *client = [(SyphonNameboundClient*)mClient client];
		
        mLatestImage = [client newFrameImageForContext:CGLGetCurrentContext()];
		NSSize texSize = [(SyphonImage*)mLatestImage textureSize];
		GLuint m_id = [(SyphonImage*)mLatestImage textureName];

		mTex = ci::gl::Texture::create( GL_TEXTURE_RECTANGLE_ARB, m_id, texSize.width, texSize.height, true );
		mTex->bind();
    } else {
        std::cout << "Client is not setup, or is not properly connected to server. Cannot bind.\n" << std::endl;
    }
    [pool drain];
}

void Client::unbind()
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if( mSetup ) {
        mTex->unbind();
        
        [(SyphonNameboundClient*)mClient unlockClient];
        [(SyphonImage*)mLatestImage release];
        
        mLatestImage = nil;
    }
    else {
        std::cout << "Client is not setup, or is not properly connected to server. Cannot unbind.\n" << std::endl;
    }
	
	[pool drain];
}

void Client::draw( glm::vec2 origin, glm::vec2 drawSize )
{
	draw( origin.x, origin.y, drawSize.x, drawSize.y );
}

void Client::draw( glm::vec2 origin )
{
	draw( origin.x, origin.y );
}

void Client::draw( float x, float y, float w, float h )
{
	if( mSetup && mTex ) {
		this->bind();
        ci::gl::draw( mTex, ci::Rectf( x, y, x + w, y + h ) );
        this->unbind();
	}
}

void Client::draw( float x, float y )
{
	if( mSetup && mTex ) {
		this->bind();
		ci::gl::draw( mTex, glm::vec2( x, y ) );
		this->unbind();
	}
}

const std::string& Client::getApplicationName()
{
    return mAppName;
}

const std::string& Client::getServerName()
{
    return mServerName;
}
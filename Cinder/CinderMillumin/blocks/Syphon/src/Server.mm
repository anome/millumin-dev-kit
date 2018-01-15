#import <Syphon/Syphon.h>

#include "Server.h"

using namespace reza::syphon;

Server::Server() : mServer(nullptr), mBinded(false)
{

}

Server::~Server()
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
    [(SyphonServer *)mServer stop];
    [(SyphonServer *)mServer release];
    
    [pool drain];
}


void Server::setName( const std::string& name )
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
	NSString *title = [NSString stringWithCString:name.c_str() encoding:[NSString defaultCStringEncoding]];
	
	if( !mServer ) {
        mServer = [[SyphonServer alloc] initWithName:title context:CGLGetCurrentContext() options:@{ SyphonServerOptionAntialiasSampleCount : @(0) } ];
	} else {
		[(SyphonServer *)mServer setName:title];
	}
    
    [pool drain];
}

std::string Server::getName()
{
	std::string name;
	if( mServer ) {
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		
		name = [[(SyphonServer *)mServer name] cStringUsingEncoding:[NSString defaultCStringEncoding]];
		
		[pool drain];
	} else {
		name = "Untitled";
	}
	return name;
}

void Server::publishScreen()
{
	ci::gl::TextureRef mTex = ci::gl::Texture::create( ci::app::copyWindowSurface() );
	this->publishTexture( mTex );
}

void Server::publishTexture( ci::gl::TextureRef texture )
{
	if( texture ) {
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
		GLuint texID = texture->getId();
        
		if( !mServer ) {
			mServer = [[SyphonServer alloc] initWithName:@"Untitled" context:CGLGetCurrentContext() options:nil];
		}

        
        [(SyphonServer *)mServer publishFrameTexture:texID
                                       textureTarget: texture->getTarget()
                                         imageRegion:NSMakeRect( 0, 0, texture->getWidth(), texture->getHeight() ) textureDimensions:NSMakeSize( texture->getWidth(), texture->getHeight() ) flipped:true ];

		[pool drain];
	} else {
        std::cout << "Server is not setup, or texture is not properly backed. Cannot draw.\n" << std::endl;
	}
}

bool Server::bind( glm::vec2 size )
{
    mBinded = [(SyphonServer *)mServer bindToDrawFrameOfSize:NSMakeSize( size.x, size.y )];
    return mBinded;
}

void Server::unbind()
{
    if( mBinded )
    {
        [(SyphonServer *)mServer unbindAndPublish];
        mBinded = false;
    } else {
        std::cout << "Server FBO bind unsuccessful, Server unbinded." << std::endl;
    }
}


















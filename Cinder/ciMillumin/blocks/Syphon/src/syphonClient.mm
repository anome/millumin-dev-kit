/*
 syphonClient.mm
 Cinder Syphon Implementation
 
 Created by astellato on 2/6/11
 
 Copyright 2011 astellato, bangnoise (Tom Butterworth) & vade (Anton Marini).
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "syphonClient.h"

#import <Syphon/Syphon.h>
#import "SyphonNameboundClient.h"

syphonClient::syphonClient()
{
	bSetup = false;
}

syphonClient::~syphonClient()
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
    [(SyphonNameboundClient*)mClient release];
    mClient = nil;
    
    [pool drain];
}

void syphonClient::setup()
{
    // Need pool
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	mClient = [[SyphonNameboundClient alloc] init]; 
	
	bSetup = true;
    
    [pool drain];
}

void syphonClient::setApplicationName(std::string appName)
{
    if(bSetup)
    {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
        NSString *name = [NSString stringWithCString:appName.c_str() encoding:[NSString defaultCStringEncoding]];
        
        [(SyphonNameboundClient*)mClient setAppName:name];
		
        [pool drain];
    }
    
}
void syphonClient::setServerName(std::string serverName)
{
    if(bSetup)
    {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
        NSString *name = [NSString stringWithCString:serverName.c_str() encoding:[NSString defaultCStringEncoding]];
		
        if([name length] == 0)
            name = nil;
        
        [(SyphonNameboundClient*)mClient setName:name];
		
        [pool drain];
    }    
}

void syphonClient::bind()
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
    if(bSetup)
    {
     	[(SyphonNameboundClient*)mClient lockClient];
        SyphonClient *client = [(SyphonNameboundClient*)mClient client];
		
        latestImage = [client newFrameImageForContext:CGLGetCurrentContext()];
		NSSize texSize = [(SyphonImage*)latestImage textureSize];
		GLuint m_id = [(SyphonImage*)latestImage textureName];

		mTex = new ci::gl::Texture(GL_TEXTURE_RECTANGLE_ARB, m_id,
								   texSize.width, texSize.height, false);
		mTex->setFlipped();
		
		mTex->bind();
    }
    else
		std::cout<<"syphonClient is not setup, or is not properly connected to server.  Cannot bind.\n";
    
    [pool drain];
}

void syphonClient::unbind()
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if(bSetup)
    {
        mTex->unbind();
		
        [(SyphonNameboundClient*)mClient unlockClient];
        [(SyphonImage*)latestImage release];
        latestImage = nil;
    }
    else
		std::cout<<"syphonClient is not setup, or is not properly connected to server.  Cannot unbind.\n";
	
	[pool drain];
}

void syphonClient::draw(ci::Vec2f origin, ci::Vec2f drawSize){
	draw(origin.x, origin.y, drawSize.x, drawSize.y);
}

void syphonClient::draw(ci::Vec2f origin){
	draw(origin.x, origin.y);
}

void syphonClient::draw(float x, float y, float w, float h)
{
	if(bSetup && mTex){
		this->bind();
		ci::gl::draw(*mTex, ci::Rectf(x, y, x + w, y + h));
		this->unbind();
	}
}

void syphonClient::draw(float x, float y)
{
	if(bSetup && mTex){
		this->bind();
		ci::gl::draw(*mTex,ci::Vec2f(x, y));
		this->unbind();
	}
}

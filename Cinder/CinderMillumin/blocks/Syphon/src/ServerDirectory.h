#pragma once

#include "cinder/Cinder.h"
#include "Cinder/Signals.h"
#include <algorithm>

namespace reza { namespace syphon {

class ServerDescription {
public:
    ServerDescription() : mServerName("null"), mAppName("null") { }
    ServerDescription( const std::string& serverName, const std::string& appName ) : mServerName( serverName ), mAppName( appName ) { }
    
    friend bool operator == ( const ServerDescription& lhs, const ServerDescription& rhs ) {
        return ( lhs.mServerName == rhs.mServerName) && ( lhs.mAppName == rhs.mAppName );
    }
    
    std::string mServerName, mAppName;
};

    
typedef ci::signals::Signal<void( std::vector<ServerDescription> )> SyphonServerAnnouncedSignal;
typedef ci::signals::Signal<void( std::vector<ServerDescription> )> SyphonServerUpdatedSignal;
typedef ci::signals::Signal<void( std::vector<ServerDescription> )> SyphonServerRetiredSignal;

class ServerDirectory {
public:
	ServerDirectory();
	~ServerDirectory();
	
    void setup();
    bool isSetup();
    int size();
    
    bool isValidIndex( int _idx );
    bool serverExists( const std::string& serverName, const std::string& appName );
    bool serverExists( const ServerDescription& server );
    ServerDescription& getDescription( int _idx );
    
    std::vector<ServerDescription>& getServerList();
    void printList();
	SyphonServerAnnouncedSignal* getServerAnnouncedSignal();
    SyphonServerUpdatedSignal* getServerUpdatedSignal();
    SyphonServerRetiredSignal* getServerRetiredSignal();
    
    //needs to be public because of the nature of CFNotifications.  please do not call this.
    void handleNotification(CFStringRef name, CFDictionaryRef userInfo);
	
private:
    void refresh( bool isAnnounce );
    void serverAnnounced();
    void serverUpdated();
    void serverRetired();
    
    void addObservers();
    void removeObservers();
    
    bool CFStringRefToString( CFStringRef src, std::string &dest );
    
	bool mSetup;
    std::vector<ServerDescription> mServerList;
    
    SyphonServerAnnouncedSignal mAnnouncedSignal;
    SyphonServerUpdatedSignal mUpdatedSignal;
    SyphonServerRetiredSignal mRetiredSignal;
};

} } // namespace reza::syphon
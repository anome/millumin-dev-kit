#import <Syphon/Syphon.h>
#include "ServerDirectory.h"

using namespace reza::syphon;

static void notificationHandler(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    (static_cast<ServerDirectory *>(observer))->handleNotification(name, userInfo);
}

ServerDirectory::ServerDirectory()
{
    mSetup = false;
}

ServerDirectory::~ServerDirectory()
{
    if( mSetup ) {
        removeObservers();
    }
}

bool ServerDirectory::isValidIndex( int _idx )
{
    return ( _idx < mServerList.size() );
}

void ServerDirectory::setup()
{
    if( !mSetup ) {
        mSetup = true;
        addObservers();
        refresh( true );
    }
}

bool ServerDirectory::isSetup()
{
    return mSetup;
}

void ServerDirectory::refresh( bool isAnnounce )
{
    std::vector<ServerDescription> eventArgs;
    
    for(NSDictionary* serverDescription in [[SyphonServerDirectory sharedDirectory] servers])
    {
        NSString* name = [serverDescription objectForKey:SyphonServerDescriptionNameKey];
        NSString* appName = [serverDescription objectForKey:SyphonServerDescriptionAppNameKey];
        
        if( isAnnounce ) {
            bool exists = serverExists( [name UTF8String], [appName UTF8String] );
            if(!exists){
                ServerDescription sy = ServerDescription(std::string([name UTF8String]),std::string([appName UTF8String]));
                mServerList.push_back(sy);
                eventArgs.push_back(sy);
                std::cout<<"Adding server: "<<std::string([name UTF8String])<<" appName: "<< std::string([appName UTF8String])<<"\n";
            }
        } else {
            eventArgs.push_back(ServerDescription(std::string([name UTF8String]),std::string([appName UTF8String])));
        }
        
    }
    
    if( !isAnnounce ) {
        std::vector<ServerDescription> foundServers = eventArgs;
        eventArgs.clear();
        for( auto &it : mServerList ) {
            if( std::find( foundServers.begin(), foundServers.end(), ServerDescription( it.mServerName, it.mAppName ) ) == foundServers.end() ) {
                eventArgs.push_back( ServerDescription( it.mServerName, it.mAppName ) );
                std::cout << "Removing server: " << it.mServerName << " appName: " << it.mAppName<< "\n";
            }
        }
        mServerList = foundServers;
    }
    
    if(isAnnounce ) {
        mAnnouncedSignal.emit(eventArgs);
        /*mAnnouncedSignal( eventArgs );*/}
    else {
        
//        mRetiredSignal.emmit( eventArgs );
        mRetiredSignal.emit( eventArgs );
    
    }
}

bool ServerDirectory::serverExists( const std::string& serverName, const std::string& appName )
{
    return serverExists( ServerDescription( serverName, appName ) );
}

bool ServerDirectory::serverExists( const ServerDescription& server )
{
    for( auto& it : mServerList ) {
        if( it == server ) {
            return true;
        }
    }
    return false;
}

ServerDescription& ServerDirectory::getDescription( int idx )
{
    return mServerList.at( idx );
}

std::vector<ServerDescription>& ServerDirectory::getServerList()
{
    return mServerList;
}

void ServerDirectory::printList()
{
    for( auto& it : mServerList ) {
        std::cout << "serverName: " << it.mServerName << " appName: " << it.mAppName << "\n";
    }
}

int ServerDirectory::size()
{
    return mServerList.size();
}

SyphonServerAnnouncedSignal* ServerDirectory::getServerAnnouncedSignal()
{
    return &mAnnouncedSignal;
}

SyphonServerUpdatedSignal* ServerDirectory::getServerUpdatedSignal(){
    return &mUpdatedSignal;
}

SyphonServerRetiredSignal* ServerDirectory::getServerRetiredSignal(){
    return &mRetiredSignal;
}

// Unfortunately userInfo is null when dealing with CFNotifications from a Darwin notification center.  This is one of the few non-toll-free bridges between CF and NS.  Otherwise this class would be far less complicated.
void ServerDirectory::handleNotification( CFStringRef name, CFDictionaryRef userInfo )
{
    if( (NSString*)name == SyphonServerAnnounceNotification ) {
        serverAnnounced();
    } else if( (NSString*)name == SyphonServerUpdateNotification ) {
        serverUpdated();
    } else if( (NSString*)name == SyphonServerRetireNotification ) {
        serverRetired();
    }
}

void ServerDirectory::serverAnnounced()
{
    refresh( true );
}

void ServerDirectory::serverUpdated()
{
    //TODO
}

void ServerDirectory::serverRetired()
{
    refresh( false );
}

void ServerDirectory::addObservers()
{
    CFNotificationCenterAddObserver
    (
     CFNotificationCenterGetLocalCenter(),
     this,
     (CFNotificationCallback)&notificationHandler,
     (CFStringRef)SyphonServerAnnounceNotification,
     NULL,
     CFNotificationSuspensionBehaviorDeliverImmediately
     );
    
    CFNotificationCenterAddObserver
    (
     CFNotificationCenterGetLocalCenter(),
     this,
     (CFNotificationCallback)&notificationHandler,
     (CFStringRef)SyphonServerUpdateNotification,
     NULL,
     CFNotificationSuspensionBehaviorDeliverImmediately
     );
    
    CFNotificationCenterAddObserver
    (
     CFNotificationCenterGetLocalCenter(),
     this,
     (CFNotificationCallback)&notificationHandler,
     (CFStringRef)SyphonServerRetireNotification,
     NULL,
     CFNotificationSuspensionBehaviorDeliverImmediately
     );
}

void ServerDirectory::removeObservers()
{
    CFNotificationCenterRemoveEveryObserver( CFNotificationCenterGetLocalCenter(), this );
}

bool ServerDirectory::CFStringRefToString( CFStringRef src, std::string& dest )
{
    const char *cstr = CFStringGetCStringPtr( src, CFStringGetSystemEncoding() );
    if( !cstr )
    {
        CFIndex strLen = CFStringGetMaximumSizeForEncoding( CFStringGetLength(src) + 1, CFStringGetSystemEncoding() );
        char *allocStr = (char*) malloc( strLen );
        
        if( !allocStr ) {
            return false;
        }
        
        if( !CFStringGetCString( src, allocStr, strLen, CFStringGetSystemEncoding() ) ) {
            free( (void*)allocStr );
            return false;
        }
        
        dest = allocStr;
        free( (void*)allocStr );
        return true;
    }
    
    dest = cstr;
    return true;
}
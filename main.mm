#include <discord_rpc.h>
#include <discord_register.h>
#include <cinttypes>
#include <CoreFoundation/CoreFoundation.h>
#if __MAC_OS_VERSION_MIN_REQUIRED < MAC_OS_VERSION_10_15
#import "iTunes.h"
#else
#import "Music.h"
#endif

void LoadPresence(){
  DiscordRichPresence discordPresence;
  memset(&discordPresence, 0, sizeof(discordPresence));
#if __MAC_OS_VERSION_MIN_REQUIRED < MAC_OS_VERSION_10_15
  iTunesApplication* ITA=[SBApplication applicationWithBundleIdentifier:@"com.apple.itunes"];
  iTunesTrack* currentTrack=[ITA currentTrack];
#else
  MusicApplication* ITA=[SBApplication applicationWithBundleIdentifier:@"com.apple.Music"];
  MusicTrack* currentTrack=[ITA currentTrack];
#endif
  discordPresence.details = [currentTrack.name UTF8String];
  discordPresence.state = [currentTrack.artist UTF8String];
  time_t seconds=time(NULL);
  const char* dura=[currentTrack.time UTF8String];//In MM:SS format because the direct getter is broken
  if(dura==nil){
    return;
  }
  char min[3]={'\0'};
  char sec[3]={'\0'};
  memcpy(&min,dura,2);
  memcpy(&sec,&dura[2],2);
  discordPresence.startTimestamp = seconds+floor(ITA.playerPosition+0.5);
  discordPresence.endTimestamp = seconds+atoi(min)*60+atoi(sec)-floor(ITA.playerPosition+0.5);
  discordPresence.largeImageKey="itunes";
  discordPresence.smallImageKey="itunes";
  Discord_UpdatePresence(&discordPresence);
}
static void cb(CFNotificationCenterRef center, void *observer, CFNotificationName name, const void *object, CFDictionaryRef userInfo){
  LoadPresence();
}
void Ready_Discord(const DiscordUser* request){
  printf("Logged in as:%s\n",request->username);
}
void Error_Discord(int errorCode, const char* message){
  printf("Error Code:%i Error Message:%s\n",errorCode,message);
}
void Disconnect_Discord(int errorCode, const char* message){
  printf("Disconnect. Code:%i Error Message:%s\n",errorCode,message);
}
void Init_Discord(){
  DiscordEventHandlers handlers;
  memset(&handlers, 0, sizeof(handlers));
  handlers.ready = Ready_Discord;
  handlers.errored = Error_Discord;
  handlers.disconnected = Disconnect_Discord;

  Discord_Initialize("484524537095127050", &handlers,0,NULL);
}

int main(int argc, char const *argv[]) {
  Init_Discord();
  LoadPresence();
  NSTimer* tim=[NSTimer scheduledTimerWithTimeInterval:15 repeats:YES block:^void(NSTimer *timer){
    LoadPresence();
    return;
  }];
  CFNotificationCenterRef nc=CFNotificationCenterGetDistributedCenter();
  CFNotificationCenterAddObserver(nc,nullptr,cb,CFSTR("com.apple.iTunes.playerInfo"),nullptr,CFNotificationSuspensionBehaviorDeliverImmediately);
  [tim fire];
  [[NSRunLoop currentRunLoop] run];
  Discord_Shutdown();
  return 0;
}

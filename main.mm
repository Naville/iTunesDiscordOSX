#include <discord_rpc.h>
#include <discord_register.h>
#include <cinttypes>
#import "iTunes.h"

void LoadPresence(){
  DiscordRichPresence discordPresence;
  memset(&discordPresence, 0, sizeof(discordPresence));
  iTunesApplication* ITA=[SBApplication applicationWithBundleIdentifier:@"com.apple.itunes"];
  iTunesTrack* currentTrack=[ITA currentTrack];
  discordPresence.details = [currentTrack.name UTF8String];
  discordPresence.state = [currentTrack.artist UTF8String];
  discordPresence.startTimestamp = time(0)+static_cast<std::int64_t>(ITA.playerPosition);
  discordPresence.endTimestamp = time(0)+static_cast<std::int64_t>(currentTrack.duration);
  discordPresence.largeImageKey="itunes";
  discordPresence.smallImageKey="itunes";
  Discord_UpdatePresence(&discordPresence);
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
  [tim fire];
  [[NSRunLoop currentRunLoop] run];
  Discord_Shutdown();
  return 0;
}

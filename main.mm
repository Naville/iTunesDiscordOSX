#include <discord_rpc.h>
#include <discord_register.h>
#import <iTunesLibrary/ITLibrary.h>

void LoadPresence(){
  DiscordRichPresence discordPresence;
  memset(&discordPresence, 0, sizeof(discordPresence));

  Discord_UpdatePresence(&discordPresence);
}

void Ready_Discord(const DiscordUser* request){
  printf("Logged in as:%s",request->username);
}

void Init_Discord(){
  DiscordEventHandlers handlers;
  memset(&handlers, 0, sizeof(handlers));
  handlers.ready=Ready_Discord;


  Discord_Initialize("484524537095127050", &handlers, 1, "");
}

int main(int argc, char const *argv[]) {

  return 0;
}

/*
 *  common_configs.h
 *  hackerdjz
 *
 *  Created by Robert Diamond on 4/25/11.
 *  Copyright 2011 Robert M. Diamond. All rights reserved.
 *
 */
#import "uncommon_configs.h"
#define kYoutubeSearchURL  @"http://gdata.youtube.com/feeds/mobile/videos"
#define kYoutubeSearchBody @"q=%@"
#define kYoutubeGetPlaylistsURL  @"http://gdata.youtube.com/feeds/mobile/users/%@/playlists"
#define kYoutubeAddDelPlaylistsURL  @"http://gdata.youtube.com/feeds/api/users/%@/playlists"
#define kYoutubeGetPlaylistContentsURL  @"http://gdata.youtube.com/feeds/mobile/playlists/%@"
#define kYoutubeAddToPlaylistURL  @"http://gdata.youtube.com/feeds/api/playlists/%@"
#define kYoutubeModifyPlaylistURL  @"http://gdata.youtube.com/feeds/api/playlists/%@/%@"
#define kYoutubeEntryAtom  @"<?xml version='1.0' encoding='UTF-8'?><entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:yt=\"http://gdata.youtube.com/schemas/2007\"><id>%@</id></entry>"
#define kYoutubePlaylistEntryAtom @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>  \
<entry xmlns=\"http://www.w3.org/2005/Atom\"                                    \
xmlns:yt=\"http://gdata.youtube.com/schemas/2007\">                             \
<title type=\"text\">Sports Highlights Playlist</title>                         \
<summary>A selection of sports highlights</summary>                             \
</entry>"
#define kHackerzDJBackend  @"http://www.hackerzdj.com"
#define kHackerzDJBody     @"body=%@"
#define kClientAuthURL     @"https://www.google.com/accounts/ClientLogin"
#define kClientAuthBody    @"Email=%@&Passwd=%@&service=youtube&source=iPhone"
#define kClientCaptchaAuthBody @"Email=%@&Passwd=%@&service=youtube&source=iPhone&logincaptcha=%@&logintoken=%@"

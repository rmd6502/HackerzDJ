/*
 *  common_configs.h
 *  hackerdjz
 *
 *  Created by Robert Diamond on 4/25/11.
 *  Copyright 2011 Robert M. Diamond. All rights reserved.
 *
 */

#define kYoutubeSearchURL  @"http://gdata.youtube.com/feeds/mobile/videos"
#define kYoutubeSearchBody @"q=%@"
#define kYoutubeGetPlaylistsURL  @"http://gdata.youtube.com/feeds/mobile/users/%@/playlists"
#define kYoutubeGetPlaylistContentsURL  @"http://gdata.youtube.com/feeds/mobile/playlists/%@"
#define kYoutubeEntryAtom  @"<?xml version='1.0' encoding='UTF-8'?><entry><id>%@</id></entry>"
#define kYoutubeBodyCommon @"v=2&alt=json&key=AI39si7p1SnUM-1RdiPywA9_yUtoRnsE8MLtJHDQKoTBS4fgHUffPURZbloQjJd5Dd04OnY_mez4NVQ6NWXFEQOrUAcgRQ4pog"
#define kYoutubeDevKey     @"AI39si7p1SnUM-1RdiPywA9_yUtoRnsE8MLtJHDQKoTBS4fgHUffPURZbloQjJd5Dd04OnY_mez4NVQ6NWXFEQOrUAcgRQ4pog"
#define kHackerzDJBackend  @"http://www.hackerzdj.com"
#define kHackerzDJBody     @"body=%@"
#define kClientAuthURL     @"https://www.google.com/accounts/ClientLogin"
#define kClientAuthBody    @"Email=%@&Passwd=%@&service=youtube&source=iPhone"
#define kClientAuthUsername @"hackerzdj"
#define kClientAuthPassword @"capricadj"

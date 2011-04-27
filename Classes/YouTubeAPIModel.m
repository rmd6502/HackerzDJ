//
//  YouTubeAPIModel.m
//  hackerdjz
//
//  Created by Robert Diamond on 4/26/11.
//  Copyright 2011 none. All rights reserved.
//

#import "YouTubeAPIModel.h"
#import "Reachability.h"
#import "WebRequest.h"

@implementation YouTubeAPIModel
+ (BOOL)addToQueue:(BaseRequest *)request description:(NSString *)description {
    if ([[Reachability sharedReachability] hasConnection]) {
        [[NSOperationQueue currentQueue] addOperation:request];
        return YES;
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Can't %@",description] message:@"You are not connected to the internet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[av show];
		[av release];
		return NO;
    }
}
+ (BOOL)getPlaylistsWithDelegate:(id<WebRequestDelegate,NSObject>)delegate {
	WebRequest *req = [[WebRequest alloc]init];
    req.url = [NSString stringWithFormat:@"%@?%@",[NSString stringWithFormat:kYoutubeGetPlaylistsURL,@"hackerzdj"],kYoutubeBodyCommon];
    req.delegate = delegate;
    
    BOOL ret = [YouTubeAPIModel addToQueue:req description:@"Get Playlists"];
    [req release];
    return ret;
}

+ (BOOL)getContentsOfPlaylist:(NSString *)playlistId delegate:(id<WebRequestDelegate,NSObject>)delegate {
	WebRequest *req = [[WebRequest alloc]init];
    req.url = [NSString stringWithFormat:@"%@?%@",[NSString stringWithFormat:kYoutubeGetPlaylistContentsURL,playlistId],kYoutubeBodyCommon];
    req.delegate = delegate;
    
    BOOL ret = [YouTubeAPIModel addToQueue:req description:@"Get Playlist Contents"];
    [req release];
    return ret;
}

+ (BOOL)videoSearch:(NSString *)search delegate:(id<WebRequestDelegate,NSObject>)delegate {
	NSString *query = [search stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    WebRequest *req = [[WebRequest alloc]init];
    req.url = [NSString stringWithFormat:@"%@?%@&%@",kYoutubeSearchURL,[NSString stringWithFormat:kYoutubeSearchBody,query],kYoutubeBodyCommon];
    req.delegate = delegate;
    
    BOOL ret = [YouTubeAPIModel addToQueue:req description:@"Search"];
    [req release];
	
	return ret;
}

+ (BOOL)addVideo:(NSString *)videoID toPlaylist:(NSString *)playlistId delegate:(id<WebRequestDelegate,NSObject>)delegate {
	return NO;
}

@end

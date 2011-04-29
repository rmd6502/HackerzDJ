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
#import "YoutubeClientAuth.h"

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

+ (BOOL)addVideo:(NSString *)videoID toPlaylist:(NSString *)playlistId authKey:(NSString *)authKey delegate:(id<WebRequestDelegate,NSObject>)delegate {
	BOOL ret = YES;
	
	WebRequest *req = [[WebRequest alloc]init];
	req.delegate = delegate;
	req.selector = @selector(videoAdded:result:);
	req.url = [NSString stringWithFormat:kYoutubeGetPlaylistContentsURL, videoID];
	req.httpMethod = @"POST";
	req.headers = [NSDictionary dictionaryWithObjectsAndKeys:
				   [NSString stringWithFormat:@"AuthSub token=\"%@\"", authKey], @"Authorization",
				   [NSString stringWithFormat:@"key=%@", kYoutubeDevKey], @"X-GData-Key",
				   @"application/atom+xml", @"Content-Type",
				   @"2", @"GData-Version",
				   nil];
	req.httpBody = [[NSString stringWithFormat:kYoutubeEntryAtom, videoID] dataUsingEncoding:NSASCIIStringEncoding];
	ret = [YouTubeAPIModel addToQueue:req description:@"Add to Playlist"];
	return ret;
}

+ (BOOL)clientAuthWithDelegate:(id<WebRequestDelegate,NSObject>)delegate {
	YoutubeClientAuth *req = [[YoutubeClientAuth alloc]init];
	req.target = delegate;
	req.tselector = @selector(clientAuthComplete:authKey:userData:);
	BOOL ret = [YouTubeAPIModel addToQueue:req description:@"Authenticate"];
    [req release];
    return ret;
}

@end

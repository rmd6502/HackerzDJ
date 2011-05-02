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
@synthesize authKey;

+ (YouTubeAPIModel *)sharedAPIModel {
    static YouTubeAPIModel *s_model = nil;
    if (s_model == nil) {
        s_model = [[YouTubeAPIModel alloc]init];
    }
    return s_model;
}

- (BOOL)addToQueue:(BaseRequest *)request description:(NSString *)description {
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
- (BOOL)getPlaylistsWithDelegate:(id<WebRequestDelegate,NSObject>)delegate {
	WebRequest *req = [[WebRequest alloc]init];
    req.url = [NSString stringWithFormat:@"%@?%@",[NSString stringWithFormat:kYoutubeGetPlaylistsURL,@"hackerzdj"],kYoutubeBodyCommon];
    req.delegate = delegate;
	req.selector = @selector(playlists:result:);
    
	if ([[Reachability sharedReachability] hasConnection] || [[NSOperationQueue currentQueue] operationCount] < 2) {
		[[NSOperationQueue currentQueue] addOperation:req];
	}
    [req release];
    return YES;
}

- (BOOL)getContentsOfPlaylist:(NSString *)playlistId delegate:(id<WebRequestDelegate,NSObject>)delegate {
	WebRequest *req = [[WebRequest alloc]init];
    req.url = [NSString stringWithFormat:@"%@?%@&max-results=50",[NSString stringWithFormat:kYoutubeGetPlaylistContentsURL,playlistId],kYoutubeBodyCommon];
    req.delegate = delegate;
    
    BOOL ret = [self addToQueue:req description:@"Get Playlist Contents"];
    [req release];
    return ret;
}

- (BOOL)videoSearch:(NSString *)search category:(NSString *)category delegate:(id<WebRequestDelegate,NSObject>)delegate {
	NSString *query = [search stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    WebRequest *req = [[WebRequest alloc]init];
    NSString *categoryQuery = @"";
    if ([category compare:@""] != NSOrderedSame) {
        categoryQuery = [NSString stringWithFormat:@"&category=%@",category];
    }
    req.url = [NSString stringWithFormat:@"%@?%@&%@%@",kYoutubeSearchURL,[NSString stringWithFormat:kYoutubeSearchBody,query],kYoutubeBodyCommon,categoryQuery];
    req.delegate = delegate;
    
    BOOL ret = [self addToQueue:req description:@"Search"];
    [req release];
	
	return ret;
}

- (BOOL)addVideo:(NSString *)videoID toPlaylist:(NSString *)playlistId delegate:(id<WebRequestDelegate,NSObject>)delegate {
	BOOL ret = YES;
	
	WebRequest *req = [[WebRequest alloc]init];
	req.delegate = delegate;
	req.selector = @selector(videoAdded:result:);
	req.url = [NSString stringWithFormat:kYoutubeAddToPlaylistURL, playlistId];
	req.httpMethod = @"POST";
	req.headers = [NSDictionary dictionaryWithObjectsAndKeys:
				   [NSString stringWithFormat:@"GoogleLogin auth=\"%@\"", authKey], @"Authorization",
				   [NSString stringWithFormat:@"key=%@", kYoutubeDevKey], @"X-GData-Key",
				   @"application/atom+xml", @"Content-Type",
				   @"2", @"GData-Version",
				   nil];
	req.httpBody = [[NSString stringWithFormat:kYoutubeEntryAtom, videoID] dataUsingEncoding:NSASCIIStringEncoding];
	ret = [self addToQueue:req description:@"Add to Playlist"];
	return ret;
}

- (BOOL)removeVideo:(NSString *)videoID fromPlaylist:(NSString *)playlistId indexPath:(NSIndexPath *)indexPath delegate:(id<WebRequestDelegate,NSObject>)delegate {
	BOOL ret = YES;
	
	WebRequest *req = [[WebRequest alloc]init];
	req.delegate = delegate;
	req.selector = @selector(videoRemoved:result:);
	req.url = [NSString stringWithFormat:@"%@?%@", [NSString stringWithFormat:kYoutubeModifyPlaylistURL, playlistId, videoID], kYoutubeBodyCommon];
	req.httpMethod = @"DELETE";
	req.headers = [NSDictionary dictionaryWithObjectsAndKeys:
				   [NSString stringWithFormat:@"GoogleLogin auth=\"%@\"", authKey], @"Authorization",
				   [NSString stringWithFormat:@"key=%@", kYoutubeDevKey], @"X-GData-Key",
				   @"application/atom+xml", @"Content-Type",
				   @"2", @"GData-Version",
                   @"gdata.youtube.com",@"Host",
				   nil];
    req.userData = indexPath;
	
	ret = [self addToQueue:req description:@"Remove from Playlist"];
	return ret;
}

- (BOOL)clientAuthWithDelegate:(id<WebRequestDelegate,NSObject>)delegate {
	YoutubeClientAuth *req = [[YoutubeClientAuth alloc]init];
	req.target = delegate;
	req.tselector = @selector(clientAuthComplete:authKey:userData:);
	BOOL ret = [self addToQueue:req description:@"Authenticate"];
    [req release];
    return ret;
}

@end

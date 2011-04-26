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

+ (BOOL)getPlaylistsWithDelegate:(id<WebRequestDelegate,NSObject>)delegate {
	return NO;
}

+ (BOOL)getContentsOfPlaylist:(NSString *)playlistId delegate:(id<WebRequestDelegate,NSObject>)delegate {
	return NO;
}

+ (BOOL)videoSearch:(NSString *)search delegate:(id<WebRequestDelegate,NSObject>)delegate {
	NSString *query = [search stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	if ([[Reachability sharedReachability] hasConnection]) {
		WebRequest *req = [[WebRequest alloc]init];
		req.url = [NSString stringWithFormat:@"%@?%@&%@",kYoutubeSearchURL,[NSString stringWithFormat:kYoutubeSearchBody,query],kYoutubeBodyCommon];
		req.delegate = delegate;
		
		[[NSOperationQueue currentQueue] addOperation:req];
		[req release];
	} else {
		UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Can't Search" message:@"You are not connected to the internet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[av show];
		[av release];
		return NO;
	}
	
	return YES;
}

+ (BOOL)addVideo:(NSString *)videoID toPlaylist:(NSString *)playlistId delegate:(id<WebRequestDelegate,NSObject>)delegate {
	return NO;
}

@end

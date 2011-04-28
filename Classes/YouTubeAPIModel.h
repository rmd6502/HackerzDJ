//
//  YouTubeAPIModel.h
//  hackerdjz
//
//  Created by Robert Diamond on 4/26/11.
//  Copyright 2011 none. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebRequestDelegate.h"

@interface YouTubeAPIModel : NSObject {
}

+ (BOOL)addToQueue:(BaseRequest *)request description:(NSString *)description;
+ (BOOL)getPlaylistsWithDelegate:(id<WebRequestDelegate,NSObject>)delegate;
+ (BOOL)getContentsOfPlaylist:(NSString *)playlistId delegate:(id<WebRequestDelegate,NSObject>)delegate;
+ (BOOL)videoSearch:(NSString *)search delegate:(id<WebRequestDelegate,NSObject>)delegate;
+ (BOOL)addVideo:(NSString *)videoID toPlaylist:(NSString *)playlistId authKey:(NSString *)authKey delegate:(id<WebRequestDelegate,NSObject>)delegate;
+ (BOOL)clientAuthWithDelegate:(id<WebRequestDelegate,NSObject>)delegate;

@end

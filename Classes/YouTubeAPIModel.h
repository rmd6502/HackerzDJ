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

@property (nonatomic,copy) NSString *authKey;

+ (YouTubeAPIModel *)sharedAPIModel;

- (BOOL)addToQueue:(BaseRequest *)request description:(NSString *)description;
- (BOOL)getPlaylistsWithDelegate:(id<WebRequestDelegate,NSObject>)delegate;
- (BOOL)getContentsOfPlaylist:(NSString *)playlistId delegate:(id<WebRequestDelegate,NSObject>)delegate;
- (BOOL)videoSearch:(NSString *)search category:(NSString *)category delegate:(id<WebRequestDelegate,NSObject>)delegate;
- (BOOL)addVideo:(NSString *)videoID toPlaylist:(NSString *)playlistId delegate:(id<WebRequestDelegate,NSObject>)delegate;
- (BOOL)removeVideo:(NSString *)videoID fromPlaylist:(NSString *)playlistId indexPath:(NSIndexPath *)indexPath delegate:(id<WebRequestDelegate,NSObject>)delegate;
- (BOOL)clientAuthWithDelegate:(id<WebRequestDelegate,NSObject>)delegate;
- (BOOL)addPlaylist:(NSString *)title description:(NSString *)description tags:(NSString *)tags delegate:(id<NSObject,WebRequestDelegate>)delegate;
- (BOOL)removePlaylist:(NSString *)playlistId delegate:(id<NSObject,WebRequestDelegate>)delegate;

@end

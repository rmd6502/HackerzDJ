//
//  Reachability.h
//  patch
//
//  Created by Robert Diamond on 2/7/11.
//  Copyright 2011 Patch.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#define kNotificationReachability @"Reachability"
#define kNotificationFlags        @"Flags"

@interface Reachability : NSObject {
	SCNetworkReachabilityFlags flags;
	SCNetworkReachabilityRef reachability;
}

@property (readonly) SCNetworkReachabilityFlags reachabilityFlags;
@property (readonly) BOOL hasConnection;
@property (readonly) NSURL *testURL;

+ (Reachability *)sharedReachability;
+ (BOOL)testReachability:(SCNetworkReachabilityFlags)flags_;

- (id)initWithURL:(NSString *)urlString;
- (void)startNetworkThread;
- (void)reachabilityChanged:(NSNotification *)notif;
@end

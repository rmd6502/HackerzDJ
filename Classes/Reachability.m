//
//  Reachability.m
//  patch
//
//  Created by Robert Diamond on 2/7/11.
//  Copyright 2011 Patch.com. All rights reserved.
//

#import "Reachability.h"
#import "SynthesizeSingleton.h"

void reachabilityCallBack(SCNetworkReachabilityRef target,
						  SCNetworkReachabilityFlags flags,
						  void *info);

@implementation Reachability
@synthesize reachabilityFlags = flags;
@synthesize testURL;

SYNTHESIZE_SINGLETON_FOR_CLASS(Reachability);

- (id)initWithURL:(NSString *)urlString {
	if ((self = [super init]) != nil) {
		testURL = [[NSURL alloc] initWithString:urlString];
		flags = kSCNetworkReachabilityFlagsReachable;
		[self startNetworkThread];
	}
	
	return self;
}

- (void) dealloc {
	SCNetworkReachabilityUnscheduleFromRunLoop(reachability, [[NSRunLoop mainRunLoop] getCFRunLoop], kCFRunLoopDefaultMode);
	CFRelease(reachability);
	reachability = NULL;
	[testURL release];
	[super dealloc];
}

+ (BOOL)testReachability:(SCNetworkReachabilityFlags)flags_ {
	return (flags_ & kSCNetworkReachabilityFlagsReachable) != 0;
}

- (BOOL)hasConnection {
	return [Reachability testReachability:flags];
}

- (void)startNetworkThread {
	NSString *testHost = [testURL host];
	LOG_DEBUG(@"article host %@", testHost);
	reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [testHost UTF8String]);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kNotificationReachability object:nil];
	if (!SCNetworkReachabilitySetCallback(reachability, reachabilityCallBack, nil)) {
		NSLog(@"Could not set reachability callback!");
		CFRelease(reachability);
		reachability = NULL;
		return;
	}
	if (!SCNetworkReachabilityScheduleWithRunLoop(reachability, [[NSRunLoop mainRunLoop] getCFRunLoop], kCFRunLoopDefaultMode)) {
		NSLog(@"Could not schedule reachability run loop!");
		CFRelease(reachability);
		reachability = NULL;
		return;
	}
	
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@(reachabilityCallback:) name:kPatchReachability object:nil];
}

- (void)reachabilityChanged:(NSNotification *)notif {
	NSDictionary *dict = [notif object];
	flags = [(NSNumber *)[dict objectForKey:kNotificationFlags] intValue];
}

@end

void reachabilityCallBack(SCNetworkReachabilityRef target,
						  SCNetworkReachabilityFlags flags,
						  void *info) {
	
	// Pool is not strictly necessary, but we may end up invoking from a thread other than main
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	LOG_DEBUG(@"new flags: %d", flags);
	NSNotification *notif = [NSNotification notificationWithName:kNotificationReachability 
														  object:[NSDictionary dictionaryWithObjectsAndKeys:
																  [NSNumber numberWithInt:flags], kNotificationFlags, nil]];
	
	[[NSNotificationCenter defaultCenter] postNotification:notif];
	
	[pool drain];
}

//
//  WebRequest.m
//  patch
//
//  Created by Robert Diamond on 1/24/11.
//  Copyright 2011 Patch.com. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"
#import "WebRequest.h"
#import "BaseRequest.h"

static BOOL g_isConnected = NO;

@interface WebRequest()

- (void)connection:(NSURLConnection *)connection_ didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection_ didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection_;
- (void)connection:(NSURLConnection *)connection_ didReceiveResponse:(NSURLResponse *)response;

- (void)finishSuccess:(BOOL)succeeded;
@end

@implementation WebRequest
@synthesize isFinished;
@synthesize urlData;
@synthesize url;
@synthesize httpBody;
@synthesize contentType;
@synthesize needsConnection = __needsConnection;
@synthesize responseCode;

#pragma mark -
#pragma mark Life Cycle
- (id)init {
	if ((self = [super init]) != nil) {
		self.isFinished = NO;
		__needsConnection = YES;
		httpMethod = @"GET";
		g_isConnected = [[Reachability sharedReachability] hasConnection];
	}

	return self;
}

- (void)dealloc {
	//PATCH_LOG_DEBUG(@"web request dealloc");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.error = nil;
	self.url = nil;
	self.urlData = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark NSOperation
- (void)main {
	NSAssert(NO, @"Attempt to instantiate abstract WebRequest class");
}

- (BOOL)isReady {
	BOOL ret = [super isReady] && (!__needsConnection || g_isConnected);
	PATCH_LOG_DEBUG(@"self %@ needs connection %d isConnected %d ret %d", self, __needsConnection, g_isConnected, ret);
	return ret;
}

- (BOOL)isFinished {
	PATCH_LOG_DEBUG(@"self %@ finished %d", self, isFinished);
	return isFinished;
}

- (BOOL)isConcurrent {
	return YES;
}

- (BOOL)isExecuting {
	return !isFinished;
}

- (void)start {
	if (url == nil || [self isCancelled]) {
		[self finishSuccess:NO];
		return;
	}
	PATCH_LOG_DEBUG(@"URL: %@", self.url);
	NSURL *myUrl = [NSURL URLWithString:self.url]; 
	PATCH_LOG_DEBUG(@"cookies for request %@: %@", myUrl, [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:myUrl]);
	NSMutableURLRequest *fetchRequest = [NSMutableURLRequest requestWithURL:myUrl
												  cachePolicy:NSURLRequestUseProtocolCachePolicy
											  timeoutInterval:10.0f];
	fetchRequest.HTTPMethod = httpMethod;
	if (self.httpBody != nil) {
		fetchRequest.HTTPBody = httpBody;
	}
	
	if (self.contentType) {
		[fetchRequest setValue:self.contentType forHTTPHeaderField:@"Content-Type"];
	}
	
	self.urlData = [NSMutableData dataWithCapacity:10000];
	[self willChangeValueForKey:@"isExecuting"];
	self.isFinished = NO;
	[self didChangeValueForKey:@"isExecuting"];
	// warning: this retains self!
	myConnection = [[NSURLConnection alloc] initWithRequest:fetchRequest delegate:self];	//conn:1 self:3
	[myConnection start];	//2
}

- (void)finishSuccess:(BOOL)succeeded {
	if (self.delegate && 
		([self.delegate respondsToSelector:@selector(operation:requestFinished:)] ||
		 [self.delegate respondsToSelector:self.selector])
		 ) {
		[self invokeDelegateWithResult:succeeded];
	}
	PATCH_LOG_DEBUG(@"finishing, success %d", succeeded);
	[self willChangeValueForKey:@"isFinished"];
	[self willChangeValueForKey:@"isExecuting"];
	self.isFinished = YES;
	[self didChangeValueForKey:@"isFinished"];
	[self didChangeValueForKey:@"isExecuting"];
}

#pragma mark -
#pragma mark NSURLConnection
- (void)connection:(NSURLConnection *)connection_ didFailWithError:(NSError *)error_ {
	PATCH_LOG_DEBUG(@"failed: %@", error_);
	self.error = error_;
	//[self.urlData release];
	self.urlData = nil;
	[self finishSuccess:NO];
	if (self.delegate && 
		([self.delegate respondsToSelector:@selector(operation:requestFinished:)] ||
		 [self.delegate respondsToSelector:self.selector])
		) {
		[self invokeDelegateWithResult:NO];
	}
	[connection_ release];
	myConnection = nil;
}

- (void)connection:(NSURLConnection *)connection_ didReceiveData:(NSData *)data {
	if ([self isCancelled]) {
		[connection_ cancel];
		return;
	}
	//PATCH_LOG_DEBUG(@"data %d bytes", [data length]);
	[self.urlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection_ {
	PATCH_LOG_DEBUG(@"%@ finished loading", self);
	[self finishSuccess:YES];
	
	[connection_ release];
	myConnection = nil;
}

- (void)connection:(NSURLConnection *)connection_ didReceiveResponse:(NSURLResponse *)response {
	PATCH_LOG_DEBUG(@"received response %@(%d)", 
					[(NSHTTPURLResponse *)response allHeaderFields],
					[(NSHTTPURLResponse *)response statusCode]);
	responseCode = [(NSHTTPURLResponse *)response statusCode];
	[urlData setLength:0];
}

@end

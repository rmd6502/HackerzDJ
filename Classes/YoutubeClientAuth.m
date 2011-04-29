//
//  YoutubeClientAuth.m
//  hackerdjz
//
//  Created by Robert Diamond on 4/28/11.
//  Copyright 2011 none. All rights reserved.
//

#import "YoutubeClientAuth.h"


@implementation YoutubeClientAuth
@synthesize target;
@synthesize tselector;

- (id)init {
	if ((self = [super init]) != nil) {
		self.url = kClientAuthURL;
		self.httpBody = [[NSString stringWithFormat:kClientAuthBody,kClientAuthUsername,kClientAuthPassword] dataUsingEncoding:NSASCIIStringEncoding];
		self.httpMethod = @"POST";
		self.delegate = self;
		self.contentType = @"application/x-www-form-urlencoded";
	}
	return self;
}

#pragma mark -
#pragma mark WebRequestDelegate
- (void)operation:(BaseRequest *)request requestFinished:(BOOL)success {
	NSString *authKey = @"";
	if (success) {
		NSString *keys = [[NSString alloc] initWithData:[(WebRequest *)request urlData] encoding:NSUTF8StringEncoding];
		LOG_DEBUG(@"keys %@", keys);
        for (NSString *comps in [keys componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
            NSArray *vals = [comps componentsSeparatedByString:@"="];
            if ([[vals objectAtIndex:0] caseInsensitiveCompare:@"Auth"] == NSOrderedSame) {
                authKey = [vals objectAtIndex:1];
                break;
            }
        }
		[keys release];
	}
	if ([target respondsToSelector:tselector]) {
		[target performSelector:tselector withObject:[NSNumber numberWithBool:success] withObject:authKey];
	}
}

@end

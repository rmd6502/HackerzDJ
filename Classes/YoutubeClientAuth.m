//
//  YoutubeClientAuth.m
//  hackerdjz
//
//  Created by Robert Diamond on 4/28/11.
//  Copyright 2011 none. All rights reserved.
//

#import <objc/objc.h>
#import "YoutubeClientAuth.h"


@implementation YoutubeClientAuth
@synthesize target;
@synthesize tselector;
@synthesize captcha_callback;
@synthesize captchaToken;
@synthesize captchaText;

- (id)init {
	if ((self = [super init]) != nil) {
		self.url = kClientAuthURL;
		NSString *httpBody = nil;
		
		if (captchaToken != nil) {
			httpBody = [NSString stringWithFormat:kClientCaptchaAuthBody,kClientAuthUsername,kClientAuthPassword,captchaToken,captchaText];			
		} else {
			httpBody = [NSString stringWithFormat:kClientAuthBody,kClientAuthUsername,kClientAuthPassword];
		}

		self.httpBody = [httpBody dataUsingEncoding:NSASCIIStringEncoding];		
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
	NSMutableDictionary *responses = [NSMutableDictionary dictionary];
	if (success) {
		NSString *keys = [[NSString alloc] initWithData:[(WebRequest *)request urlData] encoding:NSUTF8StringEncoding];
		LOG_DEBUG(@"keys %@", keys);
        for (NSString *comps in [keys componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
            NSArray *vals = [comps componentsSeparatedByString:@"="];
			if ([vals count] < 2) continue;
			[responses setObject:[vals objectAtIndex:1] forKey:[vals objectAtIndex:0]];
		}
		[keys release];
	}
	authKey = [responses objectForKey:@"Auth"];
	if (authKey != nil) {
		if ([target respondsToSelector:tselector]) {
			objc_msgSend(target, tselector, [NSNumber numberWithBool:success], authKey, self.userData);
			//[target performSelector:tselector withObject:[NSNumber numberWithBool:success] withObject:authKey];
		}
	} else {
		if ([target respondsToSelector:captcha_callback]) {
			objc_msgSend(target, captcha_callback, 
						 [responses objectForKey:@"CaptchaUrl"], 
						 [responses objectForKey:@"CaptchaToken"], 
						 self.userData);
		}
	}
}

@end

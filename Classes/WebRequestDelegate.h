/*
 *  WebRequestDelegate.h
 *  patch
 *
 *  Created by Robert Diamond on 1/24/11.
 *  Copyright 2011 Patch.com. All rights reserved.
 *
 */

@class BaseRequest;
@protocol WebRequestDelegate

@required
- (void)operation:(BaseRequest *)request requestFinished:(BOOL)success;

@end
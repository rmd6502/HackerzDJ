//
//  WebRequest.h
//  patch
//
//  Created by Robert Diamond on 1/24/11.
//  Copyright 2011 Patch.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BaseRequest.h"
#import "WebRequestDelegate.h"

@interface WebRequest : BaseRequest {
	BOOL __needsConnection;
	NSURLConnection *myConnection;
}

@property (nonatomic, retain) NSMutableData *urlData;
@property (nonatomic,assign) BOOL isFinished;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSData *httpBody;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *httpMethod;
@property (readonly) BOOL needsConnection;
@property (readonly) NSInteger responseCode;
@property (nonatomic, copy) NSDictionary *headers;

// DON'T invoke super when you override this!
- (void)main;

@end

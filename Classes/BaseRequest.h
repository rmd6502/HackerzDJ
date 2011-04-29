//
//  PatchRequest.h
//  patch
//
//  Created by Robert Diamond on 1/28/11.
//  Copyright 2011 Patch.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "WebRequestDelegate.h"

@interface BaseRequest : NSOperation {

}

@property (nonatomic,copy) NSError *error;
//@property (nonatomic, retain) NSObject <WebRequestDelegate> *delegate;
@property (nonatomic, assign) NSObject<WebRequestDelegate> *delegate;
@property SEL selector;
@property (nonatomic,retain) NSObject *userData;

- (void)invokeDelegateWithResult:(BOOL)result;

@end

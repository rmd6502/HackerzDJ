//
//  PatchRequest.m
//  patch
//
//  Created by Robert Diamond on 1/28/11.
//  Copyright 2011 Patch.com. All rights reserved.
//

#import "BaseRequest.h"

@implementation BaseRequest
@synthesize delegate;
@synthesize error;
@synthesize selector;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark PatchRequest

- (void)invokeDelegateWithResult:(BOOL)result {
	if (self.selector){
		objc_msgSend(delegate, selector, self, result);
	}else{
		NSInvocation *invok = [NSInvocation 
							   invocationWithMethodSignature:[self.delegate 
															  methodSignatureForSelector:@selector(operation:requestFinished:)]];
		invok.target = self.delegate;
		[invok setSelector: @selector(operation:requestFinished:)];
		[invok setArgument:&self atIndex:2];
		[invok setArgument:&result atIndex:3];
		[invok invoke];
	}
}


@end

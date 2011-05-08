//
//  UIScrollView+RMD.m
//  hackerdjz
//
//  Created by Robert Diamond on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIScrollView+RMD.h"


@implementation UIScrollView (RMD)

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touches Ended: %@", touches);
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    NSLog(@"Touches moved: %@", touches);
}

@end

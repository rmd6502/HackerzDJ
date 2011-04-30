//
//  RatingsView.m
//  hackerdjz
//
//  Created by Robert Diamond on 4/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RatingsView.h"


@implementation RatingsView
@synthesize rating;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setRating:(CGFloat)rating_ {
    rating = rating_;
    [self setNeedsDisplay];
}
- (void) setupStar {
    starImage = [[UIImage imageNamed:@"5_point_star"] retain];
}
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (starImage == nil) {
        [self setupStar];
    }
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect sz = CGRectMake(0, 0, self.frame.size.width / 5.0, self.frame.size.height);

    CGRect clip = CGRectMake(0, 0, self.frame.size.width * (rating/5.0), self.frame.size.height);
    
    NSLog(@"ratinf %f size frame %@ draw frame %@",rating, NSStringFromCGRect(sz), NSStringFromCGRect(clip));
    CGContextClipToRect(context, clip);
    CGContextDrawTiledImage(context, sz, starImage.CGImage);
}


- (void)dealloc
{
    [starImage release];
    [super dealloc];
}

@end

//
//  RatingsView.h
//  hackerdjz
//
//  Created by Robert Diamond on 4/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RatingsView : UIView {
    UIImage *starImage;
}

@property (nonatomic,assign) CGFloat rating;

- (void)setupStar;

@end

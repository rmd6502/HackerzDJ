//
//  AddPlaylistView.m
//  hackerdjz
//
//  Created by Robert Diamond on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddPlaylistView.h"


@implementation AddPlaylistView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (self.tracking || self.dragging) return;
    [[self nextResponder] touchesEnded:touches withEvent:event];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
}

@end

//
//  AddPlaylistController.m
//  hackerdjz
//
//  Created by Robert Diamond on 5/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddPlaylistController.h"


@implementation AddPlaylistController
@synthesize  backDrop;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGContextRef myBMC = CGBitmapContextCreate(nil, self.view.bounds.size.width, self.view.bounds.size.height, 8, 4 * self.view.bounds.size.width, rgb, kCGImageAlphaPremultipliedLast);
    CGColorRef cs[] = {[UIColor cyanColor].CGColor, [UIColor darkGrayColor].CGColor};
    CFArrayRef colors = CFArrayCreate(NULL, (const void **)cs, 2, NULL);
    CGFloat locs[] = {0.0,1.0};
    CGGradientRef grad = CGGradientCreateWithColors(rgb, colors, locs);
    CGContextDrawRadialGradient(myBMC, grad, CGPointMake(self.view.bounds.size.width/.35, self.view.bounds.size.height*2/.35), 5, CGPointMake(self.view.bounds.size.width*2/.35, self.view.bounds.size.height/.35), 100, kCGGradientDrawsAfterEndLocation);
    CGImageRef img = CGBitmapContextCreateImage(myBMC);
    UIImage *uiimg = [UIImage imageWithCGImage:img];
    CGImageRelease(img);
    CFRelease(myBMC);
    CGColorSpaceRelease(rgb);
    CFRelease(colors);
    CGGradientRelease(grad);
    [self.backDrop setImage:uiimg];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

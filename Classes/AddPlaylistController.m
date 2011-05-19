//
//  AddPlaylistController.m
//  hackerdjz
//
//  Created by Robert Diamond on 5/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddPlaylistController.h"

@implementation AddPlaylistController
@synthesize  pDesc;
@synthesize pTags;
@synthesize pTitle;

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
    UIScrollView *scrollView = (UIScrollView *)self.view;
    // Do any additional setup after loading the view from its nib.
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGContextRef myBMC = CGBitmapContextCreate(nil, scrollView.bounds.size.width, scrollView.bounds.size.height, 8, 4 * scrollView.bounds.size.width, rgb, kCGImageAlphaPremultipliedLast);
    CGFloat colors[] = { .5,.8,.85,1.0, .6,.75,.95,1.0 };
    CGFloat locs[] = {0.0,1.0};
    CGGradientRef grad = CGGradientCreateWithColorComponents(rgb, colors, locs, 2);
    CGContextSetFillColorWithColor(myBMC, [UIColor blueColor].CGColor);
    CGContextFillRect(myBMC, CGRectMake(0, 0, scrollView.bounds.size.width, scrollView.bounds.size.height));
    CGContextDrawRadialGradient(myBMC, grad, CGPointMake(scrollView.bounds.size.width*2*.35, 
                                                         scrollView.bounds.size.height*.35), 50, 
                                CGPointMake(scrollView.bounds.size.width*2*.35, 
                                            scrollView.bounds.size.height*.35), 300, 
                                kCGGradientDrawsAfterEndLocation+kCGGradientDrawsBeforeStartLocation);
    CGImageRef img = CGBitmapContextCreateImage(myBMC);
    UIImage *uiimg = [UIImage imageWithCGImage:img];
    scrollView.backgroundColor = [UIColor colorWithPatternImage:uiimg];
    CGImageRelease(img);
    CFRelease(myBMC);
    CGColorSpaceRelease(rgb);

    CGGradientRelease(grad);
    NSLog(@"scrollview %@ bounds %@", scrollView, NSStringFromCGRect(scrollView.bounds));
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ((UIScrollView *)self.view).contentSize = self.view.bounds.size;
}

- (void)keyboardDidShow:(NSNotification *)notif {
    CGRect kbBounds;
    [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&kbBounds];
    CGRect tbBounds = self.navigationController.toolbar.bounds;
    CGRect fr = self.view.frame;
    //CGRect sbBounds = [[UIApplication sharedApplication] statusBarFrame];
    fr.size.height -= kbBounds.size.height - tbBounds.size.height;
    self.view.frame = fr;
    
    [(UIScrollView *)self.view scrollRectToVisible:lastTextField.frame animated:YES];
    [(UIScrollView *)self.view flashScrollIndicators];
    NSLog(@"show view: %@ contentSize %@ uienabled %d", self.view, NSStringFromCGSize([(UIScrollView *)self.view contentSize]), self.view.userInteractionEnabled);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [lastTextField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    lastTextField = textField;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    lastTextField = textView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrolled!");
}

- (void)keyboardWillHide:(NSNotification *)notif {
    CGRect kbBounds;
    [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&kbBounds];
    CGRect tbBounds = self.navigationController.toolbar.bounds;
    CGRect fr = self.view.frame;
    //CGRect sbBounds = [[UIApplication sharedApplication] statusBarFrame];
    fr.size.height += kbBounds.size.height - tbBounds.size.height;
    self.view.frame = fr;
    CGPoint p = CGPointMake(0, 0);
    ((UIScrollView *)self.view).contentOffset = p;
    NSLog(@"hide view: %@ contentSize %@ uienabled %d", self.view, NSStringFromCGSize(((UIScrollView *)self.view).contentSize), self.view.userInteractionEnabled);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)doCreatePlaylist:(id)sender {

}

@end

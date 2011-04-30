//
//  CaptchaController.m
//  hackerdjz
//
//  Created by Robert Diamond on 4/29/11.
//  Copyright 2011 none. All rights reserved.
//

#import "CaptchaController.h"


@implementation CaptchaController
@synthesize captchaView;
@synthesize captchaText;
@synthesize captchaToken;
@synthesize captchaURL;
@synthesize userInfo;
@synthesize delegate;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:captchaURL]];
	UIImage *img = [UIImage imageWithData:imgData];
	captchaView.image = img;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[captchaText resignFirstResponder];
}

- (IBAction)captchaOK:(id)sender {
	objc_msgSend(delegate, @selector(captchaFinished:captchaText:userData:), captchaToken, captchaText.text, userInfo);
}

@end

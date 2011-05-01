//
//  DetailViewController.m
//  hackerdjz
//
//  Created by Robert Diamond on 4/29/11.
//  Copyright 2011 none. All rights reserved.
//

#import "DetailViewController.h"
#import "UIImageView+Cached.h"

@implementation DetailViewController
@synthesize details;
@synthesize titleLabel;
@synthesize subTitle;
@synthesize description;
@synthesize image;
@synthesize categories;
@synthesize ratings;
@synthesize delegate;

- (IBAction)playVideo:(id)sender {
    if (player != nil) {
        [player release];
    }
    NSString *mediaURL = [NSString stringWithFormat:@"http://www.youtube.com/v/%@",[[[details objectForKey:@"media$group"] objectForKey:@"yt$videoid"] objectForKey:@"$t"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mediaURL]];
}
- (IBAction)addToPlaylist:(id)sender {
    if ([delegate respondsToSelector:@selector(startAddVideo:)]) {
        [delegate performSelector:@selector(startAddVideo:) withObject:details];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
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
 [self updateLabels];
}


- (void)setDetails:(NSDictionary *)details_ {
    details = details_;
    [self updateLabels];
}
    
- (void)updateLabels {
    self.titleLabel.text = [[[details objectForKey:@"media$group"] objectForKey:@"media$title"] objectForKey:@"$t"];
    self.subTitle.text = [[[[details objectForKey:@"author"] objectAtIndex:0]objectForKey:@"name"] objectForKey:@"$t"];
    NSString *descText = [[details objectForKey:@"media$description"] objectForKey:@"$t"];
    if (descText == nil) {
        descText = @"(no description provided)";
    }
    self.description.text = descText;
    NSMutableString *category_string = [NSMutableString stringWithCapacity:100];
    for (NSDictionary *catData in [[details objectForKey:@"media$group"] objectForKey:@"media$category"]) {
        if ([category_string length] > 0) {
            [category_string appendString:@","];
        }
        [category_string appendString:[catData objectForKey:@"$t"]];
    }
    NSString *defaultTag = @"";
    NSString *defaultHQTag = @"";
    
    for (NSDictionary *thumbInfo in [[details objectForKey:@"media$group"] objectForKey:@"media$thumbnail"]) {
        NSString *videoTag = [thumbInfo objectForKey:@"yt$name"];
        if ([videoTag compare:@"default"] == NSOrderedSame) {
            defaultTag = [thumbInfo objectForKey:@"url"];
        } else if ([videoTag compare:@"hqdefault"] == NSOrderedSame) {
            defaultHQTag = [thumbInfo objectForKey:@"url"];
        }
    }
    
    if ([defaultHQTag length] > 0) {
        [image loadFromURL:[NSURL URLWithString:defaultHQTag]];
    } else if ([defaultTag length] > 0) {
        [image loadFromURL:[NSURL URLWithString:defaultTag]];
    } else {
        [image setImage:[UIImage imageNamed:@"no_image"]];
    }
    categories.text = category_string;
    ratings.rating = [[[details objectForKey:@"gd$rating"] objectForKey:@"average"] floatValue];
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


@end

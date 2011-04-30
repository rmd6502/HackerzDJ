//
//  DetailViewController.h
//  hackerdjz
//
//  Created by Robert Diamond on 4/29/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingsView.h"

@interface DetailViewController : UIViewController {

}

@property (nonatomic,copy) NSDictionary *details;
@property (nonatomic,assign) IBOutlet UILabel *titleLabel;
@property (nonatomic,assign) IBOutlet UILabel *subTitle;
@property (nonatomic,assign) IBOutlet UILabel *description;
@property (nonatomic,assign) IBOutlet UIImageView *image;
@property (nonatomic,assign) IBOutlet UILabel *categories;
@property (nonatomic,assign) IBOutlet RatingsView *ratings;


- (IBAction)playVideo:(id)sender;
- (IBAction)addToPlaylist:(id)sender;
- (void)updateLabels;
@end

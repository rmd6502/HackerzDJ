//
//  RootViewController.h
//  hackerdjz
//
//  Created by Robert Diamond on 4/22/11.
//  Copyright 2011 Robert M. Diamond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebRequestDelegate.h"

@interface RootViewController : UIViewController<WebRequestDelegate> {
	// This is the model
	NSArray *playlistArray;
	NSArray *results;
}

@property (nonatomic,assign) IBOutlet UITableView *playlistTable;
@property (nonatomic,assign) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)performAddAndSearch:(id)sender;
- (void)sendPlaylistRequest;

@end

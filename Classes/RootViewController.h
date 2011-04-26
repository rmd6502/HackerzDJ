//
//  RootViewController.h
//  hackerdjz
//
//  Created by Robert Diamond on 4/22/11.
//  Copyright 2011 Robert M. Diamond. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RootViewController : UIViewController {
	// This is the model
	NSArray *playlistArray;
}

@property (nonatomic,assign) IBOutlet UITableView *playlistTable;

- (IBAction)performAddAndSearch:(id)sender;

@end

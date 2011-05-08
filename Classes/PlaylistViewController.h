//
//  PlaylistViewController.h
//  hackerdjz
//
//  Created by Robert Diamond on 5/2/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebRequestDelegate.h"

@class WebRequest;
@interface PlaylistViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,WebRequestDelegate> {
	NSArray *playlists;
}

@property (nonatomic,assign) IBOutlet UITableView *playlistTable;
@property (nonatomic,assign) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic,assign) IBOutlet UIBarButtonItem *addButton;

- (IBAction)refresh:(id)sender;
- (IBAction)addPlaylist:(id)sender;
- (void)playlists:(WebRequest *)request result:(BOOL)success;
- (IBAction)startRemovePlaylist:(id)sender;

@end

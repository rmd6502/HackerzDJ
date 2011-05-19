//
//  RootViewController.h
//  hackerdjz
//
//  Created by Robert Diamond on 4/22/11.
//  Copyright 2011 Robert M. Diamond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebRequestDelegate.h"

@interface PlaylistVideoController : UIViewController<WebRequestDelegate,UINavigationControllerDelegate,UITableViewDelegate> {
	// This is the model
	NSArray *playlistArray;
	NSArray *results;
	
    BOOL isRefreshing;
}

@property (nonatomic,assign) IBOutlet UITableView *playlistTable;
@property (nonatomic,assign) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic,copy) NSString *playlistId;

- (IBAction)refresh:(id)sender;
- (IBAction)performAddAndSearch:(id)sender;
- (void)startRemoveVideo:(NSIndexPath *)indexPath;
- (void)doRemoveVideo:(NSIndexPath *)indexPath;
- (void)captchaRequired:(NSString *)captchaURL token:(NSString *)captchaToken userData:(NSObject *)userData;
- (void)captchaFinished:(NSString *)captchaToken captchaText:(NSString *)captchaText userData:(NSObject *)userData;

@end

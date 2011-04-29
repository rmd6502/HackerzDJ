//
//  SearchAddController.h
//  hackerdjz
//
//  Created by Robert Diamond on 4/25/11.
//  Copyright 2011 Robert M. Diamond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebRequestDelegate.h"

@interface SearchAddController : UIViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,WebRequestDelegate> {
	NSArray *results;
	NSString *authKey;
}

@property (nonatomic,assign) UILabel *instrs;

- (void)clientAuthComplete:(NSNumber *)success authKey:(NSString *)authKey userData:(NSObject *)userData;
- (void)doAddVideo:(NSString *)videoID playList:(NSString *)playlistID;
- (void)videoAdded:(NSNumber *)success;
@end

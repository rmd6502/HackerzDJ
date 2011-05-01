//
//  SearchAddController.h
//  hackerdjz
//
//  Created by Robert Diamond on 4/25/11.
//  Copyright 2011 Robert M. Diamond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebRequestDelegate.h"

@class WebRequest;
@interface SearchAddController : UIViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,WebRequestDelegate,UIPickerViewDataSource,UIPickerViewDelegate> {
	NSArray *results;
	NSString *authKey;
    NSArray *categories;
}

@property (nonatomic,assign) UILabel *instrs;
@property (nonatomic,copy)   NSString *playlistId;
@property (nonatomic,assign) IBOutlet UIActivityIndicatorView *spinner;

- (void)clientAuthComplete:(NSNumber *)success authKey:(NSString *)authKey userData:(NSObject *)userData;
- (void)doAddVideo:(NSDictionary *)videoData;
- (void)videoAdded:(WebRequest *)request result:(BOOL)success;
- (void)captchaRequired:(NSString *)captchaURL token:(NSString *)captchaToken userData:(NSObject *)userData;
- (void)captchaFinished:(NSString *)captchaToken captchaText:(NSString *)captchaText userData:(NSObject *)userData;
@end

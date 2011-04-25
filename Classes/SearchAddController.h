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
}

@property (nonatomic,assign) UILabel *instrs;

@end

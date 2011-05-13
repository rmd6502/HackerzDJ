//
//  hackerdjzAppDelegate.h
//  hackerdjz
//
//  Created by Robert Diamond on 4/22/11.
//  Copyright 2011 Robert M. Diamond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface hackerdjzAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic,assign) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic,assign) IBOutlet UIBarButtonItem *refreshButton;
@property (readonly) BOOL canAddVideos;
@property (readonly) BOOL canRemoveVideos;
@property (readonly) BOOL canAddPlaylists;
@property (readonly) BOOL canRemovePlaylists;

@end


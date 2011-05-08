//
//  AddPlaylistController.h
//  hackerdjz
//
//  Created by Robert Diamond on 5/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddPlaylistController : UIViewController<UITextFieldDelegate,UITextViewDelegate,UIScrollViewDelegate> {
    UIView *lastTextField;
    
}

@property (nonatomic,assign) IBOutlet UITextField *pTitle;
@property (nonatomic,assign) IBOutlet UITextView *pDesc;
@property (nonatomic,assign) IBOutlet UITextField *pTags;

- (IBAction)doCreatePlaylist:(id)sender;

- (void)keyboardDidShow:(NSNotification *)notif;
- (void)keyboardWillHide:(NSNotification *)notif;
@end

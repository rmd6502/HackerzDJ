//
//  CaptchaController.h
//  hackerdjz
//
//  Created by Robert Diamond on 4/29/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CaptchaController : UIViewController {

}

@property (nonatomic,assign) id delegate;
@property (nonatomic,assign) IBOutlet UIImageView *captchaView;
@property (nonatomic,assign) IBOutlet UITextField *captchaText;
@property (nonatomic,copy)   NSString *captchaToken;
@property (nonatomic,copy)   NSString *captchaURL;
@property (nonatomic,assign) NSObject *userInfo;

- (IBAction)captchaOK:(id)sender;
@end

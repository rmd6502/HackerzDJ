//
//  YoutubeClientAuth.h
//  hackerdjz
//
//  Created by Robert Diamond on 4/28/11.
//  Copyright 2011 none. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebRequest.h"

@interface YoutubeClientAuth : WebRequest<WebRequestDelegate,UIWebViewDelegate> {

}

@property (nonatomic,assign) id target;
@property (nonatomic,assign) SEL tselector;
@property (nonatomic,assign) SEL captcha_callback;
@property (nonatomic,copy)   NSString *captchaToken;
@property (nonatomic,copy)   NSString *captchaText;
@end

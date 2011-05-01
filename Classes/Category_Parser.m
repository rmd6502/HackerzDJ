//
//  Category_Parser.m
//  hackerdjz
//
//  Created by Robert Diamond on 4/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Category_Parser.h"


@implementation Category_Parser
@synthesize root;

- (id)init
{
    self = [super init];
    if (self) {
        NSError *error = nil;
        NSURL *xmlDataURL = [[NSBundle mainBundle] URLForResource:@"categories" withExtension:@"cat"];
        NSData *xmlData = [NSData dataWithContentsOfURL:xmlDataURL];
        root = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    }
    
    return self;
}

- (void)dealloc
{
    [root release];
    [super dealloc];
}

@end

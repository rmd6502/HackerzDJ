//  UIImageView+Cached.h
//
//  Created by Lane Roathe
//  Copyright 2009 Ideas From the Deep, llc. All rights reserved.

@interface UIImageView (Cached)

#ifdef CORE_DATA_CACHE
/** Invoked at the beginning of the program to clean the disk */
+ (void)expireCachedImages;
- (BOOL)hasCacheForURL:(NSURL*)url;
#endif

-(void)loadFromURL:(NSURL*)url;

-(void)loadFromURL:(NSURL*)url afterDelay:(float)delay;

- (void)flushImageCache;

- (void)setCachedImage:(UIImage *)image;

@end


//  UIImageView+Cached.h
//
//  Created by Lane Roathe
//  Copyright 2009 Ideas From the Deep, llc. All rights reserved.

#import "UIImageView+Cached.h"
#ifdef CORE_DATA_CACHE
#import "MediaData.h"
#endif
#import "Reachability.h"

static const double ImageExpiryDays = 3;
static const double SecondsPerDay = (24*3600);

#pragma mark -
#pragma mark --- Threaded & Cached image loading ---

@implementation UIImageView (Cached)

#define MAX_CACHED_IMAGES 60	// max # of images we will cache before flushing cache and starting over

#ifdef CORE_DATA_CACHE
+ (void)expireCachedImages {
	NSError *err = nil;
	NSManagedObjectContext *moc = [(patchAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	
	NSDate *expireBeforeDate = [NSDate date];
	NSTimeInterval ti = -ImageExpiryDays * SecondsPerDay;
	expireBeforeDate = [expireBeforeDate dateByAddingTimeInterval:ti];
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"createdAt < %@ AND dontExpire = NO", expireBeforeDate];
	NSFetchRequest *req = [[[NSFetchRequest alloc] init] autorelease];
	[req setPredicate:pred];
	[req setEntity:[NSEntityDescription entityForName:@"MediaData" inManagedObjectContext:moc]];
	
	NSArray *expirableImages = [moc executeFetchRequest:req error:&err];
	if (err) {
		NSLog(@"Failed to retrieve expirable images: %@", err);
		return;
	}
	for (MediaData *md in expirableImages) {
		[moc deleteObject:md];
	}
	[moc save:&err];
	if (err) {
		NSLog(@"Failed to save deletions: %@", err);
	}
}
#endif

// method to return a static cache reference (ie, no need for an init method)
-(NSMutableDictionary*)cache
{
	static NSMutableDictionary* _cache = nil;
	
	if( !_cache ) {
		@synchronized (self) {
			if( !_cache ) {
				_cache = [[NSMutableDictionary alloc] initWithCapacity:MAX_CACHED_IMAGES];
			}
		}
	}

	assert(_cache);
	return _cache;
}

#ifdef CORE_DATA_CACHE
- (void)saveData:(UIImage *)imageData forURL:(NSURL *)url {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *err = nil;
	NSManagedObjectContext *moc = [(patchAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	
	MediaData *md = [NSEntityDescription
					 insertNewObjectForEntityForName:@"MediaData"
					 inManagedObjectContext:moc];
	md.itemData = UIImagePNGRepresentation(imageData);
	md.url = [url absoluteString];
	md.createdAt = [NSDate date];
	@try {
		[moc save:&err];
		if (err) {
			NSLog(@"Failed to save image data: %@", 
				  [[err localizedFailureReason] substringToIndex:MIN(160,[[err localizedFailureReason] length])]);
		} else {
			//NSLog(@"saved image data for %@", url);
		}
	} @catch (NSError *e) {
		NSLog(@"Exception: failed to save image data: %@", 
			  [[e localizedFailureReason] substringToIndex:MIN(160,[[e localizedFailureReason] length])]);
	}
	[url release];
	[imageData release];
	[moc reset];
	[pool drain];
}

- (BOOL)hasCacheForURL:(NSURL*)url {
	BOOL ret = [[self cache] objectForKey:url.description] != nil;
	if (!ret) {
		NSManagedObjectContext *moc = [(patchAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"url = %@", [url absoluteString]];
		NSFetchRequest *req = [[NSFetchRequest alloc] init];
		NSError *err = nil;
		[req setEntity:[NSEntityDescription entityForName:@"MediaData" inManagedObjectContext:moc]];
		[req setPredicate:pred];
		NSArray *res = [moc executeFetchRequest:req error:&err];
		ret = err == nil && [res count] > 0;
		[req release];
	}
	return ret;
}
#endif

// Loads an image from a URL, caching it for later loads
// This can be called directly, or via one of the threaded accessors
-(void)cacheFromURL:(NSURL*)url
{
	// First see if the image is in memory
	UIImage* newImage = nil;
	@synchronized ([self cache]) {
		newImage = [[self cache] objectForKey:url.description];
		if (newImage) {
			[newImage retain];
		}
	}
	if( !newImage )
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSError *err = nil;
		
		NSData *imageData = nil;
		
#ifdef CORE_DATA_CACHE
		// Next see if we have a local cache of the object
		NSManagedObjectContext *moc = [(patchAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"url = %@", [url absoluteString]];
		NSFetchRequest *req = [[NSFetchRequest alloc] init];
		[req setEntity:[NSEntityDescription entityForName:@"MediaData" inManagedObjectContext:moc]];
		[req setPredicate:pred];
		NSArray *res = [moc executeFetchRequest:req error:&err];
		if ([res count]) {
			imageData = [(MediaData *)[res objectAtIndex:0] itemData];
		}
		[req release];
#endif
		
		// Finally go to the web if possible and retrieve it
		if (imageData == nil && [[Reachability sharedReachability] hasConnection]) {
			imageData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&err];
			// cache the data
			 if (imageData) {
				newImage = [UIImage imageWithData:imageData];
				[newImage retain];	// 1 for the background process
				[newImage retain];	// 1 for keeping it in case of a memory warning
				[url retain];
#ifdef CORE_DATA_CACHE				 
				NSInvocation *invok = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(saveData:forURL:)]];
				[invok setTarget:self];
				[invok setSelector:@selector(saveData:forURL:)];
				[invok setArgument:&newImage atIndex:2];
				[invok setArgument:&url atIndex:3];
				// don't hold up returning the image
				[invok performSelectorInBackground:@selector(invoke) withObject:nil];
#endif
			} 
		}
		if (!newImage) {
			newImage = [[UIImage imageWithData:imageData] retain ];
		}

		//NSLog(@"image %@ size %d", url, [imageData length]);
		if( newImage )
		{
			@synchronized ([self cache]) {
				// check to see if we should flush existing cached items before adding this new item
				if( [[self cache] count] >= MAX_CACHED_IMAGES ) {
					LOG_DEBUG(@"clearing cache");
					[[self cache] removeAllObjects];
				}

				//[newImage retain];	// since the cache could be cleared as soon as we get out of @synchronized
				[[self cache] setValue:newImage forKey:url.description];
			}
		}
		else
			NSLog( @"UIImageView:LoadImage Failed: %@", [err localizedFailureReason]);
		
#ifdef CORE_DATA_CACHE
		[moc reset];
#endif
		[pool drain];
	}

	//if( newImage ) {
		[self performSelectorOnMainThread:@selector(setCachedImage:) withObject:newImage waitUntilDone:YES];
	//}
}

- (void)setCachedImage:(UIImage *)image__ {
	[self setImage:image__];
	[image__ release];
}

// Methods to load and cache an image from a URL on a separate thread
-(void)loadFromURL:(NSURL *)url
{
	//Remove assert and change to cond to prevent failure
	//assert(url != nil);
	if ([[self cache] objectForKey:url.description] == nil) {
		[self setImage:[UIImage imageNamed:@"ic_menu_block"]];
	}
	if (url!=nil){
		[self performSelectorInBackground:@selector(cacheFromURL:) withObject:url]; 
	}
}

-(void)loadFromURL:(NSURL*)url afterDelay:(float)delay
{
	[self performSelector:@selector(loadFromURL:) withObject:url afterDelay:delay];
}

- (void)flushImageCache {
	@synchronized ([self cache]) {
		LOG_DEBUG(@"flushing cache");
		[[self cache] removeAllObjects];
	}
}

@end

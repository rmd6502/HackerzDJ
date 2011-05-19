//
//  RootViewController.m
//  hackerdjz
//
//  Created by Robert Diamond on 4/22/11.
//  Copyright 2011 Robert M. Diamond. All rights reserved.
//

#import "PlaylistVideoController.h"
#import "SearchAddController.h"
#import "YouTubeAPIModel.h"
#import "YoutubeClientAuth.h"
#import "WebRequest.h"
#import "JSONKit.h"
#import "UIImageView+Cached.h"
#import "DetailViewController.h"
#import "CaptchaController.h"

@implementation PlaylistVideoController
@synthesize playlistTable;
@synthesize spinner;
@synthesize playlistId;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    isRefreshing = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	//[YouTubeAPIModel getPlaylistsWithDelegate:self];
	//spinner.hidden = NO;
    playlistTable.rowHeight = 80;
	UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(performAddAndSearch:)] autorelease];
	addButton.style = UIBarButtonItemStyleBordered;
    addButton.enabled = CAN_ADD_VIDEOS;
	UIBarButtonItem *refreshButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)] autorelease];
	refreshButton.style = UIBarButtonItemStyleBordered;
	self.toolbarItems = [NSArray arrayWithObjects:refreshButton, addButton, nil];
    imageViews = [[NSMutableArray alloc] init];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self refresh:nil];
}

- (void)navigationController:(UINavigationController *)navigationController 
	  willShowViewController:(UIViewController *)viewController 
					animated:(BOOL)animated {
	//[super navigationController:navigationController willShowViewController:viewController animated:animated];
	if (viewController == self) {
		[self refresh:nil];
	}
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([playlistArray count] == 0) {
		return 4;
	}
    return [playlistArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PlaylistVideo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        [imageViews addObject:cell.imageView];
        [cell.imageView addObserver:self forKeyPath:@"image" options:0 context:cell];
    }
    
	// Configure the cell.
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:16];
	cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.textLabel.numberOfLines = 3;
	CGRect fr = cell.frame;
	fr.size.height = tableView.rowHeight;
	cell.frame = fr;
	fr = cell.imageView.frame;
	fr.size.height = tableView.rowHeight-1;
	cell.imageView.frame = fr;
	if ([playlistArray count] == 0) { 
		if (indexPath.row == 2) {
			cell.textLabel.text = @"Playlist is empty";
		} else if (indexPath.row == 3) {
			cell.textLabel.text = @"Click the + button above to add songs";
		}
		cell.detailTextLabel.text = @"";
	} else {
		NSDictionary *result = [playlistArray objectAtIndex:indexPath.row];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:14];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		cell.textLabel.text = [[result objectForKey:@"title"] objectForKey:@"$t"];
		cell.detailTextLabel.text = [[[[result objectForKey:@"author"] objectAtIndex:0] objectForKey:@"name"] objectForKey:@"$t"];
		NSString *imgUrl = [[[[result objectForKey:@"media$group"] objectForKey:@"media$thumbnail"] objectAtIndex:0] objectForKey:@"url"];
		if (imgUrl != nil) {
			[cell.imageView loadFromURL:[NSURL URLWithString:imgUrl]];
		}		
	}

    return cell;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    CGRect fr = [(UIImageView *)object frame];
//    fr.origin = CGPointMake(0, 0);
//    fr.size.height = fr.size.width = playlistTable.rowHeight - 1;
//    [(UIImageView *)object setFrame:fr];
    [(UITableViewCell *)context setNeedsLayout];
    //[object removeObserver:self forKeyPath:@"image"];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (!CAN_REMOVE_VIDEOS) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Not Allowed" message:@"Not allowed to remove videos" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [av show];
            [av release];
            return;
        }
        [self startRemoveVideo:indexPath];
    }
}

- (void)startRemoveVideo:(NSIndexPath *)indexPath {
    spinner.hidden = NO;
    [self.view bringSubviewToFront:spinner];
	if ([YouTubeAPIModel sharedAPIModel].authKey == nil) {
		YoutubeClientAuth *req = [[YoutubeClientAuth alloc] init];
		req.target = self;
		req.tselector = @selector(clientAuthComplete:authKey:userData:);
		req.userData = indexPath;
		[[YouTubeAPIModel sharedAPIModel] addToQueue:req description:@"Authenticate"];
	} else {
		[self doRemoveVideo:indexPath];
	}
}

- (void)doRemoveVideo:(NSIndexPath *)indexPath {
    NSDictionary *videoData = [playlistArray objectAtIndex:indexPath.row];
    NSString *videoID = [[videoData objectForKey:@"id"] objectForKey:@"$t"];
    NSRange r = [videoID rangeOfString:@":" options:NSBackwardsSearch];
    ++r.location;
    r.length = [videoID length] - r.location;
    videoID = [videoID substringWithRange:r];
    [[YouTubeAPIModel sharedAPIModel] removeVideo:videoID fromPlaylist:playlistId indexPath:indexPath delegate:self];
}

- (void)clientAuthComplete:(NSNumber *)success authKey:(NSString *)authKey_ userData:(NSObject *)userData {
	[YouTubeAPIModel sharedAPIModel].authKey = authKey_;
	[self doRemoveVideo:(NSIndexPath *)userData];
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView 
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	 DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:nil bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    NSDictionary *result = [playlistArray objectAtIndex:indexPath.row];
    detailViewController.details = result;
	 [self.navigationController pushViewController:detailViewController animated:YES];
        detailViewController.addButton.hidden = YES;
	 [detailViewController release];
}

- (IBAction)performAddAndSearch:(id)sender {
	if (playlistId != nil) {
		SearchAddController *sac = [[SearchAddController alloc] initWithNibName:nil bundle:nil];
		sac.playlistId = playlistId;
		[self.navigationController pushViewController:sac animated:YES];
		[sac release];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    for (UIImageView *vw in imageViews) {
        if ([vw observationInfo]) {
            [vw removeObserver:self forKeyPath:@"image"];
        }
    }
    [imageViews release];
    imageViews = nil;
}


- (void)dealloc {
	[results release];
	[playlistArray release];
	[playlistId release];
    for (UIImageView *vw in imageViews) {
        if ([vw observationInfo]) {
            [vw removeObserver:self forKeyPath:@"image"];
        }
    }

    [imageViews release];
    [super dealloc];
}

#pragma mark -
#pragma mark WebRequestDelegate
- (void)operation:(BaseRequest *)request requestFinished:(BOOL)success {
    isRefreshing = NO;
	if (success) {
		NSDictionary *jsondata = [[(WebRequest*)request urlData] objectFromJSONData];
		NSDictionary *feed = [jsondata objectForKey:@"feed"];
		//LOG_DEBUG(@"feed %@", feed);
		if (results != nil) {
			[results release];
		}
		results = [[feed objectForKey:@"entry"] retain];
		NSString *term = [[[feed objectForKey:@"category"] objectAtIndex:0] objectForKey:@"term"];
		
		LOG_DEBUG(@"results %d term %@", [results count],term);
		spinner.hidden = YES;
		if (playlistArray != nil) {
			[playlistArray release];
		}
		playlistArray = results;
		results = nil;
		[self.playlistTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	} else {
		spinner.hidden = YES;
		NSLog(@"Failed to retrieve search results: %@", [request.error localizedDescription]);
	}
}

- (IBAction)refresh:(id)sender {
    @synchronized(self) {
        if (isRefreshing) return;
        isRefreshing = YES;
    }
    spinner.hidden = ![[YouTubeAPIModel sharedAPIModel] getContentsOfPlaylist:playlistId delegate:self];
}

- (void)videoRemoved:(WebRequest *)request result:(BOOL)success {
    NSString *response = [NSString stringWithCString:(const char *)[request.urlData bytes] encoding:NSASCIIStringEncoding];
    LOG_DEBUG(@"video remove %@", response);
    if ([response rangeOfString:@"<error>"].location != NSNotFound) {
        success = NO;
    }
    spinner.hidden = YES;
    if (success) {
        NSIndexPath *indexPath = (NSIndexPath *)request.userData;
        NSMutableArray *newPlaylist = [NSMutableArray arrayWithArray:playlistArray];
        [playlistArray release];
        [newPlaylist removeObjectAtIndex:indexPath.row];
        playlistArray = [newPlaylist retain];
        
        [playlistTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        UIAlertView *uav = [[UIAlertView alloc] initWithTitle:@"Could not delete" message:@"Failed to delete video" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [uav show];
        [uav release];
    }
}

- (void)captchaRequired:(NSString *)captchaURL token:(NSString *)captchaToken userData:(NSObject *)userData {
	CaptchaController *captchaVC = [[CaptchaController alloc] initWithNibName:nil bundle:nil];
	captchaVC.captchaURL = captchaURL;
	captchaVC.captchaToken = captchaToken;
	captchaVC.delegate = self;
	[self.navigationController pushViewController:captchaVC animated:YES];
}

- (void)captchaFinished:(NSString *)captchaToken captchaText:(NSString *)captchaText userData:(NSObject *)userData {
	YoutubeClientAuth *req = [[YoutubeClientAuth alloc] init];
	req.target = self;
	req.tselector = @selector(clientAuthComplete:authKey:userData:);
	req.userData = userData;
	[[YouTubeAPIModel sharedAPIModel] addToQueue:req description:@"Authenticate"];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    LOG_DEBUG(@"showing view controller %p", viewController);
    if (viewController == self) {
        [self performSelector:@selector(refresh:) withObject:nil afterDelay:2.0];
    }
}

@end


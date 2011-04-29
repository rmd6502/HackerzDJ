//
//  SearchAddController.m
//  hackerdjz
//
//  Created by Robert Diamond on 4/25/11.
//  Copyright 2011 Robert M. Diamond. All rights reserved.
//

#import "SearchAddController.h"
#import "WebRequest.h"
#import "Reachability.h"
#import "JSONKit.h"
#import "UIImageView+Cached.h"
#import "YouTubeAPIModel.h"
#import "YoutubeClientAuth.h"

@implementation SearchAddController
@synthesize instrs;
@synthesize playlistId;

#pragma mark -
#pragma mark UIViewController
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
 	self.title = @"Add Youtube Videos";
	instrs.font = [UIFont fontWithName:@"ChalkDuster" size:20.0];
	results = nil;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[results release];
	results = nil;
}


- (void)dealloc {
	[authKey release];
    [super dealloc];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [results count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"YoutubeResult";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	NSDictionary *result = [results objectAtIndex:indexPath.row];
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:14];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
	cell.textLabel.text = [[result objectForKey:@"title"] objectForKey:@"$t"];
	cell.detailTextLabel.text = [[[[result objectForKey:@"author"] objectAtIndex:0] objectForKey:@"name"] objectForKey:@"$t"];
	NSString *imgUrl = [[[[result objectForKey:@"media$group"] objectForKey:@"media$thumbnail"] objectAtIndex:0] objectForKey:@"url"];
	if (imgUrl != nil) {
		[cell.imageView loadFromURL:[NSURL URLWithString:imgUrl]];
	}
	
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *result = [results objectAtIndex:indexPath.row];
	if (authKey == nil) {
		YoutubeClientAuth *req = [[YoutubeClientAuth alloc] init];
		req.target = self;
		req.tselector = @selector(clientAuthComplete:authKey:userData:);
		req.userData = result;
		[YouTubeAPIModel addToQueue:req description:@"Authenticate"];
	} else {
		[self doAddVideo:result];
	}

}

- (void)doAddVideo:(NSDictionary *)videoData {
	LOG_DEBUG(@"here");
	NSString *videoID = [[[videoData objectForKey:@"media$group"] objectForKey:@"yt$videoid"] objectForKey:@"$t"];
	[YouTubeAPIModel addVideo:videoID toPlaylist:playlistId authKey:authKey delegate:self];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	/*
	 NSDictionary *result = [results objectAtIndex:indexPath.row];
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

#pragma mark -
#pragma mark WebRequestDelegate
- (void)operation:(BaseRequest *)request requestFinished:(BOOL)success {
	if (success) {
		NSDictionary *jsondata = [[(WebRequest*)request urlData] objectFromJSONData];
		NSDictionary *feed = [jsondata objectForKey:@"feed"];
		//LOG_DEBUG(@"feed %@", feed);
		if (results != nil) {
			[results release];
		}
		results = [[feed objectForKey:@"entry"] retain];
		LOG_DEBUG(@"results %d", [results count]);
        self.searchDisplayController.searchResultsTableView.hidden = NO;
		[self.searchDisplayController.searchResultsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	} else {
		NSLog(@"Failed to retrieve search results: %@", [request.error localizedDescription]);
	}
}

#pragma mark -
#pragma mark UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	self.searchDisplayController.searchResultsTableView.hidden = ![YouTubeAPIModel videoSearch:[searchBar text] delegate:self];
}

#pragma mark -
#pragma mark UISearchDisplayDelegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
	return NO;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
	tableView.hidden = YES;
}

- (void)clientAuthComplete:(NSNumber *)success authKey:(NSString *)authKey_ userData:(NSObject *)userData {
	authKey = [authKey_ copy];
	[self doAddVideo:(NSDictionary *)userData];
}

- (void)videoAdded:(WebRequest *)request result:(BOOL)success {
	LOG_DEBUG(@"video add %@", [NSString stringWithCString:(const char *)[request.urlData bytes] encoding:NSASCIIStringEncoding]);
}

@end

//
//  RootViewController.m
//  hackerdjz
//
//  Created by Robert Diamond on 4/22/11.
//  Copyright 2011 Robert M. Diamond. All rights reserved.
//

#import "RootViewController.h"
#import "SearchAddController.h"
#import "YouTubeAPIModel.h"
#import "WebRequest.h"
#import "JSONKit.h"
#import "UIImageView+Cached.h"

@implementation RootViewController
@synthesize playlistTable;
@synthesize spinner;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	//[YouTubeAPIModel getPlaylistsWithDelegate:self];
	//spinner.hidden = NO;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	spinner.hidden = NO;
	[YouTubeAPIModel getPlaylistsWithDelegate:self];
}

- (void)navigationController:(UINavigationController *)navigationController 
	  willShowViewController:(UIViewController *)viewController 
					animated:(BOOL)animated {
	//[super navigationController:navigationController willShowViewController:viewController animated:animated];
	if (viewController == self) {
		spinner.hidden = NO;
		[YouTubeAPIModel getPlaylistsWithDelegate:self];
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
    
    static NSString *CellIdentifier = @"YoutubeResult";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:16];
	cell.textLabel.textAlignment = UITextAlignmentCenter;
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
    
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
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
}


- (void)dealloc {
	[results release];
	[playlistArray release];
	[playlistId release];
    [super dealloc];
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
		NSString *term = [[[feed objectForKey:@"category"] objectAtIndex:0] objectForKey:@"term"];
		
		LOG_DEBUG(@"results %d term %@", [results count],term);
		if ([term rangeOfString:@"#playlistLink"].location != NSNotFound) {
			// This is step 1, the list of playlists.  Step two is to get the contents of the most recent playlist
			[self sendPlaylistRequest];
		} else {
			spinner.hidden = YES;
			if (playlistArray != nil) {
				[playlistArray release];
			}
			playlistArray = results;
			results = nil;
			[self.playlistTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
		}
	} else {
		spinner.hidden = YES;
		NSLog(@"Failed to retrieve search results: %@", [request.error localizedDescription]);
	}
}

- (void)sendPlaylistRequest {
	NSArray *sorted = [results sortedArrayUsingComparator:^(id obj1, id obj2) {
		NSString *p1 = [[(NSDictionary *)obj1 objectForKey:@"published"] objectForKey:@"$t"];
		NSString *p2 = [[(NSDictionary *)obj2 objectForKey:@"published"] objectForKey:@"$t"];
		return [p2 compare:p1];
	}];
	NSDictionary *playlist = [sorted objectAtIndex:0];
	
	playlistId = [[[playlist objectForKey:@"yt$playlistId"] objectForKey:@"$t"] copy];
	LOG_DEBUG(@"playlist %@", playlistId);
	[YouTubeAPIModel getContentsOfPlaylist:playlistId delegate:self];
}

@end


//
//  PlaylistViewController.m
//  hackerdjz
//
//  Created by Robert Diamond on 5/2/11.
//  Copyright 2011 none. All rights reserved.
//

#import "PlaylistViewController.h"
#import "WebRequest.h"
#import "YouTubeAPIModel.h"
#import "JSONKit.h"

@implementation PlaylistViewController
@synthesize playlistTable;
@synthesize spinner;

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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[YouTubeAPIModel sharedAPIModel] getPlaylistsWithDelegate:self];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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
}


- (void)dealloc {
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger ret = [playlists count];
	if (ret == 0) {
		ret = 4;
	}
	return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"PlaylistCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:16];
	cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.textLabel.numberOfLines = 3;
	if ([playlists count] == 0) { 
		if (indexPath.row == 2) {
			cell.textLabel.text = @"No Playlists";
		} else if (indexPath.row == 3) {
			cell.textLabel.text = @"Click the + button above to add one";
		}
		cell.detailTextLabel.text = @"";
	} else {
		NSDictionary *result = [playlists objectAtIndex:indexPath.row];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:14];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		cell.textLabel.text = [[result objectForKey:@"title"] objectForKey:@"$t"];
		cell.detailTextLabel.text = [[[[result objectForKey:@"author"] objectAtIndex:0] objectForKey:@"name"] objectForKey:@"$t"];
	}
    return cell;
	
}

- (IBAction)refresh:(id)sender {
	spinner.hidden = NO;
	[[YouTubeAPIModel sharedAPIModel] getPlaylistsWithDelegate:self];
}

- (IBAction)addToPlaylist:(id)sender {
	LOG_DEBUG(@"refresh playlists");
}

- (void)playlists:(WebRequest *)request result:(BOOL)success {
	spinner.hidden = YES;
	NSDictionary *jsondata = [[request urlData] objectFromJSONData];
	NSDictionary *feed = [jsondata objectForKey:@"feed"];
	//LOG_DEBUG(@"feed %@", feed);
	if (playlists != nil) {
		[playlists release];
	}
	NSArray *result = [feed objectForKey:@"entry"];
	playlists = [result sortedArrayUsingComparator:^(id obj1, id obj2) {
		NSString *p1 = [[(NSDictionary *)obj1 objectForKey:@"published"] objectForKey:@"$t"];
		NSString *p2 = [[(NSDictionary *)obj2 objectForKey:@"published"] objectForKey:@"$t"];
		return [p2 compare:p1];
	}];
	[playlists retain];
	[playlistTable reloadData];
}

@end

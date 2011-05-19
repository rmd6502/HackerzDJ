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
#import "PlaylistVideoController.h"
#import "AddPlaylistController.h"
#import "Reachability.h"

@implementation PlaylistViewController
@synthesize playlistTable;
@synthesize spinner;
@synthesize addButton;

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
	[self refresh:nil];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [(hackerdjzAppDelegate *)[[UIApplication sharedApplication]delegate] addButton].target = self;
    [(hackerdjzAppDelegate *)[[UIApplication sharedApplication]delegate] refreshButton].target = self;
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
	static NSString *CellIdentifier = @"PlaylistViewCell";
    
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

- (void)tableView:(UITableView *)tableView 
        accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *result = [playlists objectAtIndex:indexPath.row];
	PlaylistVideoController *pvc = [[PlaylistVideoController alloc]initWithNibName:nil bundle:nil];
	pvc.playlistId = [[result objectForKey:@"yt$playlistId"] objectForKey:@"$t"];
	pvc.title = [[result objectForKey:@"title"] objectForKey:@"$t"];
	[self.navigationController pushViewController:pvc animated:YES];
	[pvc release];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (!CAN_REMOVE_PLAYLISTS) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Not Allowed" message:@"Not allowed to remove playlists" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [av show];
            [av release];
            return;
        }
        [self startRemovePlaylist:indexPath];
    }
}

- (IBAction)refresh:(id)sender {
    if ([[Reachability sharedReachability] hasConnection]) {
        spinner.hidden = NO;
        [[YouTubeAPIModel sharedAPIModel] getPlaylistsWithDelegate:self];
    } else {
        UIAlertView *uav = [[UIAlertView alloc]initWithTitle:@"No Connection" 
                                                     message:@"You are not connected to the Internet.  Can't load Playlists" 
                                                    delegate:nil 
                                           cancelButtonTitle:@"OK" 
                                           otherButtonTitles:nil];
        [uav show];
        [uav release];
    }
}

- (IBAction)addPlaylist:(id)sender {
	LOG_DEBUG(@"add playlists");
    if (!CAN_ADD_PLAYLISTS) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Not Allowed" message:@"Not allowed to add playlists" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [av show];
        [av release];
        return;
    }
    AddPlaylistController *apc = [[AddPlaylistController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:apc animated:YES];
    [apc release];
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

- (IBAction)startRemovePlaylist:(id)sender {
    
}

@end

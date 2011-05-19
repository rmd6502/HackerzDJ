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
#import "CaptchaController.h"
#import "DetailViewController.h"
#import "Category_Parser.h"

@implementation SearchAddController
@synthesize instrs;
@synthesize playlistId;
@synthesize spinner;
@synthesize picker;

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
    NSMutableArray *newCategories = [[NSMutableArray alloc] init];
 	self.title = @"Add Youtube Videos";
	instrs.font = [UIFont fontWithName:@"ChalkDuster" size:20.0];
	results = nil;
    Category_Parser *cp = [[Category_Parser alloc] init];
    LOG_DEBUG(@"category parser %@",cp);
    NSArray *cats = [cp.root.rootElement elementsForName:@"atom:category"];
    for (GDataXMLElement *cat in cats) {
        NSDictionary *tmp = [NSDictionary dictionaryWithObjectsAndKeys:[cat attributeForName:@"term"].stringValue,
                             @"term",
                             [cat attributeForName:@"label"].stringValue, @"label",
                             nil];
        [newCategories addObject:tmp];
    }
    if (categories != nil) {
        [categories release];
    }
    [newCategories sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[(NSDictionary *)obj1 objectForKey:@"label"] compare:[(NSDictionary *)obj2 objectForKey:@"label"]];
    }];
    [newCategories insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",
                              @"term",
                              @"Any Category", @"label",
                              nil] atIndex:0];
    categories = newCategories;
    self.searchDisplayController.searchResultsTableView.rowHeight = 80;
    //LOG_DEBUG(@"categories %@", categories);
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
    [categories release];
	[authKey release];
    [super dealloc];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.searchDisplayController.searchBar resignFirstResponder];
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
    cell.textLabel.numberOfLines = 3;
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:14];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
	cell.textLabel.text = [[result objectForKey:@"title"] objectForKey:@"$t"];
	cell.detailTextLabel.text = [[[[result objectForKey:@"author"] objectAtIndex:0] objectForKey:@"name"] objectForKey:@"$t"];
	CGRect fr = cell.frame;
	LOG_DEBUG(@"1cell frame %@",NSStringFromCGRect(fr));
	fr.size.height = tableView.rowHeight;
	LOG_DEBUG(@"2cell frame %@",NSStringFromCGRect(fr));
	cell.frame = fr;
	fr = cell.imageView.frame;
	fr.size.height = tableView.rowHeight-1;
	cell.imageView.frame = fr;
	LOG_DEBUG(@"3cell frame %@",NSStringFromCGRect(cell.imageView.frame));
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
    [self startAddVideo:result];
}

- (void)startAddVideo:(NSDictionary *)result {
    spinner.hidden = NO;
    [self.view bringSubviewToFront:spinner];
	if ([YouTubeAPIModel sharedAPIModel].authKey == nil) {
		YoutubeClientAuth *req = [[YoutubeClientAuth alloc] init];
		req.target = self;
		req.tselector = @selector(clientAuthComplete:authKey:userData:);
		req.userData = result;
		if (![[YouTubeAPIModel sharedAPIModel] addToQueue:req description:@"Authenticate"]) {
			spinner.hidden = YES;
		}
	} else {
		[self doAddVideo:result];
	}
}

- (void)doAddVideo:(NSDictionary *)videoData {
	NSString *videoID = [[[videoData objectForKey:@"media$group"] objectForKey:@"yt$videoid"] objectForKey:@"$t"];
	[[YouTubeAPIModel sharedAPIModel] addVideo:videoID toPlaylist:playlistId delegate:self];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	 NSDictionary *result = [results objectAtIndex:indexPath.row];
	 DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:nil bundle:nil];
    detailViewController.details = result;
    detailViewController.delegate = self;

     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
        detailViewController.addButton.hidden = NO;
	 [detailViewController release];

}
#pragma mark -
#pragma mark UIPickerViewDelegate and DataSource
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[categories objectAtIndex:row] objectForKey:@"label"];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [categories count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    LOG_DEBUG(@"selected row %d", row);
}

#pragma mark -
#pragma mark WebRequestDelegate
- (void)operation:(BaseRequest *)request requestFinished:(BOOL)success {
	spinner.hidden = YES;
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
    self.searchDisplayController.searchResultsTableView.rowHeight = 80;
    NSString *category = [[categories objectAtIndex:[picker selectedRowInComponent:0]] objectForKey:@"term"];
	spinner.hidden = self.searchDisplayController.searchResultsTableView.hidden = ![[YouTubeAPIModel sharedAPIModel] videoSearch:[searchBar text] category:category delegate:self];
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
    self.searchDisplayController.searchResultsTableView.rowHeight = 80;
}

- (void)clientAuthComplete:(NSNumber *)success authKey:(NSString *)authKey_ userData:(NSObject *)userData {
	[YouTubeAPIModel sharedAPIModel].authKey = authKey_;
	[self doAddVideo:(NSDictionary *)userData];
}

- (void)videoAdded:(WebRequest *)request result:(BOOL)success {
	LOG_DEBUG(@"video add %@", [NSString stringWithCString:(const char *)[request.urlData bytes] encoding:NSASCIIStringEncoding]);
    spinner.hidden = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
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

@end

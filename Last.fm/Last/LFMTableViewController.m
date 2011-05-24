//
//  LFMTableViewController.m
//  Last
//
//  Created by Matthias Tretter on 24.05.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "LFMTableViewController.h"
#import "LFMEventsRequest.h"
#import "LFMEvent.h"
#import "PSDefines.h"
#import "LFMTableViewCell.h"
#import "LFMDetailViewController.h"


#define kImageViewTag   1234

@implementation LFMTableViewController

@synthesize request = request_;
@synthesize events = events_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        self.title = @"Last.fm Events";
    }
    
    return self;
}

- (void)dealloc {
    MCRelease(request_);
    MCRelease(events_);
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.request = [LFMEventsRequest eventsRequest];
    self.request.delegate = self;
    
    [self.request startAsynchronous];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.request.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.request.delegate = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ASIHTTPRequestDelegate
////////////////////////////////////////////////////////////////////////

- (void)requestFinished:(ASIHTTPRequest *)request {
    self.events = [LFMEvent eventsFromDictionary:request.userInfo];
    [self.tableView reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    DDLogError(@"Request failed: %@", request.error);
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource
////////////////////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellID = @"MTTableViewCellID";
    
	LFMTableViewCell *cell = nil;
    LFMEvent *event = [self.events objectAtIndex:indexPath.row];
    
	// step 1: is there a dequeueable cell?
	cell = (LFMTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
	// step 2: no? -> create new cell
	if (cell == nil) {
		cell = [[[LFMTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
    }
    
	// step 3: set up cell values
    
    // set title
    cell.mainTextLabel.text = event.title;
    // set date
    cell.detailTextLabel.text = [event.startDate description];
    // set image
    [cell setImageURL:event.mediumImageURL];
    
    return cell;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate
////////////////////////////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LFMDetailViewController *detailViewController = [[[LFMDetailViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    
    detailViewController.event = [self.events objectAtIndex:indexPath.row];
    //[self.navigationController pushViewController:detailViewController animated:YES];
    
    detailViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [self presentModalViewController:detailViewController animated:YES];
}

@end

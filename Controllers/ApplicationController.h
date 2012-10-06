//
//  ApplicationController.h
//  CoreAnimationListView
//
//  Created by Patrick Geiller on 07/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SampleObject.h"
#import "CAListView.h"
#import <AtoZ/AtoZ.h>


@interface ApplicationController : NSObject <NSTableViewDataSource>

@property (nonatomic, retain) NSMA *objects;

@property (assign) IBOutlet CAListView			*caListView;
@property (assign) IBOutlet NSArrayController 	*arrayController;
@property (assign) IBOutlet NSTableView		*tableView;

@end

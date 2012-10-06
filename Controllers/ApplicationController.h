//
//  ApplicationController.h
//  CoreAnimationListView


#import "CAListView.h"
#import <AtoZ/AtoZ.h>
#import "SampleObject.h"


@interface ApplicationController : NSObject <NSTableViewDataSource>

@property (nonatomic, retain) NSMA *mutObjects;

@property (assign) IBOutlet CAListView			*caListView;
@property (assign) IBOutlet NSArrayController 	*arrayController;
@property (assign) IBOutlet NSTableView			*tableView;

@end

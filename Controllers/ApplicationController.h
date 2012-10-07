//
//  ApplicationController.h
//  CoreAnimationListView


#import "CAListView.h"
#import <AtoZ/AtoZ.h>
#import "SampleObject.h"


@interface ApplicationController : NSObject <NSTableViewDataSource>

@property (nonatomic, strong) NSMA *mutObjects;

@property (strong) IBOutlet CAListView			*caListView;
@property (strong) IBOutlet NSArrayController 	*arrayController;
@property (assign) IBOutlet NSTableView			*tableView;
@property (assign) IBOutlet NSButton			*reload;

@end

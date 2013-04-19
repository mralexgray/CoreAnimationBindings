//
//  ApplicationController.h
//  CoreAnimationListView


#import "CAListView.h"
#import <AtoZ/AtoZ.h>


@interface ApplicationController : NSObject <NSTableViewDataSource>

@property (nonatomic, retain) NSMA *mutObjects;
@property (strong) NSOQ *q;

@property (assign) IBOutlet CAListView			*caListView;
@property (assign) IBOutlet NSArrayController 	*arrayController;
@property (assign) IBOutlet NSTableView			*tableView;
@property (nonatomic) NSS* palette;
@end

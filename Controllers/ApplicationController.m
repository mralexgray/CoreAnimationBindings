//
//  ApplicationController.m
//  CoreAnimationListView
//
//  Created by Patrick Geiller on 07/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ApplicationController.h"
#import "SampleObject.h"
#import "ColorCell.h"


#define SampleObjectDataType @"com.parmanoir.SampleObject"

@implementation ApplicationController
@synthesize objects, arrayController, caListView, tableView;

- (id)init
{
	if (![super init])	return nil;
	
	objects = [NSMutableArray array];

	// Add some objects
	SampleObject* object;
	object = [[SampleObject alloc]init];
	object.name = @"Core";
	object.description = @"This is an example";
	object.color = [NSColor colorWithDeviceRed:1.0 green:0.5 blue:0.5 alpha:1.0];
	[objects addObject:object];

	object = [[SampleObject alloc]init];
	object.name = @"Animation";
	object.description = @"of binding Cocoa objects";
	object.color = [NSColor colorWithDeviceRed:0.0 green:1.0 blue:0.5 alpha:1.0];
	[objects addObject:object];

	object = [[SampleObject alloc]init];
	object.name = @"Bindings";
	object.description = @"to CALayers";
	object.color = [NSColor colorWithDeviceRed:1.0 green:0.8 blue:0.5 alpha:1.0];
	[objects addObject:object];

	return	self;
}

- (void)awakeFromNib
{

	// Observe changes to the controller's objects array, 
	[caListView bind:@"objects" toObject:arrayController withKeyPath:@"arrangedObjects" options:nil];
	// and to each key of each instance of SampleObject
	[caListView bind:@"objectsKeyChanged" toObject:[SampleObject sharedInstance] withKeyPath:@"keyChanged" options:nil];


	// Setup drag and drop our tableview
	[tableView registerForDraggedTypes:[NSArray arrayWithObject:SampleObjectDataType] ];
	[tableView setDataSource:self];
}


/*
	Using Drag and Drop in Tables
	http://developer.apple.com/documentation/Cocoa/Conceptual/DragandDrop/UsingDragAndDrop.html#//apple_ref/doc/uid/20000726-BABFIDAB
*/
- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    // Copy the row numbers to the pasteboard.
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:SampleObjectDataType] owner:self];
    [pboard setData:data forType:SampleObjectDataType];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
	// Accept only reordering, no drop on 
	if (op == NSTableViewDropAbove)
		return NSDragOperationEvery;
		
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:SampleObjectDataType];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    int dragRow = [rowIndexes firstIndex];

	// Reordering is insertion at new position and removal at old position. No atomic method in arrays.
	id object = [[arrayController arrangedObjects] objectAtIndex:dragRow];
	[arrayController insertObject:object atArrangedObjectIndex:row];
	
	if (dragRow >= row) dragRow++;
	[arrayController removeObjectAtArrangedObjectIndex:dragRow];
	return	YES;
}


@end

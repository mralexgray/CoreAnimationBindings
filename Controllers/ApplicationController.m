//
//  ApplicationController.m
//  CoreAnimationListView
//
//  Created by Patrick Geiller on 07/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ApplicationController.h"
#import "ColorCell.h"

#define SampleObjectDataType @"com.parmanoir.SampleObject"

@implementation ApplicationController
@synthesize mutObjects, arrayController, caListView, tableView;

- (id)init
{
	if (![super init])	return nil;
	[self.reload setTarget:caListView];
	[self.reload setAction:@selector(repositionObjects)];

	NSColorList *colors = [[NSColorList availableColorLists]randomElement];
	// Add some objects

	mutObjects = [[NSArray arrayFrom:0 To:8] arrayUsingBlock:^id(id obj) {
		SampleObject* object;
		object = [SampleObject new];
		NSS *x = [[colors allKeys] randomElement];
		object.name = x;
		object.description = [[colors colorWithKey:x]nameOfColor];
		object.color = [colors colorWithKey:x];
//		return object.copy;
	}].mutableCopy;
	//	[mutObjects setAssociatedValue:colors forKey:@"colorlist"];


	return	self;
}

- (void)awakeFromNib
{

	// Observe changes to the controller's objects array, 
	[caListView bind:@"objects" toObject:arrayController withKeyPath:@"arrangedObjects" options:nil];
	// and to each key of each instance of SampleObject
	[caListView bind:@"objectsKeyChanged" toObject:[SampleObject sharedInstance] withKeyPath:@"keyChanged" options:nil];
//	[[SampleObject sharedInstance] addObserver:caListView forKeyPath:@"keyChanged" options:0 context:nil];

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

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSI)row proposedDropOperation:(NSTableViewDropOperation)op
{
	// Accept only reordering, no drop on 
	if (op == NSTableViewDropAbove)
		return NSDragOperationEvery;
		
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSI)row dropOperation:(NSTableViewDropOperation)operation
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

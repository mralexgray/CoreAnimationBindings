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


- (id)init
{
	if (![super init])	return nil;

	// Add some objects
	_mutObjects = [NSC.randomPalette map:^id(id obj) {
		SampleObject* object;
		object = [SampleObject new];
		object.name 	= [NSString randomBadWord];
		object.description = [NSString randomWords:3];
		object.color = obj;
		return object;
	}].mutableCopy;
	return	self;
}

- (void) awakeFromNib	{

	// Observe changes to the controller's objects array, 
	[_caListView bind:@"objects" toObject:_arrayController withKeyPath:@"arrangedObjects" options:nil];
	// and to each key of each instance of SampleObject
	[_caListView bind:@"objectsKeyChanged" toObject:[SampleObject sharedInstance]
			withKeyPath:@"keyChanged" 			 options:nil];
	// Setup drag and drop our tableview
	[_tableView registerForDraggedTypes:@[SampleObjectDataType]];
	[_tableView setDataSource:self];
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
	[_arrayController insertObject:_arrayController.arrangedObjects[dragRow] atArrangedObjectIndex:row];
	
	if (dragRow >= row) dragRow++;
	[_arrayController removeObjectAtArrangedObjectIndex:dragRow];
	return	YES;
}


@end

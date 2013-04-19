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

- (void) setPalette:(id)palette {

	_palette = palette;
	NSA* colors = [NSC colorsInListNamed:_palette];
	[CATransaction immediately:^{
		[_arrayController unbind:@"content"];
		[_caListView unbind:@"objects"];
		_caListView.listLayer.sublayers = nil;
		self.mutObjects = [colors cw_mapArray:^id(id object) {
			return [SampleObject instanceWithName:NSS.randomBadWord andColor:object];
		}].mutableCopy;
		[_arrayController bind:@"content" toObject:self withKeyPath:@"mutObjects" options:nil];
		[_caListView bind:@"objects" toObject:_arrayController withKeyPath:@"arrangedObjects" options:nil];
	}];
//	if (_mutObjects.count == 0)	[colors eachWithIndex:^(id obj, NSInteger idx) { [self.mutObjects addObject:obj]; }];
//	else if (colors.count < _mutObjects.count ) {
//		[colors eachWithIndex:^(id obj, NSInteger idx) {	[_mutObjects[idx] setColor:obj];	}];
//		for (int d = colors.count; d < _mutObjects.count-1; d++) [self.mutObjects addObject:[colors normal:d]];
//	}
//	else if (colors.count < _mutObjects.count) {
//		for (int j = _mutObjects.count; j > colors.count; j--)
//			 [self.mutObjects removeLastObject];
//
//	}
	[_caListView.layer setNeedsLayout];
//	NSLog(@"cleared the block");
//		[[@0 to:@(howManyNeeded)] eachWithIndex:^(id obj, NSInteger idx) {
//									[self.mutObjects addObject:[SampleObject instanceWithName:NSS.randomBadWord andColor:[colors normal:(idx + howManyNeeded)]]];						}];
//	else if (howManyNeeded < 0)
//		[[@0 to:@(colors.count - 1)] eachWithIndex:^(id obj, NSInteger idx) {
//			[self.mutObjects removeLastObject];
//		}];
// }
// else self.mutObjects = [colors cw_mapArray:^id(id object) {	return [SampleObject instanceWithName:NSS.randomBadWord andColor:[colors normal:(idx
//	 NSA* e = [_mutObjects subarrayFromIndex:colors.count-1];
//										NSLog(@"wanting to purge %@",e);
//										[self.arrayController removeObjects:e];

//	NSLog(@"NeED more?  %@... %ld  %ld", StringFromBOOL(needMre), _mutObjects.count, colors.count);
//	if (needMre) {
//	[_caListView setObjects:_mutObjects];
}

- (void) awakeFromNib	{
	_mutObjects = NSMA.new;
	_q = AZOS;
	self.palette = [(NSCL*)NSC.colorLists.randomElement name];

	[NotificationCenterSpy toggleSpyingAllNotificationsIgnoring:@[] ignoreOverlyVerbose:YES];
	// Observe changes to the controller's objects array,
	[_arrayController bind:@"content" toObject:self withKeyPath:@"mutObjects" options:nil];
	[_caListView bind:@"objects" toObject:_arrayController withKeyPath:@"arrangedObjects" options:nil];
	// and to each key of each instance of SampleObject
	[_caListView bind:@"objectsKeyChanged" toObject:SampleObject.sharedInstance
			withKeyPath:@"keyChanged" 			 options:nil];

//	[_caListView bind:@"objectsKeyChanged" toObject:self.class.sharedInstance
//			withKeyPath:@"keyChanged" 			 options:nil];
	// Setup drag and drop our tableview
	[_tableView registerForDraggedTypes:@[SampleObjectDataType]];
	[_tableView setDataSource:self];

	[AZNOTCENTER addObserverForName:@"LayerHitAtIndexNotification"
							  object: nil
								queue: NSOQ.mainQueue
						 usingBlock: ^(NSNotification *d) {		NSLog(@"Rec'd notification %@", d);
		NSUI index = [d.userInfo integerForKey:@"index"];
		[_tableView selectItemsInArray:@[_mutObjects[index]] usingSourceArray:_mutObjects];
	}];
}


// drag operation stuff
//- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
//{
//	// Copy the row numbers to the pasteboard.
//	NSData *zNSIndexSetData = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
//	[pboard declareTypes:[NSArray arrayWithObject:SampleObjectDataType] owner:self];
//	[pboard setData:zNSIndexSetData forType:SampleObjectDataType];
//	return YES;
//}
- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSI)row proposedDropOperation:(NSTableViewDropOperation)op
{
	// Add code here to validate the drop
	//NSLog(@"validate Drop");	return NSDragOperationEvery;
	
	// Accept only reordering, no drop on
	if (op == NSTableViewDropAbove)	return NSDragOperationEvery;
	return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info
				  row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
	NSPasteboard* pboard = [info draggingPasteboard];
	NSData* rowData = [pboard dataForType:SampleObjectDataType];
	NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
	NSInteger dragRow = [rowIndexes firstIndex];

//	id whereTo = [self.mutObjects objectAtIndex:dragRow];
//	id dragee = [self.mutObjects objectAtIndex:row];
	// Move the specified row to its new location...  if we remove a row then everything moves down by one
	// so do an insert prior to the delete --- depends which way we're moving the data!!!
//	if (dragRow < row) {

		[self.mutObjects moveObjectAtIndex:dragRow toIndex:row]; //toIndex:dragRow];
		[_caListView.layer setNeedsLayout];
//		[self.nsMutaryOfMyData insertObject:[self.nsMutaryOfMyData objectAtIndex:dragRow] atIndex:row];
//		[self.nsMutaryOfMyData removeObjectAtIndex:dragRow];
//		[self.nsTableViewObj noteNumberOfRowsChanged];
//		[self.nsTableViewObj reloadData];

//		return YES;

//	} // end if

//	MyData * zData = [self.nsMutaryOfMyData objectAtIndex:dragRow];
//	[self.nsMutaryOfMyData removeObjectAtIndex:dragRow];
//	[self.nsMutaryOfMyData insertObject:zData atIndex:row];
//	[self.nsTableViewObj noteNumberOfRowsChanged];
//	[self.nsTableViewObj reloadData];

	return YES;
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

/*
- (BOOL)tableView:(NSTV*)aTV acceptDrop:(id <NSDraggingInfo>)info row:(NSI)row dropOperation:(NSTVDO)op
{
    NSPasteboard	 *pboard = [info 									 draggingPasteboard];
    NSData		 	*rowData = [pboard 			  dataForType:SampleObjectDataType];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    				int dragRow = rowIndexes.firstIndex;
	id moving = _mutObjects[dragRow];

	// Reordering is insertion at new position and removal at old position. No atomic method in arrays.
//	[self.mutObjects moveObjectAtIndex:[_mutObjects indexOfObject:moving] toIndex:row];
	[self.mutObjects ]
	[_arrayController insertObject:_arrayController.arrangedObjects[dragRow] atArrangedObjectIndex:row];

	if (dragRow >= row) dragRow++;
	[self.mutObjects removeObjectAtIndex:dragRow];
//	[_arrayController removeObjectAtArrangedObjectIndex:dragRow];

//	_arrayController
	return	YES;
}
*/

@end

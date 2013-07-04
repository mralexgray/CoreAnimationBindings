
#import "ApplicationController.h"
#define COLORKEY @"color"

@implementation SampleObject
+ (instancetype) instanceWithName:(NSS*)name andColor:(NSC*)c	{
	SampleObject *n = self.class.instance;	n.name = name.copy;	n.color = c ?: RANDOMCOLOR.deviceRGBColor; return n;
}
- (void) setName: 	 				 (NSS*)name					 		{
	if  (name) _name = name.copy;
	if (_name)	[AZOS addOperation:[NSBLO blockOperationWithBlock:^{	self.description = _name.wikiDescription ?: @"description N/A"; }]];
}
@end

@implementation ColorCell
SYNTHESIZE_SINGLETON_FOR_CLASS	 (ColorCell, sharedInstance);

- (void) drawInteriorWithFrame:	 (NSR)cF 	inView:(NSV*)cV	{	// Draw a bezier roundrect filled with current color
	[[NSBP bezierPathWithRoundedBottomCorners:NSInsetRect(cF, 1, 2) radius:4] drawWithFill:self.color andStroke:BLACK];
}
- (void) setObjectValue:			 (id)obj								{	// save color for use in drawing
	if (obj) _color = obj;	[super setObjectValue:obj];
}
- (void) colorPanelAction:			 (id)i								{
	
	// colorPanelAction - 	called by NSColorPanel on color change. Dispatch new color to observed object's keypath.	[self.class.observedObject
	NSC* c; NSLog(@"selfObjVal:%@  selfRepObj: %@  ColorPanlColl:%@", self.objectValue, self.representedObject, c = NSColorPanel.sharedColorPanel.color);
	[self setObjectValue:c];
	//	[[self representedObject] setValue:NSColorPanel.sharedColorPanel.color forKey:@"color"];
	//	 setValue:NSColorPanel.sharedColorPanel.color forKey:@"color"];//ColorCell.observedKeyPath];
}
- (void) selectWithFrame:(NSR)aRect         inView:(NSV*)cV
					   editor:(NSText*)textObj delegate:(id)anObject
						 start:(NSI)selStart      length:(NSI)selLen	{

	// When being double clicked, launch color panel
	//	[ColorCell setCurrentObservedObject:self keyPath:_observedKeyPath];
	AZCOLORPANEL;
	[NSApp orderFrontColorPanel:AZCOLORPANEL];
	[AZCOLORPANEL setTarget: self];//ColorCell.sharedInstance];
	[AZCOLORPANEL setAction: @selector(colorPanelAction:)];
	// Init color panel with cell's observed color
	[AZCOLORPANEL  setColor:[self vFKP:@"color"]];//[_observedObject valueForKeyPath:_observedKeyPath]];
}
@end
@implementation ApplicationController
- (void) awakeFromNib														{		_mutObjects = NSMA.new;		_q = AZOS;		_tableView.delegate = self;	[NSColorPanel sharedColorPanel];

	[AtoZ sharedInstance];
	// Observe changes to the controller's objects array,
	[_arrayController bind:@"arrangedObjects" 		toObject:self 								withKeyPath:@"mutObjects" options:nil];
	[_caListView bind:@"objects" 				toObject:_arrayController 				withKeyPath:@"arrangedObjects" options:nil];
	// and to each key of each instance of SampleObject
	[_caListView bind:@"objectsKeyChanged" toObject:SampleObject.sharedInstance withKeyPath:@"keyChanged" options:nil];


	//	_arrayController = [ColorsController.alloc initWithObject:self withKeyPath:@"mutObjects" inTable:_tableView withColumns:@[@"name", @"description", @"color"]];
	//	[_tableView registerForDraggedTypes:@[SampleObjectDataType]];
	//	[_tableView setDataSource:self];

	[AZNOTCENTER addObserverForName:@"LayerHitAtIndexNotification" object: nil	queue: NSOQ.mainQueue usingBlock: ^(NSNOT*d) {		NSLog(@"Rec'd notification %@", d);		NSUI index = [d.userInfo integerForKey:@"index"];
		[_tableView selectItemsInArray:@[_mutObjects[index]] usingSourceArray:_mutObjects];
	}];
	[self setCellClass:ColorCell.class inColumnWithId:@"color"];
	self.palette = [(NSCL*)NSC.colorLists.allValues.randomElement name];
}
- (void) setCellClass: (Class)class inColumnWithId:(NSS*)name	{

	NSUI index; NSCell* colorCell; NSTC* column;
	if ((index = [_tableView columnWithIdentifier:name]) != NSNotFound) {

					   column = _tableView.tableColumns [index];
			      colorCell = [class.alloc init];
		   column.dataCell = colorCell;
		  colorCell.target = _colorWell;
		  colorCell.action = @selector(performClick:);
//		[colorCell setValue: name forKey:@"colorKey"];
	}

}
- (void) setPalette: 		  (id)palette 								{		_palette = palette;

	NSA* colors = [NSC colorsInListNamed:_palette];
	NSLog(@"setting palette with %@: %@", _palette, colors);
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
	[_caListView.layer setNeedsLayout];
}
- (void) tableViewSelectionDidChange:(NSNOT*)notification 				{

//	NSUI row = [(NSTV*)[notification object] selectedRow];
	NSP click = [[[NSApp mainWindow]contentView] convertPointToScreen:AZCenterOfRect(_colorWell.frame)];
	[AZStringFromPoint(click) log];
//	PostMouseEvent(kCGMouseButtonLeft, NX_LMOUSEDOWN, click);
}

BASICTABLEVIEWDRAGDROP ( @"mutObjects", @"tableView");// Setup drag and drop our tableview
@end

/*

	[well performSelector:@selector(mouseDown:) withObject[_tableView selectedCell]];
	NSRect frame = [(NSTV*)sender frameOfCellAtColumn:2 row:[sender selectedRow]];
	[_colorwell setFrame:[[_colorTable window]frame]];
	[AZStringFromRect(frame) log];
	[AZStringFromRect([_colorwell frame]) log];
	[[_colorTable.enclosingScrollView superview] addSubview:_colorwell];

- (NSDO) tableView:(NSTV*)tV validateDrop:(IDDRAG)info proposedRow:(NSI)row proposedDropOperation:(NSTVDO)op	{

	// Add code here to validate the drop  NSLog(@"validate Drop");	return NSDragOperationEvery;
	// Accept only reordering, no drop on
	return op == NSTableViewDropAbove ? NSDragOperationEvery : NSDragOperationNone;
}
- (BOOL) tableView:(NSTV*)tV   acceptDrop:(IDDRAG)info		   row:(NSI)row 	      dropOperation:(NSTVDO)op	{

	NSPasteboard* pboard 		= [info draggingPasteboard];
	NSData		* rowData 		= [pboard dataForType:SampleObjectDataType];
	NSIS			* rowIndexes 	= [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
	NSI dragRow 					= [rowIndexes firstIndex];

	[self.mutObjects moveObjectAtIndex:dragRow toIndex:row]; //toIndex:dragRow];
	[_caListView.layer setNeedsLayout];
	return YES;
}
- (BOOL) tableView:(NSTV*)tV 					    writeRowsWithIndexes:(NSIS*)rowIdxs    toPasteboard:(NSPB*)pb		{

	 // Copy the row numbers to the pasteboard.
    NSData 	*data = [NSKeyedArchiver archivedDataWithRootObject:rowIdxs];
    [pb declareTypes:@[SampleObjectDataType] owner:self];
    [pb setData:data forType:SampleObjectDataType];
    return YES;
}
*/
/*

 drag operation stuff
 - (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
 {
 // Copy the row numbers to the pasteboard.
 NSData *zNSIndexSetData = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
 [pboard declareTypes:[NSArray arrayWithObject:SampleObjectDataType] owner:self];
 [pboard setData:zNSIndexSetData forType:SampleObjectDataType];
 return YES;
 }

 Using Drag and Drop in Tables
 http://developer.apple.com/documentation/Cocoa/Conceptual/DragandDrop/UsingDragAndDrop.html#//apple_ref/doc/uid/20000726-BABFIDAB

 id whereTo = [self.mutObjects objectAtIndex:dragRow];
 id dragee = [self.mutObjects objectAtIndex:row];
 // Move the specified row to its new location...  if we remove a row then everything moves down by one
 // so do an insert prior to the delete --- depends which way we're moving the data!!!
 if (dragRow < row) {
 [self.nsMutaryOfMyData insertObject:[self.nsMutaryOfMyData objectAtIndex:dragRow] atIndex:row];
 [self.nsMutaryOfMyData removeObjectAtIndex:dragRow];
 [self.nsTableViewObj noteNumberOfRowsChanged];
 [self.nsTableViewObj reloadData];
 return YES;
 } // end if
 MyData * zData = [self.nsMutaryOfMyData objectAtIndex:dragRow];
 [self.nsMutaryOfMyData removeObjectAtIndex:dragRow];
 [self.nsMutaryOfMyData insertObject:zData atIndex:row];
 [self.nsTableViewObj noteNumberOfRowsChanged];
 [self.nsTableViewObj reloadData];


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

@interface Colors : NSObject
 @property    (copy) NSString * area;
 @property  (strong)  NSColor * color;
 @end



 //			if ([ident isEqualToString:@"color"]) {
 //		}
 //	}

 //	self.innerColor = _innerObject.color;	self.outerColor = _outerObject.color;
 //	[_innerObject addObserver:self forKeyPath:@"color" options:NSKeyValueObservingOptionNew context:nil];
 //	[_outerObject addObserver:self forKeyPath:@"color" options:NSKeyValueObservingOptionNew context:nil];

 @implementation LVColorWellCell
 //-      (id) init															{		if (self != super.init ) return nil;
 //	self.target	=	self;
 ////	self.action	=	@selector(showPicker:);
 //return self;
 //}
 -(NSColor*) color:		         (id)sender						{

 if (sender == nil || [sender clickedRow] == -1)	return [self objectValue];
 _colorObject = [[(NSArrayController*)[sender dataSource] arrangedObjects] objectAtIndex:[sender clickedRow]];
 return [_colorObject valueForKey:[self colorKey]];
 }
 -    (void) setColor:		(NSColor*)color						{		[_colorObject setValue:color forKey:[self colorKey]];	}
 -    (void) showPicker:		      (id)sender						{

 [NSApp orderFrontColorPanel:self];
 NSColorPanel* colorPanel = NSColorPanel.sharedColorPanel;
 colorPanel.color			= [self color:sender];
 [colorPanel setTarget: self];//ColorCell.sharedInstance];
 [colorPanel setAction: @selector(setColor:)];
 // Init color panel with cell's observed color
 //	[colorPanel  setColor:[self valueForKeyPath:@"color"]]
 colorPanel.continuous	= YES;
 colorPanel.showsAlpha 	= YES;
 colorPanel.target		= self;
 colorPanel.action		= @selector(colorChanged:);
 [NSColorPanel.sharedColorPanel makeKeyAndOrderFront:self];

 }
 -    (void) colorChanged:	      (id)sender						{	self.color = NSColorPanel.sharedColorPanel.color;	}
 -    (void) drawWithFrame:	  (NSRect)cF inView:(NSView*)cV	{

 [NSGraphicsContext saveGraphicsState];
 [[NSColor redColor] setStroke];
 NSBezierPath * path = [NSBezierPath bezierPathWithRect:cF];	[path setLineWidth:1];	[path stroke];
 cF = NSInsetRect(cF, 2.0, 2.0);
 NSColor * color = (NSColor *)[self objectValue];
 [color respondsToSelector:@selector(setFill)]	? [color drawSwatchInRect:cF] : nil;
 [NSGraphicsContext restoreGraphicsState];
 }
 @end
 //@implementation Colors
 //@end



 @interface LVColorWellCell : NSActionCell
 @property   (weak) id			 colorObject;
 @property (strong) NSString	*colorKey;
 @end
 @interface ColorsController : NSArrayController <NSTableViewDelegate>
 @property	(weak) IBOutlet AtoZColorWell *colorwell;
 @property   (weak) IBOutlet NSTableView	*colorTable;
 @end
 @implementation ColorsController
 -   (id) initWithObject: (id)object withKeyPath:(NSS*)kp inTable:(NSTV*)tv withColumns:(NSA*)a						{		if (self != super.init ) return nil;

 _colorTable 			= tv;
 _colorTable.delegate = self;
 NSUI index 				= [_colorTable columnWithIdentifier:COLORKEY];
 if (index == NSNotFound) return self;
 LVColorWellCell *colorCell;
 NSTC *tabColumn 		= _colorTable.tableColumns [index];
 tabColumn.dataCell	= colorCell = LVColorWellCell.alloc.init;
 colorCell.target 		= _colorwell;
 colorCell.action 		= @selector(performClick:);
 colorCell.colorKey 	= COLORKEY;
 return self;
 //	NSS*binding = [NSString stringWithFormat:@"arrangedObjects.%@", ident];
 //	NSLog(@"attempting a binding with tablecolumnd at index: %ld with kp:%@",index, binding);
 //	[column bind:NSValueBinding toObject:self withKeyPath:binding options:nil];
 }
 - (void) observeValueForKeyPath:(NSS*)keyPath ofObject:(id)object change:(NSD*)change context:(void*)context	{

 NSLog(@"observeKP:%@  obj:%@  ch:%@", keyPath, object, change);
 //		object == _innerObject	? 	^{ self.innerColor = _innerObject.color; 	}()
 //	:	object == _outerObject	?	^{ self.outerColor = _outerObject.color;	}()
 //	:
 [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
 }
 @end


 */
/*	if (_mutObjects.count == 0)	[colors eachWithIndex:^(id obj, NSInteger idx) { [self.mutObjects addObject:obj]; }];
 else if (colors.count < _mutObjects.count ) {
 [colors eachWithIndex:^(id obj, NSInteger idx) {	[_mutObjects[idx] setColor:obj];	}];
 for (int d = colors.count; d < _mutObjects.count-1; d++) [self.mutObjects addObject:[colors normal:d]];
 }
 else if (colors.count < _mutObjects.count) {
 for (int j = _mutObjects.count; j > colors.count; j--)
 [self.mutObjects removeLastObject];

 }
 NSLog(@"cleared the block");
 [[@0 to:@(howManyNeeded)] eachWithIndex:^(id obj, NSInteger idx) {
 [self.mutObjects addObject:[SampleObject instanceWithName:NSS.randomBadWord andColor:[colors normal:(idx + howManyNeeded)]]];						}];
 else if (howManyNeeded < 0)
 [[@0 to:@(colors.count - 1)] eachWithIndex:^(id obj, NSInteger idx) {
 [self.mutObjects removeLastObject];
 }];
 }
 else self.mutObjects = [colors cw_mapArray:^id(id object) {	return [SampleObject instanceWithName:NSS.randomBadWord andColor:[colors normal:(idx
 NSA* e = [_mutObjects subarrayFromIndex:colors.count-1];
 NSLog(@"wanting to purge %@",e);
 [self.arrayController removeObjects:e];
 NSLog(@"NeED more?  %@... %ld  %ld", StringFromBOOL(needMre), _mutObjects.count, colors.count);
 if (needMre) {
 [_caListView setObjects:_mutObjects];
 */
/*@synthesize	observedKeyPath, color, observedObject;
 static	id		_classObservedObject = nil;
 static	NSS* 	_classObservedKeyPath = nil;;
 + (void) setCurrentObservedObject:(id)obObj keyPath:(NSS*)obKp {
 printf("%s\n\n", $(@"%@currentobvserved obj:%@, andkp:%@",[ obObj valueForKeyPath:obKp], obObj, obKp).UTF8String);
 _classObservedObject		= obObj;
 _classObservedKeyPath	= [NSS stringWithString:obKp];
 }
 +   (id) observedObject														{		return	_classObservedObject;		}
 +   (id) observedKeyPath													{		return	_classObservedKeyPath;		}
 - (void) bind:(NSS*)bndg toObject:(id)obsrvbl
 withKeyPath:(NSS*)kP 	  options:(NSD*)opt							{

 printf("%s\n\n", $(@"bind:%@ toObj: %@ kp:%@ opt:%@",bndg, obsrvbl, kP, opt).UTF8String);
 _observedObject = obsrvbl; 	 _observedKeyPath = kP;
 [super bind:bndg toObject:obsrvbl withKeyPath:kP options:opt];
 }
 */

//
//  ColorCell.m
//  CoreAnimationBindings

#import "ColorCell.h"



@implementation ColorCell
//@synthesize	observedKeyPath, color, observedObject;
//static	id		_classObservedObject = nil;
//static	NSS* 	_classObservedKeyPath = nil;;

SYNTHESIZE_SINGLETON_FOR_CLASS(ColorCell, sharedInstance);

- (void) drawInteriorWithFrame:	 (NSR)cF 	inView:(NSV*)cV	{

	// Draw a bezier roundrect filled with current color
	[[NSBP bezierPathWithRoundedBottomCorners:NSInsetRect(cF, 1, 2) radius:4] drawWithFill:_color andStroke:BLACK];
}
- (void) setObjectValue:			 (id)obj								{
	// setObjectValue -	save color for use in drawing
	if (obj != nil) _color = obj;
	[super setObjectValue:obj];
}
//+ (void) setCurrentObservedObject:(id)obObj keyPath:(NSS*)obKp {
//
//	printf("%s\n\n", $(@"%@currentobvserved obj:%@, andkp:%@",[ obObj valueForKeyPath:obKp], obObj, obKp).UTF8String);
//	_classObservedObject		= obObj;
//	_classObservedKeyPath	= [NSS stringWithString:obKp];
//}
//+   (id) observedObject														{		return	_classObservedObject;		}
//+   (id) observedKeyPath													{		return	_classObservedKeyPath;		}
- (void) colorPanelAction:			 (id)i								{

	// colorPanelAction - 	called by NSColorPanel on color change. Dispatch new color to observed object's keypath.
//[self  //	[self.class.observedObject
	[[self representedObject] setValue:NSColorPanel.sharedColorPanel.color forKey:@"color"];
//	 setValue:NSColorPanel.sharedColorPanel.color forKey:@"color"];//ColorCell.observedKeyPath];
}
//- (void) bind:(NSS*)bndg toObject:(id)obsrvbl
//  withKeyPath:(NSS*)kP 	  options:(NSD*)opt							{
//
//	printf("%s\n\n", $(@"bind:%@ toObj: %@ kp:%@ opt:%@",bndg, obsrvbl, kP, opt).UTF8String);
//
//	_observedObject = obsrvbl; 	 _observedKeyPath = kP;
//
//	[super bind:bndg toObject:obsrvbl withKeyPath:kP options:opt];
//}

- (void) selectWithFrame:(NSR)aRect         inView:(NSV*)cV
					   editor:(NSText*)textObj delegate:(id)anObject
						 start:(NSI)selStart      length:(NSI)selLen	{

	// When being double clicked, launch color panel
//	[ColorCell setCurrentObservedObject:self keyPath:_observedKeyPath];
	[NSApp orderFrontColorPanel:self];
	NSColorPanel* colorPanel = NSColorPanel.sharedColorPanel;
	[colorPanel setTarget: self];//ColorCell.sharedInstance];
	[colorPanel setAction: @selector(colorPanelAction:)];
	// Init color panel with cell's observed color
	[colorPanel  setColor:[self valueForKeyPath:@"color"]];//[_observedObject valueForKeyPath:_observedKeyPath]];
}


@end


/*		+ (id)sharedInstance															{

 //	As cells seem to be recycled very aggressively, (used for painting and dismissed) use a shared instance to hold some data we're interested in : observed object and keypath. When clicking the cell, launch color panel and keep our observed data around to know what to update.

 static id singleton;
 @synchronized(self)
 {
 if (!singleton)
 singleton = [[ColorCell alloc] init];
 return singleton;
 }
 return singleton;
 }	*/

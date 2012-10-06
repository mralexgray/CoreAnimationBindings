//
//  ColorCell.m
//  CoreAnimationBindings

#import "ColorCell.h"

@implementation ColorCell
@synthesize	observedKeyPath, color, observedObject;

// Draw a bezier roundrect filled with current color

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(cellFrame, 4, 3) xRadius:4 yRadius:4];
	[path drawWithFill:color andStroke:BLACK];
}

// setObjectValue -	save color for use in drawing
- (void)setObjectValue:(id)object
{
	if (object != nil)	
		color = object;
	[super setObjectValue:object];
}

//	As cells seem to be recycled very aggressively, (used for painting and dismissed) use a shared instance to hold some data we're interested in : observed object and keypath. When clicking the cell, launch color panel and keep our observed data around to know what to update.

+ (id)sharedInstance
{
	static id singleton;
	@synchronized(self)
	{
		if (!singleton)
			singleton = [[ColorCell alloc] init];
		return singleton;
	}
	return singleton;
}
static	id			_observedObject;
static	NSString*	_observedKeyPath;
+ (void)setCurrentObservedObject:(id)observedObject keyPath:(NSString*)observedKeyPath
{
	_observedObject		= observedObject;
	_observedKeyPath	= [NSString stringWithString:observedKeyPath];
}
+ (id)observedObject
{
	return	_observedObject;
}
+ (id)observedKeyPath
{
	return	_observedKeyPath;
}

//
// When being bound, save what we're being bound to
//
- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	observedObject = observable;
	observedKeyPath = keyPath;
	[super bind:binding toObject:observable withKeyPath:keyPath options:options];
}


//
// When being double clicked, launch color panel
//
- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength
{
	[ColorCell setCurrentObservedObject:observedObject keyPath:observedKeyPath];
	
	[NSApp orderFrontColorPanel:self];
	NSColorPanel* colorPanel = [NSColorPanel sharedColorPanel];
	[colorPanel setTarget:[ColorCell sharedInstance]];
	[colorPanel setAction:@selector(colorPanelAction:)];

	// Init color panel with cell's observed color
	[colorPanel setColor:[observedObject valueForKeyPath:observedKeyPath]];
}

//
// colorPanelAction
//	called by NSColorPanel on color change. Dispatch new color to observed object's keypath.
//
- (void)colorPanelAction:(id)i
{
	[[ColorCell observedObject] setValue:[[NSColorPanel sharedColorPanel] color] forKeyPath:[ColorCell observedKeyPath]];
}

@end

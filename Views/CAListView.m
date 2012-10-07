//
//  CAListView.m
//  CoreAnimationBindings
//
//  Created by Patrick Geiller on 23/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CAListView.h"


@implementation CAListView
@synthesize backgroundGradient, backgroundImage, layerHash, listLayer, observedObjects, recycledLayers;

- (void)awakeFromNib
{
	// Our layer hash : this is how we match objects and layers.  Holds a CALayer as value by using an object's pointer as its key.
	layerHash 				= [NSMutableDictionary dictionary];
	// Recycle bin for layers
	recycledLayers			= [NSMutableArray array];
	// Gradient
//	size_t num_locations	= 3;
//	CGFloat locations[3] 	= { 0.0, 0.7, 1.0 };
//	CGFloat components[12] 	= {	0.0, 0.0, 0.0, 1.0,  	0.7, 0.6, 1.0, 1.0,		1.0, 1.0, 1.0, 1.0 };
// 	CGColorSpaceRef space	= CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
//	backgroundGradient 		= CGGradientCreateWithColorComponents(space, components, locations, num_locations);
	// Setup core animation and our list layer
	self.wantsLayer			= YES;
	CALayer* rootLayer 		= [self layer];
	listLayer 				= [CALayer layer];
	listLayer.arMASK		= CASIZEABLE;
	rootLayer.sublayers		= @[listLayer];
	[listLayer addConstraintsSuperSize];
	listLayer.masksToBounds = YES;

	// Load our background image
	NSString* path = [[NSBundle mainBundle] pathForImageResource:@"gradient2.png"];
	backgroundImage = [[NSImage alloc]initWithContentsOfFile:path];

	// Re set our objects : we get them before waking up.
	[self setObjects:observedObjects];
}
// 	http://developer.apple.com/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_images/chapter_12_section_4.html
//	CGDataProviderRef provider = CGDataProviderCreateWithURL( (CFURLRef)([NSURL fileURLWithPath:path]) );
//	CGImageCreateWithPNGDataProvider(provider, nil, true, kCGRenderingIntentDefault);
//  CGDataProviderRelease (provider);


//
//	drawRect
//		draw our background gradient, Core Animation handles the rest
//
- (NSGradient*) backgroundGradient {
	return backgroundGradient = backgroundGradient ? backgroundGradient : [NSGradient gradientFrom:RANDOMCOLOR to:RANDOMCOLOR];
}

- (void)drawRect:(NSRect)rect 
{

//	[NSGraphicsContext saveGraphicsState];
	NSLog(@" graphics context before block : %@", [NSGraphicsContext currentContext].propertiesPlease);
	[[NSGraphicsContext currentContext]   state:^{
			NSLog(@" graphics context inside block : %@", [[NSGraphicsContext currentContext]]);
		[self.backgroundGradient drawInRect:rect angle:270];
	}];
//	[NSGraphicsContext restoreGraphicsState];
	/*	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	[NSGraphicsContext drawInContext:ctx flipped:NO actions:^{
		CGContextDrawRadialGradient(ctx, backgroundGradient,
								CGPointMake(self.width/2, self.height), self.width*2,
								CGPointMake(self.width/2, -self.height/2), 0,
								kCGGradientDrawsAfterEndLocation);
	}];
*/
}

//	the meat of the class. position objects, recycle layers of deleted objects, 
//	scale back container layer to view all objects when they're about to overflow the view

- (void)repositionObjects
{
	NSUI i;
	NSUI numObjects = [observedObjects count];
	NSLog(@"number of observed: %ld", numObjects);
	if (numObjects == 0)	return;
	AZSizer *u = [AZSizer forQuantity: numObjects inRect:[self bounds]];
	for (i=0; i<numObjects; i++)
	{
		CALayer* layer = [self layerForObject:[observedObjects objectAtIndex:i]];
		layer.frame = [[u.rects normal:i]rectValue];
	}
	NSLog(@"%d objects, %d layers", numObjects, [listLayer.sublayers count]);

	// Delete layers whose bound object has been deleted
//	NSArray* keys = [layerHash allKeys];
//	for (NSString* ptr in keys)
//	{
//		layer = [layerHash objectForKey:[NSNumber numberWithInt:(int)object]];
//		NSLog(@"layerhash ptr: %@", [layerHash valueForKey:ptr]);
//		NSUInteger idx = [observedObjects indexOfObject:];
//		// Needs recycling
//		if (idx == NSNotFound)
//			[self recycleLayerForObject:(id)[layerHash objectForKey:ptr]];
//	}
//	listLayer.bounds = CGRectMake(0, 0, containerWidth, containerHeight);
//	if (usedHeight > self.height)	listLayer.transform = CATransform3DMakeScale(s, s, s);
//	else	listLayer.transform = CATransform3DIdentity;
}

// Given an object, return its matching layer.  if no layer is found, check the recycle bin.  if recycle bin is empty, create a new layer
- (CALayer*)layerForObject:(id)object
{
	CALayer* layer = nil;
	layer = [layerHash objectForKey:[NSNumber numberWithInt:(int)object]];
	if (layer == nil)
	{
		if ([recycledLayers count]) 		// Get a layer out of the recycle bin if possible
		{
			layer = [recycledLayers objectAtIndex:0];
			[recycledLayers removeObjectAtIndex:0];
		}
		else layer = [self newLayer]; 		// Create a new one

		[self updateLayer:layer withObject:object];
		[layerHash setObject:layer forKey:[NSNumber numberWithInt:(int)object]];
		layer.transform = CATransform3DIdentity;
		layer.opacity = 1;
	}
	return	layer;
}

// new layer
//	one container layer
//	inside, another container layer, with gradient image and padding
//	inside, the two text layers for name and description
//
- (CALayer*)newLayer
{
	// master container layer
	CALayer* layer = [CALayer layer];
//	layer.anchorPoint = CGPointMake(0, 0);

	// container layer, having padding, gradient image and containing text layers
	CALayer* innerLayer = [CALayer layer];
//	innerLayer.anchorPoint = CGPointMake(0, 0);
	innerLayer.shadowOpacity = 0.5;
//	innerLayer.contents = [NSImage systemIcons].randomElement;//(id)backgroundImage;

	CATextLayer* textLayer1 = [CATextLayer layer];
	textLayer1.fontSize = 25;
	textLayer1.style	= @{@"font":@"Ubuntu Mono Bold"};
	AddShadow(textLayer1);
//	textLayer1.anchorPoint = CGPointMake(0, 0);
//	textLayer1.shadowOpacity= 0.7;
//	textLayer1.shadowRadius = 2.0;
//	textLayer1.shadowOffset = CGSizeMake(0, -2);

	CATextLayer* textLayer2 = [CATextLayer layer];
	textLayer2.fontSize = 15;
	textLayer2.style	= @{@"font":@"Ubuntu Mono Bold"};
//	textLayer2.opacity	= 0.7;
//	textLayer2.anchorPoint = CGPointMake(0, 0);


	[listLayer addSublayer:layer];
	[layer addSublayer:innerLayer];
	innerLayer.sublayers = @[textLayer1, textLayer2];
	[@[innerLayer, textLayer1, textLayer2] eachWithIndex:^(CALayer* obj, NSInteger idx) {
		obj.layoutManager 	= [CAConstraintLayoutManager layoutManager];
		obj.arMASK 			= CASIZEABLE;
		[obj addConstraintsSuperSize];
	}];
	[@[textLayer1, textLayer2]eachWithIndex:^(CATextLayer* obj, NSInteger idx) {
		[obj addConstraint:AZConstRelSuperScaleOff(kCAConstraintMaxY, .1*(idx+1),0)];
	}];
	return	layer;
}

//
// recycle layer for object
//	when an object is deleted in the controller, recycle its matching layer for later reuse
//
- (void)recycleLayerForObject:(id)object
{
	CALayer* layer = (CALayer*)[self layerForObject:object];
	// For some reason 0, 0, 0 doesn't work, use a small value instead
	layer.transform = CATransform3DMakeScale(0.01, 0.01, 0.01);
	layer.opacity = 0;

	[layerHash removeObjectForKey:[NSNumber numberWithInt:(int)object]];

	[recycledLayers addObject:layer];
}

// update layer
//	when objects change, reflect their new data in their corresponding layers
- (void)updateLayer:(CALayer*)layer withObject:(SampleObject*)object
{
	CALayer* innerLayer		= [layer.sublayers objectAtIndex:0];
	CATextLayer* textLayer1 = [innerLayer.sublayers objectAtIndex:0];
	CATextLayer* textLayer2 = [innerLayer.sublayers objectAtIndex:1];
	
	float hpadding = 10;
	float vpadding = 10;

	// Set padding of inner container layer
	innerLayer.position = CGPointMake(0, 10);
	
	// Reflect name
	textLayer1.string = object.name;
	CGSize s1 = [textLayer1 preferredFrameSize];
	textLayer1.bounds = CGRectMake(0, 0, s1.width, s1.height);
	// Reflect description
	textLayer2.string = object.description;
	CGSize s2 = [textLayer2 preferredFrameSize];
	textLayer2.bounds = CGRectMake(0, 0, s2.width, s2.height);
	// Reflect color
	NSColor*	color = [object color];
	innerLayer.backgroundColor = CGColorCreateGenericRGB([color redComponent], [color greenComponent], [color blueComponent], [color alphaComponent]);

	// Position text layers with some horizontal padding
	textLayer1.position = CGPointMake(hpadding, s2.height);
	textLayer2.position = CGPointMake(hpadding, 0);

	// Layer width is max width of its text layers
	float w = s1.width > s2.width ? s1.width : s2.width;
	innerLayer.bounds = CGRectMake(0, 0, w+hpadding*2, s1.height + s2.height);
	layer.bounds = CGRectMake(0, 0, w+hpadding*2, s1.height + s2.height+vpadding*2);
}

// Reposition objects on resize
- (void)viewDidEndLiveResize	{	[self repositionObjects];	}

// Observation
//	observe array change (insertion, removal), reposition objects on change
- (void)setObjects:(id)objects
{
	observedObjects = objects;
	[self repositionObjects];
}

- (id)objects { 	return	nil; 	}

// Observation
//	observe changes to object keys, update layer on change
- (void)setObjectsKeyChanged:(id)i
{
	SampleObject* object = [SampleObject lastModifiedInstance];
	CALayer* layer = [layerHash objectForKey:[NSNumber numberWithInt:(int)object]];
	[self updateLayer:layer withObject:object];
}
- (id)objectsKeyChanged
{
	return	nil;
}



@end

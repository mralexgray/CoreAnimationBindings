//
//  CAListView.m
//  CoreAnimationBindings
//
//  Created by Patrick Geiller on 23/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CAListView.h"


@implementation CAListView


- (void)awakeFromNib
{
	// Our layer hash : this is how we match objects and layers.
	// Holds a CALayer as value by using an object's pointer as its key.
	layerHash = [[NSMutableDictionary alloc] init];

	// Recycle bin for layers
	recycledLayers	= [[NSMutableArray alloc] init];


	// Gradient
	size_t num_locations = 3;
	CGFloat locations[3] = { 0.0, 0.7, 1.0 };
	CGFloat components[12] = {	0.0, 0.0, 0.0, 1.0,
								0.7, 0.6, 1.0, 1.0,
								1.0, 1.0, 1.0, 1.0 };
 	CGColorSpaceRef colorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	backgroundGradient = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);


	// Setup core animation and our list layer
	[self setWantsLayer:true];
	CALayer* rootLayer = [self layer];

	listLayer = [CALayer layer];
	[rootLayer addSublayer:listLayer];
	listLayer.bounds = CGRectMake(0, 0, 300, 300);
	listLayer.anchorPoint = CGPointMake(0, 0);
	listLayer.masksToBounds = YES;

	// Load our background image
	// http://developer.apple.com/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_images/chapter_12_section_4.html
	NSString* path = [[NSBundle mainBundle] pathForImageResource:@"gradient2.png"];
	CGDataProviderRef provider = CGDataProviderCreateWithURL( (CFURLRef)([NSURL fileURLWithPath:path]) );
	backgroundImage = CGImageCreateWithPNGDataProvider(provider, nil, true, kCGRenderingIntentDefault);
    CGDataProviderRelease (provider);

	
	// Re set our objects : we get them before waking up.
	[self setObjects:observedObjects];
}


//
//	drawRect
//		draw our background gradient, Core Animation handles the rest
//
- (void)drawRect:(NSRect)rect 
{
	float width = [self frame].size.width;
	float height = [self frame].size.height;
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort]; 	
	CGContextDrawRadialGradient(ctx, backgroundGradient, 
								CGPointMake(width/2, height), width*2, 
								CGPointMake(width/2, -height/2), 0,
								kCGGradientDrawsAfterEndLocation);
}


//
// reposition objects
//	the meat of the class. position objects, recycle layers of deleted objects, 
//	scale back container layer to view all objects when they're about to overflow the view
//
- (void)repositionObjects
{
	int i;
	int numObjects = [observedObjects count];
	
	
	
	// Delete layers whose bound object has been deleted
	NSArray* keys = [layerHash allKeys];
	for (NSNumber* ptr in keys)
	{
		int idx = [observedObjects indexOfObject:(id)[ptr intValue]];
		// Needs recycling
		if (idx == NSNotFound)
			[self recycleLayerForObject:(id)[ptr intValue]];
	}
	

	if (numObjects == 0)	return;

	float viewWidth = [self frame].size.width;
	float viewHeight = [self frame].size.height;

	CALayer* layer = [self layerForObject:[observedObjects objectAtIndex:0]];
	float layerHeight = layer.bounds.size.height;

	float usedHeight = numObjects * layerHeight;
	float s = viewHeight / usedHeight;
	
	float containerWidth = viewWidth;
	float containerHeight = viewHeight;
	float startHeight = viewHeight;
	if (usedHeight > viewHeight)	
	{
		startHeight = viewHeight/s;
		containerHeight = usedHeight/s;
		containerWidth = viewWidth/s;
	}
	
	for (i=0; i<numObjects; i++)
	{
		CALayer* layer = [self layerForObject:[observedObjects objectAtIndex:i]];
		float y = startHeight-layerHeight*(i+1);
		layer.position = CGPointMake(50, y);
	}
	
	listLayer.bounds = CGRectMake(0, 0, containerWidth, containerHeight);
	
	if (usedHeight > viewHeight)
		listLayer.transform = CATransform3DMakeScale(s, s, s);
	else
		listLayer.transform = CATransform3DIdentity;

//	NSLog(@"%d objects, %d layers", numObjects, [listLayer.sublayers count]);
}


//
// Given an object, return its matching layer
//	if no layer is found, check the recycle bin.
//	if recycle bin is empty, create a new layer
//
- (CALayer*)layerForObject:(id)object
{
	CALayer* layer = nil;
	layer = [layerHash objectForKey:[NSNumber numberWithInt:(int)object]];
	if (layer == nil)
	{
		// Get a layer out of the recycle bin if possible
		if ([recycledLayers count])
		{
			layer = [recycledLayers objectAtIndex:0];
			[recycledLayers removeObjectAtIndex:0];
		}
		else
		// Create a new one
			layer = [self newLayer];
		
		[self updateLayer:layer withObject:object];
		[layerHash setObject:layer forKey:[NSNumber numberWithInt:(int)object]];
		layer.transform = CATransform3DIdentity;
		layer.opacity = 1;
	}
	return	layer;
}

//
// new layer
//	one container layer
//	inside, another container layer, with gradient image and padding
//	inside, the two text layers for name and description
//
- (CALayer*)newLayer
{
	// master container layer
	CALayer* layer = [CALayer layer];
	layer.anchorPoint = CGPointMake(0, 0);

	// container layer, having padding, gradient image and containing text layers
	CALayer* innerLayer = [CALayer layer];
	innerLayer.anchorPoint = CGPointMake(0, 0);
	innerLayer.shadowOpacity = 0.5;
	innerLayer.contents = (id)backgroundImage;

	CATextLayer* textLayer1 = [CATextLayer layer];
	textLayer1.fontSize = 25;
	textLayer1.style	= [NSDictionary dictionaryWithObjectsAndKeys:@"Futura-MediumItalic", @"font", nil];
	textLayer1.anchorPoint = CGPointMake(0, 0);
	textLayer1.shadowOpacity= 0.7;
	textLayer1.shadowRadius = 2.0;
	textLayer1.shadowOffset = CGSizeMake(0, -2);

	CATextLayer* textLayer2 = [CATextLayer layer];
	textLayer2.fontSize = 15;
	textLayer2.style	= [NSDictionary dictionaryWithObjectsAndKeys:@"Futura-MediumItalic", @"font", nil];
	textLayer2.opacity	= 0.7;
	textLayer2.anchorPoint = CGPointMake(0, 0);
	
	[listLayer addSublayer:layer];
	[layer addSublayer:innerLayer];
	[innerLayer addSublayer:textLayer1];
	[innerLayer addSublayer:textLayer2];

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

//
// update layer
//	when objects change, reflect their new data in their corresponding layers
//
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


//
// Reposition objects on resize
//
- (void)viewDidEndLiveResize
{
	[self repositionObjects];
}


//
// Observation
//	observe array change (insertion, removal), reposition objects on change
//
- (void)setObjects:(id)objects
{
	observedObjects = objects;
	[self repositionObjects];
}

- (id)objects
{
	return	nil;
}

//
// Observation
//	observe changes to object keys, update layer on change
//
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

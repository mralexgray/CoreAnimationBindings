
#import "CAListView.h"

@implementation CAListView
{
	CAL*pulser;
}
- (void) viewWillStartLiveResize { [CATransaction disableActions]; }
- (void) viewDidEndLiveResize 	{ [CATransaction setDisableActions: NO]; } // [self repositionObjects]; }

- (void) mouseUp:(NSEvent *)theEvent   {

	CAL* l = [_listLayer hitTest:self.windowPoint];
	NSLog(@"Hit:  %@", l);
	CGColorRef now = l.bgC;
	if (l) { l.borderColor = cgRED;
				[l animate:@"backgroundColor" to:(__bridge id)cgRANDOMCOLOR time:1 completion:^{
					[l animate:@"backgroundColor" to:(__bridge id)now time:3 completion:^{
					l.borderColor = cgWHITE;
				}];
			}];
		NSN* idx = @([_listLayer.sublayers indexOfObject:l]);
		NSLog(@"posting index: %@", idx);
		[AZNOTCENTER postNotificationName:@"LayerHitAtIndexNotification" object:nil userInfo:@{@"index":idx}];
	}
}

- (void)awakeFromNib
{
	_layerHash 		= NSMD.new;	// Our layer hash : this is how we match objects and layers. Holds a CALayer as value by using an object's pointer as its key.
	_recycledLayers	= NSMA.new;	// Recycle bin for layers
	[self setWantsLayer:true];	// Setup core animation and our list layer
	[self.layer addSublayer:_listLayer = [CAL greyGradient]];
	self.layer.noHit							= YES;
//	_listLayer.noHit							= YES;
	_listLayer.frame							= self.bounds;
	_listLayer.masksToBounds				= YES;
	_listLayer.arMASK 						= CASIZEABLE;
	_listLayer.loM                      = self;
	[self setObjects:_observedObjects];	// Re set our objects : we get them before waking up.

}
- (void)drawRect:(NSRect)rect	{

//	[NSGraphicsContext saveGraphicsState];
//	NSLog(@" graphics context before block : %@", [NSGraphicsContext currentContext].propertiesPlease);
//	[[NSGraphicsContext currentContext]   state:^{
//			NSLog(@" graphics context inside block : %@", [NSGraphicsContext currentContext]);
//		[self.backgroundGradient drawInRect:rect angle:270];
//	}];
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
- (void) layoutSublayersOfLayer:(CALayer *)layer {
	// reposition objects - the meat of the class. position objects, recycle layers of deleted objects, scale back container layer to view all objects when they're about to overflow the view

	!_observedObjects.count ? nil :
	[[AZSizer forQuantity:_observedObjects.count inRect:self.bounds].rects eachWithIndex:^(id obj, NSInteger idx) {
		CAL* layer = [self layerForObject:[_observedObjects normal:idx]];
		!layer ? nil : ^{	layer.frame = [obj rectValue];  layer.zPosition = 100 *idx; }();
	}];
}
- (CAL*) layerForObject:(id)object	{

	// Given an object, return its matching layer if no layer is found, check the recycle bin. if recycle bin is empty, create a new layer
	CAL* layer = nil;												// Get a layer out of the recycle bin if possible
	layer = _layerHash[@((int)object)] ?: _recycledLayers.count ? _recycledLayers.shift : self.newLayer;

	//	layer = [0];[_recycledLayers removeObjectAtIndex:0];}else		// Create a new one			layer = [self newLayer];
	[self updateLayer:layer withObject:object];
	_layerHash[@((int)object)] = layer;
	layer.transform = CATransform3DIdentity;
	layer.opacity = 1;
	return	layer;
}

// new layer
//	one container layer
//	inside, another container layer, with gradient image and padding
//	inside, the two text layers for name and description
//
- (CALayer*)newLayer
{
// master container layer		CALayer* layer = [CALayer layer];	layer.anchorPoint = CGPointMake(0, 0); container layer, having padding, gradient image and containing text layers
//	innerLayer.frame = AZRectBy(100, 200);
//	innerLayer.anchorPoint = CGPointMake(0, 0);
	CAL* oLayer = [CAL layerNamed:@"objectLayer"];
//	oLayer.shadowOpacity = 0.5;
//	pLayer.borderColor = cgWHITE;
//	oLayer.borderWidth = 10;
//	innerLayer.contents = [NSImage systemIcons].randomElement;//(id)backgroundImage;

	CATextLayer* textLayer1 = [CATextLayer layer];
//	textLayer1.noHit = YES;
	textLayer1.fontSize = 30;
	textLayer1.style	= @{@"font":@"Ubuntu Mono Bold"};
//	AddShadow(textLayer1);
//	textLayer1.anchorPoint = CGPointMake(0, 0);
//	textLayer1.shadowOpacity= 0.7;
//	textLayer1.shadowRadius = 2.0;
//	textLayer1.shadowOffset = CGSizeMake(0, -2);

//	CATextLayer* textLayer2 = [CATextLayer layer];
//	textLayer2.noHit = YES;
//	textLayer2.fontSize = 30;
//	textLayer2.style	= @{@"font":@"Ubuntu Mono Bold"};
//	textLayer2.opacity	= 0.7;
//	textLayer2.anchorPoint = CGPointMake(0, 0);

//	[@[textLayer1, textLayer2]each:^(id obj) {
//		[obj setFrame: self.frame];
//		[obj setLayoutManager:AZLAYOUTMGR];
//		[obj addConstraintsSuperSize];
//		[innerLayer addSublayer:obj];
//	}];
//	[_listLayer addSublayer:layer];
//	innerLayer.sublayers = ;
	[oLayer addSublayer:textLayer1];
	[_listLayer addSublayer:oLayer];
//	[@[innerLayer, textLayer1, textLayer2] eachWithIndex:^(CALayer* obj, NSInteger idx) {
//		obj.layoutManager 	= [CAConstraintLayoutManager layoutManager];
//		obj.arMASK 			= CASIZEABLE;
//		[obj addConstraintsSuperSize];
//	}];
//	[@[textLayer1, textLayer2]eachWithIndex:^(CATextLayer* obj, NSInteger idx) {
//		[obj addConstraint:AZConstRelSuperScaleOff(kCAConstraintMaxY, .1*(idx+1),0)];
//	}];

	return	oLayer;
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

	[_layerHash removeObjectForKey:[NSNumber numberWithInt:(int)object]];

	[_recycledLayers addObject:layer];
}

// update layer
//	when objects change, reflect their new data in their corresponding layers
- (void)updateLayer:(CALayer*)layer withObject:(SampleObject*)object
{
	CALayer* innerLayer		= layer;// sublayerWithName:@"objectLayer"];//objectAtIndex:0];
	CATextLayer* textLayer1 = [innerLayer.sublayers objectAtIndex:0];
//	CATextLayer* textLayer2 = [innerLayer.sublayers objectAtIndex:1];
//
//	float hpadding = 10;
//	float vpadding = 10;

	// Set padding of inner container layer
//	innerLayer.position = CGPointMake(0, 10);

	// Reflect name
	textLayer1.string = [object.name firstLetter];
//	CGSize s1 = [textLayer1 preferredFrameSize];
//	textLayer1.bounds = CGRectMake(0, 0, s1.width, s1.height);
	// Reflect description
//	textLayer2.string = object.description;
//	CGSize s2 = [textLayer2 preferredFrameSize];
//	textLayer2.bounds = CGRectMake(0, 0, s2.width, s2.height);
	// Reflect color
	innerLayer.bgC = [[object color]CGColor];
//	innerLayer.backgroundColor = CGColorCreateGenericRGB([color redComponent], [color greenComponent], [color blueComponent], [color alphaComponent]);

	// Position text layers with some horizontal padding
//	textLayer1.position = CGPointMake(hpadding, s2.height);
//	textLayer2.position = CGPointMake(hpadding, 0);

	// Layer width is max width of its text layers
//	float w = s1.width > s2.width ? s1.width : s2.width;
//	innerLayer.bounds = CGRectMake(0, 0, w+hpadding*2, s1.height + s2.height);
//	layer.bounds = CGRectMake(0, 0, w+hpadding*2, s1.height + s2.height+vpadding*2);
}

// Observation

//	observe array change (insertion, removal), reposition objects on change
- (void)setObjects:(id)objects
{
	_observedObjects = objects;	[_listLayer setNeedsLayout];
}

- (id)objects { 	return	nil; 	}

// Observation 	observe changes to object keys, update layer on change
- (void)setObjectsKeyChanged:(id)i
{
	SampleObject* object = [SampleObject lastModifiedInstance];
	if (object)  {
		CALayer* layer = [_layerHash objectForKey:@((int)object)];
		[self updateLayer:layer withObject:object];
	}
}
- (id)objectsKeyChanged	{	return	nil;	}



@end

//	CALayer* layer = nil;
//	layer = [layerHash objectForKey:[NSNumber numberWithInt:(int)object]];
//	if (layer == nil)
//	{
//		if ([recycledLayers count]) 		// Get a layer out of the recycle bin if possible
//		{
//			layer = [recycledLayers objectAtIndex:0];
//			[recycledLayers removeObjectAtIndex:0];
//		}
//		else layer = [self newLayer]; 		// Create a new one
//
//		[self updateLayer:layer withObject:object];
//		[layerHash setObject:layer forKey:[NSNumber numberWithInt:(int)object]];
//		layer.transform = CATransform3DIdentity;
//		layer.opacity = 1;
//	}
//	return	layer;

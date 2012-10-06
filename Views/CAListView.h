//
//  CAListView.h
//  CoreAnimationBindings
//
//  Created by Patrick Geiller on 23/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "SampleObject.h"

@interface CAListView : NSView {

	NSMutableDictionary*	layerHash;
	NSMutableArray*			recycledLayers;
	
	CGGradientRef backgroundGradient;
	
	CGImageRef backgroundImage;
	CALayer*				listLayer;

	NSArray*	observedObjects;

}


- (void)repositionObjects;
- (CALayer*)layerForObject:(id)object;
- (CALayer*)newLayer;
- (void)recycleLayerForObject:(id)object;
- (void)updateLayer:(CALayer*)layer withObject:(SampleObject*)object;

- (void)setObjects:(id)objects;


@end

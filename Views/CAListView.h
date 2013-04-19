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
#import <AtoZ/AtoZ.h>

@interface CAListView : NSView

@property (nonatomic, strong) NSMD	*layerHash;
@property (nonatomic, strong) NSMA	*recycledLayers;
@property (nonatomic, strong) CAL	*listLayer;
@property (nonatomic, strong) NSA	*observedObjects;


- (void)repositionObjects;
- (CALayer*)layerForObject:(id)object;
- (CALayer*)newLayer;
- (void)recycleLayerForObject:(id)object;
- (void)updateLayer:(CALayer*)layer withObject:(id)object;

- (void)setObjects:(id)objects;


@end

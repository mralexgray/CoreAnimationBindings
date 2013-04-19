//
//  CAListView.h
//  CoreAnimationBindings
//
//  Created by Patrick Geiller on 23/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ColorCell.h"

@interface CAListView : NSView

@property (nonatomic) NSMD	*layerHash;
@property (nonatomic) NSMA	*recycledLayers;
@property (nonatomic) CAL	*listLayer;
@property (nonatomic) NSA	*observedObjects;


- (CALayer*)layerForObject:(id)object;
- (CALayer*)newLayer;
- (void)recycleLayerForObject:(id)object;
- (void)updateLayer:(CALayer*)layer withObject:(id)object;

- (void)setObjects:(id)objects;


@end

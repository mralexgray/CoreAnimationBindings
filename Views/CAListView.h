//
//  CAListView.h
//  CoreAnimationBindings
//
//  Created by Patrick Geiller on 23/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

@interface CAListView : NSView

@property (nonatomic) NSMD	* layerHash;
@property (nonatomic) NSMA	* recycledLayers;
@property (nonatomic)  CAL	* listLayer;
@property (nonatomic)  NSA	* observedObjects;

- (CAL*) newLayer;
- (CAL*) layerForObject: (id)object;
- (void) updateLayer:  (CAL*)layer withObject:(id)object;
- (void) recycleLayerForObject: 	  			    (id)object;
- (void) setObjects:									 (id)objects;

@end

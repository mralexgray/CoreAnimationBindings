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


@property (nonatomic, assign) NSUI numberOfLayers, numberOfObjects;
@property (assign) IBOutlet NSViewController *vC;
@property (nonatomic, retain) NSS *selectedIndex;
@property (nonatomic, retain) NSMA *objects;

- (void)repositionObjects;

- (void)updateLayer:(CALayer*)layer withObject:(id)object;
- (CALayer*)layerForObject:(id)object;

@end

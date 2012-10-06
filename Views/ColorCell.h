//
//  ColorCell.h
//  CoreAnimationBindings
//
//  Created by Patrick Geiller on 23/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// Derive from NSTextFieldCell so we can setup our cell name and bindings in IB. Less code !
@interface ColorCell : NSTextFieldCell {

	id	observedObject;
	
	NSString*	observedKeyPath;
	NSColor*	color;
	
}


@property	(copy)	NSString*	observedKeyPath;

@end

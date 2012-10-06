//
//  ColorCell.h
//  CoreAnimationBindings



// Derive from NSTextFieldCell so we can setup our cell name and bindings in IB. Less code !
@interface ColorCell : NSTextFieldCell

@property (nonatomic, strong) id		observedObject;
@property (nonatomic, strong) NSColor	*color;
@property (copy)			  NSString	*observedKeyPath;

@end

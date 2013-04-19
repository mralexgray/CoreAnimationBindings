



@interface SampleObject : BaseModel
@property (nonatomic)	NSString	* name;
@property (nonatomic)	NSString	* description;
@property (nonatomic)	NSColor	* color;
+ (instancetype) instanceWithName:(NSS*)name andColor:(NSC*)c;
@end

@interface ColorCell : NSTextFieldCell
// Derive from NSTextFieldCell so we can setup our cell name and bindings in IB. Less code !
@property (nonatomic, strong) id		observedObject;
@property (nonatomic, strong) NSColor	*color;
@property (copy)			  		NSString	*observedKeyPath;
@end

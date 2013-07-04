
#import <AtoZ/AtoZ.h>
#import "CAListView.h"


#define SampleObjectDataType @"com.parmanoir.SampleObject"

NS_INLINE void PostMouseEvent(CGMouseButton button, CGEventType type, const CGP point)	{
	CGEventRef theEvent =			 	 CGEventCreateMouseEvent ( NULL, type, point, button );
	CGEventSetType( theEvent, type ); CGEventPost ( kCGHIDEventTap, theEvent);	CFRelease(theEvent);
}

@interface SampleObject : BaseModel
@property (nonatomic)	NSString	* name;
@property (nonatomic)	NSString	* description;
@property (nonatomic)	NSColor	* color;
+ (instancetype) instanceWithName:(NSS*)name andColor:(NSC*)c;
@end

@interface ColorCell : NSTextFieldCell
// Derive from NSTextFieldCell so we can setup our cell name and bindings in IB. Less code !
@property (WK) 					   id	  observedObject;
@property (STRNG) 			 NSColor	* color;
@property (STRNG)	 	 		NSString	* observedKeyPath;
@end

@interface ApplicationController : NSObject <NSTableViewDataSource, NSTableViewDelegate>
@property (NATOM,STRNG) 		NSMA * mutObjects;
@property (NATOM,STRNG)  		 NSS * palette;
@property (		  STRNG)			NSOQ * q;

@property (WK) IBOutlet        CAListView * caListView;
@property (WK) IBOutlet     AtoZColorWell * colorWell;
@property (WK) IBOutlet NSArrayController * arrayController;
@property (WK) IBOutlet 	   NSTableView * tableView;
@end

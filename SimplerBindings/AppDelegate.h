//
//  AppDelegate.h
//  SimplerBindings
//
//  Created by Alex Gray on 10/6/12.
//
//

#import <Cocoa/Cocoa.h>
#import <AtoZ/AtoZ.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, assign) IBOutlet NSArrayController *arrayC;

@property (strong) NSMA *contentArray;
@end

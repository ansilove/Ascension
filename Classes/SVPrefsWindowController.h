//
//  SVPrefsWindowController.h
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import <Cocoa/Cocoa.h>

@interface SVPrefsWindowController : NSWindowController <NSToolbarDelegate> {
	
	IBOutlet NSToolbar *prefsBar;
	IBOutlet NSView	   *generalPreferenceView;
	IBOutlet NSView    *colorsPreferenceView;
	IBOutlet NSView	   *advancedPreferenceView;
	
	NSInteger currentViewTag;
}

// class methods
+ (SVPrefsWindowController *)sharedPrefsWindowController;
+ (NSString *)nibName;

// general methods
- (NSView *)viewForTag:(NSInteger)tag;
- (NSRect)newFrameForNewContentView:(NSView *)view;

// actions
- (IBAction)switchView:(id)sender;

@end

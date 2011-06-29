//
//  SVPrefsController.h
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import <Cocoa/Cocoa.h>

@interface SVPrefsController : NSObject {
	
	IBOutlet NSColorWell *fontColorWell;
	IBOutlet NSColorWell *bgrndColorWell;
	IBOutlet NSColorWell *cursorColorWell;
	IBOutlet NSColorWell *linkColorWell;
	IBOutlet NSColorWell *selectionColorWell;
	IBOutlet NSTableView *themesView;
	NSMutableArray		 *themesArray;
	NSString		     *pathForThemeLibraryFile;
}

// outlets
@property (retain) IBOutlet NSColorWell *fontColorWell;
@property (retain) IBOutlet NSColorWell *bgrndColorWell;
@property (retain) IBOutlet NSColorWell *cursorColorWell;
@property (retain) IBOutlet NSColorWell *linkColorWell;
@property (retain) IBOutlet NSColorWell *selectionColorWell;
@property (retain) IBOutlet NSTableView *themesView;

// data
@property (retain) NSMutableArray *themesArray;

// integer and float values
@property (readonly) NSInteger themeIndex;

// strings
@property (readonly) NSString *pathForThemeLibraryFile;

// class methods
+ (void)checkUserDefaults;

// actions
- (IBAction)restoreUserDefaults:(id)sender;
- (IBAction)synchronizeDefaults:(id)sender;
- (IBAction)changeResumeState:(id)sender;
- (IBAction)changeFontColor:(id)sender;
- (IBAction)changeBgrndColor:(id)sender;
- (IBAction)changeCursorColor:(id)sender;
- (IBAction)changeLinkColor:(id)sender;
- (IBAction)changeSelectionColor:(id)sender;

// color notifications
- (void)sendFontColorChangeNote;
- (void)sendBgrndColorChangeNote;
- (void)sendCursorColorChangeNote;
- (void)sendLinkColorChangeNote;
- (void)sendSelectionColorChangeNote;

@end

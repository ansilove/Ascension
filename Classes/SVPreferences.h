//
//  SVPreferences.h
//  Ascension
//
//  Copyright (C) 2010-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	fBlockZone,
    fTerminusRegular,
    fTerminusLarge
} ASCIIFonts;

@class SVToggleSlider;

@interface SVPreferences : NSObject

// outlets
@property (nonatomic, strong) IBOutlet NSColorWell    *fontColorWell;
@property (nonatomic, strong) IBOutlet NSColorWell    *bgrndColorWell;
@property (nonatomic, strong) IBOutlet NSColorWell    *cursorColorWell;
@property (nonatomic, strong) IBOutlet NSColorWell    *linkColorWell;
@property (nonatomic, strong) IBOutlet NSColorWell    *selectionColorWell;
@property (nonatomic, strong) IBOutlet NSTableView    *themesView;
@property (nonatomic, strong) IBOutlet SVToggleSlider *viewerModeSlider;
@property (nonatomic, strong) IBOutlet NSTextField    *fontInfoTextField;
@property (nonatomic, strong) IBOutlet NSButton       *fontSystemButton;

// data
@property (nonatomic, strong) NSMutableArray *themesArray;

// integer and float values
@property (nonatomic, assign) NSInteger themeIndex;

// strings
@property (nonatomic, strong) NSString *pathForThemeLibraryFile;
@property (nonatomic, strong) NSString *fontInfoLabel;
@property (nonatomic, strong) NSString *fontFile;
@property (nonatomic, strong) NSString *destinationPath;
@property (nonatomic, strong) NSString *blockZoneVersionString;
@property (nonatomic, strong) NSString *blockZoneButtonTitle;

// class methods
+ (void)checkUserDefaults;

// actions
- (IBAction)restoreUserDefaults:(id)sender;
- (IBAction)synchronizeDefaults:(id)sender;
- (IBAction)changeResumeState:(id)sender;
- (IBAction)chooseASCIIFont:(id)sender;
- (IBAction)changeAnsiLoveStateAndReRender:(id)sender;
- (IBAction)selectScrollerStyle:(id)sender;
- (IBAction)changeFontColor:(id)sender;
- (IBAction)changeBgrndColor:(id)sender;
- (IBAction)changeCursorColor:(id)sender;
- (IBAction)changeLinkColor:(id)sender;
- (IBAction)changeSelectionColor:(id)sender;
- (IBAction)changeHyperLinkAttributes:(id)sender;
- (IBAction)createCustomTheme:(id)sender;
- (IBAction)copyExistingTheme:(id)sender;
- (IBAction)installBlockZoneFont:(id)sender;

// features
- (void)changeToggleSliderState:(NSNotification *)note;

// system operations
- (void)evaluateFontPath;
- (void)copyFontFromBundle;
- (void)replaceWithFontFromBundle;
- (void)removeBlockZoneFromSystem;
- (void)fontInstallReport;
- (void)fontUpdateReport;
- (void)fontRemoveReport;

// specific theme methods
- (void)generateStandardThemes;
- (void)applyColorValueToTheme;

// color notifications
- (void)sendFontColorChangeNote;
- (void)sendBgrndColorChangeNote;
- (void)sendCursorColorChangeNote;
- (void)sendLinkColorChangeNote;
- (void)sendSelectionColorChangeNote;

// data
- (void)tableViewSelectionDidChange:(NSNotification *)notification;
- (void)clearThemesArray;
- (void)loadThemeLibraryFromDisk;
- (void)saveThemeLibraryToDisk:(NSNotification *)notification;

@end

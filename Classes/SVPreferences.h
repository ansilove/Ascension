//
//  SVPreferences.h
//  Ascension
//
//  Copyright (c) 2010-2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>

@interface SVPreferences : NSObject

// outlets
@property (nonatomic, strong) IBOutlet NSColorWell *fontColorWell;
@property (nonatomic, strong) IBOutlet NSColorWell *bgrndColorWell;
@property (nonatomic, strong) IBOutlet NSColorWell *cursorColorWell;
@property (nonatomic, strong) IBOutlet NSColorWell *linkColorWell;
@property (nonatomic, strong) IBOutlet NSColorWell *selectionColorWell;
@property (nonatomic, strong) IBOutlet NSTableView *themesView;

// data
@property (nonatomic, strong) NSMutableArray *themesArray;

// integer and float values
@property (nonatomic, assign) NSInteger themeIndex;

// strings
@property (nonatomic, strong) NSString *pathForThemeLibraryFile;

// class methods
+ (void)checkUserDefaults;

// actions
- (IBAction)restoreUserDefaults:(id)sender;
- (IBAction)synchronizeDefaults:(id)sender;
- (IBAction)changeResumeState:(id)sender;
- (IBAction)selectScrollerStyle:(id)sender;
- (IBAction)changeFontColor:(id)sender;
- (IBAction)changeBgrndColor:(id)sender;
- (IBAction)changeCursorColor:(id)sender;
- (IBAction)changeLinkColor:(id)sender;
- (IBAction)changeSelectionColor:(id)sender;
- (IBAction)createCustomTheme:(id)sender;
- (IBAction)copyExistingTheme:(id)sender;

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

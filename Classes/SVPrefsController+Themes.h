//
//  SVPrefsController+Themes.h
//  Ascension
//
//  Copyright (c) 2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>
#import "SVPrefsController.h"

@interface SVPrefsController (Themes)
	
// general theme methods
- (void)generateStandardThemes;
- (void)applyColorValueToTheme;

// actions
- (IBAction)createCustomTheme:(id)sender;
- (IBAction)copyExistingTheme:(id)sender;

// data
- (void)tableViewSelectionDidChange:(NSNotification *)notification;
- (void)clearThemesArray;
- (void)loadThemeLibraryFromDisk;
- (void)saveThemeLibraryToDisk:(NSNotification *)notification;

@end

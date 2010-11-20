//
//  SVPrefsController+Themes.h
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
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

//
//  SVPreferences.m
//  Ascension
//
//  Copyright (C) 2010-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import "SVPreferences.h"
#import "SVThemeObject.h"
#import "SVToggleSlider.h"

#define selfBundleID @"com.byteproject.Ascension"

@implementation SVPreferences

# pragma mark -
# pragma mark initialization

- (id)init
{
    if (self == [super init]) 
	{
		// Initialize the theme array.
		self.themesArray = [[NSMutableArray alloc] init];
		
		// Load theme library, provided it is already created.
		[self loadThemeLibraryFromDisk];
		
		// If the app is closing, save theme library.
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self 
			   selector:@selector(saveThemeLibraryToDisk:) 
				   name:@"AppClosing" 
				 object:nil];
        
        // Observe any toggle slider state changes.
        [nc addObserver:self
               selector:@selector(changeToggleSliderState:)
                   name:@"ToggleSliderStateChange"
                 object:nil];
	}
	return self;
}

# pragma mark -
# pragma mark key value coding

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key 
{
	NSMutableSet *keyPaths = [[super keyPathsForValuesAffectingValueForKey:key] mutableCopy];
	if ([key isEqualToString:@"themeIndex"]) {
		[keyPaths addObject:@"themesView"];
	} 
	return keyPaths;
}

# pragma mark -
# pragma mark interface related

- (NSInteger)themeIndex
{
	return self.themesView.selectedRow;
}

- (void)awakeFromNib
{
	// Apply the last known row index for themesView.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger rowForThemeIndex = [defaults integerForKey:@"themeIndex"];
	NSIndexSet *themesViewSelection = [NSIndexSet indexSetWithIndex:rowForThemeIndex];
	[self.themesView selectRowIndexes:themesViewSelection byExtendingSelection:NO];
    
    // Set viewer mode slider button state.
    if ([defaults boolForKey:@"viewerMode"] == YES) {
        [self.viewerModeSlider setState:NSOnState animate:NO];
    }
    else {
        [self.viewerModeSlider setState:NSOffState animate:NO];
    }
    
    // Change font information label to something that makes sense.
    if ([defaults integerForKey:@"asciiFontIndex"] == fBlockZone) {
        [self.fontInfoTextField setStringValue:@"font size: 16.0pt"];
    }
    if ([defaults integerForKey:@"asciiFontIndex"] == fTerminusRegular) {
        [self.fontInfoTextField setStringValue:@"font size: 16.0pt"];
    }
    if ([defaults integerForKey:@"asciiFontIndex"] == fTerminusLarge) {
        [self.fontInfoTextField setStringValue:@"font size: 20.0pt"];
    }
    if ([defaults integerForKey:@"asciiFontIndex"] == fEightyColPet) {
        [self.fontInfoTextField setStringValue:@"font size: 16.0pt"];
    }
}

# pragma mark -
# pragma mark general

+ (void)checkUserDefaults
{
	// Check for stored or corrupted user defaults data.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (![defaults valueForKey:@"startupBehavior"]) {
		[defaults setInteger:0 forKey:@"startupBehavior"];
	}
    if (![defaults valueForKey:@"scrollerStyle"]) {
		[defaults setInteger:0 forKey:@"scrollerStyle"];
	}
    if (![defaults valueForKey:@"enableAnsiLoveForASCII"]) {
        [defaults setBool:NO forKey:@"enableAnsiLoveForASCII"];
    }
	if (![defaults stringForKey:@"fontName"]) {
		[defaults setObject:@"BlockZone" forKey:@"fontName"];
	}
	if (![defaults valueForKey:@"fontSize"]) {
		[defaults setFloat:16.0 forKey:@"fontSize"];
	}
    if (![defaults valueForKey:@"asciiFontIndex"]) {
		[defaults setInteger:0 forKey:@"asciiFontIndex"];
	}
	if (![defaults valueForKey:@"nfoDizEncoding"]) {
		[defaults setInteger:0 forKey:@"nfoDizEncoding"];
	}
	if (![defaults valueForKey:@"txtEncoding"]) {
		[defaults setInteger:0 forKey:@"txtEncoding"];
	}
    if (![defaults valueForKey:@"openUntitledFileOnStart"]) {
        [defaults setBool:YES forKey:@"openUntitledFileOnStart"];
    }
	if (![defaults valueForKey:@"docsOpenCentered"]) {
		[defaults setBool:YES forKey:@"docsOpenCentered"];
	}
    if (![defaults valueForKey:@"terminateAfterLastWindowIsClosed"]) {
        [defaults setBool:NO forKey:@"terminateAfterLastWindowIsClosed"];
    }
    if (![defaults valueForKey:@"highlightAsciiHyperLinks"]) {
		[defaults setBool:YES forKey:@"highlightAsciiHyperLinks"];
	}
    if (![defaults valueForKey:@"ansiLoveFont"]) {
		[defaults setInteger:1 forKey:@"ansiLoveFont"];
    }
    if (![defaults stringForKey:@"ansiLoveBits"]) {
		[defaults setObject:@"8" forKey:@"ansiLoveBits"];
	}
    if (![defaults stringForKey:@"ansiLoveColumns"]) {
		[defaults setObject:@"160" forKey:@"ansiLoveColumns"];
	}
    if (![defaults valueForKey:@"ansiLoveIceColors"]) {
		[defaults setBool:NO forKey:@"ansiLoveIceColors"];
	}
	if (![defaults valueForKey:@"newContentWidth"]) {
		[defaults setFloat:650 forKey:@"newContentWidth"];
	}
	if (![defaults valueForKey:@"newContentHeight"]) {
		[defaults setFloat:650 forKey:@"newContentHeight"];
	}
	if (![defaults valueForKey:@"autoSizeWidth"]) {
		[defaults setBool:YES forKey:@"autoSizeWidth"];
	}
	if (![defaults valueForKey:@"autoSizeHeight"]) {
		[defaults setBool:YES forKey:@"autoSizeHeight"];
	}
	if (![defaults valueForKey:@"themeIndex"]) {
		[defaults setInteger:0 forKey:@"themeIndex"];
	}
    if (![defaults valueForKey:@"viewerMode"]) {
		[defaults setBool:NO forKey:@"viewerMode"];
	}
    if (![defaults valueForKey:@"blockZoneInstalled"]) {
        [defaults setBool:NO forKey:@"blockZoneInstalled"];
    }
	if (![defaults dataForKey:@"fontColor"]) {
		NSData *fontColorData = [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]];
		[defaults setObject:fontColorData forKey:@"fontColor"];
	}
	if (![defaults dataForKey:@"backgroundColor"]) {
		NSData *backgroundColorData = [NSArchiver archivedDataWithRootObject:[NSColor blackColor]];
		[defaults setObject:backgroundColorData forKey:@"backgroundColor"];
	}
	if (![defaults dataForKey:@"cursorColor"]) {
		NSData *cursorColorData = [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]];
		[defaults setObject:cursorColorData forKey:@"cursorColor"];
	}
	if (![defaults dataForKey:@"linkColor"]) {
		NSData *linkColorData = [NSArchiver archivedDataWithRootObject:[NSColor greenColor]];
		[defaults setObject:linkColorData forKey:@"linkColor"];
	}
	if (![defaults dataForKey:@"selectionColor"]) {
		NSColor *customGrayScale = [NSColor colorWithDeviceWhite:0.2 alpha:1.0];
		NSData *selectionColorData = [NSArchiver archivedDataWithRootObject:customGrayScale];
		[defaults setObject:selectionColorData forKey:@"selectionColor"];
	}
	[defaults synchronize];
}

- (IBAction)restoreUserDefaults:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// Restore the initial user defaults.
	[defaults setInteger:0 forKey:@"startupBehavior"];
    [defaults setInteger:0 forKey:@"scrollerStyle"];
    [defaults setBool:NO forKey:@"enableAnsiLoveForASCII"];
	[defaults setObject:@"BlockZone" forKey:@"fontName"];
	[defaults setFloat:16.0 forKey:@"fontSize"];
    [defaults setInteger:0 forKey:@"asciiFontIndex"];
	[defaults setInteger:0 forKey:@"nfoDizEncoding"];
	[defaults setInteger:0 forKey:@"txtEncoding"];
    [defaults setBool:YES forKey:@"openUntitledFileOnStart"];
	[defaults setBool:YES forKey:@"docsOpenCentered"];
    [defaults setBool:NO forKey:@"terminateAfterLastWindowIsClosed"];
    [defaults setBool:YES forKey:@"highlightAsciiHyperLinks"];
    [defaults setInteger:1 forKey:@"ansiLoveFont"];
    [defaults setObject:@"8" forKey:@"ansiLoveBits"];
    [defaults setObject:@"160" forKey:@"ansiLoveColumns"];
    [defaults setBool:NO forKey:@"ansiLoveIceColors"];
	[defaults setFloat:650 forKey:@"newContentWidth"];
	[defaults setFloat:650 forKey:@"newContentHeight"];
	[defaults setBool:YES forKey:@"autoSizeWidth"];
	[defaults setBool:YES forKey:@"autoSizeHeight"];
	[defaults setInteger:0 forKey:@"themeIndex"];
    [defaults setBool:NO forKey:@"viewerMode"];
    
    // Check if BlockZone is installed locally. If yes, no revert.
    [self evaluateFontPath];
    NSFileManager *fileManager = [NSFileManager new];
    if ([fileManager fileExistsAtPath:self.destinationPath] == YES)
    {
        [defaults setBool:YES forKey:@"blockZoneInstalled"];
    }
    else {
        [defaults setBool:NO forKey:@"blockZoneInstalled"];
    }
	
	// Store initial colors as data to user defaults.
	NSData *fontColorData = [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]];
	[defaults setObject:fontColorData forKey:@"fontColor"];
	NSData *backgroundColorData = [NSArchiver archivedDataWithRootObject:[NSColor blackColor]];
	[defaults setObject:backgroundColorData forKey:@"backgroundColor"];
	NSData *cursorColorData = [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]];
	[defaults setObject:cursorColorData forKey:@"cursorColor"];
	NSData *linkColorData = [NSArchiver archivedDataWithRootObject:[NSColor greenColor]];
	[defaults setObject:linkColorData forKey:@"linkColor"];
	NSColor *customGrayScale = [NSColor colorWithDeviceWhite:0.2 alpha:1.0];
	NSData *selectionColorData = [NSArchiver archivedDataWithRootObject:customGrayScale];
	[defaults setObject:selectionColorData forKey:@"selectionColor"];
	
	// Reset the themes array.
	[self clearThemesArray];
	[self generateStandardThemes];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"AppClosing" object:self];
    
    // Reset slider button state
    [self.viewerModeSlider setState:NSOffState animate:YES];
    [nc postNotificationName:@"ToggleSliderStateChange" object:self];
	
	[self sendFontColorChangeNote];
	[self sendBgrndColorChangeNote];
	[self sendCursorColorChangeNote];
	[self sendLinkColorChangeNote];
	[self sendSelectionColorChangeNote];
    
    // Change notification for forcing AnsiLove to re-render.
    [nc postNotificationName:@"AnsiLoveRenderChange" object:self];
    
    // Post note to change hyperlink attributes.
    [nc postNotificationName:@"HyperLinkAttributeChange" object:self];
    
    // Reset font info label to font size value that's restored now.
    [self.fontInfoTextField setStringValue:@"font size: 16.0pt"];
    
    [defaults synchronize];
}

- (IBAction)synchronizeDefaults:(id)sender
{
	// Force Shared User Defaults Controller to synchronize immediately.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
}

- (IBAction)changeResumeState:(id)sender
{
    [self synchronizeDefaults:self];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"ResumeStateChange" object:self];
}

- (void)changeToggleSliderState:(NSNotification *)note
{
    // define user defaults and notification center
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    // Check whether the viewer mode is turned ON or OFF now.
    if (self.viewerModeSlider.state == NSOffState) {
        [defaults setBool:NO forKey:@"viewerMode"];
        [nc postNotificationName:@"UnlockEditor" object:self];
    }    
    else if (self.viewerModeSlider.state == NSOnState) {
        [defaults setBool:YES forKey:@"viewerMode"];
        [nc postNotificationName:@"LockEditor" object:self];
    }
}

# pragma mark -
# pragma mark AnsiLove related

- (IBAction)changeAnsiLoveStateAndReRender:(id)sender
{
    // Synchronize and send a note so our document instance knows AnsiLove flags changed.
    [self synchronizeDefaults:self];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"AnsiLoveRenderChange" object:self];
}

# pragma mark -
# pragma mark system operations

- (IBAction)installBlockZoneFont:(id)sender
{
    NSFileManager *fileManager = [NSFileManager new];
    
    // Lead me through each gentle step, by step, by inch, by loaded memory.
    [self evaluateFontPath];
    
    // In case BlockZone is installed already, this is an update.
    if ([fileManager fileExistsAtPath:self.destinationPath] == YES)
    {
        // Show version string of bundled BlockZone, let user confirm updating.
        NSAlert *fontUpdateConfirmation = [[NSAlert alloc] init];
        [fontUpdateConfirmation addButtonWithTitle:@"Update"];
        [fontUpdateConfirmation addButtonWithTitle:@"Remove"];
        [fontUpdateConfirmation addButtonWithTitle:@"Cancel"];
        [fontUpdateConfirmation setMessageText:@"Update / remove BlockZone font"];
        [fontUpdateConfirmation setInformativeText:[NSString stringWithFormat:
         @"BlockZone seems installed already. Do you want to update the font on your system "
         @"with the bundled version %@? Ascension always uses the bundled variant, so updating "
         @"is only necessary in case you want the newest font version available for other "
         @"applications. Optionally, you can choose to uninstall the font.",
         self.blockZoneVersionString]];
        [fontUpdateConfirmation setAlertStyle:NSWarningAlertStyle];
        
        NSInteger modalReturn = [fontUpdateConfirmation runModal];
        
        // Provided the user hit 'Update', perform BlockZone update.
        if (modalReturn == NSAlertFirstButtonReturn) {
            [self replaceWithFontFromBundle];
            [self fontUpdateReport];
        }
        // For convinience, we offer an option to remove the installed font file.
        else if (modalReturn == NSAlertSecondButtonReturn) {
            [self removeBlockZoneFromSystem];
            [self fontRemoveReport];
        }
        else {
            return;
        }
    }
    // So this is a fresh install.
    else {
        // Prompt the user to confirm BlockZone installation.
        NSAlert *fontInstallConfirmation = [[NSAlert alloc] init];
        [fontInstallConfirmation addButtonWithTitle:@"Install"];
        [fontInstallConfirmation addButtonWithTitle:@"Cancel"];
        [fontInstallConfirmation setMessageText:@"Install BlockZone font"];
        [fontInstallConfirmation setInformativeText:
         @"BlockZone is a faithful, pixel-perfect recreation of the original DOS font, bundled "
         @"with Ascension. This step is not necessary unless you want the font available for "
         @"other applications on your system. Ascension will always use the bundled variant."];
        [fontInstallConfirmation setAlertStyle:NSWarningAlertStyle];
        
        // Provided the user hit 'install', perform Terminus installation.
        if ([fontInstallConfirmation runModal] == NSAlertFirstButtonReturn) {
            [self copyFontFromBundle];
            [self fontInstallReport];
        }
        else {
            return;
        }
    }
}

- (void)evaluateFontPath
{
    // Evaluate the path to BlockZone
    NSString *usrFontsPath = @"~/Library/Fonts/";
    usrFontsPath = [usrFontsPath stringByExpandingTildeInPath];
    self.fontFile = @"BlockZone.ttf";
    self.destinationPath = [usrFontsPath stringByAppendingPathComponent:self.fontFile];
}

- (void)copyFontFromBundle
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    // Copies BlockZone from the Bundle resources to ~/Library/Fonts.
    NSString *srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
                         [NSString stringWithFormat:@"/Fonts/%@", self.fontFile]];
    NSError *fontError;
    [fileManager copyItemAtPath:srcPath toPath:self.destinationPath error:&fontError];
}

- (void)replaceWithFontFromBundle
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    // Replaces BlockZone in ~/Library/Fonts with the bundled version.
    NSString *srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
                         [NSString stringWithFormat:@"/Fonts/%@", self.fontFile]];
    NSError *fontError;
    [fileManager removeItemAtPath:self.destinationPath error:&fontError];
    [fileManager copyItemAtPath:srcPath toPath:self.destinationPath error:&fontError];
}

- (void)removeBlockZoneFromSystem 
{
    // Removes BlockZone.ttf from user fonts.
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *fontError;
    [fileManager removeItemAtPath:self.destinationPath error:&fontError];
}

- (void)fontUpdateReport
{
    // Report for the font update process.
    NSAlert *fontUpdateSuccess = [[NSAlert alloc] init];
    [fontUpdateSuccess addButtonWithTitle:@"Ok"];
    [fontUpdateSuccess setMessageText:@"Update completed"];
    [fontUpdateSuccess setInformativeText:
     @"BlockZone.ttf has been successfully updated."];
    [fontUpdateSuccess runModal];
}

- (void)fontInstallReport
{
    // Report for the font installation process.
    NSAlert *fontInstallSuccess = [[NSAlert alloc] init];
    [fontInstallSuccess addButtonWithTitle:@"Ok"];
    [fontInstallSuccess setMessageText:@"Installation completed"];
    [fontInstallSuccess setInformativeText:[NSString stringWithFormat:
     @"BlockZone %@ has been successfully installed on your "
     @"system. In case you want to remove it at a later date, "
     @"just use Ascension's built-in option." , self.blockZoneVersionString]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"blockZoneInstalled"];
    [defaults synchronize];
    
    [fontInstallSuccess runModal];
    
    self.fontSystemButton.title = @"Update / Remove BlockZone.ttf";
}

- (void)fontRemoveReport
{
    // Report for the font uninstallation process.
    NSAlert *fontUninstallSuccess = [[NSAlert alloc] init];
    [fontUninstallSuccess addButtonWithTitle:@"Ok"];
    [fontUninstallSuccess setMessageText:@"Uninstall completed"];
    [fontUninstallSuccess setInformativeText:
     @"BlockZone has been successfully removed from your system."];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"blockZoneInstalled"];
    [defaults synchronize];
    
    [fontUninstallSuccess runModal];
    
    self.fontSystemButton.title = @"Install BlockZone.ttf";
}

- (NSString *)blockZoneVersionString
{
    return [[[NSBundle bundleWithIdentifier:selfBundleID] infoDictionary] valueForKey:@"BlockZone version"];
}

- (NSString *)blockZoneButtonTitle
{
    // Changes the button title to install, or update / remove depending
    // on installation status of BlockZone.ttf
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:@"blockZoneInstalled"] == YES) {
        return @"Update / Remove BlockZone.ttf";
    }
    else {
        return @"Install BlockZone.ttf";
    }
}

# pragma mark -
# pragma mark user-defined attributes

- (IBAction)chooseASCIIFont:(id)sender
{
    // Check font index, then write font properties to user defaults.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	switch ([defaults integerForKey:@"asciiFontIndex"])
	{
		case fBlockZone: {
			[defaults setObject:@"BlockZone" forKey:@"fontName"];
            [defaults setFloat:16.0 forKey:@"fontSize"];
            [self.fontInfoTextField setStringValue:@"font size: 16.0pt"];
			break;
		}
        case fTerminusRegular: {
			[defaults setObject:@"Terminus" forKey:@"fontName"];
            [defaults setFloat:16.0 forKey:@"fontSize"];
            [self.fontInfoTextField setStringValue:@"font size: 16.0pt"];
			break;
		}
        case fTerminusLarge: {
			[defaults setObject:@"Terminus" forKey:@"fontName"];
            [defaults setFloat:20.0 forKey:@"fontSize"];
            [self.fontInfoTextField setStringValue:@"font size: 20.0pt"];
			break;
		}
        case fEightyColPet: {
            [defaults setObject:@"Pet Me 64 2Y" forKey:@"fontName"];
            [defaults setFloat:16.0 forKey:@"fontSize"];
            [self.fontInfoTextField setStringValue:@"font size: 16.0pt"];
        }
		default: {
			break;
		}
	}
    [self synchronizeDefaults:self];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"ASCIIFontChange" object:self];
}

- (IBAction)selectScrollerStyle:(id)sender
{
    [self synchronizeDefaults:self];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"ScrollerStyleChange" object:self];
}

- (IBAction)changeFontColor:(id)sender
{
	// Save the new font color value to user defaults.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *fontColorData = [NSArchiver archivedDataWithRootObject:self.fontColorWell.color];
	[defaults setObject:fontColorData forKey:@"fontColor"];
	
	if (sender == self.fontColorWell) {
		[self applyColorValueToTheme];
	}
	
	[defaults synchronize];
	[self sendFontColorChangeNote];
}

- (IBAction)changeBgrndColor:(id)sender
{
	// Save our new backround color value to user defaults.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *bgrndColorData = [NSArchiver archivedDataWithRootObject:self.bgrndColorWell.color];
	[defaults setObject:bgrndColorData forKey:@"backgroundColor"];
	
	if (sender == self.bgrndColorWell) {
		[self applyColorValueToTheme];
	}	
	[defaults synchronize];
	[self sendBgrndColorChangeNote];
}

- (IBAction)changeCursorColor:(id)sender
{
	// Store the new cursor color value to user defaults.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *cursorColorData = [NSArchiver archivedDataWithRootObject:self.cursorColorWell.color];
	[defaults setObject:cursorColorData forKey:@"cursorColor"];
	
	if (sender == self.cursorColorWell) {
		[self applyColorValueToTheme];
	}	
	[defaults synchronize];
	[self sendCursorColorChangeNote];
}

- (IBAction)changeLinkColor:(id)sender
{
	// Save the new color for hyperlinks to user defaults.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *linkColorData = [NSArchiver archivedDataWithRootObject:self.linkColorWell.color];
	[defaults setObject:linkColorData forKey:@"linkColor"];
	
	if (sender == self.linkColorWell) {
		[self applyColorValueToTheme];
	}
	
	[defaults synchronize];
	[self sendLinkColorChangeNote];
}

- (IBAction)changeSelectionColor:(id)sender
{
	// Save the new color for selected text to user defaults.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *selectionColorData = [NSArchiver archivedDataWithRootObject:self.selectionColorWell.color];
	[defaults setObject:selectionColorData forKey:@"selectionColor"];
	
	if (sender == self.selectionColorWell) {
		[self applyColorValueToTheme];
	}
	
	[defaults synchronize];
	[self sendSelectionColorChangeNote];
}

- (IBAction)changeHyperLinkAttributes:(id)sender
{
    // First, synchronize defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
    
    // Post note to toggle hyperlink attributes in already opened documents.
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"HyperLinkAttributeChange" object:self];
}

# pragma mark -
# pragma mark change notifications

- (void)sendFontColorChangeNote
{
	// Send font color change notification to all instances of MyDocument.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
	NSDictionary *dict = [NSDictionary dictionaryWithObject:self.fontColorWell.color forKey:@"fontColorValue"];
	[nc postNotificationName:@"FontColorChange"
					  object:self 
					userInfo:dict];
}

- (void)sendBgrndColorChangeNote
{
	// Send background color change notification to all instances of MyDocument.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
	NSDictionary *dict = [NSDictionary dictionaryWithObject:self.bgrndColorWell.color forKey:@"bgrndColorValue"];
	[nc postNotificationName:@"BgrndColorChange"
					  object:self 
					userInfo:dict];
}

- (void)sendCursorColorChangeNote
{
	// Send cursor color change notification to all instances of MyDocument.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
	NSDictionary *dict = [NSDictionary dictionaryWithObject:self.cursorColorWell.color forKey:@"cursorColorValue"];
	[nc postNotificationName:@"CursorColorChange"
					  object:self
					userInfo:dict];
}

- (void)sendLinkColorChangeNote
{
	// Send link color change notification to all instances of MyDocument.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
	NSDictionary *dict = [NSDictionary dictionaryWithObject:self.linkColorWell.color forKey:@"linkColorValue"];
	[nc postNotificationName:@"LinkColorChange"
					  object:self
					userInfo:dict];
}

- (void)sendSelectionColorChangeNote
{
	// Send selection color change notification to all instances of MyDocument.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
	NSDictionary *dict = [NSDictionary dictionaryWithObject:self.selectionColorWell.color forKey:@"selectionColorValue"];
	[nc postNotificationName:@"SelectionColorChange"
					  object:self
					userInfo:dict];
}

# pragma mark -
# pragma mark specific theme methods

- (void)generateStandardThemes
{
	// Ascension
	SVThemeObject *themeAscension = [[SVThemeObject alloc] init];
	themeAscension.atName = @"Ascension";
	themeAscension.atFontColor = [NSColor whiteColor];
	themeAscension.atBackgroundColor = [NSColor blackColor];
	themeAscension.atLinkColor = [NSColor greenColor];
	themeAscension.atCursorColor = [NSColor whiteColor];
	themeAscension.atSelectionColor = [NSColor colorWithDeviceWhite:0.2 alpha:1.0];
	[[self mutableArrayValueForKey:@"themesArray"] addObject:themeAscension];
	
	// Inversion
	SVThemeObject *themeInversion = [[SVThemeObject alloc] init];
	themeInversion.atName = @"Inversion";
	themeInversion.atFontColor = [NSColor blackColor];
	themeInversion.atBackgroundColor = [NSColor whiteColor];
	themeInversion.atLinkColor = [NSColor blueColor];
	themeInversion.atCursorColor = [NSColor blackColor];
	themeInversion.atSelectionColor = [NSColor lightGrayColor];
	[[self mutableArrayValueForKey:@"themesArray"] addObject:themeInversion];
	
	// DOSBox
	SVThemeObject *themeDOSBox = [[SVThemeObject alloc] init];
	themeDOSBox.atName = @"DOSBox";
	themeDOSBox.atFontColor = 
	[NSColor colorWithCalibratedRed:170/255.l green:170/255.l blue:170/255.l alpha:1.0];
	themeDOSBox.atBackgroundColor = [NSColor blackColor];
	themeDOSBox.atLinkColor = 
	[NSColor colorWithCalibratedRed:170/255.l green:170/255.l blue:170/255.l alpha:1.0];
	themeDOSBox.atCursorColor = 
	[NSColor colorWithCalibratedRed:170/255.l green:170/255.l blue:170/255.l alpha:1.0];
	themeDOSBox.atSelectionColor = 
	[NSColor colorWithCalibratedRed:170/255.l green:170/255.l blue:170/255.l alpha:0.2];
	[[self mutableArrayValueForKey:@"themesArray"] addObject:themeDOSBox];
	
	// Africa
	SVThemeObject *themeAfrica = [[SVThemeObject alloc] init];
	themeAfrica.atName = @"Africa";
	themeAfrica.atFontColor = 
	[NSColor colorWithCalibratedRed:75/255.l green:47/255.l blue:46/255.l alpha:1.0];
	themeAfrica.atBackgroundColor = 
	[NSColor colorWithCalibratedRed:223/255.l green:219/255.l blue:195/255.l alpha:1.0];
	themeAfrica.atLinkColor = 
	[NSColor colorWithCalibratedRed:149/255.l green:150/255.l blue:7/255.l alpha:1.0];
	themeAfrica.atCursorColor = 
	[NSColor colorWithCalibratedRed:75/255.l green:47/255.l blue:46/255.l alpha:1.0];
	themeAfrica.atSelectionColor = 
	[NSColor colorWithCalibratedRed:243/255.l green:241/255.l blue:220/255.l alpha:1.0];
	[[self mutableArrayValueForKey:@"themesArray"] addObject:themeAfrica];
	
	// Blood Legacy
	SVThemeObject *themeBloodLegacy = [[SVThemeObject alloc] init];
	themeBloodLegacy.atName = @"Blood Legacy";
	themeBloodLegacy.atFontColor = 
	[NSColor colorWithCalibratedRed:199/255.l green:22/255.l blue:41/255.l alpha:1.0];
	themeBloodLegacy.atBackgroundColor = [NSColor blackColor];
	themeBloodLegacy.atLinkColor = 
	[NSColor colorWithCalibratedRed:248/255.l green:65/255.l blue:48/255.l alpha:1.0];
	themeBloodLegacy.atCursorColor = 
	[NSColor colorWithCalibratedRed:199/255.l green:22/255.l blue:41/255.l alpha:1.0];
	themeBloodLegacy.atSelectionColor = 
	[NSColor colorWithCalibratedRed:199/255.l green:22/255.l blue:41/255.l alpha:0.2];
	[[self mutableArrayValueForKey:@"themesArray"] addObject:themeBloodLegacy];
	
	// Commodore64
	SVThemeObject *themeCommodore64 = [[SVThemeObject alloc] init];
	themeCommodore64.atName = @"Commodore 64";
	themeCommodore64.atFontColor = 
	[NSColor colorWithCalibratedRed:124/255.l green:112/255.l blue:218/255.l alpha:1.0];
	themeCommodore64.atBackgroundColor = 
	[NSColor colorWithCalibratedRed:62/255.l green:49/255.l blue:162/255.l alpha:1.0];
	themeCommodore64.atLinkColor = 
	[NSColor colorWithCalibratedRed:124/255.l green:112/255.l blue:218/255.l alpha:1.0];
	themeCommodore64.atCursorColor = 
	[NSColor colorWithCalibratedRed:124/255.l green:112/255.l blue:218/255.l alpha:1.0];
	themeCommodore64.atSelectionColor = 
	[NSColor colorWithCalibratedRed:124/255.l green:112/255.l blue:218/255.l alpha:0.2];
	[[self mutableArrayValueForKey:@"themesArray"] addObject:themeCommodore64];
	
	// Toxicity
	SVThemeObject *themeToxicity = [[SVThemeObject alloc] init];
	themeToxicity.atName = @"Toxicity";
	themeToxicity.atFontColor = 
	[NSColor colorWithCalibratedRed:154/255.l green:254/255.l blue:92/255.l alpha:1.0];
	themeToxicity.atBackgroundColor = 
	[NSColor colorWithCalibratedRed:4/255.l green:68/255.l blue:12/255.l alpha:1.0];
	themeToxicity.atLinkColor = 
	[NSColor colorWithCalibratedRed:222/255.l green:223/255.l blue:8/255.l alpha:1.0];
	themeToxicity.atCursorColor = 
	[NSColor colorWithCalibratedRed:154/255.l green:254/255.l blue:92/255.l alpha:1.0];
	themeToxicity.atSelectionColor = 
	[NSColor colorWithCalibratedRed:154/255.l green:254/255.l blue:92/255.l alpha:0.2];
	[[self mutableArrayValueForKey:@"themesArray"] addObject:themeToxicity];
	
	// Purple Haze
	SVThemeObject *themePurpleHaze = [[SVThemeObject alloc] init];
	themePurpleHaze.atName = @"Purple Haze";
	themePurpleHaze.atFontColor = 
	[NSColor colorWithCalibratedRed:197/255.l green:81/255.l blue:255/255.l alpha:1.0];
	themePurpleHaze.atBackgroundColor = 
	[NSColor colorWithCalibratedRed:43/255.l green:1/255.l blue:70/255.l alpha:1.0];
	themePurpleHaze.atLinkColor = 
	[NSColor colorWithCalibratedRed:252/255.l green:36/255.l blue:230/255.l alpha:1.0];
	themePurpleHaze.atCursorColor = 
	[NSColor colorWithCalibratedRed:197/255.l green:81/255.l blue:255/255.l alpha:1.0];
	themePurpleHaze.atSelectionColor = 
	[NSColor colorWithCalibratedRed:197/255.l green:81/255.l blue:255/255.l alpha:0.2];
	[[self mutableArrayValueForKey:@"themesArray"] addObject:themePurpleHaze];
}

- (IBAction)createCustomTheme:(id)sender
{
	// Create a custom blank theme.
	SVThemeObject *themeCustom = [[SVThemeObject alloc] init];
	themeCustom.atName = @"Blank Theme";
	themeCustom.atFontColor = [NSColor whiteColor];
	themeCustom.atBackgroundColor = [NSColor blackColor];
	themeCustom.atLinkColor = [NSColor whiteColor];
	themeCustom.atCursorColor = [NSColor whiteColor];
	themeCustom.atSelectionColor = [NSColor colorWithDeviceWhite:0.2 alpha:1.0];
	[[self mutableArrayValueForKey:@"themesArray"] addObject:themeCustom];
}

- (IBAction)copyExistingTheme:(id)sender 
{
	// Identify the selected theme.
	NSInteger row = self.themesView.selectedRow;
	SVThemeObject *selectedTheme = [self.themesArray objectAtIndex:row];
	
	// Duplicate our selected theme in library.
	SVThemeObject *themeDuplicate = [[SVThemeObject alloc] init];
	NSString *themeNameCopy = [NSString stringWithFormat: @"Copy of %@", selectedTheme.atName];
	themeDuplicate.atName = themeNameCopy;
	themeDuplicate.atFontColor = selectedTheme.atFontColor;
	themeDuplicate.atBackgroundColor = selectedTheme.atBackgroundColor;
	themeDuplicate.atLinkColor = selectedTheme.atLinkColor;
	themeDuplicate.atCursorColor = selectedTheme.atCursorColor;
	themeDuplicate.atSelectionColor = selectedTheme.atSelectionColor;
	[[self mutableArrayValueForKey:@"themesArray"] addObject:themeDuplicate];
}

- (void)applyColorValueToTheme
{
	NSInteger row = self.themesView.selectedRow;
	SVThemeObject *selectedTheme = [self.themesArray objectAtIndex:row];
	selectedTheme.atFontColor = self.fontColorWell.color;
	selectedTheme.atBackgroundColor = self.bgrndColorWell.color;
	selectedTheme.atLinkColor = self.linkColorWell.color;
	selectedTheme.atCursorColor = self.cursorColorWell.color;
	selectedTheme.atSelectionColor = self.selectionColorWell.color;
}

# pragma mark -
# pragma mark data 

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	NSInteger row = self.themesView.selectedRow;
	if (row == -1) {
		return;
	} 
	// Apply the colors of our selected theme.
	SVThemeObject *selectedTheme = [self.themesArray objectAtIndex:row];
	self.fontColorWell.color = selectedTheme.atFontColor;
	[self changeFontColor:self];
    self.bgrndColorWell.color = selectedTheme.atBackgroundColor;
	[self changeBgrndColor:self];
    self.linkColorWell.color = selectedTheme.atLinkColor;
	[self changeLinkColor:self];
	self.cursorColorWell.color = selectedTheme.atCursorColor;
	[self changeCursorColor:self];
	self.selectionColorWell.color = selectedTheme.atSelectionColor;
	[self changeSelectionColor:self];
	
	// Write the index of our selected theme to user defaults. 
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:self.themeIndex forKey:@"themeIndex"];
	
	[defaults synchronize];
}

- (void)clearThemesArray
{
	for (id aThemeObject in self.themesArray) {
		[[self mutableArrayValueForKey:@"themesArray"] removeObject:aThemeObject];
	}
}

- (NSString *)pathForThemeLibraryFile
{
	NSFileManager *fileManager = [[NSFileManager alloc] init];
    
	NSString *folder = @"~/Library/Application Support/Ascension/";
	folder = [folder stringByExpandingTildeInPath];
	
	if ([fileManager fileExistsAtPath:folder] == NO)
	{
		[fileManager createDirectoryAtPath:folder 
			   withIntermediateDirectories:YES 
								attributes:nil 
									 error:nil];
	}
	NSString *fileName = @"Ascension.themelib";
	return [folder stringByAppendingPathComponent:fileName];    
}

- (void)saveThemeLibraryToDisk:(NSNotification *)notification;
{
	NSString *path = self.pathForThemeLibraryFile;
	
	NSMutableDictionary *rootObject;
	rootObject = [NSMutableDictionary dictionary];
	[rootObject setValue:self.themesArray forKey:@"themesArray"];
	
	[NSKeyedArchiver archiveRootObject:rootObject toFile:path];
}

- (void)loadThemeLibraryFromDisk
{
	NSString *path = self.pathForThemeLibraryFile;
	
	NSDictionary *rootObject;
    rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];    
	if ([rootObject valueForKey:@"themesArray"] != nil) 
	{
		self.themesArray = [rootObject valueForKey:@"themesArray"];	
	}
	else {
		[self generateStandardThemes];
	}
}

@end

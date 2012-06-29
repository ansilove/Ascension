//
//  SVPreferences.m
//  Ascension
//
//  Copyright (c) 2010-2012, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import "SVPreferences.h"
#import "SVThemeObject.h"
#import "SVToggleSlider.h"

@implementation SVPreferences

@synthesize fontColorWell, bgrndColorWell, cursorColorWell, linkColorWell, selectionColorWell, 
			themesArray, themesView, pathForThemeLibraryFile, themeIndex, viewerModeSlider;

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
	return [self.themesView selectedRow];
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
	if (![defaults stringForKey:@"fontName"]) {
		[defaults setObject:@"Terminus" forKey:@"fontName"];
	}
	if (![defaults valueForKey:@"fontSize"]) {
		[defaults setFloat:14.0 forKey:@"fontSize"];
	}
	if (![defaults valueForKey:@"nfoDizEncoding"]) {
		[defaults setInteger:0 forKey:@"nfoDizEncoding"];
	}
	if (![defaults valueForKey:@"txtEncoding"]) {
		[defaults setInteger:0 forKey:@"txtEncoding"];
	}
	if (![defaults valueForKey:@"docsOpenCentered"]) {
		[defaults setBool:YES forKey:@"docsOpenCentered"];
	}
    if (![defaults valueForKey:@"terminateAfterLastWindowIsClosed"]) {
        [defaults setBool:NO forKey:@"terminateAfterLastWindowIsClosed"];
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
		[defaults setBool:NO forKey:@"autoSizeHeight"];
	}
	if (![defaults valueForKey:@"themeIndex"]) {
		[defaults setInteger:0 forKey:@"themeIndex"];
	}
    if (![defaults valueForKey:@"viewerMode"]) {
		[defaults setBool:NO forKey:@"viewerMode"];
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
	[defaults setObject:@"Terminus" forKey:@"fontName"];
	[defaults setFloat:14.0 forKey:@"fontSize"];
	[defaults setInteger:0 forKey:@"nfoDizEncoding"];
	[defaults setInteger:0 forKey:@"txtEncoding"];
	[defaults setBool:YES forKey:@"docsOpenCentered"];
    [defaults setBool:NO forKey:@"terminateAfterLastWindowIsClosed"];
	[defaults setFloat:650 forKey:@"newContentWidth"];
	[defaults setFloat:650 forKey:@"newContentHeight"];
	[defaults setBool:YES forKey:@"autoSizeWidth"];
	[defaults setBool:NO forKey:@"autoSizeHeight"];
	[defaults setInteger:0 forKey:@"themeIndex"];
    [defaults setBool:NO forKey:@"viewerMode"];
	
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
	
	[defaults synchronize];
	[self sendFontColorChangeNote];
	[self sendBgrndColorChangeNote];
	[self sendCursorColorChangeNote];
	[self sendLinkColorChangeNote];
	[self sendSelectionColorChangeNote];
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
# pragma mark user-defined colors

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
	NSData *fontColorData = [NSArchiver archivedDataWithRootObject:[fontColorWell color]];
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
	NSData *bgrndColorData = [NSArchiver archivedDataWithRootObject:[bgrndColorWell color]];
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
	NSData *cursorColorData = [NSArchiver archivedDataWithRootObject:[cursorColorWell color]];
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
	NSData *linkColorData = [NSArchiver archivedDataWithRootObject:[linkColorWell color]];
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
	NSData *selectionColorData = [NSArchiver archivedDataWithRootObject:[selectionColorWell color]];
	[defaults setObject:selectionColorData forKey:@"selectionColor"];
	
	if (sender == self.selectionColorWell) {
		[self applyColorValueToTheme];
	}
	
	[defaults synchronize];
	[self sendSelectionColorChangeNote];
}

# pragma mark -
# pragma mark color notifications

- (void)sendFontColorChangeNote
{
	// Send font color change notification to all instances of MyDocument.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
	NSDictionary *dict = [NSDictionary dictionaryWithObject:[fontColorWell color] forKey:@"fontColorValue"]; 
	[nc postNotificationName:@"FontColorChange"
					  object:self 
					userInfo:dict];
}

- (void)sendBgrndColorChangeNote
{
	// Send background color change notification to all instances of MyDocument.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
	NSDictionary *dict = [NSDictionary dictionaryWithObject:[bgrndColorWell color] forKey:@"bgrndColorValue"]; 
	[nc postNotificationName:@"BgrndColorChange"
					  object:self 
					userInfo:dict];
}

- (void)sendCursorColorChangeNote
{
	// Send cursor color change notification to all instances of MyDocument.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
	NSDictionary *dict = [NSDictionary dictionaryWithObject:[cursorColorWell color] forKey:@"cursorColorValue"];
	[nc postNotificationName:@"CursorColorChange"
					  object:self
					userInfo:dict];
}

- (void)sendLinkColorChangeNote
{
	// Send link color change notification to all instances of MyDocument.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
	NSDictionary *dict = [NSDictionary dictionaryWithObject:[linkColorWell color] forKey:@"linkColorValue"];
	[nc postNotificationName:@"LinkColorChange"
					  object:self
					userInfo:dict];
}

- (void)sendSelectionColorChangeNote
{
	// Send selection color change notification to all instances of MyDocument.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
	NSDictionary *dict = [NSDictionary dictionaryWithObject:[selectionColorWell color] forKey:@"selectionColorValue"];
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
	
	// Negative
	SVThemeObject *themeNegative = [[SVThemeObject alloc] init];
	themeNegative.atName = @"Negative";
	themeNegative.atFontColor = [NSColor blackColor];
	themeNegative.atBackgroundColor = [NSColor whiteColor];
	themeNegative.atLinkColor = [NSColor blueColor];
	themeNegative.atCursorColor = [NSColor blackColor];
	themeNegative.atSelectionColor = [NSColor lightGrayColor];
	[[self mutableArrayValueForKey:@"themesArray"] addObject:themeNegative];
	
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
	NSInteger row = [self.themesView selectedRow];
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
	NSInteger row = [self.themesView selectedRow];
	SVThemeObject *selectedTheme = [self.themesArray objectAtIndex:row];
	selectedTheme.atFontColor = [self.fontColorWell color];
	selectedTheme.atBackgroundColor = [self.bgrndColorWell color];
	selectedTheme.atLinkColor = [self.linkColorWell color];
	selectedTheme.atCursorColor = [self.cursorColorWell color];
	selectedTheme.atSelectionColor = [self.selectionColorWell color];
}

# pragma mark -
# pragma mark data 

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	NSInteger row = [self.themesView selectedRow];
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

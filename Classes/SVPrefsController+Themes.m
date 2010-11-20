//
//  SVPrefsController+Themes.m
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import "SVPrefsController+Themes.h"
#import "SVThemeObject.h"

@implementation SVPrefsController (Themes)

# pragma mark -
# pragma mark general theme methods

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
	[self.fontColorWell setColor:selectedTheme.atFontColor];
	[self changeFontColor:self];
	[self.bgrndColorWell setColor:selectedTheme.atBackgroundColor];
	[self changeBgrndColor:self];
	[self.linkColorWell setColor:selectedTheme.atLinkColor];
	[self changeLinkColor:self];
	[self.cursorColorWell setColor:selectedTheme.atCursorColor];
	[self changeCursorColor:self];
	[self.selectionColorWell setColor:selectedTheme.atSelectionColor];
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

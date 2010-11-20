//
//  SVPrefsController.m
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import "SVPrefsController.h"
#import "SVPrefsController+Themes.h"
#import "SVThemeObject.h" 

// Notification string definition
NSString * const FontColorChangeNotification = @"FontColorChange";
NSString * const BgrndColorChangeNotification = @"BgrndColorChange";
NSString * const CursorColorChangeNotification = @"CursorColorChange";
NSString * const LinkColorChangeNotification = @"LinkColorChange";
NSString * const SelectionColorChangeNotification = @"SelectionColorChange";

@implementation SVPrefsController

@synthesize fontColorWell, bgrndColorWell, cursorColorWell, linkColorWell, selectionColorWell, 
			themesArray, themesView, pathForThemeLibraryFile;

# pragma mark -
# pragma mark initialization

- (id)init
{
    if (self = [super init]) 
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
	if (![defaults stringForKey:@"fontName"]) {
		[defaults setObject:@"Terminus" forKey:@"fontName"];
	}
	if (![defaults valueForKey:@"fontSize"]) {
		[defaults setFloat:14.0 forKey:@"fontSize"];
	}
	if (![defaults valueForKey:@"preferredEncoding"]) {
		[defaults setInteger:0 forKey:@"preferredEncoding"];
	}
	if (![defaults valueForKey:@"failEncoding"]) {
		[defaults setInteger:2 forKey:@"failEncoding"];
	}
	if (![defaults valueForKey:@"encNotApplicableNote"]) {
		[defaults setBool:YES forKey:@"encNotApplicableNote"];
	}
	if (![defaults valueForKey:@"docsOpenCentered"]) {
		[defaults setBool:YES forKey:@"docsOpenCentered"];
	}
	if (![defaults valueForKey:@"centerFileInfoHud"]) {
		[defaults setBool:YES forKey:@"centerFileInfoHud"];
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
	[defaults setObject:@"Terminus" forKey:@"fontName"];
	[defaults setFloat:14.0 forKey:@"fontSize"];
	[defaults setInteger:0 forKey:@"preferredEncoding"];
	[defaults setInteger:2 forKey:@"failEncoding"];
	[defaults setBool:YES forKey:@"encNotApplicableNote"];
	[defaults setBool:YES forKey:@"docsOpenCentered"];
	[defaults setFloat:650 forKey:@"newContentWidth"];
	[defaults setFloat:650 forKey:@"newContentHeight"];
	[defaults setBool:YES forKey:@"autoSizeWidth"];
	[defaults setBool:NO forKey:@"autoSizeHeight"];
	[defaults setInteger:0 forKey:@"themeIndex"];
	
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

# pragma mark -
# pragma mark user-defined colors

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
	[nc postNotificationName:FontColorChangeNotification
					  object:self 
					userInfo:dict];
}

- (void)sendBgrndColorChangeNote
{
	// Send background color change notification to all instances of MyDocument.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
	NSDictionary *dict = [NSDictionary dictionaryWithObject:[bgrndColorWell color] forKey:@"bgrndColorValue"]; 
	[nc postNotificationName:BgrndColorChangeNotification
					  object:self 
					userInfo:dict];
}

- (void)sendCursorColorChangeNote
{
	// Send cursor color change notification to all instances of MyDocument.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
	NSDictionary *dict = [NSDictionary dictionaryWithObject:[cursorColorWell color] forKey:@"cursorColorValue"];
	[nc postNotificationName:CursorColorChangeNotification
					  object:self
					userInfo:dict];
}

- (void)sendLinkColorChangeNote
{
	// Send link color change notification to all instances of MyDocument.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
	NSDictionary *dict = [NSDictionary dictionaryWithObject:[linkColorWell color] forKey:@"linkColorValue"];
	[nc postNotificationName:LinkColorChangeNotification
					  object:self
					userInfo:dict];
}

- (void)sendSelectionColorChangeNote
{
	// Send selection color change notification to all instances of MyDocument.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
	NSDictionary *dict = [NSDictionary dictionaryWithObject:[selectionColorWell color] forKey:@"selectionColorValue"];
	[nc postNotificationName:SelectionColorChangeNotification
					  object:self
					userInfo:dict];
}

@end

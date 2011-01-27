//
//  SVFontController.m
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import "SVFontController.h"

@implementation SVFontController

@synthesize fontFile, fontName, fontSize, destPath;

# pragma mark -
# pragma mark initialization

- (id)init
{
	if (self == [super init]) 
	{
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		// Read user defaults to get font name and size.
		self.fontName = [defaults stringForKey:@"fontName"];
		self.fontSize = [defaults floatForKey:@"fontSize"];
	} 
	return self;
}

# pragma mark -
# pragma mark font related methods

- (void)fontCheck
{
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	// Where do we go?
	[self evaluateFontPath];
	
	// Terminus is installed? Let's get the hell out of here!
	if ([fileManager fileExistsAtPath:self.destPath] == YES) {
		return;
	}
	// Still there? Font detection obviously failed.
	else {
		// Prompt the user to confirm Terminus installation.
		NSAlert *fontInstallConfirmation = [[NSAlert alloc] init];
		[fontInstallConfirmation addButtonWithTitle:@"Install"];
		[fontInstallConfirmation addButtonWithTitle:@"Cancel"];
		[fontInstallConfirmation setMessageText:@"Terminus.dfont not installed."];
		[fontInstallConfirmation setInformativeText:@"This special font variant comes bundled with "
													@"Ascension and is absolutely needed for properly "
													@"rendering documents containing ASCII / ANSI art."];
		[fontInstallConfirmation setAlertStyle:NSWarningAlertStyle];
		
		// Provided the user hit 'install', perform Terminus installation.
		if ([fontInstallConfirmation runModal] == NSAlertFirstButtonReturn) {
			[self copyFontFromBundle];
			
			// Wait for the font to be available.
			[NSThread sleepForTimeInterval:4];
			[self fontInstallReport];
		}
		else {
			// Fall back to Menlo 13pt, since Terminus is not installed.
			self.fontName = @"Menlo";
			self.fontSize = 13.0;
		}
		
	}
}

- (void)evaluateFontPath
{
	// Evaluate the path to Terminus.
	NSString *usrFontsPath = @"~/Library/Fonts/";
	usrFontsPath = [usrFontsPath stringByExpandingTildeInPath];
	self.fontFile = @"Terminus.dfont";
	self.destPath = [usrFontsPath stringByAppendingPathComponent:self.fontFile];
}

- (void)copyFontFromBundle
{
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	// Copies Terminus from the Bundle resources to ~/Library/Fonts. 
	NSString *srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.fontFile];
	NSError *fontError;
	[fileManager copyItemAtPath:srcPath toPath:self.destPath error:&fontError];
}

- (void)fontInstallReport
{
	// Report about the font installation process.
	NSAlert *fontInstallSuccess = [[NSAlert alloc] init];
	[fontInstallSuccess addButtonWithTitle:@"Ok"];
	[fontInstallSuccess setMessageText:@"Installation done."];
	[fontInstallSuccess setInformativeText:@"Terminus has been successfully installed on your "
										   @"system. In case you want to remove it at a later date, "
										   @"just open the folder ~/Library/Fonts/ with Finder "
										   @"and drag Terminus.dfont to trash."];
	[fontInstallSuccess runModal];
}

@end

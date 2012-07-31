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

@implementation SVPreferences

# pragma mark -
# pragma mark initialization

- (id)init
{
    if (self == [super init]) {}
	return self;
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
    if (![defaults valueForKey:@"colorSchemeIndex"]) {
		[defaults setInteger:0 forKey:@"colorSchemeIndex"];
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
	if (![defaults valueForKey:@"docsOpenCentered"]) {
		[defaults setBool:YES forKey:@"docsOpenCentered"];
	}
    if (![defaults valueForKey:@"terminateAfterLastWindowIsClosed"]) {
        [defaults setBool:NO forKey:@"terminateAfterLastWindowIsClosed"];
    }
    if (![defaults valueForKey:@"highlightAsciiHyperLinks"]) {
		[defaults setBool:YES forKey:@"highlightAsciiHyperLinks"];
	}
	if (![defaults valueForKey:@"autoSizeWidth"]) {
		[defaults setBool:YES forKey:@"autoSizeWidth"];
	}
	if (![defaults valueForKey:@"autoSizeHeight"]) {
		[defaults setBool:NO forKey:@"autoSizeHeight"];
	}
	if (![defaults dataForKey:@"fontColor"]) {
		NSData *fontColorData = [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:170/255.l green:170/255.l blue:170/255.l alpha:1.0]];
		[defaults setObject:fontColorData forKey:@"fontColor"];
	}
	if (![defaults dataForKey:@"backgroundColor"]) {
		NSData *backgroundColorData = [NSArchiver archivedDataWithRootObject:[NSColor blackColor]];
		[defaults setObject:backgroundColorData forKey:@"backgroundColor"];
	}
	if (![defaults dataForKey:@"cursorColor"]) {
		NSData *cursorColorData = [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:170/255.l green:170/255.l blue:170/255.l alpha:1.0]];
		[defaults setObject:cursorColorData forKey:@"cursorColor"];
	}
	if (![defaults dataForKey:@"linkColor"]) {
		NSData *linkColorData = [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:170/255.l green:170/255.l blue:170/255.l alpha:1.0]];
		[defaults setObject:linkColorData forKey:@"linkColor"];
	}
	if (![defaults dataForKey:@"selectionColor"]) {
		NSData *selectionColorData = [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:170/255.l green:170/255.l blue:170/255.l alpha:0.2]];
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
    [defaults setInteger:0 forKey:@"colorSchemeIndex"];
	[defaults setObject:@"Terminus" forKey:@"fontName"];
	[defaults setFloat:14.0 forKey:@"fontSize"];
	[defaults setInteger:0 forKey:@"nfoDizEncoding"];
	[defaults setBool:YES forKey:@"docsOpenCentered"];
    [defaults setBool:NO forKey:@"terminateAfterLastWindowIsClosed"];
    [defaults setBool:YES forKey:@"highlightAsciiHyperLinks"];
	[defaults setBool:YES forKey:@"autoSizeWidth"];
	[defaults setBool:NO forKey:@"autoSizeHeight"];
    
	// Store initial colors as data to user defaults.
	NSData *fontColorData = [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:170/255.l green:170/255.l blue:170/255.l alpha:1.0]];
	[defaults setObject:fontColorData forKey:@"fontColor"];
    
	NSData *backgroundColorData =[NSArchiver archivedDataWithRootObject:[NSColor blackColor]];
	[defaults setObject:backgroundColorData forKey:@"backgroundColor"];
    
    NSData *linkColorData = [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:170/255.l green:170/255.l blue:170/255.l alpha:1.0]];
	[defaults setObject:linkColorData forKey:@"linkColor"];
    
	NSData *cursorColorData = [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:170/255.l green:170/255.l blue:170/255.l alpha:1.0]];
	[defaults setObject:cursorColorData forKey:@"cursorColor"];
	
	NSData *selectionColorData = [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:170/255.l green:170/255.l blue:170/255.l alpha:0.2]];
	[defaults setObject:selectionColorData forKey:@"selectionColor"];
	
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

# pragma mark -
# pragma mark user-defined attributes

- (IBAction)selectScrollerStyle:(id)sender
{
    [self synchronizeDefaults:self];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"ScrollerStyleChange" object:self];
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
# pragma mark color schemes

- (IBAction)setColorScheme:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch ([defaults integerForKey:@"colorSchemeIndex"])
    {
        case sDOS:
        {
            // DOS color scheme
            NSData *fontColorData = [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:170/255.l green:170/255.l blue:170/255.l alpha:1.0]];
            [defaults setObject:fontColorData forKey:@"fontColor"];
            
            NSData *backgroundColorData =[NSArchiver archivedDataWithRootObject:[NSColor blackColor]];
            [defaults setObject:backgroundColorData forKey:@"backgroundColor"];
            
            NSData *linkColorData = [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:170/255.l green:170/255.l blue:170/255.l alpha:1.0]];
            [defaults setObject:linkColorData forKey:@"linkColor"];
            
            NSData *cursorColorData = [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:170/255.l green:170/255.l blue:170/255.l alpha:1.0]];
            [defaults setObject:cursorColorData forKey:@"cursorColor"];
            
            NSData *selectionColorData = [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:170/255.l green:170/255.l blue:170/255.l alpha:0.2]];
            [defaults setObject:selectionColorData forKey:@"selectionColor"];
			break;
		}
        case sBlackAndWhite: {
            // Black and White color scheme
            NSData *fontColorData = [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]];
            [defaults setObject:fontColorData forKey:@"fontColor"];
            
            NSData *backgroundColorData =[NSArchiver archivedDataWithRootObject:[NSColor blackColor]];
            [defaults setObject:backgroundColorData forKey:@"backgroundColor"];
            
            NSData *linkColorData = [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]];
            [defaults setObject:linkColorData forKey:@"linkColor"];
            
            NSData *cursorColorData = [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]];
            [defaults setObject:cursorColorData forKey:@"cursorColor"];
            
            NSData *selectionColorData = [NSArchiver archivedDataWithRootObject:[NSColor colorWithDeviceWhite:0.2 alpha:1.0]];
            [defaults setObject:selectionColorData forKey:@"selectionColor"];
			break;
		}
        case sReversed: {
            NSData *fontColorData = [NSArchiver archivedDataWithRootObject:[NSColor blackColor]];
            [defaults setObject:fontColorData forKey:@"fontColor"];
            
            NSData *backgroundColorData =[NSArchiver archivedDataWithRootObject:[NSColor whiteColor]];
            [defaults setObject:backgroundColorData forKey:@"backgroundColor"];
            
            NSData *linkColorData = [NSArchiver archivedDataWithRootObject:[NSColor blueColor]];
            [defaults setObject:linkColorData forKey:@"linkColor"];
            
            NSData *cursorColorData = [NSArchiver archivedDataWithRootObject:[NSColor blackColor]];
            [defaults setObject:cursorColorData forKey:@"cursorColor"];
            
            NSData *selectionColorData = [NSArchiver archivedDataWithRootObject:[NSColor lightGrayColor]];
            [defaults setObject:selectionColorData forKey:@"selectionColor"];
        }
        default: {
			break;
		}
    }
    [self synchronizeDefaults:self];
    
    // Send note to restyle content stuff.
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"ColorSchemeChange" object:self];
}

@end

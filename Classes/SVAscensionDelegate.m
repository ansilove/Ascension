//
//  SVAscensionDelegate.m
//  Ascension
///
//  Copyright (C) 2011-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import "SVAscensionDelegate.h"
#import "SVPreferencesWC.h"
#import "SVPreferences.h"
#import "SVEpicAboutBoxWC.h"

@implementation SVAscensionDelegate

@synthesize applicationHasStarted;

# pragma mark -
# pragma mark initialization

- (id)init
{
	if (self == [super init]) 
	{
		self.applicationHasStarted = NO;
        
        // First thing we do is generating the 'Application support' folder. That
        // will work around an issue that occurs when opening ANSi upon 1st launch.
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
        // Now check for the user defaults.
		[SVPreferences checkUserDefaults];
        
        // Let's observe if the save menu item needs to be disabled / enabled.
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        [nc addObserver:self 
               selector:@selector(disableSaveItem:)
                   name:@"DisableSave"
                 object:nil];
        
        [nc addObserver:self 
               selector:@selector(enableSaveItem:)
                   name:@"EnableSave"
                 object:nil];
    } 
	return self;
}

# pragma mark -
# pragma mark general

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"openUntitledFileOnStart"];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    return NO;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"terminateAfterLastWindowIsClosed"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	self.applicationHasStarted = YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"AppClosing" object:self];
}

- (IBAction)openPreferences:(id)sender
{
	[[SVPreferencesWC sharedPreferencesWC] showWindow:nil];
	(void)sender;
}

- (IBAction)readAnsiLoveDocumentation:(id)sender;
{
    NSString *ansiLoveDocs = (@"https://github.com/ByteProject/AnsiLove-C#documentation");
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:ansiLoveDocs]];
}

- (IBAction)showAboutBox:(id)sender
{
    [[SVEpicAboutBoxWC sharedEpicAboutBoxWC] showWindow:nil];
    (void)sender;
}

- (void)disableSaveItem:(NSNotification *)note
{
    self.enableSaveMenuItem = NO;
}

- (void)enableSaveItem:(NSNotification *)note
{
    self.enableSaveMenuItem = YES;
}

@end

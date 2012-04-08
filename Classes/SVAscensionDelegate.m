//
//  SVAscensionDelegate.m
//  Ascension
//
//  Copyright (c) 2010-2012, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
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
    } 
	return self;
}

# pragma mark -
# pragma mark general

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    return NO;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    return NO;
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

- (IBAction)openIssueTracker:(id)sender 
{
	NSString *issueTracker = (@"https://github.com/ByteProject/Ascension/issues");
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:issueTracker]];
}

- (IBAction)showAboutBox:(id)sender
{
    [[SVEpicAboutBoxWC sharedEpicAboutBoxWC] showWindow:nil];
    (void)sender;
}

@end

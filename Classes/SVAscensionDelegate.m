//
//  SVAscensionDelegate.m
//  Ascension
//
//  Copyright (c) 2010-2013, Stefan Vogt. All rights reserved.
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

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"terminateAfterLastWindowIsClosed"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	self.applicationHasStarted = YES;
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

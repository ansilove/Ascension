//
//  SVAscensionDelegate.m
//  Ascension
//
//  Copyright (c) 2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import "SVAscensionDelegate.h"
#import "SVPreferencesWC.h"
#import "SVPreferences.h"

@implementation SVAscensionDelegate

@synthesize applicationHasStarted;

# pragma mark -
# pragma mark initialization

- (id)init
{
	if (self == [super init]) 
	{
		self.applicationHasStarted = NO;
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

@end

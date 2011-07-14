//
//  SVAscensionDelegate.m
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import "SVAscensionDelegate.h"
#import "SVPrefsWindowController.h"
#import "SVPrefsController.h"
#import "SVPrefsController+Themes.h"

@implementation SVAscensionDelegate

@synthesize applicationHasStarted;

# pragma mark -
# pragma mark initialization

- (id)init
{
	if (self == [super init]) 
	{
		self.applicationHasStarted = NO;
		[SVPrefsController checkUserDefaults];
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
	[[SVPrefsWindowController sharedPrefsWindowController] showWindow:nil];
	(void)sender;
}

- (IBAction)openIssueTracker:(id)sender 
{
	NSString *issueTracker = (@"https://github.com/ByteProject/Ascension/issues");
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:issueTracker]];
}

@end

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
	if (self = [super init]) 
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
	if (!applicationHasStarted)
    {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults integerForKey:@"startupBehavior"] == 1) 
		{
			// Get the array of recent documents.
			NSDocumentController *controller = [NSDocumentController sharedDocumentController];
			NSArray *documents = [controller recentDocumentURLs];
			
			// Open the recent document, provided there is one.
			if ([documents count] > 0)
			{
				NSError *error = nil;
				[controller
				 openDocumentWithContentsOfURL:[documents objectAtIndex:0]
				 display:YES error:&error];
				
				// If an error occured, open an untitled document. 
				if (error == nil)
				{
					return NO;
				}
			}
		}
		if ([defaults integerForKey:@"startupBehavior"] == 2) {
			return NO;
		}
	}
	// None of the above applied? So open a new document.
	return YES;
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

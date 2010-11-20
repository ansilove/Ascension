//
//  SVFileInfoWindowController.m
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import "SVFileInfoWindowController.h"
static SVFileInfoWindowController *_sharedFileInfoWindowController = nil;

@implementation SVFileInfoWindowController

# pragma mark -
# pragma mark class methods

+ (SVFileInfoWindowController *)sharedFileInfoWindowController
{
	if (!_sharedFileInfoWindowController) {
		_sharedFileInfoWindowController = [[self alloc] initWithWindowNibName:[self nibName]];
	}
	return _sharedFileInfoWindowController;
}

+ (NSString *)nibName
{
	return @"FileInfo";
}

# pragma mark -
# pragma mark initialization 

- (void)awakeFromNib
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults boolForKey:@"centerFileInfoHud"] == YES) 
	{
		[self.window center];
		[defaults setBool:NO forKey:@"centerFileInfoHud"];
	}
}

@end

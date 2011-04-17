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

@synthesize fontName, fontSize;

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

@end

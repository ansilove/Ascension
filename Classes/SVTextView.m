//
//  SVTextView.m
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import "SVTextView.h"

@implementation SVTextView

- (BOOL)readSelectionFromPasteboard:(NSPasteboard *)pboard
							   type:(NSString *)type
{
	// Send a note if the user pastes content into SVTextView.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"PasteNote" object:self];
	
	return [super readSelectionFromPasteboard:pboard type:type];
}

@end

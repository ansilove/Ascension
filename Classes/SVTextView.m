//
//  SVTextView.m
//  Ascension
//
//  Copyright (c) 2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
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

- (BOOL)importsGraphics 
{
    // Override this so we can import rendered ANSi images.
    return YES;
}

@end

//
//  SVFontProperties.m
//  Ascension
//
//  Copyright (c) 2010-2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import "SVFontProperties.h"

@implementation SVFontProperties

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

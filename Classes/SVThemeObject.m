//
//  SVThemeObject.m
//  Ascension
//
//  Copyright (c) 2010-2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import "SVThemeObject.h"

@implementation SVThemeObject

@synthesize atName, atFontColor, atBackgroundColor, atLinkColor, atCursorColor, 
			atSelectionColor;

# pragma mark -
# pragma mark initialization

- (id)init
{
	if (self == [super init]) {}
	return self;
}

# pragma mark -
# pragma mark save and restore

- (id)initWithCoder:(NSCoder *)decoder
{
	if (self == [super init])
	{
		self.atName	= [decoder decodeObjectForKey:@"atName"];
		self.atFontColor = [decoder decodeObjectForKey:@"atFontColor"];
		self.atBackgroundColor = [decoder decodeObjectForKey:@"atBackgroundColor"];
		self.atLinkColor = [decoder decodeObjectForKey:@"atLinkColor"];
		self.atCursorColor = [decoder decodeObjectForKey:@"atCursorColor"];
		self.atSelectionColor = [decoder decodeObjectForKey:@"atSelectionColor"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder 
{
	[encoder encodeObject:self.atName forKey:@"atName"];
	[encoder encodeObject:self.atFontColor forKey:@"atFontColor"];
	[encoder encodeObject:self.atBackgroundColor forKey:@"atBackgroundColor"];
	[encoder encodeObject:self.atLinkColor forKey:@"atLinkColor"];
	[encoder encodeObject:self.atCursorColor forKey:@"atCursorColor"];
	[encoder encodeObject:self.atSelectionColor forKey:@"atSelectionColor"];
}

@end

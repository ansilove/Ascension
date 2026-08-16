//
//  SVThemeObject.m
//  Ascension
//
//  Copyright (C) 2010-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import "SVThemeObject.h"

@implementation SVThemeObject

+ (BOOL)supportsSecureCoding {
    return YES;
}

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
		self.atName = [decoder decodeObjectOfClass:[NSString class] forKey:@"atName"];
		self.atFontColor = [decoder decodeObjectOfClass:[NSColor class] forKey:@"atFontColor"];
		self.atBackgroundColor = [decoder decodeObjectOfClass:[NSColor class] forKey:@"atBackgroundColor"];
		self.atLinkColor = [decoder decodeObjectOfClass:[NSColor class] forKey:@"atLinkColor"];
		self.atCursorColor = [decoder decodeObjectOfClass:[NSColor class] forKey:@"atCursorColor"];
		self.atSelectionColor = [decoder decodeObjectOfClass:[NSColor class] forKey:@"atSelectionColor"];
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

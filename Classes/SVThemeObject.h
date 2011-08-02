//
//  SVThemeObject.h
//  Ascension
//
//  Copyright (c) 2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import <Foundation/Foundation.h>

@interface SVThemeObject : NSObject <NSCoding> {
	
	NSString *atName;
	NSColor  *atFontColor;
	NSColor  *atBackgroundColor;
	NSColor  *atLinkColor;
	NSColor  *atCursorColor;
	NSColor  *atSelectionColor;
}

// strings
@property (readwrite, assign) NSString *atName;

// colors
@property (readwrite, assign) NSColor *atFontColor;
@property (readwrite, assign) NSColor *atBackgroundColor;
@property (readwrite, assign) NSColor *atLinkColor;
@property (readwrite, assign) NSColor *atCursorColor;
@property (readwrite, assign) NSColor *atSelectionColor;

@end

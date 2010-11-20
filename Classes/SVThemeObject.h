//
//  SVThemeObject.h
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
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

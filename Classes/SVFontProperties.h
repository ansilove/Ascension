//
//  SVFontProperties.h
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import <Cocoa/Cocoa.h>

@interface SVFontProperties : NSObject {
	
	NSString *fontName;
	CGFloat	 fontSize;
}

// strings
@property (readwrite, assign) NSString *fontName;

// integer and float values
@property (readwrite, assign) CGFloat fontSize;

@end

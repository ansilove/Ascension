//
//  SVFontController.h
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import <Cocoa/Cocoa.h>

@interface SVFontController : NSObject {
	
	NSString *fontFile;
	NSString *destPath;
	NSString *fontName;
	CGFloat	 fontSize;
}

// strings
@property (readwrite, assign) NSString *fontFile;
@property (readwrite, assign) NSString *destPath;
@property (readwrite, assign) NSString *fontName;

// integer and float values
@property (readwrite, assign) CGFloat fontSize;

// general methods
- (void)fontCheck;
- (void)evaluateFontPath;
- (void)copyFontFromBundle;
- (void)fontInstallReport;

@end

//
//  MyDocument.h
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import <Cocoa/Cocoa.h>
#import <AutoHyperlinks/AutoHyperlinks.h>

typedef enum {
	EncBlockASCII,
	EncUnicode,
	EncMacRoman
} SVEncoding;

@interface MyDocument : NSDocument {
	
	IBOutlet NSTextView			  *asciiTextView;
	IBOutlet NSScrollView		  *asciiScrollView;
	IBOutlet NSToolbar			  *appToolbar;
	IBOutlet NSPopUpButton		  *encodingButton;
    NSMutableAttributedString	  *contentString;
	NSColor						  *fontColor;
	NSColor						  *backgroundColor;
	NSColor						  *cursorColor;
	NSColor						  *linkColor;
	NSColor						  *selectionColor;
	NSDictionary				  *linkAttributes;
	NSDictionary				  *selectionAttributes;
	NSStringEncoding			  charEncoding;
	CGFloat						  newContentWidth;
	CGFloat						  newContentHeight;
	NSString					  *iFilePath;
	NSString					  *iCreationDate;
	NSString					  *iModDate;
	NSString					  *iFileSize;
}

// strings
@property (readwrite, assign) NSMutableAttributedString *contentString;
@property (readwrite, assign) NSStringEncoding			charEncoding;
@property (readwrite, assign) NSString					*iFilePath;
@property (readwrite, assign) NSString					*iFileSize;
@property (readwrite, assign) NSString					*iCreationDate;
@property (readwrite, assign) NSString					*iModDate;

// integer and float values
@property (readwrite, assign) CGFloat	newContentWidth;
@property (readwrite, assign) CGFloat   newContentHeight;

// colors
@property (readwrite, assign) NSColor *fontColor;
@property (readwrite, assign) NSColor *backgroundColor;
@property (readwrite, assign) NSColor *cursorColor;
@property (readwrite, assign) NSColor *linkColor;
@property (readwrite, assign) NSColor *selectionColor;

// dictionaries
@property (readwrite, assign) NSDictionary *linkAttributes;
@property (readwrite, assign) NSDictionary *selectionAttributes;

// outlets
@property (retain) IBOutlet NSTextView	  *asciiTextView;
@property (retain) IBOutlet NSScrollView  *asciiScrollView;
@property (retain) IBOutlet NSPopUpButton *encodingButton;

// general methods
- (void)applyParagraphStyle;
- (void)performLinkification;
- (void)performFontColorChange:(NSNotification *)note;
- (void)performBgrndColorChange:(NSNotification *)note;
- (void)performCursorColorChange:(NSNotification *)note;
- (void)performLinkColorChange:(NSNotification *)note;
- (void)performSelectionColorChange:(NSNotification *)note;
- (void)switchEncoding;
- (void)switchEncodingButton;
- (void)updateFileInfoValues;

// objects and return values
- (CGFloat)titlebarHeight;
- (NSRect)screenRect;

// actions
- (IBAction)encodeInUnicode:(id)sender;
- (IBAction)encodeInBlockASCII:(id)sender;
- (IBAction)encodeInMacRoman:(id)sender;
- (IBAction)openFileInformation:(id)sender;

@end

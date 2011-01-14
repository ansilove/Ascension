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
#import "SVTextView.h"

typedef enum {
	EncDosCP437,
	EncDosCP866,
	EncUniUTF8,
	EncUniUTF16,
	EncMacRoman,
	EncWinLatin
} SVEncoding;

@interface MyDocument : NSDocument {
	
	IBOutlet NSWindow			  *mainWindow;
	IBOutlet NSView				  *attachedEncView;
	IBOutlet SVTextView			  *asciiTextView;
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
	CGFloat						  newContentWidth;
	CGFloat						  newContentHeight;
	NSString					  *iFilePath;
	NSString					  *iCreationDate;
	NSString					  *iModDate;
	NSString					  *iFileSize;
	NSStringEncoding			  nfoDizEncoding;
	NSStringEncoding			  txtEncoding;
	NSStringEncoding			  exportEncoding;
}

// strings
@property (readwrite, assign) NSMutableAttributedString *contentString;
@property (readwrite, assign) NSString					*iFilePath;
@property (readwrite, assign) NSString					*iFileSize;
@property (readwrite, assign) NSString					*iCreationDate;
@property (readwrite, assign) NSString					*iModDate;
@property (readwrite, assign) NSStringEncoding			nfoDizEncoding;
@property (readwrite, assign) NSStringEncoding			txtEncoding;
@property (readwrite, assign) NSStringEncoding			exportEncoding;

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
@property (retain) IBOutlet NSWindow	  *mainWindow;
@property (retain) IBOutlet NSView		  *attachedEncView;
@property (retain) IBOutlet SVTextView	  *asciiTextView;
@property (retain) IBOutlet NSScrollView  *asciiScrollView;
@property (retain) IBOutlet NSPopUpButton *encodingButton;

// general methods
- (void)createInterface;
- (void)prepareContent;
- (void)applyThemeColors;
- (void)applyParagraphStyle;
- (void)performLinkification;
- (void)handlePasteOperation:(NSNotification *)note;
- (void)performFontColorChange:(NSNotification *)note;
- (void)performBgrndColorChange:(NSNotification *)note;
- (void)performCursorColorChange:(NSNotification *)note;
- (void)performLinkColorChange:(NSNotification *)note;
- (void)performSelectionColorChange:(NSNotification *)note;
- (void)switchASCIIEncoding;
- (void)switchTextEncoding;
- (void)setEncodingButton;
- (void)updateFileInfoValues;
- (void)setString:(NSMutableAttributedString *)value;
- (NSFileWrapper *)nfoFileWrapperWithError:(NSError **)pOutError;
- (NSFileWrapper *)txtFileWrapperWithError:(NSError **)pOutError;
- (BOOL)nfoReadFileWrapper:(NSFileWrapper *)pFileWrapper error:(NSError **)pOutError;
- (BOOL)txtReadFileWrapper:(NSFileWrapper *)pFileWrapper error:(NSError **)pOutError;

// objects and return values
- (CGFloat)titlebarHeight;
- (NSRect)screenRect;
- (NSMutableAttributedString *)string;

// actions
- (IBAction)openFileInformation:(id)sender;

@end

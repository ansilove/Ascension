//
//  SVAsciiDocument.h
//  Ascension
//
//  Copyright (c) 2010-2012, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>
#import <AutoHyperlinks/AutoHyperlinks.h>

@class SVTextView;
@class SVRoardactedScroller;

typedef enum {
	eDosCP437, // Latin US
    eDosCP775, // Baltic Rim
    eDosCP855, // Cyrillic (Slavic)
    eDosCP863, // French-Canadian
    eDosCP737, // Greek
    eDosCP869, // Greek2 
	eDosCP862, // Hebrew
    eDosCP861, // Icelandic
    eDosCP850, // Latin1
    eDosCP852, // Latin2
    eDosCP865, // Nordic
    eDosCP860, // Portuguese
    eDosCP866, // Cyrillic (Russian)
    eDosCP857, // Turkish
    eAmiga     // Amiga (Latin 1, Western)
} ASCIIArtEncoding;

typedef enum {
	eUniUTF8,
	eUniUTF16,
	eMacRoman,
	eWinLatin
} TextFileEncoding;

typedef enum {
	xDosCP437,
    xDosCP775,
    xDosCP855,
    xDosCP863,
    xDosCP737,
    xDosCP869,
	xDosCP862,
    xDosCP861,
    xDosCP850,
    xDosCP852,
    xDosCP865,
    xDosCP860,
    xDosCP866,
    xDosCP857,
    xAmiga,
    xUniUTF8,
	xUniUTF16,
	xMacRoman,
	xWinLatin1
} EncodingButtonIndex;

@interface SVAsciiDocument : NSDocument

// strings
@property (nonatomic, strong) NSMutableAttributedString *contentString;
@property (nonatomic, strong) NSString                  *iFilePath;
@property (nonatomic, strong) NSString                  *iFileSize;
@property (nonatomic, strong) NSString                  *iCreationDate;
@property (nonatomic, strong) NSString                  *iModDate;
@property (nonatomic, strong) NSString                  *fontName;
@property (nonatomic, assign) NSStringEncoding          nfoDizEncoding;
@property (nonatomic, assign) NSStringEncoding          newEncoding;

// integer and float values
@property (nonatomic, assign) CGFloat   fontSize;
@property (nonatomic, assign) CGFloat   newContentWidth;
@property (nonatomic, assign) CGFloat   newContentHeight;
@property (nonatomic, assign) NSInteger encButtonIndex;

// colors
@property (nonatomic, strong) NSColor *fontColor;
@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, strong) NSColor *cursorColor;
@property (nonatomic, strong) NSColor *linkColor;
@property (nonatomic, strong) NSColor *selectionColor;

// dictionaries
@property (nonatomic, strong) NSDictionary *linkAttributes;
@property (nonatomic, strong) NSDictionary *selectionAttributes;

// outlets
@property (nonatomic, strong) IBOutlet NSWindow             *mainWindow;
@property (nonatomic, strong) IBOutlet NSPopover            *fileInfoPopover;
@property (nonatomic, strong) IBOutlet NSTextView           *asciiTextView;
@property (nonatomic, strong) IBOutlet NSScrollView         *asciiScrollView;
@property (nonatomic, strong) IBOutlet NSToolbar            *appToolbar;
@property (nonatomic, strong) IBOutlet NSPopUpButton        *encodingButton;
@property (nonatomic, strong) IBOutlet SVRoardactedScroller *vScroller;
@property (nonatomic, strong) IBOutlet SVRoardactedScroller *hScroller;

// general methods
- (void)createInterface;
- (void)prepareContent;
- (void)applySchemeColors;
- (void)applyParagraphStyle;
- (void)performLinkification;
- (void)performColorSchemeChange:(NSNotification *)note;
- (void)performResumeStateChange:(NSNotification *)note;
- (void)performScrollerStyleChange:(NSNotification *)note;
- (void)toggleHyperLinkAttributes:(NSNotification *)note;
- (void)switchASCIIEncoding;
- (void)updateFileInfoValues;
- (void)setString:(NSMutableAttributedString *)value;
- (BOOL)asciiArtReadFileWrapper:(NSFileWrapper *)pFileWrapper error:(NSError **)pOutError;

// objects and return values
- (CGFloat)titlebarHeight;
- (NSRect)screenRect;
- (NSMutableAttributedString *)string;

// actions
- (IBAction)showFileInfoPopover:(id)sender;
- (IBAction)switchCurrentEncoding:(id)sender;

@end

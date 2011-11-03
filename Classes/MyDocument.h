//
//  MyDocument.h
//  Ascension
//
//  Copyright (c) 2010-2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>
#import <AutoHyperlinks/AutoHyperlinks.h>
#import <AnsiLove/AnsiLove.h>

@class SVTextView;

// No confusion in switch methods, so much easier to read.
typedef enum {
	EncDosCP437,
	EncDosCP866
} SVAscensionASCIIEncoding;

typedef enum {
	EncUniUTF8,
	EncUniUTF16,
	EncMacRoman,
	EncWinLatin
} SVAscensionTextEncoding;

typedef enum {
	EIndexDosCP437,
	EIndexDosCP866,
	EIndexUniUTF8,
	EIndexUniUTF16,
	EIndexMacRoman,
	EIndexWinLatin1,
} SVEncodingButtonIndex;

@interface MyDocument : NSDocument

// strings
@property (nonatomic, strong) NSMutableAttributedString *contentString;
@property (nonatomic, strong) NSMutableAttributedString *rawAnsiString;
@property (nonatomic, strong) NSString                  *ansiCacheFile;
@property (nonatomic, weak)   NSString					*iFilePath;
@property (nonatomic, weak)   NSString					*iFileSize;
@property (nonatomic, weak)   NSString					*iCreationDate;
@property (nonatomic, weak)   NSString					*iModDate;
@property (nonatomic, assign) NSStringEncoding			nfoDizEncoding;
@property (nonatomic, assign) NSStringEncoding			txtEncoding;
@property (nonatomic, assign) NSStringEncoding			exportEncoding;

// integer and float values
@property (nonatomic, assign) CGFloat   newContentWidth;
@property (nonatomic, assign) CGFloat   newContentHeight;
@property (nonatomic, assign) NSInteger encButtonIndex;
@property (nonatomic, assign) BOOL      isAnsiFile;

// colors
@property (nonatomic, weak) NSColor *fontColor;
@property (nonatomic, weak) NSColor *backgroundColor;
@property (nonatomic, weak) NSColor *cursorColor;
@property (nonatomic, weak) NSColor *linkColor;
@property (nonatomic, weak) NSColor *selectionColor;

// dictionaries
@property (nonatomic, weak) NSDictionary *linkAttributes;
@property (nonatomic, weak) NSDictionary *selectionAttributes;

// outlets
@property (nonatomic, strong) IBOutlet NSWindow      *mainWindow;
@property (nonatomic, strong) IBOutlet NSPopover     *fileInfoPopover;
@property (nonatomic, strong) IBOutlet SVTextView	 *asciiTextView;
@property (nonatomic, strong) IBOutlet NSScrollView  *asciiScrollView;
@property (nonatomic, strong) IBOutlet NSToolbar     *appToolbar;
@property (nonatomic, strong) IBOutlet NSPopUpButton *encodingButton;
@property (nonatomic, strong) IBOutlet NSScroller    *vScroller;
@property (nonatomic, strong) IBOutlet NSScroller    *hScroller;


// general methods
- (void)createInterface;
- (void)prepareContent;
- (void)applyThemeColors;
- (void)applyParagraphStyle;
- (void)performLinkification;
- (void)handlePasteOperation:(NSNotification *)note;
- (void)performResumeStateChange:(NSNotification *)note;
- (void)performScrollerStyleChange:(NSNotification *)note;
- (void)performFontColorChange:(NSNotification *)note;
- (void)performBgrndColorChange:(NSNotification *)note;
- (void)performCursorColorChange:(NSNotification *)note;
- (void)performLinkColorChange:(NSNotification *)note;
- (void)performSelectionColorChange:(NSNotification *)note;
- (void)switchASCIIEncoding;
- (void)switchTextEncoding;
- (void)updateFileInfoValues;
- (void)setString:(NSMutableAttributedString *)value;
- (NSFileWrapper *)nfoFileWrapperWithError:(NSError **)pOutError;
- (NSFileWrapper *)ansFileWrapperWithError:(NSError **)pOutError;
- (NSFileWrapper *)txtFileWrapperWithError:(NSError **)pOutError;
- (BOOL)nfoReadFileWrapper:(NSFileWrapper *)pFileWrapper error:(NSError **)pOutError;
- (BOOL)ansReadFileWrapper:(NSFileWrapper *)pFileWrapper error:(NSError **)pOutError;
- (BOOL)txtReadFileWrapper:(NSFileWrapper *)pFileWrapper error:(NSError **)pOutError;

// objects and return values
- (CGFloat)titlebarHeight;
- (NSRect)screenRect;
- (NSMutableAttributedString *)string;
- (NSArray *)lsStringRangesInDocument:(NSString *)liveSearchString;

// actions
- (IBAction)switchExportEncoding:(id)sender;
- (IBAction)performLiveSearch:(id)sender;
- (IBAction)showFileInfoPopover:(id)sender;

@end

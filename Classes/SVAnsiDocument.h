//
//  SVAnsiDocument.h
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
#import <AnsiLove/AnsiLove.h>

@class SVTextView;
@class SVRoardactedScroller;

typedef enum {
	eDosCP437,
	eDosCP866
} ASCIIArtEncoding;

typedef enum {
	eUniUTF8,
	eUniUTF16,
	eMacRoman,
	eWinLatin
} TextFileEncoding;

typedef enum {
	xDosCP437,
	xDosCP866,
	xUniUTF8,
	xUniUTF16,
	xMacRoman,
	xWinLatin1
} EncodingButtonIndex;

typedef enum {
    alTerminus,
    al80x25,
    al80x50,
    alBaltic,
    alCyrillicSlavic,
    alFrenchCanadian,
    alGreek,
    alGreek869,
    alHebrew,
    alIcelandic,
    alLatin1,
    alLatin2,
    alNordic,
    alPortuguese,
    alCyrillicRussian,
    alTurkish,
    alTopaz,
    alTopazPlus,
    alTopaz500,
    alTopaz500Plus,
    alMoSoul,
    alPotNoodle,
    alMicroKnight,
    alMicroKnightPlus
} AnsiLoveFonts;

typedef enum {
    alEight,
    alNine,
    alCed,
    alWorkbench,
    alTransparent
} AnsiLoveBits;

@interface SVAnsiDocument : NSDocument

// strings
@property (nonatomic, strong) NSMutableAttributedString *contentString;
@property (nonatomic, strong) NSMutableAttributedString *rawAnsiString;
@property (nonatomic, strong) NSString                  *ansiCacheFile;
@property (nonatomic, strong) NSString                  *alFont;
@property (nonatomic, strong) NSString                  *alBits;
@property (nonatomic, strong) NSString                  *alIceColors;
@property (nonatomic, strong) NSString                  *alColumns;
@property (nonatomic, strong) NSString                  *iFilePath;
@property (nonatomic, strong) NSString                  *iFileSize;
@property (nonatomic, strong) NSString                  *iCreationDate;
@property (nonatomic, strong) NSString                  *iModDate;
@property (nonatomic, strong) NSString                  *fontName;
@property (nonatomic, assign) NSStringEncoding          nfoDizEncoding;
@property (nonatomic, assign) NSStringEncoding          txtEncoding;
@property (nonatomic, assign) NSStringEncoding          exportEncoding;

// images
@property (nonatomic, strong) NSImage *renderedAnsiImage;

// integer and float values
@property (nonatomic, assign) CGFloat   fontSize;
@property (nonatomic, assign) CGFloat   newContentWidth;
@property (nonatomic, assign) CGFloat   newContentHeight;
@property (nonatomic, assign) NSInteger encButtonIndex;
@property (nonatomic, assign) BOOL      isRendered;
@property (nonatomic, assign) BOOL      isUsingAnsiLove;
@property (nonatomic, assign) BOOL      isAnsFile;
@property (nonatomic, assign) BOOL      isIdfFile;
@property (nonatomic, assign) BOOL      isPcbFile;
@property (nonatomic, assign) BOOL      isXbFile;
@property (nonatomic, assign) BOOL      isAdfFile;
@property (nonatomic, assign) BOOL      isBinFile;
@property (nonatomic, assign) BOOL      isTndFile;
@property (nonatomic, assign) BOOL      shouldDisableSave;

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
@property (nonatomic, strong) IBOutlet SVTextView           *asciiTextView;
@property (nonatomic, strong) IBOutlet NSScrollView         *asciiScrollView;
@property (nonatomic, strong) IBOutlet NSToolbar            *appToolbar;
@property (nonatomic, strong) IBOutlet NSPopUpButton        *encodingButton;
@property (nonatomic, strong) IBOutlet SVRoardactedScroller *vScroller;
@property (nonatomic, strong) IBOutlet SVRoardactedScroller *hScroller;

// general methods
- (void)createInterface;
- (void)disableEditing;
- (void)enableEditing;
- (void)lockEditorFeatures:(NSNotification *)note;
- (void)unlockEditorFeatures:(NSNotification *)note;
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
- (void)toggleHyperLinkAttributes:(NSNotification *)note;
- (void)setRenderingFinishedState:(NSNotification *)note;
- (void)switchASCIIEncoding;
- (void)switchTextEncoding;
- (void)updateFileInfoValues;
- (void)setString:(NSMutableAttributedString *)value;
- (void)performAnsiLoveRenderChange:(NSNotification *)note;
- (void)setAnsiLoveFont;
- (void)setAnsiLoveBits;
- (void)setAnsiLoveColumns;
- (void)setAnsiLoveIceColors;
- (NSFileWrapper *)ansiArtFileWrapperWithError:(NSError **)pOutError;
- (NSFileWrapper *)textFileWrapperWithError:(NSError **)pOutError;
- (BOOL)asciiArtReadFileWrapper:(NSFileWrapper *)pFileWrapper error:(NSError **)pOutError;
- (BOOL)ansiArtReadFileWrapper:(NSFileWrapper *)pFileWrapper error:(NSError **)pOutError;
- (BOOL)textReadFileWrapper:(NSFileWrapper *)pFileWrapper error:(NSError **)pOutError;

// objects and return values
- (CGFloat)titlebarHeight;
- (NSRect)screenRect;
- (NSMutableAttributedString *)string;

// actions
- (IBAction)switchExportEncoding:(id)sender;
- (IBAction)showFileInfoPopover:(id)sender;
- (IBAction)exportAsImage:(id)sender;
- (IBAction)showSauceRecord:(id)sender;
- (IBAction)postOnTwitter:(id)sender;

@end

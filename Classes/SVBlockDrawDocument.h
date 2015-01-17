//
//  SVBlockDrawDocument.h
//  Ascension
//
//  Copyright (C) 2011-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>
#import <AutoHyperlinks/AutoHyperlinks.h>
#import <AnsiLove/AnsiLove.h>

@class SVRetroTextView;
@class RFOverlayScrollView;
@class RFOverlayScroller;

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

typedef enum {
    alTerminus,
    al80x25,
    al80x50,
    alBalticRim,
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

@interface SVBlockDrawDocument : NSDocument

// instances
@property (nonatomic, strong) ALAnsiGenerator           *ansiGen;

// strings
@property (nonatomic, strong) NSMutableAttributedString *contentString;
@property (nonatomic, strong) NSMutableAttributedString *rawAnsiString;
@property (nonatomic, strong) NSString                  *ansiCacheFile;
@property (nonatomic, strong) NSString                  *retinaCacheFile;
@property (nonatomic, strong) NSString                  *twitterCacheFile;
@property (nonatomic, strong) NSString                  *exportCacheFile;
@property (nonatomic, strong) NSString                  *exportURLString;
@property (nonatomic, strong) NSString                  *alURLString;
@property (nonatomic, strong) NSString                  *alOutputString;
@property (nonatomic, strong) NSString                  *alFont;
@property (nonatomic, strong) NSString                  *alBits;
@property (nonatomic, strong) NSString                  *alColumns;
@property (nonatomic, strong) NSString                  *iFilePath;
@property (nonatomic, strong) NSString                  *iFileSize;
@property (nonatomic, strong) NSString                  *iCreationDate;
@property (nonatomic, strong) NSString                  *iModDate;
@property (nonatomic, strong) NSString                  *fontName;
@property (nonatomic, strong) NSString                  *sauceURLString;
@property (nonatomic, strong) NSString                  *sauceID;
@property (nonatomic, strong) NSString                  *sauceVersion;
@property (nonatomic, strong) NSString                  *sauceTitle;
@property (nonatomic, strong) NSString                  *sauceAuthor;
@property (nonatomic, strong) NSString                  *sauceGroup;
@property (nonatomic, strong) NSString                  *sauceDate;
@property (nonatomic, strong) NSString                  *sauceComments;
@property (nonatomic, assign) NSStringEncoding          nfoDizEncoding;
@property (nonatomic, assign) NSStringEncoding          txtEncoding;
@property (nonatomic, assign) NSStringEncoding          exportEncoding;

// images
@property (nonatomic, strong) NSImage *renderedAnsiImage;
@property (nonatomic, strong) NSImage *renderedTwitterImage;

// integer and float values
@property (nonatomic, assign) CGFloat   fontSize;
@property (nonatomic, assign) CGFloat   newContentWidth;
@property (nonatomic, assign) CGFloat   newContentHeight;
@property (nonatomic, assign) CGFloat   dotsPerInch;
@property (nonatomic, assign) NSInteger encButtonIndex;
@property (nonatomic, assign) NSInteger previousEncIndex;
@property (nonatomic, assign) NSInteger sauceDataType;
@property (nonatomic, assign) NSInteger sauceFileType;
@property (nonatomic, assign) NSInteger sauceTinfo1;
@property (nonatomic, assign) NSInteger sauceTinfo2;
@property (nonatomic, assign) NSInteger sauceTinfo3;
@property (nonatomic, assign) NSInteger sauceTinfo4;
@property (nonatomic, assign) NSInteger sauceFlags;
@property (nonatomic, assign) BOOL      alIceColors;
@property (nonatomic, assign) BOOL      isRendered;
@property (nonatomic, assign) BOOL      isUsingAnsiLove;
@property (nonatomic, assign) BOOL      isAnsFile;
@property (nonatomic, assign) BOOL      isIdfFile;
@property (nonatomic, assign) BOOL      isPcbFile;
@property (nonatomic, assign) BOOL      isXbFile;
@property (nonatomic, assign) BOOL      isAdfFile;
@property (nonatomic, assign) BOOL      isBinFile;
@property (nonatomic, assign) BOOL      isTndFile;
@property (nonatomic, assign) BOOL      isTextFile;
@property (nonatomic, assign) BOOL      shouldDisableSave;
@property (nonatomic, assign) BOOL      isInLimbo;
@property (nonatomic, assign) BOOL      isNewFile;

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
@property (nonatomic, strong) IBOutlet NSPopover            *saucePopover;
@property (nonatomic, strong) IBOutlet NSSavePanel          *exportPanel;
@property (nonatomic, strong) IBOutlet SVRetroTextView      *ansiTextView;
@property (nonatomic, strong) IBOutlet RFOverlayScrollView  *ansiScrollView;
@property (nonatomic, strong) IBOutlet NSToolbar            *appToolbar;
@property (nonatomic, strong) IBOutlet NSPopUpButton        *encodingButton;
@property (nonatomic, strong) IBOutlet RFOverlayScroller    *vScroller;
@property (nonatomic, strong) IBOutlet RFOverlayScroller    *hScroller;

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
- (void)performFontChange:(NSNotification *)note;
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
- (void)renderANSiArtwork;
- (void)updateANSiLivePreview;
- (void)performAnsiLoveRenderChange:(NSNotification *)note;
- (void)setAnsiLoveFontAndEncoding;
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

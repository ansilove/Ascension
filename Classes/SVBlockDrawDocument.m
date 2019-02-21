//
//  SVBlockDrawDocument.m
//  Ascension
//
//  Copyright (C) 2010-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import "SVBlockDrawDocument.h"
#import "SVRetroTextView.h"
#import "SVPreferences.h"
#import "SVFileInfoStrings.h"
#import "NSImage+SVExtensions.h"
#import "RFOverlayScrollView.h"
#import "RFOverlayScroller.h"

// helpers
#define ansiEscapeSeq @"[0m"
#define stdNSTextViewMargin 20
#define ansiHelperMargin 8

// ANSi / ASCII string encodings
#define CodePage437 CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSLatinUS)
#define CodePage775 CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSBalticRim)
#define CodePage855 CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSCyrillic)
#define CodePage863 CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSCanadianFrench)
#define CodePage737 CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSGreek)
#define CodePage869 CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSGreek2)
#define CodePage862 CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSHebrew)
#define CodePage861 CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSIcelandic)
#define CodePage850 CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSLatin1)
#define CodePage852 CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSLatin2)
#define CodePage865 CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSNordic)
#define CodePage860 CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSPortuguese)
#define CodePage866 CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSRussian)
#define CodePage857 CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSTurkish)

// alternate string encodings
#define UnicodeUTF8 NSUTF8StringEncoding
#define UnicodeUTF16 NSUTF16StringEncoding
#define MacOSRoman NSMacOSRomanStringEncoding
#define WinLatin1 NSWindowsCP1252StringEncoding

@implementation SVBlockDrawDocument

# pragma mark -
# pragma mark initialization

- (id)init
{
   if (self == [super init]) 
   {
	   // If there is no content string, create one.
	   if (self.contentString == nil) {
		   self.contentString = [[NSMutableAttributedString alloc] initWithString:@""];
	   }
       
       // Step one: we are untitled. Are we? Probably.
       self.isNewFile = YES;
       
       // Step two: creating an Instance of ALAnsiGenerator.
       self.ansiGen = [ALAnsiGenerator new];
       
	   // Define NSNotificationCenter.
	   NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	   
       // Register as an observer for font and font color changes.
       [nc addObserver:self
			  selector:@selector(performFontChange:)
				  name:@"ASCIIFontChange"
				object:nil];
       
	   [nc addObserver:self
			  selector:@selector(performFontColorChange:) 
				  name:@"FontColorChange"
				object:nil];
	   
	   // Become an observer for background color changes.
	   [nc addObserver:self
			  selector:@selector(performBgrndColorChange:) 
				  name:@"BgrndColorChange"
				object:nil];
	   
	   // Start observating any cursor color changes.
	   [nc addObserver:self
			  selector:@selector(performCursorColorChange:)
				  name:@"CursorColorChange"
				object:nil];
	   
	   // Register as observer for link color changes.
	   [nc addObserver:self
			  selector:@selector(performLinkColorChange:)
				  name:@"LinkColorChange"
				object:nil];
	   
	   // Become observer of color changes for selected text.
	   [nc addObserver:self
			  selector:@selector(performSelectionColorChange:)
				  name:@"SelectionColorChange"
				object:nil];
	   
	   // Check if the user pastes content into SVTextView.
	   [nc addObserver:self
			  selector:@selector(handlePasteOperation:)
				  name:@"PasteNote"
				object:nil];
       
       // Check if the user enables or disables the OS X resume feature.
       [nc addObserver:self 
              selector:@selector(performResumeStateChange:)
                  name:@"ResumeStateChange"
                object:nil];
       
       // Observe changes of the overlay scroller knob style.
       [nc addObserver:self 
              selector:@selector(performScrollerStyleChange:)
                  name:@"ScrollerStyleChange"
                object:nil];
       
       // Get notified once AnsiLove finished rendering of ANSi sources.
       [nc addObserver:self 
              selector:@selector(setRenderingFinishedState:)
                  name:@"AnsiLoveFinishedRendering"
                object:nil];
       
       // Know when the editor needs to be locked or unlocked.
       [nc addObserver:self 
              selector:@selector(lockEditorFeatures:)
                  name:@"LockEditor"
                object:nil];
       
       [nc addObserver:self 
              selector:@selector(unlockEditorFeatures:)
                  name:@"UnlockEditor"
                object:nil];
       
       // Get notified when the user toggles hyperlink attributes in prefs.
       [nc addObserver:self
              selector:@selector(toggleHyperLinkAttributes:)
                  name:@"HyperLinkAttributeChange"
                object:nil];
       
       // Watch for AnsiLove related state changes.
       [nc addObserver:self
              selector:@selector(performAnsiLoveRenderChange:)
                  name:@"AnsiLoveRenderChange"
                object:nil];
       
       // Init the file information values.
       [SVFileInfoStrings sharedFileInfoStrings];
   }
	return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{	
	[super windowControllerDidLoadNib:aController];
	
    // Tracks the state whether the window has been dismissed or not.
    self.isInLimbo = NO;
    
	// Add our custom UI elements.
	[self createInterface];
	
	// Assign our attributed string.
	if ([self string] != nil) {
		[self.ansiTextView.textStorage setAttributedString:[self string]];
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// Apply the appearance attributes.
    [self prepareContent];
	
	// New documents get width / height from the values specified in preferences.
	if (self.contentString.length < 1 && self.isUsingAnsiLove == NO)
    {
		self.newContentWidth = [defaults floatForKey:@"newContentWidth"];
		self.newContentHeight = [defaults floatForKey:@"newContentWidth"];
        
        // Apply content hight and width for new documents.
        [self.mainWindow setContentSize:NSMakeSize(self.newContentWidth, self.newContentHeight)];
	}
	else {
        // The method name describes exactly what's happening here.
        [self autoSizeDocumentWindow];
    }
    
    // Get current file path as string.
    NSURL *currentURL = [self fileURL];
    self.sauceURLString = [currentURL path];
    
    // Let's see if the file contains a SAUCE record.
    ALSauceMachine *sauce = [ALSauceMachine new];
    [sauce readRecordFromFile:self.sauceURLString];
    
    // No record found? Update information labels to something useful.
    if (sauce.fileHasRecord == NO)
    {
        self.sauceID       = @"File does not contain a SAUCE record.";
        self.sauceVersion  = @"-";
        self.sauceTitle    = @"-";
        self.sauceAuthor   = @"-";
        self.sauceGroup    = @"-";
        self.sauceDate     = @"-";
        self.sauceDataType = sauce.dataType;
        self.sauceFileType = sauce.fileType;
        self.sauceTinfo1   = sauce.tinfo1;
        self.sauceTinfo2   = sauce.tinfo2;
        self.sauceTinfo3   = sauce.tinfo3;
        self.sauceTinfo4   = sauce.tinfo4;
        self.sauceComments = @"No comments were found.";
        self.sauceFlags    = sauce.flags;
    }
    else
    {
        // So the file has a SAUCE record. Do what has to be done.
        self.sauceID       = sauce.ID;
        self.sauceVersion  = sauce.version;
        self.sauceTitle    = sauce.title;
        self.sauceAuthor   = sauce.author;
        self.sauceGroup    = sauce.group;
        self.sauceDate     = sauce.date;
        self.sauceDataType = sauce.dataType;
        self.sauceFileType = sauce.fileType;
        self.sauceTinfo1   = sauce.tinfo1;
        self.sauceTinfo2   = sauce.tinfo2;
        self.sauceTinfo3   = sauce.tinfo3;
        self.sauceTinfo4   = sauce.tinfo4;
        if (sauce.fileHasComments == NO) {
            self.sauceComments = @"No comments were found.";
        }
        else {
            self.sauceComments = sauce.comments;
        }
        self.sauceFlags = sauce.flags;
    }

	// Set position of the document window.
	[NSApp activateIgnoringOtherApps:YES];
	if ([defaults boolForKey:@"docsOpenCentered"] == YES)
	{
		[aController.window center];
	}
	[aController.window makeKeyAndOrderFront:self];
}

# pragma mark -
# pragma mark NSDocument overrides


+ (BOOL)canConcurrentlyReadDocumentsOfType:(NSString *)typeName
{
    // Opens each document instance in a separate thread.
    return YES;
}

- (BOOL)shouldRunSavePanelWithAccessoryView
{
    // For now, we don't want any accessory view to be displayed.
    return NO;
}

- (BOOL)prepareSavePanel:(NSSavePanel *)savePanel
{
    // We override prepareSavePanel to customize it to our needs.
    if (self.isNewFile == NO)
    {
        // Hack to surpress adding .NFO to files with custom suffix.
        [savePanel setNameFieldStringValue:[self displayName]];
    }
    [savePanel setAllowsOtherFileTypes:YES];
    
    return YES;
}

# pragma mark -
# pragma mark UI specific

- (NSString *)windowNibName
{
    return @"SVBlockDrawDocument";
}

- (void)windowDidBecomeKey:(NSNotification *)notification 
{
	// Update the file information interface strings.
	[self updateFileInfoValues];
    
    // Disable or enable the save menu item.
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
    if (self.shouldDisableSave == YES) {
        [nc postNotificationName:@"DisableSave" object:self];
    }
    else {
        [nc postNotificationName:@"EnableSave" object:self];
    }
}

// Returns options for the fullscreen mode.
- (NSApplicationPresentationOptions)window:(NSWindow *)window
      willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)proposedOptions {
    return NSApplicationPresentationAutoHideMenuBar | NSApplicationPresentationHideDock | 
           NSApplicationPresentationFullScreen | NSApplicationPresentationAutoHideToolbar;
}

- (void)createInterface 
{
     // Should we disable the OS X window state restoration mechanism?
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults integerForKey:@"startupBehavior"] == 1) {
        [self.mainWindow setRestorable:NO];
    }
    
    [self.mainWindow setContentBorderThickness:25.0 forEdge:NSMinYEdge];
   
    // Embedded look for the encoding button.
    [[self.encodingButton cell] setBackgroundStyle:NSBackgroundStyleRaised];
    
    // Set the style of our overlay Scrollers.
    if ([defaults integerForKey:@"scrollerStyle"] == 0) {
        [self.hScroller setKnobStyle:NSScrollerKnobStyleLight];
        [self.vScroller setKnobStyle:NSScrollerKnobStyleLight];
    }
    else if ([defaults integerForKey:@"scrollerStyle"] == 1) {
        [self.hScroller setKnobStyle:NSScrollerKnobStyleDark];
        [self.vScroller setKnobStyle:NSScrollerKnobStyleDark];
    }
    else {
        [self.hScroller setKnobStyle:NSScrollerKnobStyleDefault];
        [self.vScroller setKnobStyle:NSScrollerKnobStyleDefault];
    }
    
    // Configure some behaviors of the file information popover.
    self.fileInfoPopover.behavior = NSPopoverBehaviorTransient;
    self.fileInfoPopover.animates = YES;
    //self.fileInfoPopover.appearance = NSPopoverAppearanceHUD;
    
    self.saucePopover.behavior = NSPopoverBehaviorTransient;
    self.saucePopover.animates = YES;
    //self.saucePopover.appearance = NSPopoverAppearanceHUD;
}


- (void)performResumeStateChange:(NSNotification *)note
{
    // Enables or disables the resume state.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch ([defaults integerForKey:@"startupBehavior"]) {
        case 0: {
            [self.mainWindow setRestorable:YES];
            break;
        }
        case 1: {
            [self.mainWindow setRestorable:NO];
        }
        default: {
            break;
        }
    }
}

- (void)performScrollerStyleChange:(NSNotification *)note
{
    // Change scroller style to the specified value.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch ([defaults integerForKey:@"scrollerStyle"]) {
        case 0: {
            [self.hScroller setKnobStyle:NSScrollerKnobStyleLight];
            [self.vScroller setKnobStyle:NSScrollerKnobStyleLight];
            break;
        }
        case 1: {
            [self.hScroller setKnobStyle:NSScrollerKnobStyleDark];
            [self.vScroller setKnobStyle:NSScrollerKnobStyleDark];
        }
        case 2: {
            [self.hScroller setKnobStyle:NSScrollerKnobStyleDefault];
            [self.vScroller setKnobStyle:NSScrollerKnobStyleDefault];
        }
        default: {
            break;
        }
    }
}

- (void)windowWillClose:(NSNotification *)notification
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // In case this is an ANSi file, delete the cached PNG when the window closes.
    if (self.isUsingAnsiLove == YES) {
        if ([fileManager fileExistsAtPath:self.ansiCacheFile]) {
            [fileManager removeItemAtPath:self.ansiCacheFile error:nil];
        }
    }
    
    // In case this is an ANSi file, delete the cached PNG when the window closes.
    if (self.isUsingAnsiLove == YES) {
        if ([fileManager fileExistsAtPath:self.retinaCacheFile]) {
            [fileManager removeItemAtPath:self.retinaCacheFile error:nil];
        }
    }
    
    // Also wipe social image cache files.
    if ([fileManager fileExistsAtPath:self.twitterCacheFile]) {
        [fileManager removeItemAtPath:self.twitterCacheFile error:nil];
    }
    if ([fileManager fileExistsAtPath:self.facebookCacheFile]) {
        [fileManager removeItemAtPath:self.facebookCacheFile error:nil];
    }
    
    // Finally nuke export cache files
    if ([fileManager fileExistsAtPath:self.exportCacheFile]) {
        [fileManager removeItemAtPath:self.exportCacheFile error:nil];
    }
    
    // Keep in mind we have been dismissed already.
    self.isInLimbo = YES;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"DisableSave" object:self];
}

- (void)autoSizeDocumentWindow
{
    // We need the textstorage size for auto-sizing the document window.
	NSSize myTextSize = self.ansiTextView.textStorage.size;
    
    // Calculate the new content dimensions, consider the toolbar (if visible).
    CGFloat toolbarHeight = 0;
    if ([self.appToolbar isVisible])
    {
        NSRect windowFrame;
        windowFrame = [NSWindow contentRectForFrameRect:self.mainWindow.frame
                                              styleMask:self.mainWindow.styleMask];
        toolbarHeight = NSHeight(windowFrame) - NSHeight([[self.mainWindow contentView] frame]);
    }
    // Check if the user enabled width auto-sizing.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"autoSizeWidth"] == YES)
    {
        // In case the content is an AnsiLove image, caluculate the width based on it...
        if (self.isUsingAnsiLove == YES) {
            self.newContentWidth = self.renderedAnsiImage.size.width + ansiHelperMargin;
        }
        else {
            // ...if not, calculate width via the textstorage.
            self.newContentWidth = myTextSize.width + stdNSTextViewMargin;
        }
        
        // Prevent autosizing from programatically resizing smaller than the window's minSize.
        if (self.newContentWidth <= self.mainWindow.minSize.width) {
            self.newContentWidth = self.mainWindow.minSize.width;
        }
    }
    else {
        self.newContentWidth = [self.mainWindow frame].size.width;
    }
    // Determine if height auto-sizing is enabled.
    if ([defaults boolForKey:@"autoSizeHeight"] == YES)
    {
        if (self.isUsingAnsiLove == YES) {
            // Use the AnsiLove image to calculate height, provided we got one in our textView...
            self.newContentHeight = self.renderedAnsiImage.size.height + [self titlebarHeight] + toolbarHeight;
        }
        else {
            // ...and if not: use the textstorage again.
            self.newContentHeight = myTextSize.height + [self titlebarHeight] + toolbarHeight;
        }
        
        // Again prevent auto-sizing from resizing under the minSize value.
        if (self.newContentHeight <= self.mainWindow.minSize.height) {
            self.newContentHeight = self.mainWindow.minSize.height;
        }
    }
    else {
        self.newContentHeight = self.mainWindow.frame.size.height - [self titlebarHeight] - toolbarHeight;
    }
    // Finally resize the document window based on either the caluclation or the preferences.
    [self.mainWindow setContentSize:NSMakeSize(self.newContentWidth, self.newContentHeight)];
}

# pragma mark -
# pragma mark tools palette

- (IBAction)showFileInfoPopover:(id)sender
{
    [self.fileInfoPopover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
}

- (IBAction)exportAsImage:(id)sender
{
    if (self.isNewFile == YES)
    {
        // Run informal sheet so we know why PNG export is not possible right now.
        NSAlert *exportCanceledAlert =
		[NSAlert alertWithMessageText:@"PNG image export canceled"
						defaultButton:@"OK"
					  alternateButton:nil
						  otherButton:nil
		    informativeTextWithFormat:@"You need to save your current changes before the "
                                      @"built-in parser is able to export this document as "
                                      @"PNG image."];
		
		[exportCanceledAlert setAlertStyle:NSInformationalAlertStyle];
		[exportCanceledAlert beginSheetModalForWindow:self.mainWindow
                                      modalDelegate:self
                                     didEndSelector:NULL
                                        contextInfo:NULL];
        // Now get outta here.
        return;
    }
    
    // Get the current file URL and convert it to an UNIX path.
    NSURL *currentURL = [self fileURL];
    self.alURLString = [currentURL path];
    
    // Get the currrent file name without any path informations.
    NSString *pureFileName = [self.alURLString lastPathComponent];
    NSString *fileNameWithoutSuffix = [pureFileName stringByDeletingPathExtension];
    
    // Generate cache file name and path.
    self.exportCacheFile = [NSString stringWithFormat:
                             @"~/Library/Application Support/Ascension/%@.png", pureFileName];

    // Expand tilde in cache file path.
    self.exportCacheFile = [self.exportCacheFile stringByExpandingTildeInPath];

    // Create string we can pass as outputfile flag.
    self.alOutputString = [NSString stringWithFormat:
                           @"~/Library/Application Support/Ascension/%@", pureFileName];

    self.alOutputString = [self.alOutputString stringByExpandingTildeInPath];

    // The selected font and encoding could differ from preferences.
    switch (self.encButtonIndex)
    {
        case xDosCP437: {
            // Lets find out if that is the case.
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults integerForKey:@"ansiLoveFont"] == al80x25) {
                self.alFont = @"80x25";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alTerminus) {
                self.alFont = @"terminus";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == al80x50) {
                self.alFont = @"80x50";
            }
            else {
                // No CP437 font selected in preferences, work with defaults.
                self.alFont = @"80x25";
            }
            break;
        }
        case xDosCP775: {
            // Baltic Rim
            self.alFont = @"baltic";
            break;
        }
        case xDosCP855: {
            // Cyrillic (Slavic)
            self.alFont = @"cyrillic";
            break;
        }
        case xDosCP863: {
            // French-Canadian
            self.alFont = @"french-canadian";
            break;
        }
        case xDosCP737: {
            // Greek
            self.alFont = @"greek";
            break;
        }
        case xDosCP869: {
            // Greek 2
            self.alFont = @"greek-869";
            break;
        }
        case xDosCP862: {
            // Hebrew
            self.alFont = @"hebrew";
            break;
        }
        case xDosCP861: {
            // Icelandic
            self.alFont = @"icelandic";
            break;
        }
        case xDosCP850: {
            // Latin 1
            self.alFont = @"latin1";
            break;
        }
        case xDosCP852: {
            // Latin 2
            self.alFont = @"latin2";
            break;
        }
        case xDosCP865: {
            // Nordic
            self.alFont = @"nordic";
            break;
        }
        case xDosCP860: {
            // Portuguese
            self.alFont = @"portuguese";
            break;
        }
        case xDosCP866: {
            // Cyrillic (Russian)
            self.alFont = @"russian";
            break;
        }
        case xDosCP857: {
            // Turkish
            self.alFont = @"turkish";
            break;
        }
        case xAmiga: {
            // Amiga Latin 1 fonts also come in many flavors the user possibly selected.
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults integerForKey:@"ansiLoveFont"] == alTopaz) {
                self.alFont = @"topaz";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alTopazPlus) {
                self.alFont = @"topaz+";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alTopaz500) {
                self.alFont = @"topaz500";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alTopaz500Plus) {
                self.alFont = @"topaz500+";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alMoSoul) {
                self.alFont = @"mosoul";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alPotNoodle) {
                self.alFont = @"pot-noodle";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alMicroKnight) {
                self.alFont = @"microknight";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alMicroKnightPlus) {
                self.alFont = @"microknight+";
            }
            else {
                // No Amiga font defined in prefs? Fine. Lets render with Topaz then.
                self.alFont = @"topaz";
            }
            break;
        }
        default: {
            break;
        }
    }
    // Don't use the AnsiLove font either for ASCII nor text files.
    if (self.isUsingAnsiLove == NO) {
        self.alFont = @"80x25";
    }

    // Call AnsiLove and generate the rendered image.
    [self.ansiGen renderAnsiFile:self.alURLString
                      outputFile:self.alOutputString
                            font:self.alFont
                            bits:self.alBits
                       iceColors:self.alIceColors
                         columns:self.alColumns
                          retina:NO];

    // Wait for AnsiLove.framework to finish rendering.
    while (self.isRendered == NO) {
        [NSThread sleepForTimeInterval:0.1];
    }

    // Create an export panel for the user to verify the operation.
    self.exportPanel = [NSSavePanel savePanel];

    // Set URL and name field string value.
    NSString *workingDirString = [[[self fileURL] path] stringByDeletingLastPathComponent];
    NSURL *workingDirectory = [NSURL fileURLWithPath:workingDirString];
    [self.exportPanel setDirectoryURL:workingDirectory];
    [self.exportPanel setNameFieldStringValue:[NSString stringWithFormat:@"%@.png", fileNameWithoutSuffix]];

    // Register PNG as only legitimate suffix.
    NSArray *reqOutTypes = [NSArray arrayWithObjects:@"png", nil];
    [self.exportPanel setAllowedFileTypes:reqOutTypes];
    [self.exportPanel setAllowsOtherFileTypes:NO];

    // Let's optionally see the PNG extension in exportPanel.
    [self.exportPanel setCanSelectHiddenExtension:YES];

    [self.exportPanel beginSheetModalForWindow:self.mainWindow completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton)
        {
            // Get the exportPanel's URL as path.
            self.exportURLString = [[self.exportPanel URL] path];

            // Copy operation of the already existing export cache file.
            NSFileManager *fileManager = [NSFileManager defaultManager];

            if ([fileManager fileExistsAtPath:self.exportCacheFile]) {
                [fileManager copyItemAtPath:self.exportCacheFile toPath:self.exportURLString error:nil];
            }
        }
    }];
}

- (IBAction)showSauceRecord:(id)sender
{
    [self.saucePopover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
}

- (IBAction)postOnTwitter:(id)sender
{
    if (self.isNewFile == YES)
    {
        // The user should know why we can't tweet a new document.
        NSAlert *tweetCanceledAlert =
		[NSAlert alertWithMessageText:@"Tweet canceled"
						defaultButton:@"OK"
					  alternateButton:nil
						  otherButton:nil
		    informativeTextWithFormat:@"You need to save your current changes before the "
                                      @"built-in parser is able to add this document as "
                                      @"PNG image attachment to your tweet."];

		[tweetCanceledAlert setAlertStyle:NSInformationalAlertStyle];
		[tweetCanceledAlert beginSheetModalForWindow:self.mainWindow
                                        modalDelegate:self
                                       didEndSelector:NULL
                                          contextInfo:NULL];
        // Now get outta here.
        return;
    }

    // Get the current file URL and convert it to an UNIX path.
    NSURL *currentURL = [self fileURL];
    self.alURLString = [currentURL path];

    // Get the currrent file name without any path informations.
    NSString *pureFileName = [self.alURLString lastPathComponent];

    // Generate cache file name and path.
    self.twitterCacheFile = [NSString stringWithFormat:
                             @"~/Library/Application Support/Ascension/%@.png", pureFileName];

    // Expand tilde in cache file path.
    self.twitterCacheFile = [self.twitterCacheFile stringByExpandingTildeInPath];

    // Create string we can pass as outputfile flag.
    self.alOutputString = [NSString stringWithFormat:
                           @"~/Library/Application Support/Ascension/%@", pureFileName];

    self.alOutputString = [self.alOutputString stringByExpandingTildeInPath];

    // Once again, we mess around with encoding overrides.
    // The selected font and encoding could differ from preferences.
    switch (self.encButtonIndex)
	{
		case xDosCP437: {
            // Lets find out if that is the case.
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults integerForKey:@"ansiLoveFont"] == al80x25) {
                self.alFont = @"80x25";
			}
            else if ([defaults integerForKey:@"ansiLoveFont"] == alTerminus) {
                self.alFont = @"terminus";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == al80x50) {
                self.alFont = @"80x50";
            }
            else {
                // No CP437 font selected in preferences, work with defaults.
                self.alFont = @"80x25";
            }
			break;
		}
        case xDosCP775: {
            // Baltic Rim
			self.alFont = @"baltic";
			break;
		}
        case xDosCP855: {
            // Cyrillic (Slavic)
			self.alFont = @"cyrillic";
			break;
		}
        case xDosCP863: {
            // French-Canadian
			self.alFont = @"french-canadian";
			break;
		}
        case xDosCP737: {
            // Greek
			self.alFont = @"greek";
			break;
		}
        case xDosCP869: {
            // Greek 2
			self.alFont = @"greek-869";
			break;
		}
        case xDosCP862: {
            // Hebrew
			self.alFont = @"hebrew";
			break;
		}
        case xDosCP861: {
            // Icelandic
            self.alFont = @"icelandic";
			break;
		}
        case xDosCP850: {
            // Latin 1
			self.alFont = @"latin1";
			break;
		}
        case xDosCP852: {
            // Latin 2
			self.alFont = @"latin2";
			break;
		}
        case xDosCP865: {
            // Nordic
			self.alFont = @"nordic";
			break;
		}
        case xDosCP860: {
            // Portuguese
			self.alFont = @"portuguese";
			break;
		}
		case xDosCP866: {
            // Cyrillic (Russian)
			self.alFont = @"russian";
			break;
		}
        case xDosCP857: {
            // Turkish
			self.alFont = @"turkish";
			break;
		}
        case xAmiga: {
            // Amiga Latin 1 fonts also come in many flavors the user possibly selected.
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults integerForKey:@"ansiLoveFont"] == alTopaz) {
                self.alFont = @"topaz";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alTopazPlus) {
                self.alFont = @"topaz+";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alTopaz500) {
                self.alFont = @"topaz500";
            }
			else if ([defaults integerForKey:@"ansiLoveFont"] == alTopaz500Plus) {
                self.alFont = @"topaz500+";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alMoSoul) {
                self.alFont = @"mosoul";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alPotNoodle) {
                self.alFont = @"pot-noodle";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alMicroKnight) {
                self.alFont = @"microknight";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alMicroKnightPlus) {
                self.alFont = @"microknight+";
            }
            else {
                // No Amiga font defined in prefs? Fine. Lets render with Topaz then.
                self.alFont = @"topaz";
            }
			break;
		}
		default: {
			break;
		}
	}
    // Don't use the DOS font either for ASCII nor text files.
    if (self.isUsingAnsiLove == NO) {
        self.alFont = @"80x25";
    }

    // Call AnsiLove and generate the rendered image.
    [self.ansiGen renderAnsiFile:self.alURLString
                      outputFile:self.alOutputString
                            font:self.alFont
                            bits:self.alBits
                       iceColors:self.alIceColors
                         columns:self.alColumns
                          retina:NO];

    // Wait for AnsiLove.framework to finish rendering.
    while (self.isRendered == NO) {
        [NSThread sleepForTimeInterval:0.1];
    }

    // Grab the rendered image and init an NSImage instance for it.
    self.renderedTwitterImage = [[NSImage alloc] initWithContentsOfFile:self.twitterCacheFile];

    // Finally post image on Twitter, use file name as Tweet text.
    NSSharingService *service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
    [service performWithItems:[NSArray arrayWithObjects:pureFileName,self.renderedTwitterImage, nil]];
}

- (IBAction)postOnFacebook:(id)sender
{
    if (self.isNewFile == YES)
    {
        // The user should know why we can't post a new document.
        NSAlert *fbCanceledAlert =
        [NSAlert alertWithMessageText:@"Facebook post canceled"
                        defaultButton:@"OK"
                      alternateButton:nil
                          otherButton:nil
            informativeTextWithFormat:@"You need to save your current changes before the "
         @"built-in parser is able to add this document as "
         @"PNG image attachment to your Facebook post."];
        
        [fbCanceledAlert setAlertStyle:NSInformationalAlertStyle];
        [fbCanceledAlert beginSheetModalForWindow:self.mainWindow
                                       modalDelegate:self
                                      didEndSelector:NULL
                                         contextInfo:NULL];
        // Now get outta here.
        return;
    }
    
    // Get the current file URL and convert it to an UNIX path.
    NSURL *currentURL = [self fileURL];
    self.alURLString = [currentURL path];
    
    // Get the currrent file name without any path informations.
    NSString *pureFileName = [self.alURLString lastPathComponent];
    
    // Generate cache file name and path.
    self.facebookCacheFile = [NSString stringWithFormat:
                             @"~/Library/Application Support/Ascension/%@.png", pureFileName];
    
    // Expand tilde in cache file path.
    self.facebookCacheFile = [self.facebookCacheFile stringByExpandingTildeInPath];
    
    // Create string we can pass as outputfile flag.
    self.alOutputString = [NSString stringWithFormat:
                           @"~/Library/Application Support/Ascension/%@", pureFileName];
    
    self.alOutputString = [self.alOutputString stringByExpandingTildeInPath];
    
    // Once again, we mess around with encoding overrides.
    // The selected font and encoding could differ from preferences.
    switch (self.encButtonIndex)
    {
        case xDosCP437: {
            // Lets find out if that is the case.
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults integerForKey:@"ansiLoveFont"] == al80x25) {
                self.alFont = @"80x25";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alTerminus) {
                self.alFont = @"terminus";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == al80x50) {
                self.alFont = @"80x50";
            }
            else {
                // No CP437 font selected in preferences, work with defaults.
                self.alFont = @"80x25";
            }
            break;
        }
        case xDosCP775: {
            // Baltic Rim
            self.alFont = @"baltic";
            break;
        }
        case xDosCP855: {
            // Cyrillic (Slavic)
            self.alFont = @"cyrillic";
            break;
        }
        case xDosCP863: {
            // French-Canadian
            self.alFont = @"french-canadian";
            break;
        }
        case xDosCP737: {
            // Greek
            self.alFont = @"greek";
            break;
        }
        case xDosCP869: {
            // Greek 2
            self.alFont = @"greek-869";
            break;
        }
        case xDosCP862: {
            // Hebrew
            self.alFont = @"hebrew";
            break;
        }
        case xDosCP861: {
            // Icelandic
            self.alFont = @"icelandic";
            break;
        }
        case xDosCP850: {
            // Latin 1
            self.alFont = @"latin1";
            break;
        }
        case xDosCP852: {
            // Latin 2
            self.alFont = @"latin2";
            break;
        }
        case xDosCP865: {
            // Nordic
            self.alFont = @"nordic";
            break;
        }
        case xDosCP860: {
            // Portuguese
            self.alFont = @"portuguese";
            break;
        }
        case xDosCP866: {
            // Cyrillic (Russian)
            self.alFont = @"russian";
            break;
        }
        case xDosCP857: {
            // Turkish
            self.alFont = @"turkish";
            break;
        }
        case xAmiga: {
            // Amiga Latin 1 fonts also come in many flavors the user possibly selected.
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults integerForKey:@"ansiLoveFont"] == alTopaz) {
                self.alFont = @"topaz";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alTopazPlus) {
                self.alFont = @"topaz+";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alTopaz500) {
                self.alFont = @"topaz500";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alTopaz500Plus) {
                self.alFont = @"topaz500+";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alMoSoul) {
                self.alFont = @"mosoul";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alPotNoodle) {
                self.alFont = @"pot-noodle";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alMicroKnight) {
                self.alFont = @"microknight";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alMicroKnightPlus) {
                self.alFont = @"microknight+";
            }
            else {
                // No Amiga font defined in prefs? Fine. Lets render with Topaz then.
                self.alFont = @"topaz";
            }
            break;
        }
        default: {
            break;
        }
    }
    // Don't use the DOS font either for ASCII nor text files.
    if (self.isUsingAnsiLove == NO) {
        self.alFont = @"80x25";
    }
    
    // Call AnsiLove and generate the rendered image.
    [self.ansiGen renderAnsiFile:self.alURLString
                      outputFile:self.alOutputString
                            font:self.alFont
                            bits:self.alBits
                       iceColors:self.alIceColors
                         columns:self.alColumns
                          retina:NO];
    
    // Wait for AnsiLove.framework to finish rendering.
    while (self.isRendered == NO) {
        [NSThread sleepForTimeInterval:0.1];
    }
    
    // Grab the rendered image and init an NSImage instance for it.
    self.renderedFacebookImage = [[NSImage alloc] initWithContentsOfFile:self.facebookCacheFile];
    
    // Finally post image on Facebook, use file name as post text.
    NSSharingService *service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnFacebook];
    [service performWithItems:[NSArray arrayWithObjects:pureFileName,self.renderedFacebookImage, nil]];
}


# pragma mark -
# pragma mark content appearance

- (void)disableEditing
{
    [self.ansiTextView setEditable:NO];

    // Only applies to ANSi files as they contain rendered images and no selectable text.
    if (self.isUsingAnsiLove == YES) {
        [self.ansiTextView setSelectable:NO];
    }
}

- (void)enableEditing
{
    // Editing is not supported for types we rendered with AnsiLove.
    if (self.isUsingAnsiLove == NO) {
        [self.ansiTextView setEditable:YES];
        [self.ansiTextView setSelectable:YES];
    }
}

- (void)lockEditorFeatures:(NSNotification *)note
{
    [self disableEditing];

    // Inform app delegate to disable save menu item.
    self.shouldDisableSave = YES;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"DisableSave" object:self];
}

- (void)unlockEditorFeatures:(NSNotification *)note
{
    [self enableEditing];

    if (self.isUsingAnsiLove == NO)
    {
        // Inform app delegate to enable save menu item.
        self.shouldDisableSave = NO;
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"EnableSave" object:self];
    }
    else {
        self.shouldDisableSave = YES;
    }
}

- (void)prepareContent
{
	// If this is no ANSi source file, prepare the textual content.
    if (self.isUsingAnsiLove == NO) {
        [self applyParagraphStyle];
        [self performLinkification];
    }
    else {
        // So this is an ANSi source file? We can't use themes and custom colors.
        [self.ansiTextView setBackgroundColor:[NSColor blackColor]];
        [self.ansiScrollView setBackgroundColor:[NSColor blackColor]];

        // Also disable editing anyway.
        [self disableEditing];

        self.shouldDisableSave = YES;
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"DisableSave" object:self];

        // Then, get the hell out.
        return;
    }
    // Let's mess around with ASCII themes.
    [self applyThemeColors];

	// Set the text color.
	[self.ansiTextView setTextColor:self.fontColor];

	// Apply background color.
	[self.ansiTextView setBackgroundColor:self.backgroundColor];
    [self.ansiScrollView setBackgroundColor:self.backgroundColor];

	// Set the cursor color.
	[self.ansiTextView setInsertionPointColor:self.cursorColor];

	// Specify the style for all contained links.
	[self.ansiTextView setLinkTextAttributes:self.linkAttributes];

	// Set the color for selected and marked text.
	[self.ansiTextView setSelectedTextAttributes:self.selectionAttributes];

    // Definition of user defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Now find out if viewer mode is enabled?
    if ([defaults boolForKey:@"viewerMode"] == YES) {
        [self disableEditing];

        // Inform app delegate to disable save menu item.
        self.shouldDisableSave = YES;
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"DisableSave" object:self];
    }
}

- (void)applyThemeColors
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	// Read font color data from user defaults.
	NSData *fontColorData = [defaults objectForKey:@"fontColor"];
	self.fontColor = [NSUnarchiver unarchiveObjectWithData:fontColorData];

	// Restore background color data from user defaults.
	NSData *bgrndColorData = [defaults objectForKey:@"backgroundColor"];
	self.backgroundColor = [NSUnarchiver unarchiveObjectWithData:bgrndColorData];

	// Load cursor color data from the user defaults.
	NSData *cursorColorData = [defaults objectForKey:@"cursorColor"];
	self.cursorColor = [NSUnarchiver unarchiveObjectWithData:cursorColorData];

	// Get the link color data from user defaults.
	NSData *linkColorData = [defaults objectForKey:@"linkColor"];
	self.linkColor = [NSUnarchiver unarchiveObjectWithData:linkColorData];

	// Restore color data for selected text from user defaults.
	NSData *selectionColorData = [defaults objectForKey:@"selectionColor"];
	self.selectionColor = [NSUnarchiver unarchiveObjectWithData:selectionColorData];
}

- (void)applyParagraphStyle
{
	// Instance variable declaration.
	NSFont *asciiFont;
	NSMutableParagraphStyle *customParagraph;
	NSDictionary *attributes;
    NSInteger intFontSize;
    CGFloat pitchValue;

	// Read font properties from preferences.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.fontName = [defaults stringForKey:@"fontName"];
    self.fontSize = [defaults floatForKey:@"fontSize"];

    // Set the font.
	asciiFont = [NSFont fontWithName:self.fontName size:self.fontSize];

    // Get current font size as integer.
    intFontSize = (NSInteger)self.fontSize;

    // Figure out the pitch value we should apply.
    switch (intFontSize)
    {
        case 16: {
            pitchValue = 8.0;
            break;
        }
        case 20: {
            pitchValue = 10.0;
            break;
        }
        default: {
            pitchValue = 8.0;
            break;
        }
    }

    // Create dictionary with fixed width font attribute.
    NSDictionary *pitchDict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithFloat:pitchValue], NSFontFixedAdvanceAttribute, nil];

    // Grab font descriptor from current font.
    NSFontDescriptor *desc = [asciiFont fontDescriptor];

    // Add fixed pitch attributes to font descriptor.
    desc = [desc fontDescriptorByAddingAttributes:pitchDict];

    // Apply fixed pitch changes to current font.
    asciiFont = [NSFont fontWithDescriptor:desc size:[asciiFont pointSize]];

	// Set line height identical to font size.
	customParagraph = [NSMutableParagraphStyle new];
	[customParagraph setLineSpacing:0];
	[customParagraph setMinimumLineHeight:self.fontSize];
	[customParagraph setMaximumLineHeight:self.fontSize];

	// Set our custom paragraph as default paragraph style.
	[self.ansiTextView setDefaultParagraphStyle:customParagraph];
    [self.ansiTextView setFont:asciiFont];

	// Apply our atttributes.
	attributes = [NSDictionary dictionaryWithObjectsAndKeys:asciiFont,
				  NSFontAttributeName, customParagraph, NSParagraphStyleAttributeName ,nil];
	 [self.ansiTextView.textStorage setAttributes:attributes
											  range:NSMakeRange(0, self.ansiTextView.textStorage.length)];
}

- (void)performLinkification
{
    // When highlighting hyperlinks is turned off in preferences...
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"highlightAsciiHyperLinks"] == NO)
    {
        // ...prevent NSTextView from automatically detecting hyperlinks
        [self.ansiTextView setAutomaticLinkDetectionEnabled:NO];

        // ... and peform an early return.
        return;
    }

    // Save insertion point / cursor position.
    NSInteger insertionPoint = [[self.ansiTextView.selectedRanges objectAtIndex:0] rangeValue].location;

	// Analyze the text storage and return a linkified string.
	AHHyperlinkScanner *scanner =
	[AHHyperlinkScanner hyperlinkScannerWithAttributedString:self.ansiTextView.textStorage];
	[self.ansiTextView.textStorage setAttributedString:[scanner linkifiedString]];

    // Reapply the cursor position we stored before.
    self.ansiTextView.selectedRange = NSMakeRange(insertionPoint, 0);
}

- (void)toggleHyperLinkAttributes:(NSNotification *)note
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([defaults boolForKey:@"highlightAsciiHyperLinks"] == NO)
    {
        // Create range based on the textStorage length.
        NSRange area = NSMakeRange(0, self.ansiTextView.textStorage.length);

        // Now remove already highlighted hyperlinks.
        [self.ansiTextView.textStorage removeAttribute:NSLinkAttributeName range:area];

        // Finally, we don't want NSTextView to automatically detect hyperlinks.
        [self.ansiTextView setAutomaticLinkDetectionEnabled:NO];
    }
    else {
        [self.ansiTextView setAutomaticLinkDetectionEnabled:YES];
        [self performLinkification];
    }
}

- (void)handlePasteOperation:(NSNotification *)note
{
	// Linkify hyperlinks in the pasted content, only happens if highlighting links is enabled.
	[self performSelector:@selector(performLinkification) withObject:nil afterDelay:0.5];
}

- (CGFloat)titlebarHeight
{
	// Return height of the window title bar.
    NSRect frame = NSMakeRect (0, 0, 100, 100);

    NSRect contentRect;
    contentRect = [NSWindow contentRectForFrameRect: frame
										  styleMask: NSTitledWindowMask];

    return (frame.size.height - contentRect.size.height);
}

- (NSRect)screenRect
{
    // Return the visible screen frame.
	NSRect screenRect = [[NSScreen mainScreen] frame];

    return screenRect;
}

- (void)performFontChange:(NSNotification *)note
{
    if (self.isUsingAnsiLove == NO) {
        [self prepareContent];
        [self autoSizeDocumentWindow];
    }
}

- (void)performFontColorChange:(NSNotification *)note
{
    if (self.isUsingAnsiLove == NO) {
        NSColor *fontColorValue = [[note userInfo] objectForKey:@"fontColorValue"];
        [self.ansiTextView setTextColor:fontColorValue];
    }
}

- (void)performBgrndColorChange:(NSNotification *)note
{
    if (self.isUsingAnsiLove == NO) {
         NSColor *bgrndColorValue = [[note userInfo] objectForKey:@"bgrndColorValue"];
         [self.ansiTextView setBackgroundColor:bgrndColorValue];
         [self.ansiScrollView setBackgroundColor:bgrndColorValue];
     }
}

- (void)performCursorColorChange:(NSNotification *)note
{
    if (self.isUsingAnsiLove == NO) {
        NSColor *cursorColorValue = [[note userInfo] objectForKey:@"cursorColorValue"];
        [self.ansiTextView setInsertionPointColor:cursorColorValue];
    }
}

- (void)performLinkColorChange:(NSNotification *)note
{
    if (self.isUsingAnsiLove == NO) {
        self.linkColor = [[note userInfo] objectForKey:@"linkColorValue"];
        [self.ansiTextView setLinkTextAttributes:self.linkAttributes];
    }
}

- (void)performSelectionColorChange:(NSNotification *)note
{
    if (self.isUsingAnsiLove == NO) {
        self.selectionColor = [[note userInfo] objectForKey:@"selectionColorValue"];
        [self.ansiTextView setSelectedTextAttributes:self.selectionAttributes];
    }
}

- (NSDictionary *)linkAttributes
{
	// The attributes for embedded hyperlinks.
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSCursor pointingHandCursor], NSCursorAttributeName,
			[NSNumber numberWithInt:NSUnderlineStyleSingle], NSUnderlineStyleAttributeName,
			self.linkColor, NSForegroundColorAttributeName, nil];
}

- (NSDictionary *)selectionAttributes
{
	// Attribute dicitionary for selections.
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.selectionColor, NSBackgroundColorAttributeName, nil];
}

# pragma mark -
# pragma mark getter and setter

- (NSMutableAttributedString *)string
{
	// Returns the contentstring.
	return self.contentString;
}

- (void)setString:(NSMutableAttributedString *)newValue {
	// Performs a copy operation.
    if (self.contentString != newValue) {
        self.contentString = [newValue copy];
    }
}

# pragma mark -
# pragma mark delegates

- (void)textDidChange:(NSNotification *)notification
{
    [self setString:self.ansiTextView.textStorage];
}

# pragma mark -
# pragma mark data and encoding

- (NSFileWrapper *)fileWrapperOfType:(NSString *)pTypeName
							   error:(NSError **)pOutError
{
	// Launch the output file wrapper based on the document UTI.
	if ([pTypeName compare:@"com.byteproject.ascension.diz"] == NSOrderedSame)
    {
		return [self ansiArtFileWrapperWithError:pOutError];
	}
	else if ([pTypeName compare:@"com.byteproject.ascension.nfo"] == NSOrderedSame)
    {
		return [self ansiArtFileWrapperWithError:pOutError];
	}
    else if ([pTypeName compare:@"com.byteproject.ascension.asc"] == NSOrderedSame)
    {
		return [self ansiArtFileWrapperWithError:pOutError];
	}
    else if ([pTypeName compare:@"com.byteproject.ascension.ans"] == NSOrderedSame)
    {
        return [self ansiArtFileWrapperWithError:pOutError];
    }
    else if ([pTypeName compare:@"com.byteproject.ascension.idf"] == NSOrderedSame)
    {
        return [self ansiArtFileWrapperWithError:pOutError];
    }
    else if ([pTypeName compare:@"com.byteproject.ascension.pcb"] == NSOrderedSame)
    {
        return [self ansiArtFileWrapperWithError:pOutError];
    }
    else if ([pTypeName compare:@"com.byteproject.ascension.xb"] == NSOrderedSame)
    {
        return [self ansiArtFileWrapperWithError:pOutError];
    }
    else if ([pTypeName compare:@"com.amiga.adf-archive"] == NSOrderedSame)
    {
        return [self ansiArtFileWrapperWithError:pOutError];
    }
    else if ([pTypeName compare:@"com.apple.macbinary-archive"] == NSOrderedSame)
    {
        return [self ansiArtFileWrapperWithError:pOutError];
    }
    else if ([pTypeName compare:@"com.byteproject.ascension.tnd"] == NSOrderedSame)
    {
        return [self ansiArtFileWrapperWithError:pOutError];
    }
    else {
        return [self textFileWrapperWithError:pOutError];
    }
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)pFileWrapper
					 ofType:(NSString *)pTypeName
					  error:(NSError **)pOutError
{
	// Determine file type and launch the input file wrapper, also set informal bool values.
	if ([pFileWrapper isRegularFile] && ([pTypeName compare:@"com.byteproject.ascension.diz"] == NSOrderedSame))
    {
        // Sometimes, even DIZ files contain escapes sequences. Check so we can enable the correct renderer.
		NSData *cp437Data = [pFileWrapper regularFileContents];

        // Now look up the proper encoding and init the data as NSString.
        [self switchASCIIEncoding];
        NSString *cp437String = [[NSString alloc]initWithData:cp437Data encoding:self.nfoDizEncoding];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        // Search for any ANSi escape sequences in our strin, use AnsiLove anway if user-defined.
        if ([cp437String rangeOfString:ansiEscapeSeq].location != NSNotFound ||
            [defaults boolForKey:@"enableAnsiLoveForASCII"] == YES)
        {
            // Obiously this string contains ANSi escape sequences, we need to use the .ANS file wrapper.
            self.isNewFile = NO;
            self.isUsingAnsiLove = YES;
            self.isAnsFile = YES;
            return [self ansiArtReadFileWrapper:pFileWrapper error:pOutError];
        }
        else {
            // Everything is fine, what we got here is a .DIZ file.
            self.isNewFile = NO;
            return [self asciiArtReadFileWrapper:pFileWrapper error:pOutError];
        }
	}
	else if ([pFileWrapper isRegularFile] && ([pTypeName compare:@"com.byteproject.ascension.nfo"] == NSOrderedSame))
    {
        // We need to check if the file really is a .NFO or maybe a masked .ANS file with .NFO extension.
        // I had to learn it's not uncommon, so this is the only way for accurate rendering results.
        NSData *cp437Data = [pFileWrapper regularFileContents];

        // Now look up the proper encoding and init the data as NSString.
        [self switchASCIIEncoding];
        NSString *cp437String = [[NSString alloc]initWithData:cp437Data encoding:self.nfoDizEncoding];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        // Search for any ANSi escape sequences in our string, use AnsiLove anyway if user-defined.
        if ([cp437String rangeOfString:ansiEscapeSeq].location != NSNotFound ||
            [defaults boolForKey:@"enableAnsiLoveForASCII"] == YES)
        {
            // Obiously this string contains ANSi escape sequences, we need to use the .ANS file wrapper.
            self.isNewFile = NO;
            self.isUsingAnsiLove = YES;
            self.isAnsFile = YES;
            return [self ansiArtReadFileWrapper:pFileWrapper error:pOutError];
        }
        else {
            // Everything is fine, what we got here is a .NFO file.
            self.isNewFile = NO;
            return [self asciiArtReadFileWrapper:pFileWrapper error:pOutError];
        }
	}
	else if ([pFileWrapper isRegularFile] && ([pTypeName compare:@"com.byteproject.ascension.asc"] == NSOrderedSame))
    {
		// Let's check if the file really is an .ASC or maybe a masked .ANS file with .ASC extension.
        NSData *cp437Data = [pFileWrapper regularFileContents];

        // Now look up the proper encoding and init the data as NSString.
        [self switchASCIIEncoding];
        NSString *cp437String = [[NSString alloc]initWithData:cp437Data encoding:self.nfoDizEncoding];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        // Search for any ANSi escape sequences in our string, use AnsiLove anyway if user-defined.
        if ([cp437String rangeOfString:ansiEscapeSeq].location != NSNotFound ||
            [defaults boolForKey:@"enableAnsiLoveForASCII"] == YES)
        {
            // Obiously this string contains ANSi escape sequences, we need to use the .ANS file wrapper.
            self.isNewFile = NO;
            self.isUsingAnsiLove = YES;
            self.isAnsFile = YES;
            return [self ansiArtReadFileWrapper:pFileWrapper error:pOutError];
        }
        else {
            // Everything is fine, what we got here is a .ASC file.
            self.isNewFile = NO;
            return [self asciiArtReadFileWrapper:pFileWrapper error:pOutError];
        }
	}
    else if ([pFileWrapper isRegularFile] && ([pTypeName compare:@"com.byteproject.ascension.ans"] == NSOrderedSame))
    {
        self.isNewFile = NO;
        self.isUsingAnsiLove = YES;
        self.isAnsFile = YES;
		return [self ansiArtReadFileWrapper:pFileWrapper error:pOutError];
	}
    else if ([pFileWrapper isRegularFile] && ([pTypeName compare:@"com.byteproject.ascension.idf"] == NSOrderedSame))
    {
        self.isNewFile = NO;
        self.isUsingAnsiLove = YES;
        self.isIdfFile = YES;
		return [self ansiArtReadFileWrapper:pFileWrapper error:pOutError];
	}
    else if ([pFileWrapper isRegularFile] && ([pTypeName compare:@"com.byteproject.ascension.pcb"] == NSOrderedSame))
    {
        self.isNewFile = NO;
        self.isUsingAnsiLove = YES;
        self.isPcbFile = YES;
		return [self ansiArtReadFileWrapper:pFileWrapper error:pOutError];
	}
    else if ([pFileWrapper isRegularFile] && ([pTypeName compare:@"com.byteproject.ascension.xb"] == NSOrderedSame))
    {
        self.isNewFile = NO;
        self.isUsingAnsiLove = YES;
        self.isXbFile = YES;
		return [self ansiArtReadFileWrapper:pFileWrapper error:pOutError];
	}
    else if ([pFileWrapper isRegularFile] && ([pTypeName compare:@"com.amiga.adf-archive"] == NSOrderedSame))
    {
        self.isNewFile = NO;
        self.isUsingAnsiLove = YES;
        self.isAdfFile = YES;
		return [self ansiArtReadFileWrapper:pFileWrapper error:pOutError];
	}
    else if ([pFileWrapper isRegularFile] && ([pTypeName compare:@"com.apple.macbinary-archive"] == NSOrderedSame))
    {
        self.isNewFile = NO;
        self.isUsingAnsiLove = YES;
        self.isBinFile = YES;
		return [self ansiArtReadFileWrapper:pFileWrapper error:pOutError];
	}
    else if ([pFileWrapper isRegularFile] && ([pTypeName compare:@"com.byteproject.ascension.tnd"] == NSOrderedSame))
    {
        self.isNewFile = NO;
        self.isUsingAnsiLove = YES;
        self.isTndFile = YES;
		return [self ansiArtReadFileWrapper:pFileWrapper error:pOutError];
	}
	// In all other cases open the document using the text file wrapper.
	else {
        self.isNewFile = NO;
        self.isTextFile = YES;
		return [self textReadFileWrapper:pFileWrapper error:pOutError];
	}
	return NO;
}

- (BOOL)asciiArtReadFileWrapper:(NSFileWrapper *)pFileWrapper
						   error:(NSError **)pOutError
{
	// File wrapper for reading NFO and DIZ documents.
	NSData *cp437Data = [pFileWrapper regularFileContents];
	if(!cp437Data)
	{
		return NO;
	}
    // Check what encoding should be applied.
    [self switchASCIIEncoding];

	NSString *cp437String = [[NSString alloc]initWithData:cp437Data encoding:self.nfoDizEncoding];
	NSMutableAttributedString *importString = [[NSMutableAttributedString alloc] initWithString:cp437String];
	[self setString:importString];

    // We store the raw string as fallback, in case rendering engine will be toggled.
    self.rawAnsiString = importString;

	//If the UI is already loaded, this must be a 'revert to saved' operation.
	if (self.ansiTextView)
	{
		// Apply the loaded data to the text storage and restyle contents.
		[self.ansiTextView.textStorage setAttributedString:[self string]];
		[self prepareContent];
	}
	return YES;
}

- (BOOL)ansiArtReadFileWrapper:(NSFileWrapper *)pFileWrapper
                     error:(NSError **)pOutError
{
	// File wrapper for reading documents containing ANSi escape sequences.
	NSData *cp437Data = [pFileWrapper regularFileContents];
	if(!cp437Data)
	{
		return NO;
	}

	// Check and apply the proper NFO / DIZ encoding (needed for the raw string in background).
	[self setAnsiLoveFontAndEncoding];

    // Read the raw ANSi string.
	NSString *cp437String = [[NSString alloc]initWithData:cp437Data encoding:self.nfoDizEncoding];

    // This will store the raw ANSi string for save operations and other stuff.
	self.rawAnsiString = [[NSMutableAttributedString alloc] initWithString:cp437String];

    // Fire our code to render ANSi art, yay!
    [self renderANSiArtwork];

	return YES;
}

- (BOOL)textReadFileWrapper:(NSFileWrapper *)pFileWrapper
					 error:(NSError **)pOutError
{
	// File wrapper for reading all text-based documents except NFO and DIZ.
	NSData *textData = [pFileWrapper regularFileContents];
	if(!textData)
	{
		return NO;
	}

	// Check and apply the text encoding.
	[self switchTextEncoding];

    // Init data with the specified encoding.
	NSString *textString = [[NSString alloc]initWithData:textData encoding:self.txtEncoding];

    // Bugfix, don't ask why. It's working now.
    if (!textString) {
        self.txtEncoding = WinLatin1;
        NSString *failString = [[NSString alloc]initWithData:textData encoding:self.txtEncoding];
        self.encButtonIndex = xWinLatin1;
        textString = failString;
    }

    // Apply what we imported to our content string.
    NSMutableAttributedString *importString = [[NSMutableAttributedString alloc] initWithString:textString];
	[self setString:importString];

	// If the UI is already loaded, this must be a 'revert to saved' operation.
	if (self.ansiTextView)
	{
		// Apply the loaded data to the text storage and restyle contents.
		[self.ansiTextView.textStorage setAttributedString:[self string]];
		[self prepareContent];
	}
	return YES;
}

- (NSFileWrapper *)ansiArtFileWrapperWithError:(NSError **)pOutError
{
    // One thing for sure: this is no new file.
    self.isNewFile = NO;

    // This is a unified file wrapper for all kinds of supported ANSi art types.
    // We figure out what to do with our 'isUsingAnsiLove' variable.
    if (self.isUsingAnsiLove == YES)
    {
        // File wrapper for writing .ANS, .IDF, .PCB, .XB, .ADF, .BIN and .TND.
        NSData *ansData =
        [self.rawAnsiString.string dataUsingEncoding:self.exportEncoding allowLossyConversion:YES];

        if (!ansData) {
            return NULL;
        }
        // Enable undo after save operations.
        [self.ansiTextView breakUndoCoalescing];

        NSFileWrapper *ansFileWrapperObj = [[NSFileWrapper alloc] initRegularFileWithContents:ansData];
        if (!ansFileWrapperObj) {
            return NULL;
        }
        return ansFileWrapperObj;
    }
    else {
        // File wrapper for writing .NFO, .DIZ and .ASC.
        NSData *ascData =
        [self.contentString.string dataUsingEncoding:self.exportEncoding allowLossyConversion:YES];

        if (!ascData) {
            return NULL;
        }
        // Enable undo after save operations.
        [self.ansiTextView breakUndoCoalescing];

        NSFileWrapper *ascFileWrapperObj = [[NSFileWrapper alloc] initRegularFileWithContents:ascData];
        if (!ascFileWrapperObj) {
            return NULL;
        }
        return ascFileWrapperObj;
    }
}

- (NSFileWrapper *)textFileWrapperWithError:(NSError **)pOutError
{
    // New file? No longer with this save operation.
    self.isNewFile = NO;

	// File wrapper for writing all text-based documents except NFO and DIZ.
	NSData *txtData =
	[self.contentString.string dataUsingEncoding:self.exportEncoding allowLossyConversion:YES];

	if (!txtData) {
        return NULL;
	}
	// Enable undo after save operations.
	[self.ansiTextView breakUndoCoalescing];

	NSFileWrapper *txtFileWrapperObj = [[NSFileWrapper alloc] initRegularFileWithContents:txtData];
	if (!txtFileWrapperObj) {
		return NULL;
	}
	return txtFileWrapperObj;
}

- (void)switchASCIIEncoding
{
	// Read and apply the ASCII encoding from user defaults.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch ([defaults integerForKey:@"nfoDizEncoding"])
	{
		case eDosCP437: {
            // Latin US
			self.nfoDizEncoding = CodePage437;
			self.encButtonIndex = xDosCP437;
			break;
		}
        case eDosCP775: {
            // Baltic Rim
            self.nfoDizEncoding = CodePage775;
            self.encButtonIndex = xDosCP775;
            break;
        }
        case eDosCP855: {
            // Cyrillic (Slavic)
            self.nfoDizEncoding = CodePage855;
            self.encButtonIndex = xDosCP855;
            break;
        }
        case eDosCP863: {
            // French-Canadian
            self.nfoDizEncoding = CodePage863;
            self.encButtonIndex = xDosCP863;
            break;
        }
        case eDosCP737: {
            // Greek
            self.nfoDizEncoding = CodePage737;
            self.encButtonIndex = xDosCP737;
            break;
        }
        case eDosCP869: {
            // Greek 2
            self.nfoDizEncoding = CodePage869;
            self.encButtonIndex = xDosCP869;
            break;
        }
        case eDosCP862: {
            // Hebrew
            self.nfoDizEncoding = CodePage862;
            self.encButtonIndex = xDosCP862;
            break;
        }
        case eDosCP861: {
            // Icelandic
            self.nfoDizEncoding = CodePage861;
            self.encButtonIndex = xDosCP861;
            break;
        }
        case eDosCP850: {
            // Latin 1
            self.nfoDizEncoding = CodePage850;
            self.encButtonIndex = xDosCP850;
            break;
        }
        case eDosCP852: {
            // Latin 2
            self.nfoDizEncoding = CodePage852;
            self.encButtonIndex = xDosCP852;
            break;
        }
        case eDosCP865: {
            // Nordic
            self.nfoDizEncoding = CodePage865;
            self.encButtonIndex = xDosCP865;
            break;
        }
        case eDosCP860: {
            // Portuguese
            self.nfoDizEncoding = CodePage860;
            self.encButtonIndex = xDosCP860;
            break;
        }
		case eDosCP866: {
            // Cyrillic (Russian)
			self.nfoDizEncoding = CodePage866;
			self.encButtonIndex = xDosCP866;
			break;
		}
        case eDosCP857: {
            // Turkish
            self.nfoDizEncoding = CodePage857;
            self.encButtonIndex = xDosCP857;
            break;
        }
        case eAmiga: {
            // Amiga (Latin 1, Western)
            self.nfoDizEncoding = CodePage850;
            self.encButtonIndex = xAmiga;
            break;
        }
		default: {
			break;
		}
	}
	// Set the export encoding to the current NFO / DIZ encoding.
	self.exportEncoding = self.nfoDizEncoding;
}

- (void)switchTextEncoding
{
	// Read and apply the TXT encoding from user defaults.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	switch ([defaults integerForKey:@"txtEncoding"])
	{
		case eUniUTF8: {
			self.txtEncoding = UnicodeUTF8;
			self.encButtonIndex = xUniUTF8;
			break;
		}
		case eUniUTF16: {
			self.txtEncoding = UnicodeUTF16;
			self.encButtonIndex = xUniUTF16;
			break;
		}
		case eMacRoman: {
			self.txtEncoding = MacOSRoman;
			self.encButtonIndex = xMacRoman;
			break;
		}
		case eWinLatin: {
			self.txtEncoding = WinLatin1;
			self.encButtonIndex = xWinLatin1;
			break;
		}
		default: {
			break;
		}
	}
	// Set the export encoding to the current TXT encoding.
	self.exportEncoding = self.txtEncoding;
}

- (IBAction)switchExportEncoding:(id)sender
{
	// Define encoding for exporting, generate live preview afterwards.
	switch (self.encButtonIndex)
	{
		case xDosCP437: {
            // Latin US
			self.exportEncoding = CodePage437;
			break;
		}
        case xDosCP775: {
            // Baltic Rim
			self.exportEncoding = CodePage775;
			break;
		}
        case xDosCP855: {
            // Cyrillic (Slavic)
			self.exportEncoding = CodePage855;
			break;
		}
        case xDosCP863: {
            // French-Canadian
			self.exportEncoding = CodePage863;
			break;
		}
        case xDosCP737: {
            // Greek
			self.exportEncoding = CodePage737;
			break;
		}
        case xDosCP869: {
            // Greek 2
			self.exportEncoding = CodePage869;
			break;
		}
        case xDosCP862: {
            // Hebrew
			self.exportEncoding = CodePage862;
			break;
		}
        case xDosCP861: {
            // Icelandic
			self.exportEncoding = CodePage861;
			break;
		}
        case xDosCP850: {
            // Latin 1
			self.exportEncoding = CodePage850;
			break;
		}
        case xDosCP852: {
            // Latin 2
			self.exportEncoding = CodePage852;
			break;
		}
        case xDosCP865: {
            // Nordic
			self.exportEncoding = CodePage865;
			break;
		}
        case xDosCP860: {
            // Portuguese
			self.exportEncoding = CodePage860;
			break;
		}
		case xDosCP866: {
            // Cyrillic (Russian)
			self.exportEncoding = CodePage866;
			break;
		}
        case xDosCP857: {
            // Turkish
			self.exportEncoding = CodePage857;
			break;
		}
        case xAmiga: {
            // Amiga (Latin 1, Western)
			self.exportEncoding = CodePage850;
			break;
		}
		case xUniUTF8: {
			self.exportEncoding = UnicodeUTF8;
			break;
		}
		case xUniUTF16: {
			self.exportEncoding = UnicodeUTF16;
			break;
		}
		case xMacRoman: {
			self.exportEncoding = MacOSRoman;
			break;
		}
		case xWinLatin1: {
			self.exportEncoding = WinLatin1;
			break;
		}
		default: {
			break;
		}
	}

    if (self.isUsingAnsiLove == NO)
    {
        // Convert current string to NSData, generate newly encoded string and apply.
        NSData *convertData = [self.contentString.string dataUsingEncoding:self.nfoDizEncoding];
        NSString *cp437String = [[NSString alloc]initWithData:convertData encoding:self.exportEncoding];
        NSMutableAttributedString *importString = [[NSMutableAttributedString alloc] initWithString:cp437String];
        [self setString:importString];
        [self.ansiTextView.textStorage setAttributedString:[self string]];
        [self prepareContent];
    }
    else {
        // Unicode is an exception. ANSi art is not intended to be rendered in Unicode.
        if (self.exportEncoding == UnicodeUTF8 || self.exportEncoding == UnicodeUTF16)
        {
            // Inform the user and revert encoding changes.
            NSAlert *exportFailureAlert =
            [NSAlert alertWithMessageText:@"Encoding not applicable"
                            defaultButton:@"OK"
                          alternateButton:nil
                              otherButton:nil
                informativeTextWithFormat:@"The current file is not intended to be rendered in "
                                          @"the selected encoding and thus conversion is not "
                                          @"possible. Operation has been reverted."];

            [exportFailureAlert setAlertStyle:NSInformationalAlertStyle];
            [exportFailureAlert beginSheetModalForWindow:self.mainWindow
                                           modalDelegate:self
                                          didEndSelector:NULL
                                             contextInfo:NULL];
            // Revert and get out.
            self.exportEncoding = self.nfoDizEncoding;
            self.encButtonIndex = self.previousEncIndex;
            return;
        }
        // Encodings with uncomplete ANSi char set cause problems. Default to CP437 here.
        else if (self.exportEncoding == CodePage855 || self.exportEncoding == CodePage869 ||
                 self.exportEncoding == CodePage850 || self.exportEncoding == CodePage852 ||
                 self.exportEncoding == CodePage857)
        {
            self.exportEncoding = self.nfoDizEncoding;

            // Anyway, that doesn't mean we can't let AnsiLove do a sneak preview before we vanish.
            [self updateANSiLivePreview];
            return;
        }
        else {
            // This raw ANSi string stored in memory can be converted without issues.
            NSData *convertData = [self.rawAnsiString.string dataUsingEncoding:self.nfoDizEncoding];
            NSString *cp437String = [[NSString alloc]initWithData:convertData encoding:self.exportEncoding];
            NSMutableAttributedString *importString = [[NSMutableAttributedString alloc] initWithString:cp437String];
            self.rawAnsiString = importString;
            self.previousEncIndex = self.encButtonIndex;
            [self updateANSiLivePreview];
        }
    }

    // Now set the new encoding as current encoding.
    self.nfoDizEncoding = self.exportEncoding;
    self.txtEncoding = self.exportEncoding;
}

# pragma mark -
# pragma mark file information

- (NSString *)iFilePath
{
	// Get the current file URL and convert it to a path.
	NSURL *fileURL = [self fileURL];
	return [fileURL path];
}

- (NSString *)iCreationDate
{
	// Get the creation date as NSDate and return it as string.
	NSFileManager *fileManager = [NSFileManager new];
	NSDateFormatter *dateFormat = [NSDateFormatter new];
	[dateFormat setDateFormat:@"MMM dd, yyyy @ hh:mm"];
	NSString *dateString = [dateFormat stringFromDate:
							[[fileManager attributesOfItemAtPath:self.iFilePath error:nil] fileCreationDate]];
	if (dateString == nil || dateString == 0) {
		return @"n/a";
	}
	return dateString;
}

- (NSString *)iModDate
{
	// Get the modification date as NSDate and return it as String.
	NSFileManager *fileManager = [NSFileManager new];
	NSDateFormatter *dateFormat = [NSDateFormatter new];
	[dateFormat setDateFormat:@"MMM dd, yyyy @ hh:mm"];
	NSString *dateString = [dateFormat stringFromDate:
							[[fileManager attributesOfItemAtPath:self.iFilePath error:nil] fileModificationDate]];
	if (dateString == nil || dateString == 0) {
		return @"n/a";
	}
    if ([dateString isEqualToString:self.iCreationDate]) {
        return @"untouched file";
    }
	return dateString;
}

- (NSString *)iFileSize
{
	// Get the fileSize as NSNumber and return it as string.
	NSFileManager *fileManager = [NSFileManager new];
	NSNumber *fSize = [NSNumber numberWithInt:([[fileManager attributesOfItemAtPath:self.iFilePath error:nil] fileSize])];
	return [NSString stringWithFormat:@"%@ bytes", fSize];
}

- (void)updateFileInfoValues
{
	// Create dictionaries for the objects we pass our shared file information instance.
    NSDictionary *fSizeDict = [NSDictionary dictionaryWithObject:self.iFileSize forKey:@"fileSizeValue"];
	NSDictionary *cDateDict = [NSDictionary dictionaryWithObject:self.iCreationDate forKey:@"creationDateValue"];
	NSDictionary *mDateDict = [NSDictionary dictionaryWithObject:self.iModDate forKey:@"modDateValue"];

	// Send the needed notes, including our file attribute dictionaries.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"FileSizeNote"
					  object:self
					userInfo:fSizeDict];

	[nc postNotificationName:@"CreationDateNote"
					  object:self
					userInfo:cDateDict];

	[nc postNotificationName:@"ModDateNote"
					  object:self
					userInfo:mDateDict];
}

# pragma mark -
# pragma mark AnsiLove.framework specific

- (void)renderANSiArtwork
{
    // Get the current file URL and convert it to an UNIX path.
    NSURL *currentURL = [self fileURL];
    self.alURLString = [currentURL path];

    // Get the currrent file name without any path informations.
    NSString *pureFileName = [self.alURLString lastPathComponent];

    // Generate cache file name and path.
    self.ansiCacheFile = [NSString stringWithFormat:
                          @"~/Library/Application Support/Ascension/%@.png", pureFileName];

    self.retinaCacheFile = [NSString stringWithFormat:
                            @"~/Library/Application Support/Ascension/%@@2x.png", pureFileName];

    // Expand tilde in cache file path.
    self.ansiCacheFile = [self.ansiCacheFile stringByExpandingTildeInPath];
    self.retinaCacheFile = [self.retinaCacheFile stringByExpandingTildeInPath];

    // Create string we can pass as outputfile flag.
    self.alOutputString = [NSString stringWithFormat:
                           @"~/Library/Application Support/Ascension/%@", pureFileName];
    self.alOutputString = [self.alOutputString stringByExpandingTildeInPath];
        
    // What AnsiLove flags should be used to render the current artwork?
    [self setAnsiLoveFontAndEncoding];
    [self setAnsiLoveBits];
    [self setAnsiLoveIceColors];
    [self setAnsiLoveColumns];
    
    // Call AnsiLove and generate the rendered image.
    [self.ansiGen renderAnsiFile:self.alURLString
                      outputFile:self.alOutputString
                            font:self.alFont
                            bits:self.alBits
                       iceColors:self.alIceColors
                         columns:self.alColumns
                          retina:YES];
    
    // Wait for AnsiLove.framework to finish rendering.
    while (self.isRendered == NO) {
        [NSThread sleepForTimeInterval:0.1];
    }
    
    // Grab the rendered image and init an NSImage instance for it.
    self.renderedAnsiImage = [[NSImage alloc] initWithHiResContentsOfFile:self.ansiCacheFile];
    
    // Since libgd2 output files are 96 DPI, we need to deal with resolutions.
    // We use a BitmapImageRep for managing / adjusting pixel values.
    CGImageRef ansiImageRef = [self.renderedAnsiImage CGImageForProposedRect:nil context:nil hints:nil];
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:ansiImageRef];
    
    // Get the point and pixel sizes.
    NSSize pointsSize = rep.size;
    NSSize pixelSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
    NSSize updatedPointsSize = pointsSize;
    
    // Check wether the screen is regular or Retina resolution.
    if ([[NSScreen mainScreen]backingScaleFactor] == 2.0f)
    {
        self.dotsPerInch = 144.0f;
    }
    else {
        self.dotsPerInch = 72.0f;
    }
    
    // Update point size based on the user DPI.
    updatedPointsSize.width = ceilf((72.0f * pixelSize.width)/self.dotsPerInch);
    updatedPointsSize.height = ceilf((72.0f * pixelSize.height)/self.dotsPerInch);
    
    // Set the correct aspect ratio and add representation to our NSImage instance.
    [rep setSize:updatedPointsSize];
    self.renderedAnsiImage.size = rep.size;
    [self.renderedAnsiImage addRepresentation:rep];
    
    // To display our ANSi .png create an NSTextAttachment and corresponding cell.
    NSTextAttachmentCell *attachmentCell = [[NSTextAttachmentCell alloc] initImageCell:self.renderedAnsiImage];
    NSTextAttachment *attachment = [NSTextAttachment new];
    [attachment setAttachmentCell:attachmentCell];
    
    // Now generate an attributed String with our .png attachment.
    NSAttributedString *imageString = [NSAttributedString new];
    imageString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    // The content string of ansiTextView is mutable, so we need a mutable copy.
    NSMutableAttributedString *mutableImageString = [imageString mutableCopy];
    
    // Finally set the mutable string with our .png attachement as content string.
    [self setString:mutableImageString];
}

- (void)setRenderingFinishedState:(NSNotification *)note
{
    self.isRendered = YES;
}

- (void)performAnsiLoveRenderChange:(NSNotification *)note
{
    // Apply render changes only to contents that have not been dismissed already.
    if (self.isInLimbo == NO)
    {
        if (self.isUsingAnsiLove == YES)
        {
            // Reset isRendered bool value.
            self.isRendered = NO;
            
            // Re-render the ANSi artwork with updated AnsiLove flags.
            [self renderANSiArtwork];
            
            // Apply the updated string to our NSTextView instance.
            [self.ansiTextView.textStorage setAttributedString:[self string]];
            
            // Optimize the document window again, content sizes probably changed.
            [self autoSizeDocumentWindow];
        }
    }
}

- (void)updateANSiLivePreview
{
    // Reset rendering finished state.
    self.isRendered = NO;
    
    // Let's head over to the tricky part in this method...
    switch (self.encButtonIndex)
	{
		case xDosCP437: {
            // ...for Latin US we need to know which of three fonts is selected in prefs.
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults integerForKey:@"ansiLoveFont"] == al80x25) {
                self.alFont = @"80x25";
			}
            else if ([defaults integerForKey:@"ansiLoveFont"] == alTerminus) {
                self.alFont = @"terminus";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == al80x50) {
                self.alFont = @"80x50";
            }
            else {
                // No CP437 font selected in preferences, work with defaults.
                self.alFont = @"80x25";
            }
			break;
		}
        case xDosCP775: {
            // Baltic Rim
			self.alFont = @"baltic";
			break;
		}
        case xDosCP855: {
            // Cyrillic (Slavic)
			self.alFont = @"cyrillic";
			break;
		}
        case xDosCP863: {
            // French-Canadian
			self.alFont = @"french-canadian";
			break;
		}
        case xDosCP737: {
            // Greek
			self.alFont = @"greek";
			break;
		}
        case xDosCP869: {
            // Greek 2
			self.alFont = @"greek-869";
			break;
		}
        case xDosCP862: {
            // Hebrew
			self.alFont = @"hebrew";
			break;
		}
        case xDosCP861: {
            // Icelandic
            self.alFont = @"icelandic";
			break;
		}
        case xDosCP850: {
            // Latin 1
			self.alFont = @"latin1";
			break;
		}
        case xDosCP852: {
            // Latin 2
			self.alFont = @"latin2";
			break;
		}
        case xDosCP865: {
            // Nordic
			self.alFont = @"nordic";
			break;
		}
        case xDosCP860: {
            // Portuguese
			self.alFont = @"portuguese";
			break;
		}
		case xDosCP866: {
            // Cyrillic (Russian)
			self.alFont = @"russian";
			break;
		}
        case xDosCP857: {
            // Turkish
			self.alFont = @"turkish";
			break;
		}
        case xAmiga: {
            // Amiga Latin 1 fonts also come in many flavors the user possibly selected.
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults integerForKey:@"ansiLoveFont"] == alTopaz) {
                self.alFont = @"topaz";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alTopazPlus) {
                self.alFont = @"topaz+";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alTopaz500) {
                self.alFont = @"topaz500";
            }
			else if ([defaults integerForKey:@"ansiLoveFont"] == alTopaz500Plus) {
                self.alFont = @"topaz500+";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alMoSoul) {
                self.alFont = @"mosoul";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alPotNoodle) {
                self.alFont = @"pot-noodle";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alMicroKnight) {
                self.alFont = @"microknight";
            }
            else if ([defaults integerForKey:@"ansiLoveFont"] == alMicroKnightPlus) {
                self.alFont = @"microknight+";
            }
            else {
                // No Amiga font defined in prefs? Fine. Lets render with Topaz then.
                self.alFont = @"topaz";
            }
			break;
		}
		default: {
			break;
		}
	}

    // We urgently need to update the live preview now.
    [self.ansiGen renderAnsiFile:self.alURLString
                      outputFile:self.alOutputString
                            font:self.alFont
                            bits:self.alBits
                       iceColors:self.alIceColors
                         columns:self.alColumns
                          retina:YES];
    
    // Wait for AnsiLove.framework to finish rendering.
    while (self.isRendered == NO) {
        [NSThread sleepForTimeInterval:0.1];
    }
    
    // Grab the rendered image and init an NSImage instance for it.
    self.renderedAnsiImage = [[NSImage alloc] initWithContentsOfFile:self.ansiCacheFile];
    
    // Since libgd2 output files are 96 DPI, we need to deal with resolutions.
    // We use a BitmapImageRep for managing / adjusting pixel values.
    CGImageRef ansiImageRef = [self.renderedAnsiImage CGImageForProposedRect:nil context:nil hints:nil];
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:ansiImageRef];
    
    // Get the point and pixel sizes.
    NSSize pointsSize = rep.size;
    NSSize pixelSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
    NSSize updatedPointsSize = pointsSize;
    
    // Check wether the screen is regular or Retina resolution.
    if ([[NSScreen mainScreen]backingScaleFactor] == 2.0f)
    {
        self.dotsPerInch = 144.0f;
    }
    else {
        self.dotsPerInch = 72.0f;
    }
    
    // Update point size based on the user DPI.
    updatedPointsSize.width = ceilf((72.0f * pixelSize.width)/self.dotsPerInch);
    updatedPointsSize.height = ceilf((72.0f * pixelSize.height)/self.dotsPerInch);
    
    // Set the correct aspect ratio and add representation to our NSImage instance.
    [rep setSize:updatedPointsSize];
    self.renderedAnsiImage.size = rep.size;
    [self.renderedAnsiImage addRepresentation:rep];
    
    // To display our ANSi .png create an NSTextAttachment and corresponding cell.
    NSTextAttachmentCell *attachmentCell = [[NSTextAttachmentCell alloc] initImageCell:self.renderedAnsiImage];
    NSTextAttachment *attachment = [NSTextAttachment new];
    [attachment setAttachmentCell:attachmentCell];
    
    // Now generate an attributed String with our .png attachment.
    NSAttributedString *imageString = [NSAttributedString new];
    imageString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    // The content string of ansiTextView is mutable, so we need a mutable copy.
    NSMutableAttributedString *mutableImageString = [imageString mutableCopy];
    
    // Finally set the mutable string with our .png attachement as content string.
    [self setString:mutableImageString];
    
    // Make changes visible.
    [self.ansiTextView.textStorage setAttributedString:[self string]];
    
    // Optimize the document window again, content sizes probably changed.
    [self autoSizeDocumentWindow];
}

- (void)setAnsiLoveFontAndEncoding
{
	// Get the font value to pass to AnsiLove.framework.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	switch ([defaults integerForKey:@"ansiLoveFont"])
	{
		case alTerminus: {
			self.alFont = @"terminus";
            self.nfoDizEncoding = CodePage437;
			self.encButtonIndex = xDosCP437;
            self.previousEncIndex = xDosCP437;
			break;
		}
        case al80x25: {
			self.alFont = @"80x25";
            self.nfoDizEncoding = CodePage437;
			self.encButtonIndex = xDosCP437;
            self.previousEncIndex = xDosCP437;
			break;
		}
        case al80x50: {
			self.alFont = @"80x50";
            self.nfoDizEncoding = CodePage437;
			self.encButtonIndex = xDosCP437;
            self.previousEncIndex = xDosCP437;
			break;
		}
        case alBalticRim: {
			self.alFont = @"baltic";
            self.nfoDizEncoding = CodePage775;
			self.encButtonIndex = xDosCP775;
            self.previousEncIndex = xDosCP775;
			break;
		}
        case alCyrillicSlavic: {
			self.alFont = @"cyrillic";
            self.nfoDizEncoding = CodePage855;
			self.encButtonIndex = xDosCP855;
            self.previousEncIndex = xDosCP855;
			break;
		}
        case alFrenchCanadian: {
			self.alFont = @"french-canadian";
            self.nfoDizEncoding = CodePage863;
			self.encButtonIndex = xDosCP863;
            self.previousEncIndex = xDosCP863;
			break;
		}
        case alGreek: {
			self.alFont = @"greek";
            self.nfoDizEncoding = CodePage737;
			self.encButtonIndex = xDosCP737;
            self.previousEncIndex = xDosCP737;
			break;
		}
        case alGreek869: {
			self.alFont = @"greek-869";
            self.nfoDizEncoding = CodePage869;
			self.encButtonIndex = xDosCP869;
            self.previousEncIndex = xDosCP869;
			break;
		}
        case alHebrew: {
			self.alFont = @"hebrew";
            self.nfoDizEncoding = CodePage862;
			self.encButtonIndex = xDosCP862;
            self.previousEncIndex = xDosCP862;
			break;
		}
        case alIcelandic: {
			self.alFont = @"icelandic";
            self.nfoDizEncoding = CodePage861;
			self.encButtonIndex = xDosCP861;
            self.previousEncIndex = xDosCP861;
			break;
		}
        case alLatin1: {
			self.alFont = @"latin1";
            self.nfoDizEncoding = CodePage850;
			self.encButtonIndex = xDosCP850;
            self.previousEncIndex = xDosCP850;
			break;
		}
        case alLatin2: {
			self.alFont = @"latin2";
            self.nfoDizEncoding = CodePage852;
			self.encButtonIndex = xDosCP852;
            self.previousEncIndex = xDosCP852;
			break;
		}
        case alNordic: {
			self.alFont = @"nordic";
            self.nfoDizEncoding = CodePage865;
			self.encButtonIndex = xDosCP865;
            self.previousEncIndex = xDosCP865;
			break;
		}
        case alPortuguese: {
			self.alFont = @"portuguese";
            self.nfoDizEncoding = CodePage860;
			self.encButtonIndex = xDosCP860;
            self.previousEncIndex = xDosCP860;
			break;
		}
        case alCyrillicRussian: {
			self.alFont = @"russian";
            self.nfoDizEncoding = CodePage866;
			self.encButtonIndex = xDosCP866;
            self.previousEncIndex = xDosCP866;
			break;
		}
        case alTurkish: {
			self.alFont = @"turkish";
            self.nfoDizEncoding = CodePage857;
			self.encButtonIndex = xDosCP857;
            self.previousEncIndex = xDosCP857;
			break;
		}
        case alTopaz: {
			self.alFont = @"topaz";
            self.nfoDizEncoding = CodePage850;
			self.encButtonIndex = xAmiga;
            self.previousEncIndex = xAmiga;
			break;
		}
        case alTopazPlus: {
			self.alFont = @"topaz+";
            self.nfoDizEncoding = CodePage850;
			self.encButtonIndex = xAmiga;
            self.previousEncIndex = xAmiga;
			break;
		}
        case alTopaz500: {
			self.alFont = @"topaz500";
            self.nfoDizEncoding = CodePage850;
			self.encButtonIndex = xAmiga;
            self.previousEncIndex = xAmiga;
			break;
		}
        case alTopaz500Plus: {
			self.alFont = @"topaz500+";
            self.nfoDizEncoding = CodePage850;
			self.encButtonIndex = xAmiga;
            self.previousEncIndex = xAmiga;
			break;
		}
        case alMoSoul: {
			self.alFont = @"mosoul";
            self.nfoDizEncoding = CodePage850;
			self.encButtonIndex = xAmiga;
            self.previousEncIndex = xAmiga;
			break;
		}
        case alPotNoodle: {
			self.alFont = @"pot-noodle";
            self.nfoDizEncoding = CodePage850;
			self.encButtonIndex = xAmiga;
            self.previousEncIndex = xAmiga;
			break;
		}
        case alMicroKnight: {
			self.alFont = @"microknight";
            self.nfoDizEncoding = CodePage850;
			self.encButtonIndex = xAmiga;
            self.previousEncIndex = xAmiga;
			break;
		}
        case alMicroKnightPlus: {
			self.alFont = @"microknight+";
            self.nfoDizEncoding = CodePage850;
			self.encButtonIndex = xAmiga;
            self.previousEncIndex = xAmiga;
			break;
		}
		default: {
			break;
		}
	}
}

- (void)setAnsiLoveBits
{
    // Set the bits value to pass to AnsiLove.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.alBits = [defaults stringForKey:@"ansiLoveBits"];
}

- (void)setAnsiLoveIceColors
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:@"ansiLoveIceColors"] == YES) {
        self.alIceColors = YES;
    }
    else {
        self.alIceColors = NO;
    }
}

- (void)setAnsiLoveColumns
{
    // Set the bits value to pass to AnsiLove.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.alColumns = [defaults stringForKey:@"ansiLoveColumns"];
}

@end

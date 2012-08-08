//
//  SVAsciiDocument.m
//  Ascension
//
//  Copyright (c) 2010-2012, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import "SVAsciiDocument.h"
#import "SVRoardactedScroller.h"
#import "SVPreferences.h"
#import "SVFileInfoStrings.h"

// helpers
#define stdNSTextViewMargin 20
#define wtfBugFixForTextStorageSize 79

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

@implementation SVAsciiDocument

@synthesize asciiTextView, asciiScrollView, contentString, newContentHeight, newContentWidth, backgroundColor,  
            cursorColor, linkColor, linkAttributes, selectionColor, encodingButton, selectionAttributes, fontColor,
            nfoDizEncoding, newEncoding, iFilePath, iCreationDate, iModDate, iFileSize, mainWindow, encButtonIndex,
            vScroller, hScroller, appToolbar, fileInfoPopover, fontName, fontSize;

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
	   // Define NSNotificationCenter.
	   NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	   
       // Register as an observer for font and font color changes.
       [nc addObserver:self
			  selector:@selector(performColorSchemeChange:)
				  name:@"ColorSchemeChange"
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
       
       // Get notified when the user toggles hyperlink attributes in prefs.
       [nc addObserver:self
              selector:@selector(toggleHyperLinkAttributes:)
                  name:@"HyperLinkAttributeChange"
                object:nil];
       
       // Init the file information values.
       [SVFileInfoStrings sharedFileInfoStrings];
   }
	return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{	
	[super windowControllerDidLoadNib:aController];
	
	// Add our custom UI elements.
	[self createInterface];
	
	// Assign our attributed string.
	if ([self string] != nil) {
		[self.asciiTextView.textStorage setAttributedString:[self string]];
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// Apply the appearance attributes.
    [self prepareContent];
	
    // The method name describes exactly what's happening here.
    [self autoSizeDocumentWindow];
 	
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

// Opens each document instance in a separate thread.
+ (BOOL)canConcurrentlyReadDocumentsOfType:(NSString *)typeName {
    return YES;
}

# pragma mark -
# pragma mark UI specific

- (NSString *)windowNibName
{
    return @"SVAsciiDocument";
}

- (void)windowDidBecomeKey:(NSNotification *)notification 
{
	// Update the file information interface strings.
	[self updateFileInfoValues];
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
   
    // Embedded look for the encoding button.
    [[self.encodingButton cell] setBackgroundStyle:NSBackgroundStyleRaised];
    
    // Set the style of our overlay Scrollers.
    if ([defaults integerForKey:@"scrollerStyle"] == 0) {
        [self.hScroller setKnobStyle:NSScrollerKnobStyleLight];
        [self.vScroller setKnobStyle:NSScrollerKnobStyleLight];
    }
    else {
        [self.hScroller setKnobStyle:NSScrollerKnobStyleDark];
        [self.vScroller setKnobStyle:NSScrollerKnobStyleDark];
    }
    
    // Configure some behaviors of the file information popover.
    self.fileInfoPopover.behavior = NSPopoverBehaviorTransient;
    self.fileInfoPopover.animates = YES;
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
        default: {
            break;
        }
    }
}

- (void)autoSizeDocumentWindow
{
    // We need the textstorage size for auto-sizing the document window.
	NSSize myTextSize = self.asciiTextView.textStorage.size;
    
    // Calculate the new content dimensions, consider the toolbar (if visible).
    CGFloat toolbarHeight = 0;
    if ([appToolbar isVisible])
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
        // Calculate width via the textstorage.
        self.newContentWidth = myTextSize.width + stdNSTextViewMargin - wtfBugFixForTextStorageSize;
        
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
        // Use the textstorage again to calculate a proper height value.
        self.newContentHeight = myTextSize.height + [self titlebarHeight] + toolbarHeight;
                
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

# pragma mark -
# pragma mark content appearance

- (void)prepareContent
{
	// Prepare the textual content.
    [self applyParagraphStyle];
    [self performLinkification];
    
    // Let's mess around with ASCII themes.
    [self applySchemeColors];
	
	// Set the text color.
	[self.asciiTextView setTextColor:self.fontColor];
	
	// Apply background color.
	[self.asciiTextView setBackgroundColor:self.backgroundColor];
    [self.asciiScrollView setBackgroundColor:self.backgroundColor];
	
	// Set the cursor color.
	[self.asciiTextView setInsertionPointColor:self.cursorColor];
	
	// Specify the style for all contained links.
	[self.asciiTextView setLinkTextAttributes:self.linkAttributes];
	
	// Set the color for selected and marked text.
	[self.asciiTextView setSelectedTextAttributes:self.selectionAttributes];
}

- (void)applySchemeColors
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
	
	// Read font properties from preferences.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.fontName = [defaults stringForKey:@"fontName"];
    self.fontSize = [defaults floatForKey:@"fontSize"];
    
	// Set the font.
	asciiFont = [NSFont fontWithName:self.fontName size:self.fontSize];
    
	// Set line height identical to font size.
	customParagraph = [[NSMutableParagraphStyle alloc] init];
	[customParagraph setLineSpacing:0];
	[customParagraph setMinimumLineHeight:self.fontSize];
	[customParagraph setMaximumLineHeight:self.fontSize];
    
	// Set our custom paragraph as default paragraph style.
	[self.asciiTextView setDefaultParagraphStyle:customParagraph];
	
	// Apply our atttributes.
	attributes = [NSDictionary dictionaryWithObjectsAndKeys:asciiFont,
				  NSFontAttributeName, customParagraph, NSParagraphStyleAttributeName, nil];
	 [self.asciiTextView.textStorage setAttributes:attributes 
											  range:NSMakeRange(0, self.asciiTextView.textStorage.length)];
}

- (void)performLinkification
{
    // When highlighting hyperlinks is turned off in preferences...
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"highlightAsciiHyperLinks"] == NO)
    {
        // ...prevent NSTextView from automatically detecting hyperlinks
        [self.asciiTextView setAutomaticLinkDetectionEnabled:NO];
        
        // ... and peform an early return.
        return;
    }
	// Analyze the text storage and return a linkified string.
	AHHyperlinkScanner *scanner = 
	[AHHyperlinkScanner hyperlinkScannerWithAttributedString:self.asciiTextView.textStorage];
	[self.asciiTextView.textStorage setAttributedString:[scanner linkifiedString]];
}

- (void)toggleHyperLinkAttributes:(NSNotification *)note
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:@"highlightAsciiHyperLinks"] == NO)
    {
        // Create range based on the textStorage length.
        NSRange area = NSMakeRange(0, self.asciiTextView.textStorage.length);
        
        // Now remove already highlighted hyperlinks.
        [self.asciiTextView.textStorage removeAttribute:NSLinkAttributeName range:area];
        
        // Finally, we don't want NSTextView to automatically detect hyperlinks.
        [self.asciiTextView setAutomaticLinkDetectionEnabled:NO];
    }
    else {
        [self.asciiTextView setAutomaticLinkDetectionEnabled:YES];
        [self performLinkification];
    }
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

- (void)performColorSchemeChange:(NSNotification *)note
{
    [self applySchemeColors];
    [self.asciiTextView setTextColor:self.fontColor];
    [self.asciiTextView setBackgroundColor:self.backgroundColor];
    [self.asciiScrollView setBackgroundColor:self.backgroundColor];
    [self.asciiTextView setInsertionPointColor:self.cursorColor];
    [self.asciiTextView setLinkTextAttributes:self.linkAttributes];
    [self.asciiTextView setSelectedTextAttributes:self.selectionAttributes];
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
    [self setString:self.asciiTextView.textStorage];
}

# pragma mark -
# pragma mark data and encoding

- (BOOL)readFromFileWrapper:(NSFileWrapper *)pFileWrapper 
					 ofType:(NSString *)pTypeName 
					  error:(NSError **)pOutError
{
	// Determine file type and launch the input file wrapper, also set informal bool values.
	if ([pFileWrapper isRegularFile] && ([pTypeName compare:@"com.byteproject.ascension.diz"] == NSOrderedSame)) 
    {
		return [self asciiArtReadFileWrapper:pFileWrapper error:pOutError];
	}
	else if ([pFileWrapper isRegularFile] && ([pTypeName compare:@"com.byteproject.ascension.nfo"] == NSOrderedSame)) 
    {
        return [self asciiArtReadFileWrapper:pFileWrapper error:pOutError];
	}
	else if ([pFileWrapper isRegularFile] && ([pTypeName compare:@"com.byteproject.ascension.asc"] == NSOrderedSame)) 
    {
		return [self asciiArtReadFileWrapper:pFileWrapper error:pOutError];
    }
	else {
		return [self asciiArtReadFileWrapper:pFileWrapper error:pOutError];
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
    
	return YES;
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
}

- (IBAction)switchCurrentEncoding:(id)sender
{
	// Switch the current encoding based on the encoding button index.
	switch (self.encButtonIndex)
	{
		case xDosCP437: {
            // Latin US
			self.newEncoding = CodePage437;
			break;
		}
        case xDosCP775: {
            // Baltic Rim
			self.newEncoding = CodePage775;
			break;
		}
        case xDosCP855: {
            // Cyrillic (Slavic)
			self.newEncoding = CodePage855;
			break;
		}
        case xDosCP863: {
            // French-Canadian
			self.newEncoding = CodePage863;
			break;
		}
        case xDosCP737: {
            // Greek
			self.newEncoding = CodePage737;
			break;
		}
        case xDosCP869: {
            // Greek 2
			self.newEncoding = CodePage869;
			break;
		}
        case xDosCP862: {
            // Hebrew
			self.newEncoding = CodePage862;
			break;
		}
        case xDosCP861: {
            // Icelandic
			self.newEncoding = CodePage861;
			break;
		}
        case xDosCP850: {
            // Latin 1
			self.newEncoding = CodePage850;
			break;
		}
        case xDosCP852: {
            // Latin 2
			self.newEncoding = CodePage852;
			break;
		}
        case xDosCP865: {
            // Nordic
			self.newEncoding = CodePage865;
			break;
		}
        case xDosCP860: {
            // Portuguese
			self.newEncoding = CodePage860;
			break;
		}
		case xDosCP866: {
            // Cyrillic (Russian)
			self.newEncoding = CodePage866;
			break;
		}
        case xDosCP857: {
            // Turkish
			self.newEncoding = CodePage857;
			break;
		}
        case xAmiga: {
            // Amiga (Latin 1, Western)
			self.newEncoding = CodePage850;
			break;
        }
		default: {
			break;
		}
	}
    
    // Convert current string to NSData, generate newly encoded string and apply.
    NSData *convertData = [self.contentString.string dataUsingEncoding:self.nfoDizEncoding];
    NSString *cp437String = [[NSString alloc]initWithData:convertData encoding:self.newEncoding];
	NSMutableAttributedString *importString = [[NSMutableAttributedString alloc] initWithString:cp437String];
    [self setString:importString];
    [self.asciiTextView.textStorage setAttributedString:[self string]];
    [self prepareContent];
    
    // Now set the new encoding as current encoding.
    self.nfoDizEncoding = self.newEncoding;
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
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
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
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
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
	NSFileManager *fileManager = [[NSFileManager alloc] init];
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

@end

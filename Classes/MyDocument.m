//
//  MyDocument.m
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import "MyDocument.h"
#import "SVFontProperties.h"
#import "SVPrefsController.h"
#import "SVFileInfoStrings.h"
#import "SVControlCharStringEngine.h"

#define stdNSTextViewMargin 20
#define CodePage437 CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSLatinUS)
#define CodePage866 CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSRussian)
#define UnicodeUTF8 NSUTF8StringEncoding
#define UnicodeUTF16 NSUTF16StringEncoding
#define MacOSRoman NSMacOSRomanStringEncoding
#define WinLatin1 NSWindowsCP1252StringEncoding

@implementation MyDocument

@synthesize asciiTextView, asciiScrollView, contentString, newContentHeight, newContentWidth, backgroundColor,  
			cursorColor, linkColor, linkAttributes, selectionColor, encodingButton, selectionAttributes, fontColor,
			nfoDizEncoding, txtEncoding, exportEncoding, iFilePath, iCreationDate, iModDate, iFileSize, mainWindow, 
			attachedEncView, encButtonIndex, vScroller, hScroller; 


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
	   
	   // Register as an observer for font color changes.
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
		[[self.asciiTextView textStorage] setAttributedString:[self string]];
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// Apply the appearance attributes.
	[self prepareContent];
	
	// Value for auto-sizing the document window.
	NSSize myTextSize = [self.asciiTextView textStorage].size;
	
	// Apply width and height based on the specified values in the preferences.
	if (self.contentString.length < 50) {
		self.newContentWidth = [defaults floatForKey:@"newContentWidth"];
		self.newContentHeight = [defaults floatForKey:@"newContentWidth"];
	}
	else {
		// Calculate the new content width and height, consider the toolbar (if visible).
		CGFloat toolbarHeight = 0;
		if ([appToolbar isVisible]) 
		{
			NSRect windowFrame;
			windowFrame = [NSWindow contentRectForFrameRect:aController.window.frame
												  styleMask:aController.window.styleMask];
			toolbarHeight = NSHeight(windowFrame) - NSHeight([[aController.window contentView] frame]);
		}
		// Check if the user enabled width auto-sizing.
		if ([defaults boolForKey:@"autoSizeWidth"] == YES) {
			self.newContentWidth = myTextSize.width + stdNSTextViewMargin;
		}
		else {
			self.newContentWidth = [aController.window frame].size.width;
		}
		// Determine if height auto-sizing is enabled.
		if ([defaults boolForKey:@"autoSizeHeight"] == YES) {
			self.newContentHeight = myTextSize.height + [self titlebarHeight] + toolbarHeight;
		}
		else {
			self.newContentHeight = aController.window.frame.size.height - [self titlebarHeight] - toolbarHeight;
		}
		
	}
    // NOTE: Future implementation will use 'windowWillUseStandardFrame'!
	// Resize the document window based on either the caluclation or the preferences.
	[aController.window setContentSize:NSMakeSize(self.newContentWidth, self.newContentHeight)];
	
	// Set position of the document window.
	[NSApp activateIgnoringOtherApps:YES];
	if ([defaults boolForKey:@"docsOpenCentered"] == YES) 
	{
		[aController.window center];
	}
	[aController.window makeKeyAndOrderFront:self];
}

# pragma mark -
# pragma mark UI specific

- (NSString *)windowNibName
{
    return @"MyDocument";
}

- (void)windowDidBecomeKey:(NSNotification *)notification 
{
	// Update the file information interface strings.
	[self updateFileInfoValues];
}

- (void)createInterface 
{
	// Create the bottom bar.
    [self.mainWindow setContentBorderThickness:24.0 forEdge:NSMinYEdge];
    
    // Should we disable the OS X window state restoration mechanism?
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults integerForKey:@"startupBehavior"] == 1) {
        [self.mainWindow setRestorable:NO];
    }
    
    // Embedded look for the encoding button.
    [[encodingButton cell] setBackgroundStyle:NSBackgroundStyleRaised];
    
    // Set the style of our overlay Scrollers.
    if ([defaults integerForKey:@"scrollerStyle"] == 0) {
        [self.hScroller setKnobStyle:NSScrollerKnobStyleLight];
        [self.vScroller setKnobStyle:NSScrollerKnobStyleLight];
    }
    else {
        [self.hScroller setKnobStyle:NSScrollerKnobStyleDark];
        [self.vScroller setKnobStyle:NSScrollerKnobStyleDark];
    }
}

- (void)performResumeStateChange:(NSNotification *)note
{
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

# pragma mark -
# pragma mark content appearance

- (void)prepareContent
{
	// Prepare the textual content.
	[self applyParagraphStyle];
	[self performLinkification];
	[self applyThemeColors];
	
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
	
	// Initialize instance of SVFontProperties.
	SVFontProperties *myFontProperty = [[SVFontProperties alloc] init];
	
	// Set the font.
	asciiFont = [NSFont fontWithName:myFontProperty.fontName size:myFontProperty.fontSize];
	
	// Set line height identical to font size.
	customParagraph = [[NSMutableParagraphStyle alloc] init];
	[customParagraph setLineSpacing:0];
	[customParagraph setMinimumLineHeight:myFontProperty.fontSize];
	[customParagraph setMaximumLineHeight:myFontProperty.fontSize];
	
	// Set our custom paragraph as default paragraph style.
	[self.asciiTextView setDefaultParagraphStyle:customParagraph];
	
	// Apply our atttributes.
	attributes = [NSDictionary dictionaryWithObjectsAndKeys:asciiFont,
				  NSFontAttributeName, customParagraph, NSParagraphStyleAttributeName, nil];
	 [[self.asciiTextView textStorage] setAttributes:attributes 
											  range:NSMakeRange(0, [self.asciiTextView textStorage].length)];
}

- (void)performLinkification
{
	// Analyze the text storage and return a linkified string.
	AHHyperlinkScanner *scanner = 
	[AHHyperlinkScanner hyperlinkScannerWithAttributedString:[self.asciiTextView textStorage]];
	[[self.asciiTextView textStorage] setAttributedString:[scanner linkifiedString]];
}

- (void)handlePasteOperation:(NSNotification *)note
{
	// Linkify hyperlinks in the pasted content.
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

// The performColorChange methods are fired by notifications, invoked from the prefs.
- (void)performFontColorChange:(NSNotification *)note
{
	NSColor *fontColorValue = [[note userInfo] objectForKey:@"fontColorValue"];
	[self.asciiTextView setTextColor:fontColorValue];
}

- (void)performBgrndColorChange:(NSNotification *)note
{
	NSColor *bgrndColorValue = [[note userInfo] objectForKey:@"bgrndColorValue"];
	[self.asciiTextView setBackgroundColor:bgrndColorValue];
    [self.asciiScrollView setBackgroundColor:bgrndColorValue];
}

- (void)performCursorColorChange:(NSNotification *)note
{
	NSColor *cursorColorValue = [[note userInfo] objectForKey:@"cursorColorValue"];
	[self.asciiTextView setInsertionPointColor:cursorColorValue];
}

- (void)performLinkColorChange:(NSNotification *)note
{
	self.linkColor = [[note userInfo] objectForKey:@"linkColorValue"];
	[self.asciiTextView setLinkTextAttributes:self.linkAttributes];
}

- (void)performSelectionColorChange:(NSNotification *)note
{
	self.selectionColor = [[note userInfo] objectForKey:@"selectionColorValue"];
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
# pragma mark live search

- (IBAction)performLiveSearch:(id)sender
{
	// Search for the sender's string value and show any matching entries.
	NSString *liveSearchString = [sender stringValue];
	NSRange lsStringRange = [[self.asciiTextView string] rangeOfString:liveSearchString];
	if (lsStringRange.location == NSNotFound) {
		return;
	}
	else {
		NSArray *lsStringRanges = [self lsStringRangesInDocument:liveSearchString];
		if ([lsStringRanges count]) {
			if ([self.asciiTextView respondsToSelector:@selector(setSelectedRanges:)]) {
				[self.asciiTextView setSelectedRanges:lsStringRanges];
			} 
			else {
				[self.asciiTextView setSelectedRange:[[lsStringRanges objectAtIndex:0] rangeValue]];
			}
		}
		[self.mainWindow makeFirstResponder:self.asciiTextView];
		[self.asciiTextView scrollRangeToVisible:lsStringRange];
		[self.asciiTextView showFindIndicatorForRange:lsStringRange];
	}
}

- (NSArray *)lsStringRangesInDocument:(NSString *)liveSearchString 
{
	// Returns an array of ranges suitable for NSTextView's setSelectedRanges method.
    NSString *txtStorString = [[self.asciiTextView textStorage] string];
    NSMutableArray *ranges = [NSMutableArray array];
	
	NSRange thisCharRange, searchCharRange;
    searchCharRange = NSMakeRange(0, [txtStorString length]);
    while (searchCharRange.length > 0) {
        thisCharRange = [txtStorString rangeOfString:liveSearchString options:0 range:searchCharRange];
        if (thisCharRange.length > 0) {
            searchCharRange.location = NSMaxRange(thisCharRange);
            searchCharRange.length = [txtStorString length] - NSMaxRange(thisCharRange);
            [ranges addObject: [NSValue valueWithRange:thisCharRange]];
        } 
		else {
            searchCharRange = NSMakeRange(NSNotFound, 0);
        }
    }
    return ranges;
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
    [self setString:[self.asciiTextView textStorage]];
}

# pragma mark -
# pragma mark data and encoding

- (NSFileWrapper *)fileWrapperOfType:(NSString *)pTypeName 
							   error:(NSError **)pOutError 
{	
	// Launch the output file wrapper based on the document UTI.
	if ([pTypeName compare:@"com.byteproject.ascension.nfo"] == NSOrderedSame) {
		return [self nfoFileWrapperWithError:pOutError];
	}
	if ([pTypeName compare:@"com.byteproject.ascension.diz"] == NSOrderedSame) {
		return [self nfoFileWrapperWithError:pOutError];
	}
    else {
        return [self txtFileWrapperWithError:pOutError]; 
    }
	return nil;
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)pFileWrapper 
					 ofType:(NSString *)pTypeName 
					  error:(NSError **)pOutError
{
	// Determine file type and launch the input file wrapper.
	if ([pFileWrapper isRegularFile] && ([pTypeName compare:@"com.byteproject.ascension.nfo"] == NSOrderedSame)) {
		return [self nfoReadFileWrapper:pFileWrapper error:pOutError];
	}
	if ([pFileWrapper isRegularFile] && ([pTypeName compare:@"com.byteproject.ascension.diz"] == NSOrderedSame)) {
		return [self nfoReadFileWrapper:pFileWrapper error:pOutError];
	}
	if ([pFileWrapper isRegularFile] && ([pTypeName compare:@"public.plain-text"] == NSOrderedSame)) {
		return [self txtReadFileWrapper:pFileWrapper error:pOutError];
	}
	// In all other cases open the document using the text file wrapper.
	else {
		return [self txtReadFileWrapper:pFileWrapper error:pOutError];
	}
	return NO;
}

- (BOOL)nfoReadFileWrapper:(NSFileWrapper *)pFileWrapper 
						   error:(NSError **)pOutError 
{	
	// File wrapper for reading NFO and DIZ documents.
	NSData *cp437Data = [pFileWrapper regularFileContents];
	if(!cp437Data) 
	{
		return NO;
	}
	
	// Check and apply the NFO / DIZ encoding.
	[self switchASCIIEncoding];
	
	NSString *cp437String = [[NSString alloc]initWithData:cp437Data encoding:self.nfoDizEncoding];
	NSMutableAttributedString *importString = [[NSMutableAttributedString alloc] initWithString:cp437String];
	[self setString:importString];
	
	//If the UI is already loaded, this must be a 'revert to saved' operation.
	if (self.asciiTextView) 
	{
		// Apply the loaded data to the text storage and restyle contents.
		[[self.asciiTextView textStorage] setAttributedString:[self string]];
		[self prepareContent];
	}
	return YES;
}

- (BOOL)txtReadFileWrapper:(NSFileWrapper *)pFileWrapper 
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
	
	NSString *textString = [[NSString alloc]initWithData:textData encoding:self.txtEncoding];
	NSMutableAttributedString *importString = [[NSMutableAttributedString alloc] initWithString:textString];
	[self setString:importString];
	
	//If the UI is already loaded, this must be a 'revert to saved' operation.
	if (self.asciiTextView) 
	{
		// Apply the loaded data to the text storage and restyle contents.
		[[self.asciiTextView textStorage] setAttributedString:[self string]];
		[self prepareContent];
	}
	return YES;
}

- (NSFileWrapper *)nfoFileWrapperWithError:(NSError **)pOutError 
{
	// File wrapper for writing NFO and DIZ documents.
	NSData *nfoData = 
	[self.contentString.string dataUsingEncoding:self.exportEncoding allowLossyConversion:YES];

	if (!nfoData) {
		return NULL;
	}
	// Enable undo after save operations.
	[self.asciiTextView breakUndoCoalescing];
	
	NSFileWrapper * nfoFileWrapperObj = [[NSFileWrapper alloc] initRegularFileWithContents:nfoData];
	if (!nfoFileWrapperObj) {
		return NULL;
	}
	return nfoFileWrapperObj;	
}

- (NSFileWrapper *)txtFileWrapperWithError:(NSError **)pOutError 
{
	// File wrapper for writing all text-based documents except NFO and DIZ.
	NSData *txtData = 
	[self.contentString.string dataUsingEncoding:self.exportEncoding allowLossyConversion:YES];
	
	if (!txtData) {
		return NULL;
	}
	// Enable undo after save operations.
	[self.asciiTextView breakUndoCoalescing];
	
	NSFileWrapper * txtFileWrapperObj = [[NSFileWrapper alloc] initRegularFileWithContents:txtData];
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
		case EncDosCP437: {
			self.nfoDizEncoding = CodePage437;
			self.encButtonIndex = EIndexDosCP437;
			break;
		}
		case EncDosCP866: {
			self.nfoDizEncoding = CodePage866;
			self.encButtonIndex = EIndexDosCP866;
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
		case EncUniUTF8: {
			self.txtEncoding = UnicodeUTF8;
			self.encButtonIndex = EIndexUniUTF8;
			break;
		}
		case EncUniUTF16: {
			self.txtEncoding = UnicodeUTF16;
			self.encButtonIndex = EIndexUniUTF16;
			break;
		}
		case EncMacRoman: {
			self.txtEncoding = MacOSRoman;
			self.encButtonIndex = EIndexMacRoman;
			break;
		}
		case EncWinLatin: {
			self.txtEncoding = WinLatin1;
			self.encButtonIndex = EIndexWinLatin1;
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
	// Define the export encoding based on the encoding button index.
	switch (self.encButtonIndex) 
	{
		case EIndexDosCP437: {
			self.exportEncoding = CodePage437;
			break;
		}
		case EIndexDosCP866: {
			self.exportEncoding = CodePage866;
			break;
		}
		case EIndexUniUTF8: {
			self.exportEncoding = UnicodeUTF8;
			break;
		}
		case EIndexUniUTF16: {
			self.exportEncoding = UnicodeUTF16;
			break;
		}
		case EIndexMacRoman: {
			self.exportEncoding = MacOSRoman;
			break;
		}
		case EIndexWinLatin1: {
			self.exportEncoding = WinLatin1;
			break;
		}
		default: {
			break;
		}
	}
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

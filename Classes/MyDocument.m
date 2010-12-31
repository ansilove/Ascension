//
//  MyDocument.m
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import "MyDocument.h"
#import "SVFontController.h"
#import "SVPrefsController.h"
#import "SVFileInfoWindowController.h"

#define stdNSTextViewMargin 10
#define BlockASCII CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSLatinUS)
#define UnicodeUTF8 NSUTF8StringEncoding
#define MacRomanASCII NSMacOSRomanStringEncoding

@implementation MyDocument

@synthesize asciiTextView, asciiScrollView, contentString, newContentHeight, newContentWidth, backgroundColor,  
			cursorColor, linkColor, linkAttributes, selectionColor, encodingButton, selectionAttributes, fontColor,
			charEncoding, iFilePath, iCreationDate, iModDate, iFileSize, mainWindow, attachedEncView; 


# pragma mark -
# pragma mark initialization

- (id)init
{
   if (self = [super init]) 
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
				  name:FontColorChangeNotification
				object:nil];
	   
	   // Become an observer for background color changes.
	   [nc addObserver:self
			  selector:@selector(performBgrndColorChange:) 
				  name:BgrndColorChangeNotification
				object:nil];
	   
	   // Start observating any cursor color changes.
	   [nc addObserver:self
			  selector:@selector(performCursorColorChange:)
				  name:CursorColorChangeNotification
				object:nil];
	   
	   // Register as observer for link color changes.
	   [nc addObserver:self
			  selector:@selector(performLinkColorChange:)
				  name:LinkColorChangeNotification
				object:nil];
	   
	   // Become observer of color changes for selected text.
	   [nc addObserver:self
			  selector:@selector(performSelectionColorChange:)
				  name:SelectionColorChangeNotification
				object:nil];
	   
	   // Check if the user pastes content into SVTextView.
	   [nc addObserver:self
			  selector:@selector(handlePasteOperation:)
				  name:@"PasteNote"
				object:nil];
	   
	   [self switchEncoding];
   }
	return self;
}

- (void)windowControllerWillLoadNib:(NSWindowController *)aController
{
	// Make sure all conditions are met.
	SVFontController *myFontController = [[SVFontController alloc] init];
	[myFontController fontCheck];
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
	
	// Create a beautiful window bottom.
	[aController.window setContentBorderThickness:20.0f forEdge:NSMinYEdge];
	
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
		if ([defaults boolForKey:@"autoSizeWidth"] == YES) 
		{
			self.newContentWidth = myTextSize.width + stdNSTextViewMargin + [NSScroller scrollerWidth];
		}
		else {
			self.newContentWidth = [aController.window frame].size.width;
		}
		if ([defaults boolForKey:@"autoSizeHeight"] == YES)
		{
			self.newContentHeight = myTextSize.height + [self titlebarHeight] + toolbarHeight;
		}
		else {
			self.newContentHeight = aController.window.frame.size.height - [self titlebarHeight] - toolbarHeight;
		}
		
	}
	// Resize the document window based on either the caluclation or the preferences.
	[aController.window setContentSize:NSMakeSize(self.newContentWidth, self.newContentHeight)];
	
	[self switchEncodingButton];
	
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
	// For now, this method attaches the encoding view to the UI.
	NSView *themeFrame = [[mainWindow contentView] superview];
	
	NSRect container = [themeFrame frame];
	NSRect encV = [attachedEncView frame];
	
	NSRect newFrame = NSMakeRect(container.size.width - encV.size.width,
								 container.size.height - encV.size.height,
								 encV.size.width,
								 encV.size.height);
	
	[attachedEncView setFrame:newFrame];
	[themeFrame addSubview:attachedEncView];
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
	
	// Set the cursor color.
	[self.asciiTextView setInsertionPointColor:self.cursorColor];
	
	// Specify the style for all contained links.
	[self.asciiTextView setLinkTextAttributes:self.linkAttributes];
	
	// Set the color for selected text.
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
	
	// Initialize instance of SVFontController.
	SVFontController *myFontController = [[SVFontController alloc] init];
	
	// Set the font.
	asciiFont = [NSFont fontWithName:myFontController.fontName size:myFontController.fontSize];
	
	// Set line height identical to font size.
	customParagraph = [[NSMutableParagraphStyle alloc] init];
	[customParagraph setLineSpacing:0];
	[customParagraph setMinimumLineHeight:myFontController.fontSize];
	[customParagraph setMaximumLineHeight:myFontController.fontSize];
	
	// Disable Line Wrapping.
	[customParagraph setLineBreakMode:NSLineBreakByTruncatingTail];
	
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

- (void)performFontColorChange:(NSNotification *)note
{
	NSColor *fontColorValue = [[note userInfo] objectForKey:@"fontColorValue"];
	[self.asciiTextView setTextColor:fontColorValue];
}

- (void)performBgrndColorChange:(NSNotification *)note
{
	NSColor *bgrndColorValue = [[note userInfo] objectForKey:@"bgrndColorValue"];
	[self.asciiTextView setBackgroundColor:bgrndColorValue];
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
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSCursor pointingHandCursor], NSCursorAttributeName,
			[NSNumber numberWithInt:NSUnderlineStyleSingle], NSUnderlineStyleAttributeName,
			self.linkColor, NSForegroundColorAttributeName, nil];
}

- (NSDictionary *)selectionAttributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			self.selectionColor, NSBackgroundColorAttributeName, nil];
}

# pragma mark -
# pragma mark getter and setter

- (NSMutableAttributedString *)string 
{ 
	return self.contentString; 
}

- (void)setString:(NSMutableAttributedString *)newValue {
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

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	// Write data using the given encoding. 
	NSData *data = [self.contentString.string dataUsingEncoding:self.charEncoding];
	
	// Enable undo after save operations.
	[self.asciiTextView breakUndoCoalescing];
	
	return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	BOOL readSuccess = NO;
	
	// Try reading the file data using the specified encoding.
	NSString *fileContent = 
	[[NSString alloc] initWithData:data encoding:self.charEncoding];
	
	// In case the data is unreadable, do the following.
	if (!fileContent) 
	{
		// Check if the user wants information about the failed encoding.
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		switch ([defaults boolForKey:@"encNotApplicableNote"]) {
			case YES: {
				// Report that the encoding in not applicable.
				if (self.charEncoding == UnicodeUTF8) {
					NSRunInformationalAlertPanel(@"Encoding not applicable", 
												 @"This document does not contain Unicode characters.", 
												 @"OK", nil, nil);
				}
				else if (self.charEncoding == MacRomanASCII) {
					NSRunInformationalAlertPanel(@"Encoding not applicable", 
												 @"This document does not contain Mac Roman characters.", 
												 @"OK", nil, nil);
				}
				else if (self.charEncoding == BlockASCII) {
					NSRunInformationalAlertPanel(@"Encoding not applicable", 
												 @"This document does not contain Block ASCII characters.", 
												 @"OK", nil, nil);
				}
			}
				break;
			case NO: {
				break;	
			}
			default: {
				break;
			}
		}
		// Apply the fail encoding.
		switch ([defaults integerForKey:@"failEncoding"]) 
		{
			case EncBlockASCII: {
				self.charEncoding = BlockASCII;
				break;
			}
			case EncUnicode: {
				self.charEncoding = UnicodeUTF8;
				break;
			}
			case EncMacRoman: {
				self.charEncoding = MacRomanASCII;
				break;
			}
			default: {
				break;
			}
		}
		fileContent = [[NSString alloc] initWithData:data encoding:self.charEncoding];
	}
	// In case the data was readable, continue here.
    if (fileContent) 
	{
		readSuccess = YES;
		NSMutableAttributedString *importString = [[NSMutableAttributedString alloc] initWithString:fileContent];
		[self setString:importString];
		
		// If the UI is already loaded, this must be a 'revert to saved' operation.
		if (self.asciiTextView) 
		{
			// Apply the loaded data to the text storage and restyle contents.
			[[self.asciiTextView textStorage] setAttributedString:[self string]];
			[self prepareContent];
		}
    }
	[self updateFileInfoValues];
    return readSuccess;
}

- (void)switchEncoding
{
	// Read our desired encoding from user defaults.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	switch ([defaults integerForKey:@"preferredEncoding"]) 
	{
		case EncBlockASCII: {
			self.charEncoding = BlockASCII;
			break;
		}
		case EncUnicode: {
			self.charEncoding = UnicodeUTF8;
			break;
		}
		case EncMacRoman: {
			self.charEncoding = MacRomanASCII;
			break;
		}
		default: {
			break;
		}
	}
}

- (void)switchEncodingButton
{
	// Update encoding button to display the correct encoding.
	if (self.charEncoding == UnicodeUTF8) 
	{
		[self.encodingButton selectItemAtIndex:EncUnicode];
	}
	else if (self.charEncoding == MacRomanASCII) 
	{
		[self.encodingButton selectItemAtIndex:EncMacRoman];
	}
	else {
		[self.encodingButton selectItemAtIndex:EncBlockASCII];
	}
}

- (IBAction)encodeInBlockASCII:(id)sender
{
	// In case the string is already in Block ASCII encoding, leave this place.
	if (self.charEncoding == BlockASCII) {
		return;
	}
	// Create data object from the current content string.
	NSData *strData = [self.contentString.string dataUsingEncoding:self.charEncoding];
	NSMutableString *encodedStr = [[NSMutableString alloc] initWithData:strData encoding:BlockASCII];
	
	if (encodedStr) {
		// Init temporary attributed string with our encoded content.
		NSMutableAttributedString *tempAtrStr = [[NSMutableAttributedString alloc] initWithString:encodedStr];
		
		// Apply the new content string and set it's encoding.
		self.charEncoding = BlockASCII;
		[self setString:tempAtrStr];
		[[self.asciiTextView textStorage] setAttributedString:[self string]];
		
		// Apply the appearance attributes.
		[self prepareContent];
	}
	else {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults boolForKey:@"encNotApplicableNote"] == YES) 
		{
			// Display note that the encoding can not be applied.
			NSRunInformationalAlertPanel(@"Encoding not applicable", 
										 @"This document does not contain Block ASCII characters.", 
										 @"OK", nil, nil);
		}
		// Switch encoding button to previous selection.
		[self switchEncodingButton];
	}
}

- (IBAction)encodeInUnicode:(id)sender 
{	
	// In case the string is already in UTF8 encoding, bye bye.
	if (self.charEncoding == UnicodeUTF8) {
		return;
	}
	// Create data object from the current content string.
	NSData *strData = [self.contentString.string dataUsingEncoding:self.charEncoding];
	NSMutableString *encodedStr = [[NSMutableString alloc] initWithData:strData encoding:UnicodeUTF8];
	
	if (encodedStr) {
		// Init temporary attributed string with our encoded content.
		NSMutableAttributedString *tempAtrStr = [[NSMutableAttributedString alloc] initWithString:encodedStr];
		
		// Apply the new content string and set it's encoding.
		self.charEncoding = UnicodeUTF8;
		[self setString:tempAtrStr];
		[[self.asciiTextView textStorage] setAttributedString:[self string]];
		
		// Apply the appearance attributes.
		[self prepareContent];
	}
	else {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults boolForKey:@"encNotApplicableNote"] == YES) 
		{
			// Display note that the encoding can not be applied.
			NSRunInformationalAlertPanel(@"Encoding not applicable", 
										 @"This document does not contain Unicode characters.", 
										 @"OK", nil, nil);
		}
		// Switch encoding button to previous selection.
		[self switchEncodingButton];
	}
}

- (IBAction)encodeInMacRoman:(id)sender 
{
	if (self.charEncoding == MacRomanASCII) {
		return;
	}
	// Create data object from the current content string.
	NSData *strData = [self.contentString.string dataUsingEncoding:self.charEncoding];
	NSMutableString *encodedStr = [[NSMutableString alloc] initWithData:strData encoding:MacRomanASCII];
	
	if (encodedStr) {
		// Init temporary attributed string with our encoded content.
		NSMutableAttributedString *tempAtrStr = [[NSMutableAttributedString alloc] initWithString:encodedStr];
		
		// Apply the new content string and set it's encoding.
		self.charEncoding = MacRomanASCII;
		[self setString:tempAtrStr];
		[[self.asciiTextView textStorage] setAttributedString:[self string]];
		
		// Apply the appearance attributes.
		[self prepareContent];
	}
	else {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults boolForKey:@"encNotApplicableNote"] == YES) 
		{
			// Display note that the encoding can not be applied.
			NSRunInformationalAlertPanel(@"Encoding not applicable", 
										 @"This document does not contain Mac Roman characters.", 
										 @"OK", nil, nil);
		}
		// Switch encoding button to previous selection.
		[self switchEncodingButton];
	}
}

# pragma mark -
# pragma mark file information

- (IBAction)openFileInformation:(id)sender
{
	// Shared instance of the file information HUD.
	[[SVFileInfoWindowController sharedFileInfoWindowController] showWindow:nil];
	(void)sender;
	
	// Update file information attribute strings.
	[self updateFileInfoValues];
}

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

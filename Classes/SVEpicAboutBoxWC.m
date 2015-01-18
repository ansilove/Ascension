//
//  SVEpicAboutBoxWC.m
//  Ascension
//
//  Copyright (C) 2010-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import "SVEpicAboutBoxWC.h"

@implementation SVEpicAboutBoxWC

@synthesize getInTouchView, getInTouchPopover, licenseSheet, licenseTextView;

# pragma mark -
# pragma mark class methods

+ (SVEpicAboutBoxWC *)sharedEpicAboutBoxWC
{
    // We abuse GCD to be sure this class will be created once.
    static SVEpicAboutBoxWC *sharedEpicAboutBoxWC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEpicAboutBoxWC = [[self alloc] initWithWindowNibName:[self nibName]];
    });
    return sharedEpicAboutBoxWC;
}

+ (NSString *)nibName 
{
    return @"AboutBox";
}

# pragma mark -
# pragma mark initialization

- (void)awakeFromNib
{     
    // This is an 'epic' about box, make the bottom sexy goddammit!
    [self.window setContentBorderThickness:45.0 forEdge:NSMinYEdge];
    
    // Attach the accessory 'get in touch' view to the main window.
    NSView *themeFrame = [[self.window contentView] superview];
	
	NSRect container = [themeFrame frame];
	NSRect getInTouchRect = [self.getInTouchView frame];
	
	NSRect newFrame = NSMakeRect(container.size.width - getInTouchRect.size.width,
								 container.size.height - getInTouchRect.size.height,
								 getInTouchRect.size.width,
								 getInTouchRect.size.height);
	
	[self.getInTouchView setFrame:newFrame];
	[themeFrame addSubview:self.getInTouchView];
    
    // Configure behaviour of the 'get in touch' popover.
    self.getInTouchPopover.behavior = NSPopoverBehaviorTransient;
    self.getInTouchPopover.animates = YES;
    
    // Minor configuration of the embedded licenseTextView.
    [self.licenseTextView.textContainer setLineFragmentPadding:10.0];
    
    // There is only one way for about boxes to see the light: centered.
    [self.window center];
}

# pragma mark -
# pragma mark actions

- (IBAction)showGetInTouchPopover:(id)sender
{
    // This method calls the 'get in touch' popover.
    [self.getInTouchPopover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
}

- (IBAction)openDeveloperSite:(id)sender
{
    // Opens my blog. Enjoy (or not).
    NSString *devSite = (@"http://byteproject.net");
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:devSite]];
}

- (IBAction)openProjectWebsite:(id)sender
{
    // This will open the Ascension website.
    NSString *projectSite = (@"http://ascension.byteproject.net");
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:projectSite]];
}

- (IBAction)followOnTwitter:(id)sender
{
    // Opens my Twitter profile so you can follow me. Careful, may contain tweets.
    NSString *twitterProfile = (@"http://twitter.com/byteproject");
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:twitterProfile]];
}

- (IBAction)orderFrontLicenseSheet:(id)sender
{
    // Invoke the appropriate code, based on the button's sender tag.
    switch ([sender tag]) 
	{
		case AckTag: {
			// First, set the window title to 'Acknowledgements'.
            [self.window setTitle:@"Acknowledgements"];
            
            // Now our NSTextView instance will read the Acknowledgements.rtf file.
            NSBundle *myMainBundle = [NSBundle mainBundle];
            NSString *ackFilePath = [myMainBundle pathForResource:@"Acknowledgements" ofType:@"rtf"];
            [self.licenseTextView readRTFDFromFile:ackFilePath];
            
            // Opens our license textview scrolled to top.
            NSRange zeroRange = { 0, 0 };
            [self.licenseTextView scrollRangeToVisible: zeroRange];
            
            // Show up the license / acknowledgements sheet.
            [NSApp beginSheet:self.licenseSheet
               modalForWindow:self.window 
                modalDelegate:self 
               didEndSelector:NULL 
                  contextInfo:NULL];
			break;
		}
		case LicTag: {
            // Set the window title to 'License Agreement'.
            [self.window setTitle:@"License Agreement"];
            
            // Make our NSTextView instance load the License.rtf file.
            NSBundle *myMainBundle = [NSBundle mainBundle];
            NSString *licenseFilePath = [myMainBundle pathForResource:@"License" ofType:@"rtf"];
            [self.licenseTextView readRTFDFromFile:licenseFilePath];
            
            // Opens our license textview scrolled to top.
            NSRange zeroRange = { 0, 0 };
            [self.licenseTextView scrollRangeToVisible: zeroRange];
            
            // Show up the license / acknowledgements sheet.
            [NSApp beginSheet:self.licenseSheet
               modalForWindow:self.window 
                modalDelegate:self 
               didEndSelector:NULL 
                  contextInfo:NULL];
			break;
		}
		default: {
			break;
		}
    }
}

- (IBAction)orderOutLicenseSheet:(id)sender
{
    // Remove informative window title when the sheet closes.
    [self.window setTitle:@""];
    
    // Remove the license / acknowledgements sheet.
    [NSApp endSheet:self.licenseSheet]; 
    [self.licenseSheet orderOut:nil];
}

@end

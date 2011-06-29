//
//  SVFileInfoWindowController.h
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import <Cocoa/Cocoa.h>

@class SVFileInfoPopoverController;

@interface SVFileInfoWindowController : NSWindowController <NSPopoverDelegate> {

@private
    NSPopover *fileInfoPopover;
    
    // Detached window for the popover.
    IBOutlet NSWindow *detachedWindow;
    
    // NSViewController for the file info popover.
    IBOutlet SVFileInfoPopoverController *popoverViewController;
    
    // NSViewController for our detached popover window.
    IBOutlet SVFileInfoPopoverController *detachedWindowViewController;
}

- (IBAction)showPopoverAction:(id)sender;

@property (retain) NSPopover *fileInfoPopover;

@end
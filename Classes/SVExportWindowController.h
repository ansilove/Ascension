//
//  SVExportWindowController.h
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import <Cocoa/Cocoa.h>

@class SVExportPopoverController;

@interface SVExportWindowController : NSWindowController <NSPopoverDelegate> {

@private
    NSPopover *exportPopover;
    
    // detached window for the popover
    IBOutlet NSWindow *detachedWindow;
    
    // NSViewController for the export popover
    IBOutlet SVExportPopoverController *popoverViewController;
    
    // NSViewController for our detached popover window
    IBOutlet SVExportPopoverController *detachedWindowViewController;
}

- (IBAction)showPopoverAction:(id)sender;

@property (retain) NSPopover *exportPopover;

@end
//
//  SVExportWindowController.m
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import "SVExportWindowController.h"
#import "SVExportPopoverController.h"

@implementation SVExportWindowController

@synthesize exportPopover;

- (void)awakeFromNib
{
    // Set separate copies of the view controller's view to each detached window
    detachedWindow.contentView = detachedWindowViewController.view;
}

- (void)createPopover
{
    if (self.exportPopover == nil)
    {
        // Create and setup our popover.
        exportPopover = [[NSPopover alloc] init];
        
        // Define the view controller to use.
        self.exportPopover.contentViewController = popoverViewController;
        
        // We want an animated popover.
        self.exportPopover.animates = YES;
        
        // Close the popover when the user interacts with a UI element outside the popover.
        self.exportPopover.behavior = NSPopoverBehaviorTransient;
        
        // Let us be notified when the popover appears or closes.
        self.exportPopover.delegate = self;
    }
}

- (IBAction)showPopoverAction:(id)sender
{
    [self createPopover];
    
    // Configure the preferred position of the popover. Possible positions:
    // left (NSMinXEdge),  right (NSMaxXEdge), top (NSMinYEdge), bottom (NSMaxYEdge).
    NSRectEdge prefEdge = NSMinYEdge;
    
    [self.exportPopover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:prefEdge];
}

#pragma mark -
#pragma mark NSPopoverDelegate

- (NSWindow *)detachableWindowForPopover:(NSPopover *)popover
{
    // Invoked on the delegate asked for the detachable window for the popover.
    NSWindow *window = detachedWindow;
    return window;
}

@end

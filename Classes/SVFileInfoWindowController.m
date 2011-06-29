//
//  SVFileInfoWindowController.m
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import "SVFileInfoWindowController.h"
#import "SVfileInfoPopoverController.h"

@implementation SVFileInfoWindowController

@synthesize fileInfoPopover;

- (void)awakeFromNib
{
    // Set separate copies of the view controller's view to each detached window
    detachedWindow.contentView = detachedWindowViewController.view;
}

- (void)createPopover
{
    if (self.fileInfoPopover == nil)
    {
        // Create and setup our popover.
        fileInfoPopover = [[NSPopover alloc] init];
        
        // Define the view controller to use.
        self.fileInfoPopover.contentViewController = popoverViewController;
        
        // We want an animated popover.
        self.fileInfoPopover.animates = YES;
        
        // Close the popover when the user interacts with a UI element outside the popover.
        self.fileInfoPopover.behavior = NSPopoverBehaviorTransient;
        
        // Let us be notified when the popover appears or closes.
        self.fileInfoPopover.delegate = self;
    }
}

- (IBAction)showPopoverAction:(id)sender
{
    [self createPopover];
    
    // Configure the preferred position of the popover. Possible positions:
    // left (NSMinXEdge),  right (NSMaxXEdge), top (NSMinYEdge), bottom (NSMaxYEdge).
    NSRectEdge prefEdge = NSMinYEdge;
    
    [self.fileInfoPopover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:prefEdge];
}

#pragma mark -
#pragma mark NSPopoverDelegate

- (NSWindow *)detachableWindowForPopover:(NSPopover *)popover
{
    // Invoked on the delegate asked for the detachable window for the popover.
    NSWindow *window = detachedWindow;
    return window;
}

- (void)popoverDidShow:(NSNotification *)notification
{
    // added for implementations to come
}

@end

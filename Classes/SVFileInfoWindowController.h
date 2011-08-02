//
//  SVFileInfoWindowController.h
//  Ascension
//
//  Copyright (c) 2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
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
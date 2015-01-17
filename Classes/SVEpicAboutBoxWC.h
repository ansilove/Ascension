//
//  SVEpicAboutBoxWC.h
//  Ascension
//
//  Copyright (C) 2011-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>

// Significantly improves readability while working with sender tags.
typedef enum {
    AckTag,
    LicTag
} SVAboutBoxButtonTag;

@interface SVEpicAboutBoxWC : NSWindowController

// outlets
@property (nonatomic, strong) IBOutlet NSView       *getInTouchView;
@property (nonatomic, strong) IBOutlet NSPopover    *getInTouchPopover;
@property (nonatomic, strong) IBOutlet NSPanel      *licenseSheet;
@property (nonatomic, strong) IBOutlet NSTextView   *licenseTextView;

// class methods
+ (SVEpicAboutBoxWC *)sharedEpicAboutBoxWC;
+ (NSString *)nibName;

// actions
- (IBAction)showGetInTouchPopover:(id)sender;
- (IBAction)openDeveloperSite:(id)sender;
- (IBAction)openProjectWebsite:(id)sender;
- (IBAction)followOnTwitter:(id)sender;
- (IBAction)orderFrontLicenseSheet:(id)sender;
- (IBAction)orderOutLicenseSheet:(id)sender;

@end

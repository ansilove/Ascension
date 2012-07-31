//
//  SVEpicAboutBoxWC.h
//  Ascension
//
//  Copyright (c) 2010-2012, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
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
- (IBAction)openDevelopersBlog:(id)sender;
- (IBAction)openProjectWebsite:(id)sender;
- (IBAction)followOnTwitter:(id)sender;
- (IBAction)orderFrontLicenseSheet:(id)sender;
- (IBAction)orderOutLicenseSheet:(id)sender;
- (IBAction)grabEscapes:(id)sender;

@end

//
//  SVEpicAboutBoxWC.h
//  Ascension
//
//  Copyright (c) 2010-2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>

@interface SVEpicAboutBoxWC : NSWindowController

// outlets
@property (nonatomic, strong) IBOutlet NSView *getInTouchView;
@property (nonatomic, strong) IBOutlet NSPopover *getInTouchPopover;

// class methods
+ (SVEpicAboutBoxWC *)sharedEpicAboutBoxWC;
+ (NSString *)nibName;

// actions
- (IBAction)showGetInTouchPopover:(id)sender;
- (IBAction)openDevelopersBlog:(id)sender;
- (IBAction)openProjectWebsite:(id)sender;
- (IBAction)followOnTwitter:(id)sender;

@end

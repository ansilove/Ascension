//
//  SVAscensionDelegate.h
//  Ascension
//
//  Copyright (C) 2010-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>

@interface SVAscensionDelegate : NSObject <NSApplicationDelegate>

// integer and float values
@property (nonatomic, assign) BOOL applicationHasStarted;
@property (nonatomic, assign) BOOL enableSaveMenuItem;

// actions
- (IBAction)openPreferences:(id)sender;
- (IBAction)readAnsiLoveDocumentation:(id)sender;
- (IBAction)showAboutBox:(id)sender;

// general stuff
- (void)disableSaveItem:(NSNotification *)note;
- (void)enableSaveItem:(NSNotification *)note;

@end

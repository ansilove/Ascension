//
//  SVPreferencesWC.h
//  Ascension
//
//  Copyright (C) 2010-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>

@interface SVPreferencesWC : NSWindowController <NSToolbarDelegate> 

// outlets
@property (nonatomic, strong) IBOutlet NSToolbar *prefsBar;
@property (nonatomic, strong) IBOutlet NSView	 *generalPrefView;
@property (nonatomic, strong) IBOutlet NSView    *interfacePrefView;
@property (nonatomic, strong) IBOutlet NSView	 *textPrefView;
@property (nonatomic, strong) IBOutlet NSView    *themePrefView;
@property (nonatomic, strong) IBOutlet NSView    *asciiPrefView;
@property (nonatomic, strong) IBOutlet NSView    *ansiPrefView;

// integer and float values
@property (nonatomic, assign) NSInteger currentViewTag;

// class methods
+ (SVPreferencesWC *)sharedPreferencesWC;
+ (NSString *)nibName;

// general methods
- (NSView *)viewForTag:(NSInteger)tag;
- (NSRect)newFrameForNewContentView:(NSView *)view;

// actions
- (IBAction)switchView:(id)sender;

@end

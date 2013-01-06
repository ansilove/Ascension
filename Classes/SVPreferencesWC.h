//
//  SVPreferencesWC.h
//  Ascension
//
//  Copyright (c) 2010-2013, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>

@interface SVPreferencesWC : NSWindowController <NSToolbarDelegate> 

// outlets
@property (nonatomic, strong) IBOutlet NSToolbar *prefsBar;
@property (nonatomic, strong) IBOutlet NSView	 *generalPrefView;
@property (nonatomic, strong) IBOutlet NSView    *interfacePrefView;
@property (nonatomic, strong) IBOutlet NSView    *schemePrefView;
@property (nonatomic, strong) IBOutlet NSView    *asciiPrefView;

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

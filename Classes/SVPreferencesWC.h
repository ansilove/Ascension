//
//  SVPreferencesWC.h
//  Ascension
//
//  Copyright (c) 2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>

@interface SVPreferencesWC : NSWindowController <NSToolbarDelegate> 

// outlets
@property (nonatomic, strong) IBOutlet NSToolbar *prefsBar;
@property (nonatomic, strong) IBOutlet NSView	 *generalPreferenceView;
@property (nonatomic, strong) IBOutlet NSView    *colorsPreferenceView;
@property (nonatomic, strong) IBOutlet NSView	 *advancedPreferenceView;

// integer and float values
@property (nonatomic, assign) NSInteger currentViewTag;

// class methods
+ (SVPreferencesWC *)sharedPrefsWindowController;
+ (NSString *)nibName;

// general methods
- (NSView *)viewForTag:(NSInteger)tag;
- (NSRect)newFrameForNewContentView:(NSView *)view;

// actions
- (IBAction)switchView:(id)sender;

@end

//
//  SVPrefsWindowController.h
//  Ascension
//
//  Copyright (c) 2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>

@interface SVPrefsWindowController : NSWindowController <NSToolbarDelegate> {
	
	IBOutlet NSToolbar *prefsBar;
	IBOutlet NSView	   *generalPreferenceView;
	IBOutlet NSView    *colorsPreferenceView;
	IBOutlet NSView	   *advancedPreferenceView;
	
	NSInteger currentViewTag;
}

// class methods
+ (SVPrefsWindowController *)sharedPrefsWindowController;
+ (NSString *)nibName;

// general methods
- (NSView *)viewForTag:(NSInteger)tag;
- (NSRect)newFrameForNewContentView:(NSView *)view;

// actions
- (IBAction)switchView:(id)sender;

@end

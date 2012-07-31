//
//  SVPreferences.h
//  Ascension
//
//  Copyright (c) 2010-2012, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	sDOS,
    sBlackAndWhite,
    sReversed
} ColorSchemes;

@class SVToggleSlider;

@interface SVPreferences : NSObject

// class methods
+ (void)checkUserDefaults;

// actions
- (IBAction)restoreUserDefaults:(id)sender;
- (IBAction)synchronizeDefaults:(id)sender;
- (IBAction)changeResumeState:(id)sender;
- (IBAction)selectScrollerStyle:(id)sender;
- (IBAction)changeHyperLinkAttributes:(id)sender;
- (IBAction)setColorScheme:(id)sender;

@end

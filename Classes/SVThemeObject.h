//
//  SVThemeObject.h
//  Ascension
//
//  Copyright (c) 2010-2012, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import <Foundation/Foundation.h>

@interface SVThemeObject : NSObject <NSCoding>

// strings
@property (nonatomic, strong) NSString *atName;

// colors
@property (nonatomic, strong) NSColor *atFontColor;
@property (nonatomic, strong) NSColor *atBackgroundColor;
@property (nonatomic, strong) NSColor *atLinkColor;
@property (nonatomic, strong) NSColor *atCursorColor;
@property (nonatomic, strong) NSColor *atSelectionColor;

@end

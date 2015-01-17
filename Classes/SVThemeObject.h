//
//  SVThemeObject.h
//  Ascension
//
//  Copyright (C) 2011-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
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

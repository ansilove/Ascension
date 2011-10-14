//
//  SVFontProperties.h
//  Ascension
//
//  Copyright (c) 2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>

@interface SVFontProperties : NSObject

// strings
@property (nonatomic, weak) NSString *fontName;

// integer and float values
@property (nonatomic, assign) CGFloat fontSize;

@end

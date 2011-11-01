//
//  SVEpicAboutBox.h
//  Ascension
//
//  Copyright (c) 2010-2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import <Foundation/Foundation.h>

@interface SVEpicAboutBox : NSObject

@property (nonatomic, strong) NSString *bundleShortVersionString;
@property (nonatomic, strong) NSString *bundleVersionNumber;
@property (nonatomic, strong) NSString *humanReadableCopyright;

@end

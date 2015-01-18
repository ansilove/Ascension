//
//  SVEpicAboutBox.h
//  Ascension
//
//  Copyright (C) 2010-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import <Foundation/Foundation.h>

// Class providing NSBundle informations. Gets automatically initalized
// when interface elements are bound to it's containing properties.

@interface SVEpicAboutBox : NSObject

@property (nonatomic, strong) NSString *bundleShortVersionString;
@property (nonatomic, strong) NSString *bundleVersionNumber;
@property (nonatomic, strong) NSString *humanReadableCopyright;

@end

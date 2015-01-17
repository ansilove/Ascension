//
//  SVEpicAboutBox.m
//  Ascension
//
//  Copyright (C) 2011-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import "SVEpicAboutBox.h"

#define selfBundleID @"com.byteproject.Ascension"

@implementation SVEpicAboutBox

@synthesize bundleShortVersionString, bundleVersionNumber, humanReadableCopyright;

- (id)init
{
    if (self == [super init]) 
    {
        // Fetch the keys we need from info.plist and assign them to our synthesized properties.
        self.bundleShortVersionString =
        [[[NSBundle bundleWithIdentifier:selfBundleID] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
        
        self.bundleVersionNumber =
        [[[NSBundle bundleWithIdentifier:selfBundleID] infoDictionary] valueForKey:@"CFBundleVersion"];
        
        self.humanReadableCopyright =
        [[[NSBundle bundleWithIdentifier:selfBundleID] infoDictionary] valueForKey:@"NSHumanReadableCopyright"];
    }
    return self;
}

@end

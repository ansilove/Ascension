//
//  SVEpicAboutBox.m
//  Ascension
//
//  Copyright (c) 2010-2013, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
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

//
//  SVEpicAboutBox.m
//  Ascension
//
//  Copyright (C) 2010-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import "SVEpicAboutBox.h"

#define selfBundleID @"com.byteproject.Ascension"
#define ansiLoveBundleID @"com.byteproject.AnsiLove"

@implementation SVEpicAboutBox

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
        
        self.blockZoneVersionInformation =
        [[[NSBundle bundleWithIdentifier:selfBundleID] infoDictionary] valueForKey:@"BlockZone version"];
        
        self.ansiLoveVersionInformation =
        [[[NSBundle bundleWithIdentifier:ansiLoveBundleID] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    }
    return self;
}

@end

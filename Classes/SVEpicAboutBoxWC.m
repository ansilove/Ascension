//
//  SVEpicAboutBoxWC.m
//  Ascension
//
//  Copyright (c) 2010-2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import "SVEpicAboutBoxWC.h"

@implementation SVEpicAboutBoxWC

# pragma mark -
# pragma mark class methods

+ (SVEpicAboutBoxWC *)sharedEpicAboutBoxWC
{
    // We abuse GCD to be sure this class will be created once.
    static SVEpicAboutBoxWC *sharedEpicAboutBoxWC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEpicAboutBoxWC = [[self alloc] initWithWindowNibName:[self nibName]];
    });
    return sharedEpicAboutBoxWC;
}

+ (NSString *)nibName 
{
    return @"AboutBox";
}

# pragma mark -
# pragma mark class methods

- (void)awakeFromNib
{
    // This is an 'epic' about box, make the bottom sexy goddammit!
    [self.window setContentBorderThickness:45.0 forEdge:NSMinYEdge];
	
    // There is only one way for about boxes to see the light: centered.
    [self.window center];
}

@end

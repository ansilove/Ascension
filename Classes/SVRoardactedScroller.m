//
//  SVRoardactedScroller.m
//  Ascension
//
//  Copyright (c) 2010-2012, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import "SVRoardactedScroller.h"

@implementation SVRoardactedScroller

+ (BOOL)isCompatibleWithOverlayScrollers
{
    return self == [SVRoardactedScroller class];
}

- (void)setKnobStyle:(NSScrollerKnobStyle)newKnobStyle
{
    return [super setKnobStyle:newKnobStyle];
}

@end

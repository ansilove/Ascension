//
//  SVRoardactedScroller.m
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
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

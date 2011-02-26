//
//  SVTransparentScroller.h
//  Ascension
//
//  Forked by Stefan Vogt, based on code by Brandon Walkin.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import <Cocoa/Cocoa.h>

// Subclass of NSScroller with custom knobs and a background that will match theme colors.

@interface SVTransparentScroller : NSScroller {
    
	BOOL isVertical;
}

- (void)applyScrollerBgrndColor:(NSNotification *)note;

@end

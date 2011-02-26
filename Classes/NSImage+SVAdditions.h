//
//  NSImage+SVAdditions.h
//  Ascension
//
//  Forked by Stefan Vogt, based on code by Brandon Walkin.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import <Cocoa/Cocoa.h>

@interface NSImage (SVAdditions)

// Draw a solid color over an image - taking into account alpha. Useful for coloring template images.
- (NSImage *)bwTintedImageWithColor:(NSColor *)tint;

// Rotate an image 90 degrees clockwise or counterclockwise
- (NSImage *)bwRotateImage90DegreesClockwise:(BOOL)clockwise;

@end

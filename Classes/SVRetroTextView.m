//
//  SVTextView.m
//  Ascension
//
//  Copyright (C) 2011-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import "SVRetroTextView.h"

@implementation SVRetroTextView

- (BOOL)readSelectionFromPasteboard:(NSPasteboard *)pboard
							   type:(NSString *)type
{
	// Send a note if the user pastes content into SVTextView.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"PasteNote" object:self];
	
	return [super readSelectionFromPasteboard:pboard type:type];
}

- (BOOL)importsGraphics 
{
    // Override this so we can import rendered ANSi images.
    return YES;
}

- (void)drawRect:(NSRect)rect
{
    // Define CGContext reference.
    CGContextRef ctxt = [[NSGraphicsContext currentContext] graphicsPort];
    
    // Antialiasing.
    CGContextSetShouldAntialias(ctxt, false);
    CGContextSetAllowsAntialiasing(ctxt, false);
    
    // Font smoothing, subpixel positioning and quantization.
    CGContextSetShouldSmoothFonts(ctxt, false);
    CGContextSetAllowsFontSmoothing(ctxt, false);
    CGContextSetShouldSubpixelPositionFonts(ctxt, false);
    CGContextSetAllowsFontSubpixelPositioning(ctxt, false);
    CGContextSetShouldSubpixelQuantizeFonts(ctxt, false);
    CGContextSetAllowsFontSubpixelQuantization(ctxt, false);
    
    // Text drawing mode. Set to default value but you might want to alter it.
    CGContextSetTextDrawingMode(ctxt, kCGTextFill);
    
    // Additional space to place between glyphs can be added here.
    CGContextSetCharacterSpacing(ctxt, 0.0);
    
    // Calling super finally.
    [super drawRect:rect];
}

@end

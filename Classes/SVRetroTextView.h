//
//  SVTextView.h
//  Ascension
//
//  Copyright (C) 2010-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>

// Subclass of NSTextView that is optimzied for displaying retro
// typefaces. It disables antialiasing, font smoothing, subpixel
// positioning and subpixel quantization. Consequently, pixelfonts
// and block art using extended character sets are displayed as
// originally intended. It also comes with an option to customize
// the way CoreGraphics draws characters in your SVRetroTextView
// instance, as well as with an option to tweak character spacing.

@interface SVRetroTextView : NSTextView

@end

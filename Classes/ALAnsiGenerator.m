//
//  ALAnsiGenerator.m
//  Ascension
//
//  Copyright (C) 2011-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//
//  Wrapper around Homebrew libansilove, replacing the old AnsiLove.framework.
//

#import "ALAnsiGenerator.h"
#import <ansilove.h>

#pragma mark - Font name to constant mapping

static uint8_t ALFontConstantFromString(NSString *fontName)
{
    static NSDictionary *fontMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fontMap = @{
            @"80x25"          : @(ANSILOVE_FONT_CP437),
            @"80x50"          : @(ANSILOVE_FONT_CP437_80x50),
            @"terminus"       : @(ANSILOVE_FONT_TERMINUS),
            @"baltic"         : @(ANSILOVE_FONT_CP775),
            @"cyrillic"       : @(ANSILOVE_FONT_CP855),
            @"french-canadian": @(ANSILOVE_FONT_CP863),
            @"greek"          : @(ANSILOVE_FONT_CP737),
            @"greek-869"      : @(ANSILOVE_FONT_CP869),
            @"hebrew"         : @(ANSILOVE_FONT_CP862),
            @"icelandic"      : @(ANSILOVE_FONT_CP861),
            @"latin1"         : @(ANSILOVE_FONT_CP850),
            @"latin2"         : @(ANSILOVE_FONT_CP852),
            @"nordic"         : @(ANSILOVE_FONT_CP865),
            @"portuguese"     : @(ANSILOVE_FONT_CP860),
            @"russian"        : @(ANSILOVE_FONT_CP866),
            @"turkish"        : @(ANSILOVE_FONT_CP857),
            @"topaz"          : @(ANSILOVE_FONT_TOPAZ),
            @"topaz+"         : @(ANSILOVE_FONT_TOPAZ_PLUS),
            @"topaz500"       : @(ANSILOVE_FONT_TOPAZ500),
            @"topaz500+"      : @(ANSILOVE_FONT_TOPAZ500_PLUS),
            @"mosoul"         : @(ANSILOVE_FONT_MOSOUL),
            @"pot-noodle"     : @(ANSILOVE_FONT_POT_NOODLE),
            @"microknight"    : @(ANSILOVE_FONT_MICROKNIGHT),
            @"microknight+"   : @(ANSILOVE_FONT_MICROKNIGHT_PLUS),
        };
    });

    NSNumber *value = fontMap[[fontName lowercaseString]];
    if (value) {
        return [value unsignedCharValue];
    }
    return ANSILOVE_FONT_CP437;
}

#pragma mark - Format handler selection based on file extension

typedef int (*AnsiloveFormatHandler)(struct ansilove_ctx *, struct ansilove_options *);

static AnsiloveFormatHandler ALFormatHandlerForExtension(NSString *extension)
{
    static NSDictionary *handlerMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handlerMap = @{
            @"ans" : [NSValue valueWithPointer:ansilove_ansi],
            @"bin" : [NSValue valueWithPointer:ansilove_binary],
            @"idf" : [NSValue valueWithPointer:ansilove_icedraw],
            @"pcb" : [NSValue valueWithPointer:ansilove_pcboard],
            @"xb"  : [NSValue valueWithPointer:ansilove_xbin],
            @"adf" : [NSValue valueWithPointer:ansilove_artworx],
            @"tnd" : [NSValue valueWithPointer:ansilove_tundra],
        };
    });

    NSValue *handler = handlerMap[[extension lowercaseString]];
    if (handler) {
        return [handler pointerValue];
    }

    // Default for .nfo, .diz, .asc, .txt and other text formats.
    return ansilove_ansi;
}

#pragma mark - Bits/mode string parsing

static void ALApplyBitsAndMode(NSString *bits, struct ansilove_options *options)
{
    if (bits == nil || [bits length] == 0) {
        options->bits = 8;
        return;
    }

    NSString *lower = [bits lowercaseString];

    if ([lower isEqualToString:@"9"]) {
        options->bits = 9;
    } else if ([lower isEqualToString:@"ced"]) {
        options->mode = ANSILOVE_MODE_CED;
    } else if ([lower isEqualToString:@"workbench"]) {
        options->mode = ANSILOVE_MODE_WORKBENCH;
    } else if ([lower isEqualToString:@"transparent"]) {
        options->mode = ANSILOVE_MODE_TRANSPARENT;
    } else {
        // Default: "8" or any unrecognized value.
        options->bits = 8;
    }
}

#pragma mark - Single render pass

static BOOL ALRenderOnce(NSString *inputFile,
                         NSString *outputPath,
                         struct ansilove_options *templateOptions,
                         uint8_t scaleFactor)
{
    struct ansilove_ctx ctx;
    struct ansilove_options options = *templateOptions;
    options.scale_factor = scaleFactor;

    if (ansilove_init(&ctx, &options) != 0) {
        NSLog(@"ALAnsiGenerator: ansilove_init failed.");
        return NO;
    }

    if (ansilove_loadfile(&ctx, [inputFile fileSystemRepresentation]) != 0) {
        NSLog(@"ALAnsiGenerator: ansilove_loadfile failed for %@ — %s",
              inputFile, ansilove_error(&ctx));
        ansilove_clean(&ctx);
        return NO;
    }

    // Select the appropriate format handler based on the file extension.
    NSString *extension = [inputFile pathExtension];
    AnsiloveFormatHandler handler = ALFormatHandlerForExtension(extension);

    if (handler(&ctx, &options) != 0) {
        NSLog(@"ALAnsiGenerator: format handler failed for %@ — %s",
              inputFile, ansilove_error(&ctx));
        ansilove_clean(&ctx);
        return NO;
    }

    if (ansilove_savefile(&ctx, [outputPath fileSystemRepresentation]) != 0) {
        NSLog(@"ALAnsiGenerator: ansilove_savefile failed for %@ — %s",
              outputPath, ansilove_error(&ctx));
        ansilove_clean(&ctx);
        return NO;
    }

    ansilove_clean(&ctx);
    return YES;
}

#pragma mark -

@implementation ALAnsiGenerator

- (void)renderAnsiFile:(NSString *)inputFile
            outputFile:(NSString *)outputFile
                  font:(NSString *)font
                  bits:(NSString *)bits
             iceColors:(BOOL)iceColors
               columns:(NSString *)columns
                retina:(BOOL)generateRetina
{
    // Store parameters in properties (preserves old framework behaviour).
    self.ansi_inputFile  = inputFile;
    self.ansi_outputFile = outputFile;
    self.ansi_font       = font;
    self.ansi_bits       = bits;
    self.ansi_iceColors  = iceColors;
    self.ansi_columns    = columns;
    self.generatesRetinaFile = generateRetina;

    // Build a template options struct shared by all render passes.
    struct ansilove_options options;
    memset(&options, 0, sizeof(options));

    options.font      = ALFontConstantFromString(font);
    options.icecolors = (bool)iceColors;
    options.dos       = true;

    if (columns != nil && [columns length] > 0) {
        options.columns = (int16_t)[columns intValue];
    }

    ALApplyBitsAndMode(bits, &options);

    // Determine final output paths.
    // The caller passes a base path (without .png extension).
    // We append .png / @2x.png to match what SVBlockDrawDocument expects.
    NSString *normalOutput = [NSString stringWithFormat:@"%@.png", outputFile];
    NSString *retinaOutput = [NSString stringWithFormat:@"%@@2x.png", outputFile];

    // Retina pass first (scale_factor = 2), then normal (scale_factor = 1).
    if (generateRetina) {
        ALRenderOnce(inputFile, retinaOutput, &options, 2);
        self.ansi_retinaOutputFile = retinaOutput;
    }

    ALRenderOnce(inputFile, normalOutput, &options, 1);

    // Store the raw output path for consumers that need it.
    self.rawOutputString = normalOutput;

    // Post the notification that callers are listening for.
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"AnsiLoveFinishedRendering"
                      object:self];
}

@end

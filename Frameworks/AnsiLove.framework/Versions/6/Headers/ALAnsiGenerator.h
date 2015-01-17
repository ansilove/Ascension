//
//  ALAnsiGenerator.h
//  AnsiLove.framework
//
//  Copyright (C) 2011-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import <Foundation/Foundation.h>

@interface ALAnsiGenerator : NSObject

// Affecting supported output formats.
@property (nonatomic, assign) BOOL generatesRetinaFile;

// Affecting implemented rendering options.
@property (nonatomic, assign) BOOL usesDefaultFont;
@property (nonatomic, assign) BOOL usesDefaultBits;
@property (nonatomic, assign) BOOL usesDefaultColumns;
@property (nonatomic, assign) BOOL hasSauceRecord;

// ANSi file
@property (nonatomic, strong) NSString *ansi_inputFile;
@property (nonatomic, strong) NSString *ansi_outputFile;
@property (nonatomic, strong) NSString *ansi_retinaOutputFile;
@property (nonatomic, strong) NSString *ansi_font;
@property (nonatomic, strong) NSString *ansi_bits;
@property (nonatomic, assign) BOOL      ansi_iceColors;
@property (nonatomic, strong) NSString *ansi_columns;
@property (nonatomic, strong) NSString *rawOutputString;

// One method to make the magic happen.
- (void)renderAnsiFile:(NSString *)inputFile
            outputFile:(NSString *)outputFile
                  font:(NSString *)font
                  bits:(NSString *)bits
             iceColors:(BOOL      )iceColors
               columns:(NSString *)columns
                retina:(BOOL      )generateRetina;

@end

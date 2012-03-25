//
//  ALAnsiGenerator.h
//  AnsiLove.framework
//
//  Copyright (c) 2011-2012, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import <Foundation/Foundation.h>

@interface ALAnsiGenerator : NSObject

// class methods
+ (void)createPNGFromAnsiSource:(NSString *)inputFile 
                     outputFile:(NSString *)outputFile
                           font:(NSString *)font 
                           bits:(NSString *)bits
                      iceColors:(NSString *)iceColors
                        columns:(NSString *)columns;

@end

//
//  NSImage+SVExtensions.h
//  Ascension
//
//  Copyright (C) 2010-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (SVExtensions)

- (id)initWithHiResContentsOfURL:(NSURL *)url;
- (id)initWithHiResContentsOfFile:(NSString *)fileName;

@end

//
//  NSImage+SVExtensions.m
//  Ascension
//
//  Copyright (C) 2010-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import "NSImage+SVExtensions.h"

@implementation NSImage (SVExtensions)

- (id)initWithHiResContentsOfURL:(NSURL *)url
{
    if ((self = [self initWithContentsOfURL:url]))
    {
        NSURL *strippedURL = url.URLByDeletingLastPathComponent;
        NSString *strippedName = url.lastPathComponent.stringByDeletingPathExtension;
        NSString *ext = url.lastPathComponent.pathExtension;
        NSString *hiResStrippedName = [NSString stringWithFormat:@"%@@2x", strippedName];
        NSURL *hiResURL = [strippedURL URLByAppendingPathComponent:
                           [hiResStrippedName stringByAppendingPathExtension:ext]];
        
        if([hiResURL checkResourceIsReachableAndReturnError:NULL] == YES)
        {
            NSData *imgData = [[NSData alloc] initWithContentsOfURL:hiResURL];
            NSBitmapImageRep *imgRep = [[NSBitmapImageRep alloc] initWithData:imgData];
            
            imgRep.size = self.size;
            [self addRepresentation:imgRep];
        }
    }
    return self;
}

- (id)initWithHiResContentsOfFile:(NSString *)fileName
{
    if ((self = [self initWithContentsOfFile:fileName]))
    {
        NSString *strippedPath = fileName.stringByDeletingLastPathComponent;
        NSString *strippedName = fileName.lastPathComponent.stringByDeletingPathExtension;
        NSString *ext = fileName.lastPathComponent.pathExtension;
        NSString *hiResStrippedName = [NSString stringWithFormat:@"%@@2x", strippedName];
        NSString *hiResPath = [strippedPath stringByAppendingPathComponent:
                               [hiResStrippedName stringByAppendingPathExtension:ext]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:hiResPath] == YES)
        {
            NSData *imgData = [[NSData alloc] initWithContentsOfFile:hiResPath];
            NSBitmapImageRep *imgRep = [[NSBitmapImageRep alloc] initWithData:imgData];
            
            imgRep.size = self.size;
            [self addRepresentation:imgRep];
        }
    }
    return self;
}

@end

//
//  ALSauceMachine.h
//  Ascension
//
//  Copyright (C) 2011-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//
//  Pure Objective-C/C SAUCE record reader, replacing the old AnsiLove.framework.
//  Based on the SAUCE standard (Standard Architecture for Universal Comment Extensions).
//

#import <Foundation/Foundation.h>

#define RECORD_SIZE  128
#define COMMENT_SIZE 64

@interface ALSauceMachine : NSObject

// SAUCE record properties
@property (nonatomic, strong) NSString  *ID;
@property (nonatomic, strong) NSString  *version;
@property (nonatomic, strong) NSString  *title;
@property (nonatomic, strong) NSString  *author;
@property (nonatomic, strong) NSString  *group;
@property (nonatomic, strong) NSString  *date;
@property (nonatomic, assign) NSInteger dataType;
@property (nonatomic, assign) NSInteger fileType;
@property (nonatomic, assign) NSInteger tinfo1;
@property (nonatomic, assign) NSInteger tinfo2;
@property (nonatomic, assign) NSInteger tinfo3;
@property (nonatomic, assign) NSInteger tinfo4;
@property (nonatomic, strong) NSString  *comments;
@property (nonatomic, assign) NSInteger flags;

// SAUCE record BOOL properties
@property (nonatomic, assign) BOOL fileHasRecord;
@property (nonatomic, assign) BOOL fileHasComments;
@property (nonatomic, assign) BOOL fileHasFlags;

// Read SAUCE record from the given file path.
- (void)readRecordFromFile:(NSString *)inputFile;

@end

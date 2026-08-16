//
//  ALSauceMachine.m
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

#import "ALSauceMachine.h"
#import <string.h>

// SAUCE binary format layout (last 128 bytes of file).
//
// Offset  Size  Field
// 0       5     ID ("SAUCE")
// 5       2     Version ("00")
// 7       35    Title
// 42      20    Author
// 62      20    Group
// 82      8     Date (YYYYMMDD)
// 90      4     FileSize (uint32_t LE)
// 94      1     DataType
// 95      1     FileType
// 96      2     TInfo1 (uint16_t LE)
// 98      2     TInfo2 (uint16_t LE)
// 100     2     TInfo3 (uint16_t LE)
// 102     2     TInfo4 (uint16_t LE)
// 104     1     Comments (number of comment lines)
// 105     1     Flags
// 106     22    Filler

static const char kSauceID[]   = "SAUCE";
static const char kCommentID[] = "COMNT";

#pragma mark - C helpers

// Create an NSString from a fixed-width C buffer, trimming trailing spaces and nulls.
// Uses CP437 (DOS Latin US) encoding to preserve SAUCE-era characters.
static NSString *ALStringFromBuffer(const char *buffer, NSUInteger length)
{
    // Find the last non-space, non-null character.
    NSUInteger end = length;
    while (end > 0 && (buffer[end - 1] == ' ' || buffer[end - 1] == '\0')) {
        end--;
    }

    if (end == 0) {
        return @"";
    }

    NSStringEncoding cp437 =
        CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSLatinUS);

    NSString *result = [[NSString alloc] initWithBytes:buffer
                                                length:end
                                              encoding:cp437];
    return result ? result : @"";
}

// Read a little-endian uint16 from a 2-byte buffer.
static uint16_t ALReadUint16LE(const uint8_t *bytes)
{
    return (uint16_t)bytes[0] | ((uint16_t)bytes[1] << 8);
}

#pragma mark -

@implementation ALSauceMachine

- (void)readRecordFromFile:(NSString *)inputFile
{
    // Reset all state so the object can be reused.
    [self resetState];

    if (inputFile == nil || [inputFile length] == 0) {
        return;
    }

    FILE *file = fopen([inputFile fileSystemRepresentation], "rb");
    if (file == NULL) {
        NSLog(@"ALSauceMachine: unable to open file: %@", inputFile);
        return;
    }

    [self parseFile:file];
    fclose(file);
}

#pragma mark - Private

- (void)resetState
{
    self.ID       = @"";
    self.version  = @"";
    self.title    = @"";
    self.author   = @"";
    self.group    = @"";
    self.date     = @"";
    self.dataType = 0;
    self.fileType = 0;
    self.tinfo1   = 0;
    self.tinfo2   = 0;
    self.tinfo3   = 0;
    self.tinfo4   = 0;
    self.comments = @"";
    self.flags    = 0;

    self.fileHasRecord   = NO;
    self.fileHasComments = NO;
    self.fileHasFlags    = NO;
}

- (void)parseFile:(FILE *)file
{
    // Determine file size.
    if (fseek(file, 0, SEEK_END) != 0) {
        return;
    }

    long fileSize = ftell(file);
    if (fileSize < RECORD_SIZE) {
        return;
    }

    // Seek to the SAUCE record (last 128 bytes).
    if (fseek(file, -RECORD_SIZE, SEEK_END) != 0) {
        return;
    }

    uint8_t record[RECORD_SIZE];
    if (fread(record, 1, RECORD_SIZE, file) != RECORD_SIZE) {
        return;
    }

    // Verify magic bytes: "SAUCE" at offset 0.
    if (memcmp(record, kSauceID, 5) != 0) {
        return;
    }

    // Valid SAUCE record found.
    self.fileHasRecord = YES;

    self.ID       = ALStringFromBuffer((const char *)&record[0],  5);
    self.version  = ALStringFromBuffer((const char *)&record[5],  2);
    self.title    = ALStringFromBuffer((const char *)&record[7],  35);
    self.author   = ALStringFromBuffer((const char *)&record[42], 20);
    self.group    = ALStringFromBuffer((const char *)&record[62], 20);
    self.date     = ALStringFromBuffer((const char *)&record[82], 8);
    self.dataType = record[94];
    self.fileType = record[95];
    self.tinfo1   = ALReadUint16LE(&record[96]);
    self.tinfo2   = ALReadUint16LE(&record[98]);
    self.tinfo3   = ALReadUint16LE(&record[100]);
    self.tinfo4   = ALReadUint16LE(&record[102]);
    self.flags    = record[105];

    if (self.flags != 0) {
        self.fileHasFlags = YES;
    }

    // Read comments if present.
    NSInteger commentLineCount = record[104];
    if (commentLineCount > 0) {
        [self readComments:file lineCount:commentLineCount fileSize:fileSize];
    }
}

- (void)readComments:(FILE *)file
           lineCount:(NSInteger)lineCount
            fileSize:(long)fileSize
{
    // Comments block layout (immediately before the SAUCE record):
    //   "COMNT" (5 bytes) + lineCount * COMMENT_SIZE bytes
    //
    // Total block size including marker:
    NSInteger commentBlockSize = 5 + (lineCount * COMMENT_SIZE);

    // The comment block starts at:
    //   fileSize - RECORD_SIZE - commentBlockSize
    long commentOffset = fileSize - RECORD_SIZE - commentBlockSize;
    if (commentOffset < 0) {
        return;
    }

    if (fseek(file, commentOffset, SEEK_SET) != 0) {
        return;
    }

    // Verify the "COMNT" marker.
    char marker[5];
    if (fread(marker, 1, 5, file) != 5) {
        return;
    }
    if (memcmp(marker, kCommentID, 5) != 0) {
        return;
    }

    // Read and concatenate each comment line.
    NSMutableArray *lines = [NSMutableArray arrayWithCapacity:(NSUInteger)lineCount];
    char lineBuffer[COMMENT_SIZE];

    for (NSInteger i = 0; i < lineCount; i++) {
        if (fread(lineBuffer, 1, COMMENT_SIZE, file) != COMMENT_SIZE) {
            break;
        }
        NSString *line = ALStringFromBuffer(lineBuffer, COMMENT_SIZE);
        [lines addObject:line];
    }

    if ([lines count] > 0) {
        self.fileHasComments = YES;
        self.comments = [lines componentsJoinedByString:@"\n"];
    }
}

@end

//
//  SVFileInfoStrings.h
//  Ascension
//
//  Copyright (C) 2011-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import <Foundation/Foundation.h>

@interface SVFileInfoStrings : NSObject

// interface strings
@property (nonatomic, strong) NSString *uiFileSizeString;
@property (nonatomic, strong) NSString *uiCreationDateString;
@property (nonatomic, strong) NSString *uiModDateString;

// singleton class method
+ (SVFileInfoStrings *)sharedFileInfoStrings;

// general methods
- (void)updateFileSizeString:(NSNotification *)note;
- (void)updateCreationDateString:(NSNotification *)note;
- (void)updateModDateString:(NSNotification *)note;

@end

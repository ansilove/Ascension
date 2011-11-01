//
//  SVFileInfoStrings.h
//  Ascension
//
//  Copyright (c) 2010-2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
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

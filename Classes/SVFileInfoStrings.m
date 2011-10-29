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

#import "SVFileInfoStrings.h"

@implementation SVFileInfoStrings

@synthesize uiFileSizeString, uiCreationDateString, uiModDateString;

# pragma mark -
# pragma mark initialization 

+ (SVFileInfoStrings *)sharedFileInfoStrings
{
    static SVFileInfoStrings *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
    });
    return sharedInstance;
}

- (id)init
{
    if (self == [super init]) 
    {
        // Observe and process the file information values.
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        [nc addObserver:self 
               selector:@selector(updateFileSizeString:) 
                   name:@"FileSizeNote" 
                 object:nil];
        
        [nc addObserver:self 
               selector:@selector(updateCreationDateString:) 
                   name:@"CreationDateNote" 
                 object:nil];
        
        [nc addObserver:self 
               selector:@selector(updateModDateString:) 
                   name:@"ModDateNote" 
                 object:nil];   
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedFileInfoStrings];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


# pragma mark -
# pragma mark dictionaries to properties

- (void)updateFileSizeString:(NSNotification *)note
{
	self.uiFileSizeString = [[note userInfo] objectForKey:@"fileSizeValue"];
}

- (void)updateCreationDateString:(NSNotification *)note
{
	self.uiCreationDateString = [[note userInfo] objectForKey:@"creationDateValue"];
}

- (void)updateModDateString:(NSNotification *)note
{
	self.uiModDateString = [[note userInfo] objectForKey:@"modDateValue"];
}

@end

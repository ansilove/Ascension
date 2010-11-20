//
//  SVFileInfoController.m
//  Ascension
//
//  Created by Stefan Vogt on 19.11.10.
//  Copyright 2010 Stefan Vogt. All rights reserved.
//

#import "SVFileInfoController.h"

@implementation SVFileInfoController

@synthesize uiFileSizeString, uiCreationDateString, uiModDateString;

# pragma mark -
# pragma mark initialization 

- (id)init 
{
	if (self = [super init]) 
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

//
//  SVAscensionDelegate.h
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import "SVFileInfoController.h"

@implementation SVFileInfoController

@synthesize uiFileSizeString, uiCreationDateString, uiModDateString;

# pragma mark -
# pragma mark initialization 

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

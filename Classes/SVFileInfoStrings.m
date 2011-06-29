//
//  SVFileInfoStrings.h
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import "SVFileInfoStrings.h"

static SVFileInfoStrings *sharedInstance = nil;

@implementation SVFileInfoStrings

@synthesize uiFileSizeString, uiCreationDateString, uiModDateString;

# pragma mark -
# pragma mark initialization 

+ (SVFileInfoStrings *)sharedFileInfoStrings
{
    if (sharedInstance == nil) 
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
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
    return [[self sharedFileInfoStrings] retain];
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

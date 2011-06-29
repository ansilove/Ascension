//
//  SVFileInfoStrings.h
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import <Cocoa/Cocoa.h>

@interface SVFileInfoStrings : NSObject {
	
	NSString *uiFileSizeString;
	NSString *uiCreationDateString;
	NSString *uiModDateString;
}

// interface strings
@property (readwrite, assign) NSString *uiFileSizeString;
@property (readwrite, assign) NSString *uiCreationDateString;
@property (readwrite, assign) NSString *uiModDateString;

// singleton class method
+ (SVFileInfoStrings *)sharedFileInfoStrings;

// general methods
- (void)updateFileSizeString:(NSNotification *)note;
- (void)updateCreationDateString:(NSNotification *)note;
- (void)updateModDateString:(NSNotification *)note;

@end

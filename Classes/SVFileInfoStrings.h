//
//  SVAscensionDelegate.h
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import <Cocoa/Cocoa.h>

@interface SVFileInfoController : NSObject {
	
	NSString *uiFileSizeString;
	NSString *uiCreationDateString;
	NSString *uiModDateString;
}

// interface strings
@property (readwrite, assign) NSString *uiFileSizeString;
@property (readwrite, assign) NSString *uiCreationDateString;
@property (readwrite, assign) NSString *uiModDateString;

// general methods
- (void)updateFileSizeString:(NSNotification *)note;
- (void)updateCreationDateString:(NSNotification *)note;
- (void)updateModDateString:(NSNotification *)note;

@end

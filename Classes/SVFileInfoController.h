//
//  SVFileInfoController.h
//  Ascension
//
//  Created by Stefan Vogt on 19.11.10.
//  Copyright 2010 Stefan Vogt. All rights reserved.
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

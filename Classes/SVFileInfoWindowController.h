//
//  SVFileInfoWindowController.h
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import <Cocoa/Cocoa.h>

@interface SVFileInfoWindowController : NSWindowController {}

// class methods
+ (SVFileInfoWindowController *)sharedFileInfoWindowController;
+ (NSString *)nibName;

@end

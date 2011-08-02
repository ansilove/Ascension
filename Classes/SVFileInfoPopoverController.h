//
//  SVFileInfoPopoverController.h
//  Ascension
//
//  Copyright (c) 2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>

@interface SVFileInfoPopoverController : NSViewController {
    
    NSMatrix *encodingMatrix;
}
    
- (IBAction)encodingMatrixAction:(id)sender;

@property (assign) IBOutlet NSMatrix *encodingMatrix;
    
@end

//
//  SVFileInfoPopoverController.h
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import <Cocoa/Cocoa.h>

@interface SVFileInfoPopoverController : NSViewController {
    
    NSMatrix *encodingMatrix;
}
    
- (IBAction)encodingMatrixAction:(id)sender;

@property (assign) IBOutlet NSMatrix *encodingMatrix;
    
@end

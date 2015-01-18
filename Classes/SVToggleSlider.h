//
//  SVToggleSlider.h
//  Ascension
//
//  Copyright (C) 2010-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>

@interface SVToggleSlider : NSControl
{   
    NSPoint  location;
    NSImage  *knob;
    NSImage  *surround;
    bool     state;
}

-(IBAction)moveLeft:(id)sender;
-(IBAction)moveRight:(id)sender;

-(NSInteger)state;
-(void)setState:(NSInteger)newstate;
-(void)setState:(NSInteger)newstate animate:(bool)animate;

@end

//
//  SVToggleSlider.h
//  Ascension
//
//  Copyright (c) 2010-2012, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//
//  Based on MBSliderButton. Copyright (c) 2009, Max Howell.
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

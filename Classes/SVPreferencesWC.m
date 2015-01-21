//
//  SVPreferencesWC.m
//  Ascension
//
//  Copyright (C) 2010-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import "SVPreferencesWC.h"

@implementation SVPreferencesWC

# pragma mark -
# pragma mark class methods

+ (SVPreferencesWC *)sharedPreferencesWC
{
    // Numerous instances of a prefs window don't make any sense.
    static SVPreferencesWC *sharedPreferencesWC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPreferencesWC = [[self alloc] initWithWindowNibName:[self nibName]];
    });
    return sharedPreferencesWC;
}

+ (NSString *)nibName
{
	return @"Preferences";
}

# pragma mark -
# pragma mark initialization

- (void)awakeFromNib
{
	// Configure the preferences window.
	[self.window setContentSize:self.generalPrefView.frame.size];
	[[self.window contentView] addSubview:self.generalPrefView];
	[self.prefsBar setSelectedItemIdentifier:@"General"];
	[self.window center];
}

# pragma mark -
# pragma mark view methods

- (NSView *)viewForTag:(NSInteger)tag 
{
    // Helper method for our Preferences window controller.
	NSView *view = nil;
	
	switch(tag) {
        case 0 : {
            view = self.generalPrefView;
            break;
        }
        case 1 : {
            view = self.interfacePrefView;
            break;
        }
        case 2 : {
            view = self.ansiPrefView;
            break;
        }
        case 3 : {
            view = self.asciiPrefView;
            break;
        }
        case 4 : {
            view = self.themePrefView;
            break;
        }
        default: {
            view = self.generalPrefView;
            break;
        }
	}
    return view;
}

- (NSRect)newFrameForNewContentView:(NSView *)view 
{
	// Calculates the window frame based on the new view.
    NSRect newFrameRect = [self.window frameRectForContentRect:[view frame]];
    NSRect oldFrameRect = [self.window frame];
    NSSize newSize = newFrameRect.size;
    NSSize oldSize = oldFrameRect.size;    
    NSRect frame = [self.window frame];
    frame.size = newSize;
	frame.origin.y -= (newSize.height - oldSize.height);
    
    return frame;
}

- (IBAction)switchView:(id)sender 
{	
	// Changes the view based on the view tag.
	NSInteger tag = [sender tag];
	
	NSView *view = [self viewForTag:tag];
	NSView *previousView = [self viewForTag:self.currentViewTag];
	self.currentViewTag = tag;
	NSRect newFrame = [self newFrameForNewContentView:view];
	
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.1];
	
	if ([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask)
	    [[NSAnimationContext currentContext] setDuration:1.0];
	
	[[[self.window contentView] animator] replaceSubview:previousView with:view];
	[[self.window animator] setFrame:newFrame display:YES];
	
	[NSAnimationContext endGrouping];
}

# pragma mark -
# pragma mark appearance

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar 
{
	return [[toolbar items] valueForKey:@"itemIdentifier"];
}

@end

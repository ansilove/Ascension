//
//  SVTransparentScroller.m
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import "SVTransparentScroller.h"
#define PFIR(imgStr) [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:[NSString stringWithUTF8String:imgStr]]]

// Static variables, inherited from BWTransparentScroller and left untouched.
static NSImage *knobTop, *knobVerticalFill, *knobBottom, *slotTop, *slotVerticalFill, *slotBottom;
static float verticalPaddingTop		 = 2.0;
static float verticalPaddingBottom	 = 0.0;
static float minKnobHeight;
static NSImage *knobLeft, *knobHorizontalFill, *knobRight, *slotLeft, *slotHorizontalFill, *slotRight;
static float horizontalPaddingLeft	 = 2.0;
static float horizontalPaddingRight  = 2.0;
static float minKnobWidth;

static NSColor *backgroundColor;

@interface BWTransparentScroller (BWTSPrivate)
- (void)drawKnobSlot;
@end

@interface NSScroller (BWTSPrivate)
- (NSRect)_drawingRectForPart:(NSScrollerPart)aPart;
@end

@implementation SVTransparentScroller

// This method contains optimized code compared to BWTransparentScroller, see #define above.
+ (void)initialize
{
	NSBundle *bundle = [NSBundle bundleForClass:[BWTransparentScroller class]];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// Vertical scroller
	knobTop				= PFIR("TransparentScrollerKnobTop.tif");
	knobVerticalFill	= PFIR("TransparentScrollerKnobVerticalFill.tif");
	knobBottom			= PFIR("TransparentScrollerKnobBottom.tif");
	
	// Vertical scroller slot: SVTransparentController sets these images to nil.
	slotTop				= nil;	
	slotVerticalFill	= nil;
	slotBottom			= nil;
	
	// Horizontal scroller
	knobLeft			= PFIR("TransparentScrollerKnobLeft.tif");
	knobHorizontalFill	= PFIR("TransparentScrollerKnobHorizontalFill.tif");
	knobRight			= PFIR("TransparentScrollerKnobRight.tif");
	
	// Horizontal scroller slot: SVTransparentController forces these images to not be drawn.
	slotLeft			= nil;
	slotHorizontalFill	= nil;
	slotRight			= nil;
	
	// Read the TextView's background color from user defaults and apply it to the scroller.
	NSData *bgrndColorData = [defaults objectForKey:@"backgroundColor"];
	backgroundColor		   = [NSUnarchiver unarchiveObjectWithData:bgrndColorData];
	
	minKnobHeight = knobTop.size.height + knobVerticalFill.size.height + knobBottom.size.height + 10;
	minKnobWidth = knobLeft.size.width + knobHorizontalFill.size.width + knobRight.size.width + 10;
}

- (id)initWithFrame:(NSRect)frameRect;
{
	if (self == [super initWithFrame:frameRect])
	{
		[self setArrowsPosition:NSScrollerArrowsNone];
		
		if ([self bounds].size.width / [self bounds].size.height < 1)
			isVertical = YES;
		else
			isVertical = NO;
		
		// Observe live background color changes to apply them to the scroller.
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(applyScrollerBgrndColor:) 
				   name:@"BgrndColorChange"
				 object:nil];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder;
{
	if (self == [super initWithCoder:decoder])
	{
		[self setArrowsPosition:NSScrollerArrowsNone];	
		
		if ([self bounds].size.width / [self bounds].size.height < 1)
			isVertical = YES;
		else
			isVertical = NO;
		
		// Same purpose as in initWithFrame.
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(applyScrollerBgrndColor:) 
				   name:@"BgrndColorChange"
				 object:nil];
	}
	
	return self;
}

// Required to get the scroller width from SVTransparentScroller, returning super.
+ (CGFloat)scrollerWidth
{
	return [super scrollerWidth];
}

// Required to get scroller width for control size from SVTransparentScroller, also returning super.
+ (CGFloat)scrollerWidthForControlSize:(NSControlSize)controlSize 
{
	return [super scrollerWidthForControlSize:controlSize];
}

// We override drawRect to get our custom background color value.
- (void)drawRect:(NSRect)aRect;
{
	[backgroundColor set];
	NSRectFill([self bounds]);
	
	// Only draw if the slot is larger than the knob.
	if (isVertical && ([self bounds].size.height - verticalPaddingTop - verticalPaddingBottom + 1) > minKnobHeight)
	{
		[self drawKnobSlot];
		
		if ([self knobProportion] > 0.0)	
			[self drawKnob];
	}
	else if (!isVertical && ([self bounds].size.width - horizontalPaddingLeft - horizontalPaddingRight + 1) > minKnobWidth)
	{
		[self drawKnobSlot];
		
		if ([self knobProportion] > 0.0)	
			[self drawKnob];
	}
}

// Overriding drawKnobSlot ensures that no slots will be drawn. 
- (void)drawKnobSlot;
{
	NSRect slotRect = [self rectForPart:NSScrollerKnobSlot];
	
	if (isVertical)
		NSDrawThreePartImage(slotRect, slotTop, slotVerticalFill, slotBottom, YES, NSCompositeSourceOver, 1, NO);
	else
		NSDrawThreePartImage(slotRect, slotLeft, slotHorizontalFill, slotRight, NO, NSCompositeSourceOver, 1, NO);
}

- (void)applyScrollerBgrndColor:(NSNotification *)note;
{
	// Reads the background color dictionary and applys color values to the scroller.
	NSColor *scrollerBgrndColor = [[note userInfo] objectForKey:@"bgrndColorValue"];
	backgroundColor = scrollerBgrndColor;
	[backgroundColor set];
	
	// Redraws SVTransparentController after a color change.
	[self setNeedsDisplay:YES];
}

@end

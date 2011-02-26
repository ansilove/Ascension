//
//  SVTransparentScroller.h
//  Ascension
//
//  Forked by Stefan Vogt, based on code by Brandon Walkin.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import "SVTransparentScroller.h"
#define PFIR(imgStr) [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:[NSString stringWithUTF8String:imgStr]]]

// Vertical scroller
static NSImage *knobTop, *knobVerticalFill, *knobBottom, *slotTop, *slotVerticalFill, *slotBottom;
static float verticalPaddingLeft = 0.9;
static float verticalPaddingRight = 1.0;
static float verticalPaddingTop = 2.0;
static float verticalPaddingBottom = 2.0;
static float minKnobHeight;

// Horizontal scroller
static NSImage *knobLeft, *knobHorizontalFill, *knobRight, *slotLeft, *slotHorizontalFill, *slotRight;
static float horizontalPaddingLeft = 3.0;
static float horizontalPaddingRight = 3.0;
static float horizontalPaddingTop = 0.9;
static float horizontalPaddingBottom = 1.0;
static float minKnobWidth;

static NSColor *backgroundColor;

@interface SVTransparentScroller (SVTSPrivate)
- (void)drawKnobSlot;
@end

@interface NSScroller (SVTSPrivate)
- (NSRect)_drawingRectForPart:(NSScrollerPart)aPart;
@end

@implementation SVTransparentScroller

// For PFIR explanation, see the #define above.
+ (void)initialize
{
	NSBundle *bundle = [NSBundle bundleForClass:[SVTransparentScroller class]];
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

// Required to get the scroller width from SVTransparentScroller.
+ (CGFloat)scrollerWidth
{
	return slotVerticalFill.size.width + verticalPaddingLeft + verticalPaddingRight;
}

// Required to get scroller width for control size from SVTransparentScroller.
+ (CGFloat)scrollerWidthForControlSize:(NSControlSize)controlSize 
{
	return slotVerticalFill.size.width + verticalPaddingLeft + verticalPaddingRight;
}

- (void)drawRect:(NSRect)aRect;
{
	[backgroundColor set];
	NSRectFill([self bounds]);
	
	// Only draw if the slot is larger than the knob
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

// Since the slot images are set to nil, this method ensures no slots will be drawn.
- (void)drawKnobSlot;
{
	NSRect slotRect = [self rectForPart:NSScrollerKnobSlot];
	
	if (isVertical)
		NSDrawThreePartImage(slotRect, slotTop, slotVerticalFill, slotBottom, YES, NSCompositeSourceOver, 1, NO);
	else
		NSDrawThreePartImage(slotRect, slotLeft, slotHorizontalFill, slotRight, NO, NSCompositeSourceOver, 1, NO);
}

// Draws the knob based on three specified images.
- (void)drawKnob;
{
	NSRect knobRect = [self rectForPart:NSScrollerKnob];
	
	if (isVertical)
		NSDrawThreePartImage(knobRect, knobTop, knobVerticalFill, knobBottom, YES, NSCompositeSourceOver, 1, NO);
	else
		NSDrawThreePartImage(knobRect, knobLeft, knobHorizontalFill, knobRight, NO, NSCompositeSourceOver, 1, NO);
}

- (NSRect)_drawingRectForPart:(NSScrollerPart)aPart;
{
	// Call super even though we're not using its value (has some side effects we need).
	[super _drawingRectForPart:aPart];
	
	// Return our own rects rather than use the default behavior.
	return [self rectForPart:aPart];
}

- (NSRect)rectForPart:(NSScrollerPart)aPart;
{
	switch (aPart)
	{
		case NSScrollerNoPart:
			return [self bounds];
			break;
		case NSScrollerKnob:
		{
			NSRect knobRect;
			NSRect slotRect = [self rectForPart:NSScrollerKnobSlot];			
			
			if (isVertical)
			{
				float knobHeight = roundf(slotRect.size.height * [self knobProportion]);
				
				if (knobHeight < minKnobHeight)
					knobHeight = minKnobHeight;
				
				float knobY = slotRect.origin.y + roundf((slotRect.size.height - knobHeight) * [self floatValue]);
				knobRect = NSMakeRect(verticalPaddingLeft, knobY, slotRect.size.width, knobHeight);
			}
			else
			{
				float knobWidth = roundf(slotRect.size.width * [self knobProportion]);
				
				if (knobWidth < minKnobWidth)
					knobWidth = minKnobWidth;
				
				float knobX = slotRect.origin.x + roundf((slotRect.size.width - knobWidth) * [self floatValue]);
				knobRect = NSMakeRect(knobX, horizontalPaddingTop, knobWidth, slotRect.size.height);
			}
			
			return knobRect;
		}
			break;	
		case NSScrollerKnobSlot:
		{
			NSRect slotRect;
			
			if (isVertical)
				slotRect = NSMakeRect(verticalPaddingLeft, verticalPaddingTop, [self bounds].size.width - verticalPaddingLeft - verticalPaddingRight, [self bounds].size.height - verticalPaddingTop - verticalPaddingBottom);
			else
				slotRect = NSMakeRect(horizontalPaddingLeft, horizontalPaddingTop, [self bounds].size.width - horizontalPaddingLeft - horizontalPaddingRight, [self bounds].size.height - horizontalPaddingTop - horizontalPaddingBottom);
			
			return slotRect;
		}
			break;
		case NSScrollerIncrementLine:
			return NSZeroRect;
			break;
		case NSScrollerDecrementLine:
			return NSZeroRect;
			break;
		case NSScrollerIncrementPage:
		{
			NSRect incrementPageRect;
			NSRect knobRect = [self rectForPart:NSScrollerKnob];
			NSRect slotRect = [self rectForPart:NSScrollerKnobSlot];
			NSRect decPageRect = [self rectForPart:NSScrollerDecrementPage];
			
			if (isVertical)
			{
				float knobY = knobRect.origin.y + knobRect.size.height;	
				incrementPageRect = NSMakeRect(verticalPaddingLeft, knobY, knobRect.size.width, slotRect.size.height - knobRect.size.height - decPageRect.size.height);
			}
			else
			{
				float knobX = knobRect.origin.x + knobRect.size.width;
				incrementPageRect = NSMakeRect(knobX, horizontalPaddingTop, (slotRect.size.width + horizontalPaddingLeft) - knobX, knobRect.size.height);
			}
			
			return incrementPageRect;
		}
			break;
		case NSScrollerDecrementPage:
		{
			NSRect decrementPageRect;
			NSRect knobRect = [self rectForPart:NSScrollerKnob];
			
			if (isVertical)
				decrementPageRect = NSMakeRect(verticalPaddingLeft, verticalPaddingTop, knobRect.size.width, knobRect.origin.y - verticalPaddingTop);
			else
				decrementPageRect = NSMakeRect(horizontalPaddingLeft, horizontalPaddingTop, knobRect.origin.x - horizontalPaddingLeft, knobRect.size.height);
				
			return decrementPageRect;
		}
			break;
		default:
			break;
	}
	return NSZeroRect;
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

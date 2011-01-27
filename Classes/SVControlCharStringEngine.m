//
//  SVControlCharStringEngine.m
//  Ascension
//
//  Coded by Stefan Vogt.
//  Released under the FreeBSD license.
//  http://www.byteproject.net
//

#import "SVControlCharStringEngine.h"

#define RVAL const unichar rawValue[]
#define CTRCHR [NSString stringWithCharacters:rawValue length:1]

@implementation SVControlCharStringEngine

# pragma mark -
# pragma mark control char strings

+ (NSString *)xB0
{
	RVAL = {0x2591};
	return CTRCHR;
}

+ (NSString *)xB1
{
	RVAL = {0x2592}; 
	return CTRCHR;
}

+ (NSString *)xB2
{
	RVAL = {0x2593};
	return CTRCHR;
}

+ (NSString *)xB3
{
	RVAL = {0x2502};
	return CTRCHR;
}

+ (NSString *)xB4
{
	RVAL = {0x2524};
	return CTRCHR;
}

+ (NSString *)xB5
{
	RVAL = {0x2561};
	return CTRCHR;
}

+ (NSString *)xB6
{
	RVAL = {0x2562};
	return CTRCHR;
}

+ (NSString *)xB7
{
	RVAL = {0x2556};
	return CTRCHR;
}

+ (NSString *)xB8
{
	RVAL = {0x2555};
	return CTRCHR;
}

+ (NSString *)xB9
{
	RVAL = {0x2563};
	return CTRCHR;
}

+ (NSString *)xBA
{
	RVAL = {0x2551};
	return CTRCHR;
}

+ (NSString *)xBB
{
	RVAL = {0x2557};
	return CTRCHR;
}

+ (NSString *)xBC
{
	RVAL = {0x255D};
	return CTRCHR;
}

+ (NSString *)xBD
{
	RVAL = {0x255C};
	return CTRCHR;
}

+ (NSString *)xBE
{
	RVAL = {0x255B};
	return CTRCHR;
}

+ (NSString *)xBF
{
	RVAL = {0x2510};
	return CTRCHR;
}

+ (NSString *)xC0
{
	RVAL = {0x2514};
	return CTRCHR;
}

+ (NSString *)xC1
{
	RVAL = {0x2534};
	return CTRCHR;
}

+ (NSString *)xC2
{
	RVAL = {0x252C};
	return CTRCHR;
}

+ (NSString *)xC3
{
	RVAL = {0x251C};
	return CTRCHR;
}

+ (NSString *)xC4
{
	RVAL = {0x2500};
	return CTRCHR;
}

+ (NSString *)xC5
{
	RVAL = {0x253C};
	return CTRCHR;
}

+ (NSString *)xC6
{
	RVAL = {0x255E};
	return CTRCHR;
}

+ (NSString *)xC7
{
	RVAL = {0x255F};
	return CTRCHR;
}

+ (NSString *)xC8
{
	RVAL = {0x255A};
	return CTRCHR;
}

+ (NSString *)xC9
{
	RVAL = {0x2554};
	return CTRCHR;
}

+ (NSString *)xCA
{
	RVAL = {0x2569};
	return CTRCHR;
}

+ (NSString *)xCB
{
	RVAL = {0x2566};
	return CTRCHR;
}

+ (NSString *)xCC
{
	RVAL = {0x2560};
	return CTRCHR;
}

+ (NSString *)xCD
{
	RVAL = {0x2550};
	return CTRCHR;
}

+ (NSString *)xCE
{
	RVAL = {0x256C};
	return CTRCHR;
}

+ (NSString *)xCF
{
	RVAL = {0x2567};
	return CTRCHR;
}

+ (NSString *)xD0
{
	RVAL = {0x2568};
	return CTRCHR;
}

+ (NSString *)xD1
{
	RVAL = {0x2564};
	return CTRCHR;
}

+ (NSString *)xD2
{
	RVAL = {0x2565};
	return CTRCHR;
}

+ (NSString *)xD3
{
	RVAL = {0x2559};
	return CTRCHR;
}

+ (NSString *)xD4
{
	RVAL = {0x2558};
	return CTRCHR;
}

+ (NSString *)xD5
{
	RVAL = {0x2552};
	return CTRCHR;
}

+ (NSString *)xD6
{
	RVAL = {0x2553};
	return CTRCHR;
}

+ (NSString *)xD7
{
	RVAL = {0x256B};
	return CTRCHR;
}

+ (NSString *)xD8
{
	RVAL = {0x256A};
	return CTRCHR;
}

+ (NSString *)xD9
{
	RVAL = {0x2518};
	return CTRCHR;
}

+ (NSString *)xDA
{
	RVAL = {0x250C};
	return CTRCHR;
}

+ (NSString *)xDB
{
	RVAL = {0x2588};
	return CTRCHR;
}

+ (NSString *)xDC
{
	RVAL = {0x2584};
	return CTRCHR;
}

+ (NSString *)xDD
{
	RVAL = {0x258C};
	return CTRCHR;
}

+ (NSString *)xDE
{
	RVAL = {0x2590};
	return CTRCHR;
}

+ (NSString *)xDF
{
	RVAL = {0x2580};
	return CTRCHR;
}

+ (NSString *)xFE
{
	RVAL = {0x25A0};
	return CTRCHR;
}

@end

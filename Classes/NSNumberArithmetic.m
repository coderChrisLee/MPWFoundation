//
//  NSNumberArithmetic.m
//  MPWFoundation
//
//  Created by Marcel Weiher on 9/3/07.
//  Copyright 2007 by Marcel Weiher. All rights reserved.
//

#import "NSNumberArithmetic.h"
#import "MPWObject.h"


@implementation NSNumber(Arithmetic)

-bitOr:other
{
     return [NSNumber numberWithLong:[self longValue] | [other longValue]];
}

-pipe:other 
{
     return [self bitOr:other];
}

-or:other
{
    return [self boolValue] || [other boolValue] ? @true : @false;
}

-and:other
{
    return [self boolValue] && [other boolValue] ? @true : @false;
}

-xor:other
{
    return [self boolValue] ^ [other boolValue] ? @true : @false;
}

#define defineArithOp( opName, op ) \
-opName:other {\
	const char *type1=[self objCType];\
        const char *type2=[other objCType];\
            if ( type1 && type2 && *type1=='i' && *type2=='i' ) {\
                return [NSNumber numberWithInt:[self intValue] op [other intValue]];\
            } else {\
                return [NSNumber numberWithDouble:[self doubleValue] op [other doubleValue]];\
            }\
}\

-mod:other
{
    int otherInt=[other intValue];
    if ( otherInt != 0) {
        return [NSNumber numberWithInt:[self intValue] % otherInt];
    } else {
        [NSException raise:@"division by zero" format:@"arithmetic exception dividing %@ by 0",self];
        return 0;
    }
}

-(NSNumber*)interestPercent:(NSNumber*)interest overYears:(NSNumber*)years
{
    double factor=interest.doubleValue / 100.0 + 1.0;
    double start=self.doubleValue;
    int numYears=years.intValue;
    for (int i=0;i<numYears;i++) {
        start*=factor;
    }
    return @(start);
}

defineArithOp( add, + )
defineArithOp( mul, * )
defineArithOp( sub, - )
defineArithOp( div, / )

-squared
{
    return [self mul:self];
}

-(BOOL)isLessThan:other
{
    return [self compare:other] < 0;
}

-(BOOL)isGreaterThan:other
{
    return [self compare:other] > 0;
}

-not
{
    if ( [self boolValue]  ) {
        return (id)kCFBooleanFalse;
    } else {
        return (id)kCFBooleanTrue;
    }
}


-negated
{
	const char *type1=[self objCType];
    if ( type1 && *type1 == 'i' ){
        return [NSNumber numberWithInt:-[self intValue]];
    } else {
        return [NSNumber numberWithDouble:-[self doubleValue]];
    }
}

-(NSNumber*)random
{
    return [NSNumber numberWithInteger:arc4random_uniform( [self intValue])];
}

-(double)sin
{
    return sin([self doubleValue] * M_PI/180.0);
}


-(double)cos
{
    return cos([self doubleValue] * M_PI/180.0);
}

-(double)pow:(double)otherNumber
{
    return pow( [self doubleValue], otherNumber );
}

-(double)sqrt
{
    return sqrt([self doubleValue]);
}

-(NSString *)stringWithFormat:(NSString*)formatString
{
    NSNumberFormatter *f=[[[NSNumberFormatter alloc] init] autorelease];
    [f setPositiveFormat:formatString];
    return [f stringFromNumber:self];
}

-coerceToDecimalNumber
{
    const char *objcType=[self objCType];
    if ( *objcType == 'i' ) {
        return [NSDecimalNumber numberWithInt:[self intValue]];
    } else {
        return [NSDecimalNumber numberWithDouble:[self doubleValue]];
    }
}

+new {
	return [[self numberWithInt:0] retain];
}

-objcTypeString {
	return [NSString stringWithCString:[self objCType] encoding:NSASCIIStringEncoding];
}

static int fib( int n) {
    if ( n <= 1 ) {
        return n;
    } else {
        return fib(n-1) + fib(n-2);
    }
}

-fib
{
    return [NSNumber numberWithInt:fib([self intValue])];
    
}


-fastfib
{
    int c;
    int n=[self intValue];
    int first=0,second=1,next=0;
    for ( c = 0 ; c < n ; c++ )
    {
        if ( c <= 1 )
            next = c;
        else
        {
            next = first + second;
            first = second;
            second = next;
        }
    }
    return [NSNumber numberWithInt:next];

}

@end

@implementation NSDecimalNumber(arithmetic)

-coerceToDecimalNumber
{
    return self;
}

-add:aNumber   {
    return [self decimalNumberByAdding:[aNumber coerceToDecimalNumber]];
}

-sub:aNumber   {
    return [self decimalNumberBySubtracting:[aNumber coerceToDecimalNumber]];
}

-mul:aNumber   {
    return [self decimalNumberByMultiplyingBy:[aNumber coerceToDecimalNumber]];
}

-div:aNumber   {
    return [self decimalNumberByDividingBy:[aNumber coerceToDecimalNumber]];
}


@end


#if 0

int sendMainMessageToClass( int argc, char *argv[], NSString *className , NSString *messageName) {
	id pool=[NSAutoreleasePool new];
	id obj;
	id args=[NSMutableArray array];
	int i,res;
	for (i=1;i<argc;i++) {
		[args addObject:[NSString stringWithCString:argv[i] encoding:NSUTF8StringEncoding]];
	}
	obj=[[NSClassFromString(className) new] autorelease];
	res=(NSUInteger)[obj performSelector: NSSelectorFromString(messageName) withObject:args];
	[pool release];
	return res;
}


id _dummyGetNumtest( int value ) {
	return [NSNumber numberWithInt:value];
}
#endif 


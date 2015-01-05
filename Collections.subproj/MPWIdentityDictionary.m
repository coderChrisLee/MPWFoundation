//
//  MPWIdentityDictionary.m
//  MPWFoundation
//
//  Created by Marcel Weiher on Sun Jan 18 2004.
/*  
    Copyright (c) 2004-2015 by Marcel Weiher.  All rights reserved.


Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

	Redistributions of source code must retain the above copyright
	notice, this list of conditions and the following disclaimer.

	Redistributions in binary form must reproduce the above copyright
	notice, this list of conditions and the following disclaimer in
	the documentation and/or other materials provided with the distribution.

	Neither the name Marcel Weiher nor the names of contributors may
	be used to endorse or promote products derived from this software
	without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

*/

//

#import "MPWIdentityDictionary.h"
//#import "MPWFoundation.h>
#import "MPWObjectReference.h"
#import "DebugMacros.h"
#import "AccessorMacros.h"
#import "MPWObjectCache.h"

//#import "DebugMacros.h"

@implementation MPWIdentityDictionary

objectAccessor( NSMutableDictionary, realDict, setRealDict )
objectAccessor( MPWObjectCache,  cache, setCache )

-initWithCapacity:(NSUInteger)capacity
{
	self=[super init];
	[self setRealDict:[NSMutableDictionary dictionaryWithCapacity:capacity]];
	[self setCache:[MPWObjectCache cacheWithCapacity:10 class:[MPWObjectReference class]]];
	[cache setUnsafeFastAlloc:YES];
	return self;
}

-(MPWObjectReference*)referenceForKey:aKey
{
	MPWObjectReference *ref;
	ref = GETOBJECT( cache );
	[ref initWithTargetObject:aKey];
	return ref;
}

-objectForKeyReference:(MPWObjectReference*)aRef
{
	return [realDict objectForKey:aRef];
}

-objectForKey:aKey
{
	return [self objectForKeyReference:[self referenceForKey:aKey]];
}

-(void)setObject:anObject forKeyReference:(MPWObjectReference*)aKeyReference
{
	[realDict setObject:anObject forKey:aKeyReference];
}

-(void)setObject:anObject forKey:aKey
{
	[self setObject:anObject forKeyReference:[self referenceForKey:aKey]];
}

-(NSEnumerator*)keyEnumerator
{
	return [realDict keyEnumerator];
}

-(void)removeObjectForKeyReference:aKeyReference
{
	[realDict removeObjectForKey:aKeyReference];
}

-(void)removeObjectForKey:aKey
{
	[self removeObjectForKeyReference:[self referenceForKey:aKey]];
}

-(NSUInteger)count
{
	return [realDict count];
}

-(NSInteger)uniqueIdForObject:anObject
{
	id val = [self objectForKey:anObject];
	if ( val ) {
		return [val intValue];
	} else {
		return NSNotFound;
	}
}

-(NSInteger)uniqueIdForObjectAddIfNecessary:anObject
{
	long idForObject=0;
	id reference=[self referenceForKey:anObject];
	id val = [self objectForKeyReference:reference];
	if (val ) {
		idForObject=[val intValue];
	} else {
		idForObject=[self count];
		[self setObject:[NSNumber numberWithLong:idForObject] forKeyReference:reference];
	}
	return idForObject;
}

-(void)dealloc
{
	[cache release];
	[realDict release];
	[super dealloc];
}

@end


@implementation MPWIdentityDictionary(testing)

+(void)testSameObject
{
	id testKey=@"hello world";
	MPWIdentityDictionary* dictionary = [self dictionary];
	[dictionary setObject:@"someObject" forKey:testKey];
	INTEXPECT(1,[dictionary count], @"dictionary count" );
	[dictionary setObject:@"otherObject" forKey:testKey];
	INTEXPECT(1,[dictionary count], @"dictionary after one insertion" );
	IDEXPECT(@"otherObject",[dictionary objectForKey:testKey], @"after changing");
}

+(void)testEqualObject
{
	id testKey=@"hello world";
	id testKey2=[NSString stringWithCString:"hello world" encoding:NSUTF8StringEncoding];
	MPWIdentityDictionary* dictionary = [self dictionary];
	[dictionary setObject:@"someObject" forKey:testKey];
	INTEXPECT(1,[dictionary count], @"dictionary count" );
	[dictionary setObject:@"otherObject" forKey:testKey2];
	IDEXPECT( testKey, testKey2, @"keys are expected to be equal");
	INTEXPECT(2,[dictionary count], @"dictionary after second insertion" );
	IDEXPECT(@"someObject",[dictionary objectForKey:testKey], @"after changing");
}

+(void)testComplexKey
{
	id testKey=[NSMutableArray arrayWithObject:@"hello world"];
	MPWIdentityDictionary* dictionary = [self dictionary];
	[dictionary setObject:@"someObject" forKey:testKey];
	INTEXPECT(1,[dictionary count], @"dictionary after one insertion" );
	[testKey addObject:@"other object"];
	[dictionary setObject:@"otherObject" forKey:testKey];
	INTEXPECT(1,[dictionary count], @"dictionary after one insertion" );
	IDEXPECT(@"otherObject",[dictionary objectForKey:testKey], @"after changing");
}

+(void)testUniqueId
{
	MPWIdentityDictionary* dictionary = [self dictionary];
	id array=[NSMutableArray arrayWithObject:@"someTestValue"];
	id test1,test2,test3;
	long id1,id2,id3;
	test1=@"test1";
	test2=array;
	test3=@"test3";
	id1 = [dictionary uniqueIdForObjectAddIfNecessary:test1];
	id2 = [dictionary uniqueIdForObjectAddIfNecessary:test2];
	id3 = [dictionary uniqueIdForObjectAddIfNecessary:test3];
	NSAssert( id1 != id2 , @"unique ids for non unique object identical");
	NSAssert( id2 != id3 , @"unique ids for non unique object identical");
	NSAssert( id1 != id3 , @"unique ids for non unique object identical");
	[array addObject:@"more stuff for array"];
	INTEXPECT(  [dictionary uniqueIdForObject:test1], id1, @"couldn't find an object");
	INTEXPECT(  [dictionary uniqueIdForObject:test2], id2, @"couldn't find an object");
	INTEXPECT(  [dictionary uniqueIdForObject:test3], id3, @"couldn't find an object");
	INTEXPECT(  [dictionary uniqueIdForObjectAddIfNecessary:test1], id1, @"got a new unique id for identical object");
	INTEXPECT(  [dictionary uniqueIdForObjectAddIfNecessary:test2], id2 , @"array unique id changed");
}

+testSelectors
{
	return [NSArray arrayWithObjects:
		@"testSameObject",
		@"testEqualObject",
		@"testComplexKey",
		@"testUniqueId",
		@"testUniqueId",
		nil];
}

@end

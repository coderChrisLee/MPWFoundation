//
//  MPWConvertFromJSONStream.h
//  StackOverflow
//
//  Created by Marcel Weiher on 3/31/15.
//  Copyright (c) Copyright (c) 2015-2017 Marcel Weiher. All rights reserved.
//

#import <MPWFoundation/MPWStream.h>

@interface MPWConvertFromJSONStream : MPWStream
{
    NSString *key;
}

objectAccessor_h(NSString, key, setKey)

+(instancetype)streamWithKey:(NSString*)newKey target:(id)aTarget;
-(instancetype)initWithKey:(NSString*)newKey target:(id)aTarget;



@end

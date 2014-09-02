//
//  EmptyTools.m
//  BANJIA
//
//  Created by TeekerZW on 8/22/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "EmptyTools.h"

@implementation EmptyTools
+ (BOOL)isEmpty:(NSDictionary *)dict  key:(NSString *)key
{
    if ([dict objectForKey:key] &&
        ![[dict objectForKey:key] isEqual:[NSNull null]])
    {
        if ([[dict objectForKey:key] isKindOfClass:[NSString class]] &&
            ![[dict objectForKey:key] isEqualToString:@"(null)"])
        {
            return YES;
        }
        return YES;
    }
    return NO;
}
@end

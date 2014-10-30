//
//  UserIconTools.m
//  BANJIA
//
//  Created by TeekerZW on 14/10/24.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "UserIconTools.h"

@implementation UserIconTools
+(NSString *)uidFromNum:(NSString *)unum
{
    OperatDB *db = [[OperatDB alloc] init];
    NSArray *userIconArray = [db findSetWithDictionary:@{@"unum":unum} andTableName:USERICONTABLE];
    if ([userIconArray count] > 0)
    {
        NSDictionary *usericonDict = [userIconArray firstObject];
        NSString *uid = [usericonDict objectForKey:@"uid"];
        if (uid && ![uid isEqual:[NSNull null]])
        {
            return uid;
        }
    }
    return @"";
}

@end

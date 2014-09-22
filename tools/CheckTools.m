//
//  CheckTools.m
//  BANJIA
//
//  Created by TeekerZW on 14/9/21.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "CheckTools.h"

@implementation CheckTools
+(BOOL)isClassNumber:(NSString *)classNum
{
    NSString *classCheckNum = @"([0-9]{0,})";
    NSPredicate *classCheckPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",classCheckNum];
    return [classCheckPredicate evaluateWithObject:classNum];
}
@end

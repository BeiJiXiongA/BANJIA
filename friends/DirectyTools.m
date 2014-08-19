//
//  DirectyTools.m
//  BANJIA
//
//  Created by TeekerZW on 8/19/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "DirectyTools.h"

@implementation DirectyTools
+(NSString *)documents
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    return docDir;
}

+(NSString *)soundDir
{
    NSString *soundDir = [NSString stringWithFormat:@"%@/soundCache",[DirectyTools documents]];
    return soundDir;
}
@end

//
//  SizeTools.m
//  BANJIA
//
//  Created by TeekerZW on 7/20/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "SizeTools.h"

@implementation SizeTools

+(CGSize)getSizeWithString:(NSString *)content andWidth:(CGFloat)width andFont:(UIFont *)font
{
    
    CGSize maxSize=CGSizeMake(width, 99999);
    CGSize  strSize=[content sizeWithFont:font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    return strSize;
}

@end

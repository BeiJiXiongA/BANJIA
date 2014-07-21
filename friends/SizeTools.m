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
    
    if ([content length]>=11)
    {
        CGSize labsize = [content sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(SCREEN_WIDTH-130, 9999) lineBreakMode:NSLineBreakByWordWrapping];
        return labsize;
    }
    else
        return CGSizeMake([content length]*18, 20);
}

@end

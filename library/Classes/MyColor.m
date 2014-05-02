//
//  MyColor.m
//  XMPP1106
//
//  Created by mac120 on 13-11-7.
//  Copyright (c) 2013年 mac120. All rights reserved.
//

#import "MyColor.h"
#import "Header.h"

@implementation MyColor
+ (UIColor*) NavSelectColor
{
    return [UIColor colorWithRed:115.0 / 255.0 green:36.0 / 255.0 blue:37.0 / 255.0 alpha:1];
}

+ (UIColor*) RecomImageLabelColor
{
    return  UIColorFromRGBWithAlpha(0xFFFFFF, 0.6);
}

+ (UIColor*) SettingHeadLabelColor
{
    return [UIColor colorWithRed:146.0/255.0 green:29.0/255.0 blue:23.0/255.0 alpha:1];
}

+ (UIColor*) NickNameColor
{
    return [UIColor colorWithRed:21.0/255.0 green:125.0/255.0 blue:196.0/255.0 alpha:1];
}

+ (UIColor*) EgoTextColor
{
    return [UIColor colorWithRed:67.0/255.0 green:69.0/255.0 blue:72.0/255.0 alpha:1];
}

+ (UIColor*) BlackTransBgColor
{
    return UIColorFromRGBWithAlpha(0x000000, 0.0);
}

+ (UIColor*) BlackBgColor
{
    return UIColorFromRGBWithAlpha(0x000000, 0.7);
}

+ (UIColor*) BackGroudColor
{
    return UIColorFromRGB(0xeeeeee);
}

+ (UIColor*) HomePageTextColor
{
    return UIColorFromRGB(0xa61600);
}

+ (UIColor*) bookSelfTextColor
{
    return UIColorFromRGB(0x3b3b3b);
}

@end

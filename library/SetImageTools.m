//
//  SetImageTools.m
//  BANJIA
//
//  Created by TeekerZW on 14-6-30.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "SetImageTools.h"
#import "UIImageView+WebCache.h"


@implementation SetImageTools
+ (void) fillImageView:(UIImageView *)imageView withImageFromURL:(NSString*)URL imageWidth:(CGFloat)imageWidth andDefault:(NSString *)defaultName
{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@@%.0fw%@",IMAGEURL,[URL substringToIndex:[URL length]-4],imageWidth,[URL substringFromIndex:[URL rangeOfString:@"."].location]];
    NSURL *imageURL = [NSURL URLWithString:urlStr];
    DDLOG(@"image url %@",imageURL.absoluteString);
    [imageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:defaultName]];
}

+(void)fillHeaderImage:(UIImageView *)imageView withUserid:(NSString *)userid imageType:(NSString *)imageType defultImage:(NSString *)defaultName
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/ur/%@/%@",IMAGEURL,userid,imageType];
    NSURL *imageURL = [NSURL URLWithString:urlStr];
    DDLOG(@"image url %@",imageURL.absoluteString);
    [imageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:defaultName]];
}

@end

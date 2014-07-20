//
//  ImageTools.m
//  BANJIA
//
//  Created by TeekerZW on 7/20/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "ImageTools.h"

@implementation ImageTools
+ (UIImage *)getNormalImageFromImage:(UIImage *)originalImage
{
    //    a307741613dbc06cd926be027a15298364712d59
    CGFloat imageHeight = 0.0f;
    CGFloat imageWidth = 0.0f;
    if (originalImage.size.width > originalImage.size.height)
    {
        if (originalImage.size.height > MAXHEIGHT)
        {
            imageHeight = MAXHEIGHT;
            imageWidth = originalImage.size.width*imageHeight/originalImage.size.height;
        }
        else
        {
            imageHeight = originalImage.size.height;
            imageWidth = originalImage.size.width;
        }
    }
    else if(originalImage.size.width < originalImage.size.height)
    {
        if (originalImage.size.width > MAXWIDTH)
        {
            imageWidth = MAXWIDTH;
            imageHeight = originalImage.size.height*imageWidth/originalImage.size.width;
        }
        else
        {
            imageHeight = originalImage.size.height;
            imageWidth = originalImage.size.width;
        }
    }
    else
    {
        if (originalImage.size.width > MAXWIDTH)
        {
            imageWidth = MAXWIDTH;
            imageHeight = MAXWIDTH;
        }
        else
        {
            imageHeight = originalImage.size.height;
            imageWidth = originalImage.size.width;
        }
    }
    DDLOG(@"image direction %d",originalImage.imageOrientation);
    originalImage = [Tools thumbnailWithImageWithoutScale:originalImage size:CGSizeMake(imageWidth, imageHeight)];
    return originalImage;
}

+(CGSize)getSizeFromImage:(UIImage *)image
{
    CGFloat maxH = 60;
    CGFloat maxW = 80;
    CGFloat imageWidth = 0;
    CGFloat imageHeight = 0;
    if (image.size.width > image.size.height)
    {
        if (image.size.height > maxH)
        {
            imageHeight = maxH;
            imageWidth = image.size.width*imageHeight/image.size.height;
        }
        else
        {
            imageHeight = image.size.height;
            imageWidth = image.size.width;
        }
    }
    else if(image.size.width < image.size.height)
    {
        if (image.size.width > maxW)
        {
            imageWidth = maxW;
            imageHeight = image.size.height*imageWidth/image.size.width;
        }
        else
        {
            imageHeight = image.size.height;
            imageWidth = image.size.width;
        }
    }
    else
    {
        if (image.size.width > maxW)
        {
            imageWidth = maxW;
            imageHeight = maxW;
        }
        else
        {
            imageHeight = image.size.height;
            imageWidth = image.size.width;
        }
    }
    CGSize size = CGSizeMake(imageWidth, imageHeight);
    return size;
}


@end

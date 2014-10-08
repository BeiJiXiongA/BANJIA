//
//  ImageTools.m
//  BANJIA
//
//  Created by TeekerZW on 7/20/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "ImageTools.h"
#import "QRCodeGenerator.h"

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

//+ (UIImage *)imageWithUrl:(NSString *)imageUrl
//{
//    UIImage *image = [[SDWebImageManager sharedManager] imageWithUrl:[NSURL URLWithString:imageUrl]];
//    return image;
//}

+(NSDictionary *)iconDictWithUserID:(NSString *)userid
{
    OperatDB *db = [[OperatDB alloc] init];
    if(userid)
    {
        NSDictionary *userDict = [[db findSetWithDictionary:@{@"uid":userid} andTableName:USERICONTABLE] firstObject];
        return userDict;
    }
    return nil;
    
}

+ (UIImage *)imageWithUrl:(NSString *)imageUrl
{
//    UIImage *image = [[SDWebImageManager sharedManager]  ]
    return nil;
}

+ (UIImage *)getQrImageWithString:(NSString *)qrString width:(CGFloat)width
{
    UIImage *image = [QRCodeGenerator qrImageForString:qrString imageSize:width];
    UIImage *banjiaIcon = [UIImage imageNamed:@"logo58"];
    UIGraphicsBeginImageContext(CGSizeMake(width, width));
    [image drawAtPoint:CGPointMake(0, 0)];
    [banjiaIcon drawAtPoint:CGPointMake(211, 211)];
    UIImage *qrimage = UIGraphicsGetImageFromCurrentImageContext();
    return qrimage;
}

+ (void)convertViewToImage:(UIScrollView*)v inViewController:(XDContentViewController *)viewController
{
    
    //支持retian高分辨率
    
    UIGraphicsBeginImageContextWithOptions(viewController.view.frame.size, YES, 0.0);
    
    float curH = v.contentSize.height;
    float cha = viewController.view.frame.size.height;
    
    UIImageView *allView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, curH)];
    
    for (float f = 0; f < curH; f+=cha)
        
    {
        v.contentOffset = CGPointMake(0, f);
        
        [viewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImageView *imgV = [[UIImageView alloc]initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
        
        imgV.frame = CGRectMake(0, f, 320, cha);
        
        [allView addSubview:imgV];
    }
    
    UIGraphicsEndImageContext();
    
    //保存图片
    
    UIGraphicsBeginImageContextWithOptions(allView.frame.size, YES, 0.0);
    
    [allView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    v.contentOffset = CGPointMake(0, 0);
    
    //save phone album
//    UIImageWriteToSavedPhotosAlbum(img, nil, nil,nil);
    //save to desktop
    [UIImagePNGRepresentation(img) writeToFile:@"/users/test/desktop/saveview.png" atomically:YES];
    
//    return img;
}


@end

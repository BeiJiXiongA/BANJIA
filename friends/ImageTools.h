//
//  ImageTools.h
//  BANJIA
//
//  Created by TeekerZW on 7/20/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ImageTools : NSObject
+ (UIImage *)getNormalImageFromImage:(UIImage *)originalImage;

+ (CGSize)getSizeFromImage:(UIImage *)image;

+ (UIImage *)imageWithUrl:(NSString *)imageUrl;

+ (NSDictionary *)iconDictWithUserID:(NSString *)userid;

+ (UIImage *)getQrImageWithString:(NSString *)qrString width:(CGFloat)width;

+ (UIImage *)convertViewToImage:(UIScrollView*)v inViewController:(XDContentViewController *)viewController;

+(UIImage *)getImageFromALAssesst:(ALAsset *)asset;

+(void)setImageView:(UIImageView *)imageView withAsset:(ALAsset *)asset andDefault:(NSString *)defaultName;

@end

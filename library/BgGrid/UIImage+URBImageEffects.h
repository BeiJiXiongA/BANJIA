//
//  UIImage+URBImageEffects.h
//  HtmlDemo
//
//  Created by TeekerZW on 14-2-10.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (URBImageEffects)
- (UIImage *)URB_applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;
-(UIImage *)boxblurImageWithBlur:(CGFloat)blur;
@end

//
//  ImageTools.h
//  BANJIA
//
//  Created by TeekerZW on 7/20/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageTools : NSObject
+ (UIImage *)getNormalImageFromImage:(UIImage *)originalImage;

+ (CGSize)getSizeFromImage:(UIImage *)image;
@end

//
//  ImageItem.m
//  BANJIA
//
//  Created by TeekerZW on 14/9/3.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "ImageItem.h"

@implementation ImageItem
-(id)initWithSourceType:(CustomImageSourceType)imageSourceType andAsset:(ALAsset *)asset andFullImage:(UIImage *)fullImage
{
    if ((self = [super init]))
    {
        self.imageSourceType = imageSourceType;
        self.asset = asset;
        self.fullImage = fullImage;
    }
    return self;
}
@end

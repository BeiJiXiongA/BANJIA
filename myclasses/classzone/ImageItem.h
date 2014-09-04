//
//  ImageItem.h
//  BANJIA
//
//  Created by TeekerZW on 14/9/3.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_ENUM(NSInteger, CustomImageSourceType)
{
    ImageSourceTypeCamera = 0,
    ImageSourceTypeAlbum
};


@interface ImageItem : NSObject
@property (nonatomic, assign) CustomImageSourceType imageSourceType;
@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, strong) UIImage *fullImage;
-(id)initWithSourceType:(CustomImageSourceType)imageSourceType andAsset:(ALAsset *)asset andFullImage:(UIImage *)fullImage;
@end

//
//  SetImageTools.h
//  BANJIA
//
//  Created by TeekerZW on 14-6-30.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SetImageTools : NSObject
+(void)fillHeaderImage:(UIImageView *)imageView
            withUserid:(NSString *)userid
             imageType:(NSString *)imageType
           defultImage:(NSString *)defaultName;


@end

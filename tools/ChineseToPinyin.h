//
//  ChineseToPinyin.h
//  BANJIA
//
//  Created by TeekerZW on 14/9/28.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChineseToPinyin : NSObject
+(NSString *)jianPinFromChiniseString:(NSString *)sourceText;
+(NSString *)pinyinFromChiniseString:(NSString *)sourceText;
@end

//
//  CoreTextTools.h
//  BANJIA
//
//  Created by TeekerZW on 14/11/20.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreTextTools : NSObject
+(NSMutableAttributedString *)getAttributedStringWithString:(NSString *)string
                                                andKeyArray:(NSArray *)keyArray
                                                  textColor:(UIColor *)textColor;
@end

//
//  CoreTextTools.m
//  BANJIA
//
//  Created by TeekerZW on 14/11/20.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "CoreTextTools.h"

@implementation CoreTextTools

+(NSMutableAttributedString *)getAttributedStringWithString:(NSString *)string
                                                andKeyArray:(NSArray *)keyArray
                                                  textColor:(UIColor *)textColor
{
    NSInteger lenght = [string length];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attrString addAttribute:NSFontAttributeName value:CommentFont range:NSMakeRange(0, lenght)];
    
    for(NSString *keyStr in keyArray)
    {
        NSRange range = [string rangeOfString:keyStr];
        [attrString addAttribute:NSForegroundColorAttributeName value:textColor range:range];
    }
    return attrString;
}

@end

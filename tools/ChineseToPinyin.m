//
//  ChineseToPinyin.m
//  BANJIA
//
//  Created by TeekerZW on 14/9/28.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "ChineseToPinyin.h"

@implementation ChineseToPinyin
+(NSString *)jianPinFromChiniseString:(NSString *)sourceText
{
    NSMutableString *jianpin = [[NSMutableString alloc] initWithCapacity:0];
    HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];
    
    NSString *passwordRegex1 = @"^[a-z0-9A-Z]{0,}$";
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passwordRegex1];
    BOOL isValid1 = [predicate1 evaluateWithObject:sourceText];
    
    NSString *passwordRegex2 = @"^[a-zA-Z]$";
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passwordRegex2];
    
    BOOL isValid2 = NO;
    if ([sourceText length] > 0)
    {
        isValid2 =[predicate2 evaluateWithObject:[sourceText substringWithRange:NSMakeRange(0, 1)]];
    }
    
    if (isValid1 && isValid2)
    {
        return sourceText;
    }
    
    for(int i=0;i<[sourceText length];i++)
    {
        NSString *tmp = [PinyinHelper getFirstHanyuPinyinStringWithChar:[sourceText characterAtIndex:i] withHanyuPinyinOutputFormat:outputFormat];
        if (tmp)
        {
            [jianpin appendString:[NSString stringWithFormat:@"%c",[tmp characterAtIndex:0]]];
        }
    }
    if ([jianpin length] > 0)
    {
        return jianpin;
    }
    else
    {
        return @"#";
    }
}
+(NSString *)pinyinFromChiniseString:(NSString *)sourceText
{
    HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];
    NSString *outputPinyin=[PinyinHelper toHanyuPinyinStringWithNSString:sourceText withHanyuPinyinOutputFormat:outputFormat withNSString:@""];
    if ([outputPinyin length] > 0)
    {
        return outputPinyin;
    }
    else
    {
        return sourceText;
    }
}

@end

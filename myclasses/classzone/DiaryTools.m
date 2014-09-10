//
//  DiaryTools.m
//  BANJIA
//
//  Created by TeekerZW on 14-7-10.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "DiaryTools.h"
#import "NSString+Emojize.h"

#define ImageHeight  65.5f
#define ImageCountPerRow  4
#define PraiseW   31
#define ColumnPerRow  8

@implementation DiaryTools
+ (CGFloat)heightWithDiaryDict:(NSDictionary *)dict andShowAll:(BOOL)showAll
{
    CGFloat he=0;
    if (SYSVERSION>=7)
    {
        he = 5;
    }
    //                CGFloat imageWidth = 60;
    CGFloat imageViewHeight = ImageHeight;
    NSString *content = [[[dict objectForKey:@"detail"] objectForKey:@"content"] emojizedString];
    NSArray *imgsArray = [[[dict objectForKey:@"detail"] objectForKey:@"img"] count]>0?[[dict objectForKey:@"detail"] objectForKey:@"img"]:nil;
    NSInteger imageCount = [imgsArray count];
    NSInteger row = 0;
    if (imageCount % ImageCountPerRow > 0)
    {
        row = (imageCount/ImageCountPerRow+1) > 3 ? 3:(imageCount / ImageCountPerRow + 1);
    }
    else
    {
        row = (imageCount/ImageCountPerRow) > 3 ? 3:(imageCount / ImageCountPerRow);
    }
    
    CGFloat imgsHeight = row * (imageViewHeight+5);

    CGSize size = [Tools getSizeWithString:content andWidth:SCREEN_WIDTH-30 andFont:[UIFont systemFontOfSize:15]];
    
    CGFloat contentHeight = 0;
    if (showAll)
    {
        contentHeight = size.height+10;
    }
    else
    {
        if (size.height > 45)
        {
            contentHeight = 45;
        }
        else
        {
            contentHeight = size.height+10;
        }
    }
    
    CGFloat contentHtight = [content length] > 0 ? (contentHeight) : 10;
    CGFloat tmpcommentHeight = 0;
    if ([[dict objectForKey:@"comments_num"] integerValue] > 0)
    {
        NSArray *array = [[dict objectForKey:@"detail"] objectForKey:@"comments"];
        if (showAll)
        {
            //动态详情
            for (int i=0; i < [array count]; ++i)
            {
                NSDictionary *dict = [array objectAtIndex:i];
                NSString *content = [[dict objectForKey:@"content"] emojizedString];
                NSString *contentString = [NSString stringWithFormat:@"%@",content];
                CGSize s = [Tools getSizeWithString:contentString andWidth:MaxCommentWidth andFont:[UIFont systemFontOfSize:14]];
                tmpcommentHeight += (s.height+CommentSpace*2+25-5);
            }
        }
        else
        {
            //动态列表
            for (int i=0; i<([array count] > 6 ? 6:[array count]); ++i)
            {
                NSDictionary *dict = [array objectAtIndex:i];
                
                NSString *name = [[dict objectForKey:@"by"] objectForKey:@"name"];
                CGSize nameSize;
                if (SYSVERSION >= 7)
                {
                    nameSize = [name sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:CommentFont, NSFontAttributeName, nil]];
                }
                else
                {
                    nameSize = [Tools getSizeWithString:name andWidth:100 andFont:CommentFont];
                }
                
                NSString *content = [[dict objectForKey:@"content"] emojizedString];
                CGSize commentSize = [Tools getSizeWithString:content andWidth:MaxCommentWidth-nameSize.width andFont:CommentFont];
                 tmpcommentHeight += commentSize.height+CommentSpace*2;
            }
            if ([array count] > 6)
            {
                tmpcommentHeight += MinCommentHeight;
            }
        }
    }
    if ([[dict objectForKey:@"likes_num"] integerValue] > 0)
    {
        
        if (showAll)
        {
            int likes_num = [[dict objectForKey:@"likes_num"] integerValue];
            
            int row = likes_num % ColumnPerRow == 0 ? (likes_num/ColumnPerRow):(likes_num/ColumnPerRow+1);
            tmpcommentHeight+=(36+(PraiseW+5)*row);
        }
        else
        {
            tmpcommentHeight += 36;
        }
        
    }
    return 50 + imgsHeight+contentHtight + 55 + tmpcommentHeight + 6;
}

@end

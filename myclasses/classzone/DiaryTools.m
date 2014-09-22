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

#define PraiseCellHeight  30

@implementation DiaryTools
+ (CGFloat)heightWithDiaryDict:(NSDictionary *)dict andShowAll:(BOOL)showAll
{
    //头像
    CGFloat headerHeight = 44;
    
    //文字
    NSString *content = [[[dict objectForKey:@"detail"] objectForKey:@"content"] emojizedString];
    
    CGSize size = [Tools getSizeWithString:content andWidth:SCREEN_WIDTH-30 andFont:[UIFont systemFontOfSize:15]];
    
    CGFloat contentHeight = 0;
    if ([content length] > 0)
    {
        if (showAll)
        {
            contentHeight = size.height+10;
        }
        else
        {
            if (size.height > 45)
            {
                contentHeight = 45 + DongTaiSpace*2;
            }
            else
            {
                contentHeight = size.height + 10 + DongTaiSpace*2;
            }
        }
    }
    
    //图片
    NSArray *imgsArray = [[[dict objectForKey:@"detail"] objectForKey:@"img"] count]>0?[[dict objectForKey:@"detail"] objectForKey:@"img"]:nil;
    NSInteger imageCount = [imgsArray count];
    NSInteger row = 0;
    CGFloat imageViewHeight = ImageHeight;
    if (imageCount % ImageCountPerRow > 0)
    {
        row = (imageCount/ImageCountPerRow+1) > 3 ? 3:(imageCount / ImageCountPerRow + 1);
    }
    else
    {
        row = (imageCount/ImageCountPerRow) > 3 ? 3:(imageCount / ImageCountPerRow);
    }
    
    CGFloat imgsHeight = 0;
    if (row > 0)
    {
        if ([content length] > 0)
        {
            imgsHeight = row * (imageViewHeight+5) + DongTaiSpace*2;
        }
        else
        {
            imgsHeight = row * (imageViewHeight+5) + DongTaiSpace * 3;
        }
    }
    else
    {
        imgsHeight = DongTaiSpace;
    }
    //评论,赞，转发
    CGFloat buttonHeight = 37;
    
    //评论
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
                CGSize s = [Tools getSizeWithString:contentString andWidth:MaxCommentWidth-30 andFont:CommentFont];
                
                DDLOG(@"diary height in diary tools %@ +++ %@",contentString,NSStringFromCGSize(s));
                tmpcommentHeight += (s.height+CommentSpace*1+32);
            }
        }
        else
        {
            //动态列表
            int commentCount = [array count] > 6 ? ([array count] - 7) : -1;
            int i = [array count]-1;
            do {
                NSDictionary *dict = [array objectAtIndex:i];
                
               NSString *name = [NSString stringWithFormat:@"%@ : ",[[dict objectForKey:@"by"] objectForKey:@"name"]];
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
                
                tmpcommentHeight += (commentSize.height + CommentSpace * 2);
                
                --i;
            }while (i > commentCount);
            
            if ([array count] >= 7)
            {
                tmpcommentHeight += MinCommentHeight;
            }
        }
    }
    //赞
    if ([[dict objectForKey:@"likes_num"] integerValue] > 0)
    {
        
        if (showAll)
        {
            int likes_num = [[dict objectForKey:@"likes_num"] integerValue];
            int row = likes_num % ColumnPerRow == 0 ? (likes_num/ColumnPerRow):(likes_num/ColumnPerRow+1);
            tmpcommentHeight += ((30+(PraiseW+5)*row) + DongTaiSpace*3);
        }
        else
        {
            tmpcommentHeight += (PraiseCellHeight+CommentSpace);
        }
        
    }
    return headerHeight + imgsHeight + contentHeight + buttonHeight + tmpcommentHeight + 6; //6为动态与动态之间距离一半
}

@end

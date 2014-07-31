//
//  MessageCell.m
//  XMPP1106
//
//  Created by mac120 on 13-11-6.
//  Copyright (c) 2013年 mac120. All rights reserved.
//

#import "MessageCell.h"
#import "NSString+Emojize.h"

#define DIRECT  @"direct"
#define TYPE    @"msgType"
#define TEXTMEG  @"text"
#define IMAGEMSG  @"image"

#define Image_H 180
#define additonalH  90
#define MoreACTag   1000
#define SelectPicTag 2000


@implementation MessageCell
@synthesize messageTf,chatBg,button,timeLabel,headerImageView,joinlable,msgImageView,msgDict,isGroup,nameLabel,fromImgIcon;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        fromImage = [Tools getImageFromImage:[UIImage imageNamed:@"f"] andInsets:UIEdgeInsetsMake(40, 40, 17, 40)];
        toImage = [Tools getImageFromImage:[UIImage imageNamed:@"t2"] andInsets:UIEdgeInsetsMake(35, 40, 17, 40)];
        
        headerImageView = [[UIImageView alloc] init];
        headerImageView.clipsToBounds = YES;
        headerImageView.layer.contentsGravity = kCAGravityResizeAspectFill;
        [self.contentView addSubview:headerImageView];
        
        chatBg = [[UIImageView alloc] init];
        chatBg.hidden = YES;
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.hidden = YES;
        [self.contentView addSubview:chatBg];
        
        joinlable = [[UILabel alloc] init];
        joinlable.textColor = RGB(0, 165, 195, 1);
        joinlable.hidden = YES;
        joinlable.backgroundColor = [UIColor clearColor];
        [chatBg addSubview:joinlable];
        
        messageTf = [[UITextView alloc] init];
        messageTf.editable = NO;
        messageTf.scrollEnabled = NO;
        messageTf.backgroundColor = [UIColor clearColor];
        messageTf.hidden = YES;
        messageTf.userInteractionEnabled = YES;
        messageTf.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:messageTf];
        
        timeLabel = [[UILabel alloc] init];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.font = [UIFont systemFontOfSize:12];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:timeLabel];
        
        nameLabel = [[UILabel alloc] init];
        nameLabel.font = [UIFont systemFontOfSize:13];
        nameLabel.textColor = COMMENTCOLOR;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.hidden = YES;
        [self.contentView addSubview:nameLabel];
        
        msgImageView = [[UIImageView alloc] init];
        msgImageView.layer.contentsGravity = kCAGravityResizeAspectFill;
        msgImageView.clipsToBounds = YES;
        [self.contentView addSubview:msgImageView];
    }
    return self;
}


-(void)setCellWithDict:(NSDictionary *)dict
{
    msgDict = dict;
    self.timeLabel.backgroundColor = RGB(203, 203, 203, 1);
    CGFloat messageBgY = 30;
    CGFloat messageTfY = 5;
    NSString *msgContent = [dict objectForKey:@"content"];
    CGSize size = [SizeTools getSizeWithString:[msgContent emojizedString] andWidth:SCREEN_WIDTH/2+20 andFont:[UIFont systemFontOfSize:14]];
    headerTapTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerImageViewTap:)];
    [self.headerImageView addGestureRecognizer:headerTapTgr];
    self.headerImageView.userInteractionEnabled = YES;
    self.chatBg.hidden = NO;
    
    self.button.hidden = YES;
    self.joinlable.hidden = YES;
    self.timeLabel.hidden = NO;
    self.messageTf.editable = NO;
    self.messageTf.hidden = NO;
    self.messageTf.backgroundColor = [UIColor clearColor];
    
//    chatImageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chatimagetap:)];
//    self.msgImageView.userInteractionEnabled = YES;
//    [self.msgImageView addGestureRecognizer:chatImageTap];
    
    
    if (SYSVERSION >= 7.0)
    {
        self.messageTf.font = [UIFont systemFontOfSize:16];
    }
    else
    {
        self.messageTf.font = [UIFont systemFontOfSize:14];
    }
    
    if ([[dict objectForKey:DIRECT] isEqualToString:@"f"])
    {
        if ([[msgContent pathExtension] isEqualToString:@"png"] || [[msgContent pathExtension] isEqualToString:@"jpg"])
        {
            self.messageTf.hidden = YES;
            self.msgImageView.hidden = NO;
            self.timeLabel.frame = CGRectMake(SCREEN_WIDTH/2-50, 5, 100, 20);
            NSString *timeStr = [Tools showTime:[dict objectForKey:@"time"]];
            self.timeLabel.text = timeStr;
            
            self.chatBg.frame = CGRectMake(SCREEN_WIDTH - 10- 100- 30-45, messageBgY, 100+PhotoSpace*2+5, 100+PhotoSpace*2);
            [self.chatBg setImage:fromImage];
            
            self.msgImageView.frame = CGRectMake(self.chatBg.frame.origin.x+PhotoSpace+5, self.chatBg.frame.origin.y+PhotoSpace, 100, 100);
            
            [Tools fillImageView:self.msgImageView withImageFromURL:msgContent imageWidth:200 andDefault:@"3100"];
            
            self.headerImageView.frame = CGRectMake(5, messageBgY, 40, 40);
            
            if (isGroup)
            {
                self.nameLabel.hidden = NO;
                self.nameLabel.frame = CGRectMake(self.headerImageView.frame.size.width+self.headerImageView.frame.origin.x+5, self.headerImageView.frame.origin.y, 20, 100);
                self.nameLabel.text = [dict objectForKey:@"fname"];
            }
            
        }
        else
        {
            self.messageTf.hidden = NO;
            self.msgImageView.hidden = YES;
            self.timeLabel.frame = CGRectMake(SCREEN_WIDTH/2-50, 5, 100, 20);
            NSString *timeStr = [Tools showTime:[dict objectForKey:@"time"]];
            self.timeLabel.text = timeStr;
            
            self.chatBg.frame = CGRectMake(55, messageBgY, size.width+20, size.height+20);
            [self.chatBg setImage:fromImage];
            
            CGFloat he = 0;
            if (SYSVERSION >= 7)
            {
                he = 3;
            }
            
            self.messageTf.frame = CGRectMake(self.chatBg.frame.origin.x + 10,self.chatBg.frame.origin.y + messageTfY, size.width+12, size.height+20+he);
            self.messageTf.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0];
            self.messageTf.text = [[dict objectForKey:@"content"] emojizedString];
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if ([[dict objectForKey:@"content"] rangeOfString:@"$!#"].length >0)
            {
                
                NSString *msgContent = [dict objectForKey:@"content"];
                NSRange range = [msgContent rangeOfString:@"$!#"];
                
                self.messageTf.text = [msgContent substringFromIndex:range.location+range.length];
                
                size = [SizeTools getSizeWithString:[[msgContent substringFromIndex:range.location+range.length] emojizedString] andWidth:SCREEN_WIDTH/2+20 andFont:[UIFont systemFontOfSize:14]];
                
                self.messageTf.frame = CGRectMake(self.chatBg.frame.origin.x + 10,self.chatBg.frame.origin.y + messageTfY, size.width+12, size.height+10+he);
                self.messageTf.editable = NO;
                
                UITapGestureRecognizer *msgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(joinClass:)];
                self.chatBg.userInteractionEnabled = YES;
                [self.chatBg addGestureRecognizer:msgTap];
                self.chatBg.backgroundColor = [UIColor clearColor];
                
                self.messageTf.backgroundColor = [UIColor clearColor];
                self.messageTf.userInteractionEnabled = YES;
                
                self.joinlable.frame = CGRectMake(15, size.height+15, size.width, 30);
                self.joinlable.text = @"点击申请加入";
                self.joinlable.backgroundColor = [UIColor clearColor];
                self.joinlable.hidden = NO;
                
                self.chatBg.frame = CGRectMake(55, messageBgY-0, size.width+20, size.height+20+30);
                
                self.joinlable.userInteractionEnabled = YES;
            }
            else
            {
                self.button.hidden = YES;
            }
            
            self.headerImageView.frame = CGRectMake(5, messageBgY, 40, 40);
            if(isGroup)
            {
                OperatDB *db = [[OperatDB alloc] init];
                NSString *by = [dict objectForKey:@"by"];
                NSDictionary *userDict = [[db findSetWithDictionary:@{@"uid":by} andTableName:USERICONTABLE] firstObject];
                NSString *img_icon = [userDict objectForKey:@"uicon"];
                NSString *name = [userDict objectForKey:@"username"];
                
                self.nameLabel.hidden = NO;
                self.nameLabel.frame = CGRectMake(self.headerImageView.frame.size.width+self.headerImageView.frame.origin.x+5, self.headerImageView.frame.origin.y, 100, 20);
                self.nameLabel.text = name;
                self.chatBg.frame = CGRectMake(55, messageBgY+20, size.width+20, size.height+20);
                self.messageTf.frame = CGRectMake(self.chatBg.frame.origin.x + 10,self.chatBg.frame.origin.y + messageTfY, size.width+12, size.height+20+he);
                [Tools fillImageView:self.headerImageView withImageFromURL:img_icon andDefault:HEADERICON];
            }
            else
            {
                NSDictionary *usericondict = [ImageTools iconDictWithUserID:[dict objectForKey:@"fid"]];
                if (usericondict)
                {
                    [Tools fillImageView:self.headerImageView withImageFromURL:[usericondict objectForKey:@"uicon"] andDefault:HEADERICON];
                }
            }
        }
    }
    else if([[dict objectForKey:DIRECT] isEqualToString:@"t"])
    {
        self.nameLabel.hidden = YES;
        if ([[msgContent pathExtension] isEqualToString:@"png"] || [[msgContent pathExtension] isEqualToString:@"jpg"])
        {
            self.messageTf.hidden = YES;
            self.msgImageView.hidden = NO;
            self.timeLabel.frame = CGRectMake(SCREEN_WIDTH/2-50, 5, 100, 20);
            NSString *timeStr = [Tools showTime:[dict objectForKey:@"time"]];
            self.timeLabel.text = timeStr;
            
            CGFloat x=7;
            if([[Tools device_version] integerValue] >= 7.0)
            {
                x=0;
            }
            
            self.chatBg.frame = CGRectMake(SCREEN_WIDTH - 10- 100- 30-45, messageBgY, 100+PhotoSpace*2+5, 100+PhotoSpace*2);
            [self.chatBg setImage:toImage];
            self.msgImageView.frame = CGRectMake(self.chatBg.frame.origin.x+PhotoSpace, self.chatBg.frame.origin.y+PhotoSpace, 102, 100);
            [Tools fillImageView:self.msgImageView withImageFromURL:msgContent imageWidth:200 andDefault:@"3100"];
            self.headerImageView.frame = CGRectMake(SCREEN_WIDTH - 60, messageBgY, 40, 40);
            [Tools fillImageView:self.headerImageView withImageFromURL:[Tools header_image] andDefault:HEADERICON];
        }
        else
        {
            self.msgImageView.hidden = YES;
            self.messageTf.hidden = NO;
            self.timeLabel.frame = CGRectMake(SCREEN_WIDTH/2-50, 5, 100, 20);
            NSString *timeStr = [Tools showTime:[dict objectForKey:@"time"]];
            self.timeLabel.text = timeStr;
            
            CGFloat x=7;
            if([[Tools device_version] integerValue] >= 7.0)
            {
                x=0;
            }
            
            self.chatBg.frame = CGRectMake(SCREEN_WIDTH - 10-size.width-30-45, messageBgY, size.width+20, size.height+20);
            [self.chatBg setImage:toImage];
            
            self.messageTf.frame = CGRectMake(self.chatBg.frame.origin.x+ 5-x,self.chatBg.frame.origin.y + messageTfY, size.width+12, size.height+20);
            self.messageTf.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0];
            self.messageTf.text = [[dict objectForKey:@"content"] emojizedString];
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            self.button.hidden = YES;
            
            if ([[dict objectForKey:@"content"] rangeOfString:@"$!#"].length >0)
            {
                NSString *msgContent = [dict objectForKey:@"content"];
                NSRange range = [msgContent rangeOfString:@"$!#"];
                self.messageTf.text = [msgContent substringFromIndex:range.location+range.length];
                size = [SizeTools getSizeWithString:[[msgContent substringFromIndex:range.location+range.length] emojizedString] andWidth:SCREEN_WIDTH/2+20 andFont:[UIFont systemFontOfSize:14]];
                self.chatBg.frame = CGRectMake(SCREEN_WIDTH - 10-size.width-30-45, messageBgY, size.width+20, size.height+20);
                self.messageTf.frame = CGRectMake(self.chatBg.frame.origin.x+ 10-x,self.chatBg.frame.origin.y + messageTfY, size.width+12, size.height+30);
            }
            self.headerImageView.frame = CGRectMake(SCREEN_WIDTH - 60, messageBgY, 40, 40);
            
            [Tools fillImageView:self.headerImageView withImageFromURL:[Tools header_image] andDefault:HEADERICON];
        }
    }
    self.timeLabel.layer.cornerRadius = self.timeLabel.frame.size.height/2;
    self.timeLabel.clipsToBounds = YES;
    self.timeLabel.textColor = [UIColor whiteColor];
    self.headerImageView.layer.cornerRadius = 5;
    self.headerImageView.clipsToBounds = YES;
}

-(void)headerImageViewTap:(id)sender
{
    if ([self.msgDelegate respondsToSelector:@selector(toPersonDetail:)])
    {
        DDLOG(@"msgdict %@",msgDict);
        [self.msgDelegate toPersonDetail:msgDict];
    }
}

-(void)joinClass:(UITapGestureRecognizer *)tap
{
    DDLOG(@"msg dict %@",msgDict);
    NSString *msgContent = [msgDict objectForKey:@"content"];
    if ([self.msgDelegate respondsToSelector:@selector(joinClassWithMsgContent:)])
    {
        [self.msgDelegate joinClassWithMsgContent:msgContent];
    }
}

#pragma mark - sizeabout
-(CGSize)sizeWithImage:(UIImage *)image
{
    CGFloat width = 0;
    CGFloat height = 0;
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    //    DDLOG(@" imageWidth %.0f imageHeight %.0f",imageWidth,imageHeight);
    
    if (imageWidth >= SCREEN_WIDTH && imageHeight >=Image_H)
    {
        if (imageHeight >= imageWidth)
        {
            height = Image_H;
            width = height*imageWidth/imageHeight;
        }
        else if(imageWidth >= imageHeight)
        {
            width = SCREEN_WIDTH-80;
            height = imageHeight*width/imageWidth;
        }
    }
    else if(imageHeight >= Image_H)
    {
        height = Image_H;
        width = height*imageWidth/imageHeight;
    }
    else if(imageWidth >= SCREEN_WIDTH)
    {
        width = SCREEN_WIDTH-80;
        height = imageHeight*width/imageWidth;
    }
    else
    {
        width = imageWidth;
        height = imageHeight;
    }
    CGSize size = CGSizeMake(width, height);
    return size;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

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
@synthesize messageTf,chatBg,soundButton,timeLabel,headerImageView,joinlable,msgImageView,msgDict,isGroup,nameLabel,fromImgIcon;

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
        [self.contentView addSubview:chatBg];
        
        soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        soundButton.hidden = YES;
        [self.contentView addSubview:soundButton];
        
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
    self.chatBg.hidden = YES;
    
    self.soundButton.hidden = YES;
    self.joinlable.hidden = YES;
    self.timeLabel.hidden = NO;
    self.messageTf.editable = NO;
    self.messageTf.hidden = NO;
    self.messageTf.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.messageTf.textColor = TITLE_COLOR;
    self.messageTf.backgroundColor = [UIColor clearColor];
    self.msgImageView.layer.cornerRadius = 3;
    self.msgImageView.clipsToBounds = YES;
    
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
        NSString *extension =  [msgContent pathExtension];
        if ([extension isEqualToString:@"png"] || [extension isEqualToString:@"jpg"])
        {
            //图片
            self.chatBg.hidden = NO;
            self.messageTf.hidden = YES;
            self.msgImageView.hidden = NO;
            self.timeLabel.frame = CGRectMake(SCREEN_WIDTH/2-50, 5, 100, 20);
            NSString *timeStr = [Tools showTime:[dict objectForKey:@"time"]];
            self.timeLabel.text = timeStr;
            
            self.chatBg.frame = CGRectMake(55, messageBgY, 100+PhotoSpace*2+5, 100+PhotoSpace*2);
            [self.chatBg setImage:fromImage];
            
            self.msgImageView.frame = CGRectMake(self.chatBg.frame.origin.x+PhotoSpace+5, self.chatBg.frame.origin.y+PhotoSpace+1, 100, 100);
            self.msgImageView.layer.cornerRadius = 3;
            self.msgImageView.clipsToBounds = YES;
            
            [Tools fillImageView:self.msgImageView withImageFromURL:msgContent imageWidth:200 andDefault:@"3100"];
            
            self.headerImageView.frame = CGRectMake(5, messageBgY, 40, 40);
            
            CGFloat he = 0;
            if (SYSVERSION >= 7)
            {
                he = 3;
            }
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
                self.chatBg.frame = CGRectMake(55, messageBgY+20, 100+PhotoSpace*2+5, 100+PhotoSpace*2);
                [self.chatBg setImage:fromImage];
                
                self.msgImageView.frame = CGRectMake(self.chatBg.frame.origin.x+PhotoSpace+7, self.chatBg.frame.origin.y+PhotoSpace+2, 98, 98);
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
        else if([msgContent rangeOfString:@"amr"].length > 0)
        {
            //语音
//             DDLOG(@"from == %@%@",MEDIAURL,msgContent);
            self.chatBg.hidden = YES;
            self.msgImageView.hidden = NO;
            self.timeLabel.frame = CGRectMake(SCREEN_WIDTH/2-50, 5, 100, 20);
            NSString *timeStr = [Tools showTime:[dict objectForKey:@"time"]];
            self.timeLabel.text = timeStr;
            
            NSRange range = [msgContent rangeOfString:@"time="];
            NSString *timelength = @"";
            if (range.length > 0)
            {
                timelength = [NSString stringWithFormat:@"%@\"",[msgContent substringFromIndex:range.location+range.length]];
                self.messageTf.text = timelength;
            }
            
            self.messageTf.textColor = COMMENTCOLOR;
            
            CGFloat soundLength = 0;
            if ([timelength integerValue] * 10 > 120)
            {
                soundLength = 120;
            }
            else if([timelength integerValue] * 10 < 80)
            {
                soundLength = 80;
            }
            else
            {
                soundLength = [timelength integerValue] * 10;
            }

            self.soundButton.hidden = NO;
            self.soundButton.frame = CGRectMake(55, messageBgY, soundLength, 40);
            [self.soundButton setBackgroundImage:[Tools getImageFromImage:fromImage andInsets:UIEdgeInsetsMake(35, 25, 17, 20)] forState:UIControlStateNormal];
            [self.soundButton addTarget:self action:@selector(playSound) forControlEvents:UIControlEventTouchUpInside];
            
            self.messageTf.frame = CGRectMake(self.soundButton.frame.size.width+self.soundButton.frame.origin.x+10, self.soundButton.frame.origin.y+3, 40, 25);
            
            self.msgImageView.frame = CGRectMake(self.soundButton.frame.origin.x+PhotoSpace+5, self.soundButton.frame.origin.y+PhotoSpace+1, 25, 25);
            [self.msgImageView setImage:[UIImage imageNamed:@"icon_sound_f"]];
            
            UITapGestureRecognizer *playTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playSound)];
            self.soundButton.userInteractionEnabled = YES;
            [self.soundButton addGestureRecognizer:playTgr];
            
            
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
                self.soundButton.frame = CGRectMake(55, messageBgY+20, soundLength, 40);
                [self.soundButton setBackgroundImage:[Tools getImageFromImage:fromImage andInsets:UIEdgeInsetsMake(35, 25, 17, 20)] forState:UIControlStateNormal];
                
                self.msgImageView.frame = CGRectMake(self.soundButton.frame.origin.x+PhotoSpace+5, self.soundButton.frame.origin.y+PhotoSpace+1, 25, 25);
                [self.msgImageView setImage:[UIImage imageNamed:@"icon_sound_f"]];
                
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
        else
        {
            self.chatBg.hidden = NO;
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
            
            NSRange range = [msgContent rangeOfString:@"$!#"];
            if (range.length >0)
            {
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
                self.joinlable.text = @"点击查看详情";
                self.joinlable.backgroundColor = [UIColor clearColor];
                self.joinlable.hidden = NO;
                
                self.chatBg.frame = CGRectMake(55, messageBgY-0, size.width+20, size.height+20+30);
                
                self.joinlable.userInteractionEnabled = YES;
            }
            else
            {
                self.soundButton.hidden = YES;
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
        NSString *extension =  [msgContent pathExtension];
        if ([extension isEqualToString:@"png"] || [extension isEqualToString:@"jpg"])
        {
            self.chatBg.hidden = NO;
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
        else if([msgContent rangeOfString:@"amr"].length > 0)
        {
            //语音
            self.chatBg.hidden = YES;
            
            self.headerImageView.frame = CGRectMake(SCREEN_WIDTH - 60, messageBgY, 40, 40);
            [Tools fillImageView:self.headerImageView withImageFromURL:[Tools header_image] andDefault:HEADERICON];
            
            NSRange range = [msgContent rangeOfString:@"time="];
            NSString *timelength = @"";
            if (range.length > 0)
            {
                timelength = [NSString stringWithFormat:@"%@\"",[msgContent substringFromIndex:range.location+range.length]];
                self.messageTf.text = timelength;
            }
            
            self.messageTf.textColor = COMMENTCOLOR;
            
            CGFloat soundLength = 0;
            if ([timelength integerValue] * 10 > 120)
            {
                soundLength = 120;
            }
            else if([timelength integerValue] *10 < 80)
            {
                soundLength = 80;
            }
            else
            {
                soundLength = [timelength integerValue] * 10;
            }

            self.soundButton.hidden = NO;
            self.soundButton.frame = CGRectMake(SCREEN_WIDTH - soundLength-45-20, messageBgY, soundLength, 40);
            
            [self.soundButton setBackgroundImage:[Tools getImageFromImage:toImage andInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
            [self.soundButton addTarget:self action:@selector(playSound) forControlEvents:UIControlEventTouchUpInside];
            
            
            
            self.msgImageView.hidden = NO;
            self.msgImageView.frame = CGRectMake(self.soundButton.frame.origin.x + self.soundButton.frame.size.width-35, self.soundButton.frame.origin.y+7.5, 25, 25);
            [self.msgImageView setImage:[UIImage imageNamed:@"icon_sound_t"]];
            
            UITapGestureRecognizer *playTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playSound)];
            self.soundButton.userInteractionEnabled = YES;
            [self.soundButton addGestureRecognizer:playTgr];
            
            self.messageTf.frame = CGRectMake(self.soundButton.frame.origin.x-30,self.soundButton.frame.origin.y+3 , 40, 25);

            self.messageTf.textColor = COMMENTCOLOR;
            self.messageTf.editable = NO;
            
//            DDLOG(@"to===%@%@",MEDIAURL,msgContent);
        }
        else
        {
            self.chatBg.hidden = NO;
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
            self.soundButton.hidden = YES;
            
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

-(void)playSound
{
    NSString *msgContent = [msgDict objectForKey:@"content"];
    NSString *lastcom = [msgContent lastPathComponent];
    NSRange range = [lastcom rangeOfString:@"time="];
    NSString *filename = [lastcom substringToIndex:range.location-1];
    NSString *fileExtention = [filename pathExtension];
    NSRange extentionRange = [filename rangeOfString:fileExtention];
    NSString *notificationName = [NSString stringWithFormat:@"%@.wav",[filename substringToIndex:extentionRange.location-1]];
    if (isPlaying)
    {
        [self stopImage];
        isPlaying = NO;
        if ([self.msgDelegate respondsToSelector:@selector(stopPlay:)])
        {
            [self.msgDelegate stopPlay:[NSString stringWithFormat:@"%@/%@",[DirectyTools soundDir],filename]];
        }
    }
    else
    {
        if ([self.msgDelegate respondsToSelector:@selector(soundTap:andImageView:)])
        {
            isPlaying = YES;
            if ([[msgDict objectForKey:DIRECT] isEqualToString:@"t"])
            {
                [self playToImages];
            }
            else if ([[msgDict objectForKey:DIRECT] isEqualToString:@"f"])
            {
                [self playFromImages];
            }
            
            [self.msgDelegate soundTap:msgContent andImageView:self.msgImageView];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopImage) name:notificationName object:nil];
        }
    }
}

-(void)stopImage
{
//    [timer invalidate];
    [self.msgImageView stopAnimating];
    NSString *msgContent = [msgDict objectForKey:@"content"];
    NSString *lastcom = [msgContent lastPathComponent];
    NSRange range = [lastcom rangeOfString:@"time="];
    NSString *filename = [lastcom substringToIndex:range.location-1];
    NSString *fileExtention = [filename pathExtension];
    NSRange extentionRange = [filename rangeOfString:fileExtention];
    NSString *notificationName = [NSString stringWithFormat:@"%@.wav",[filename substringToIndex:extentionRange.location-1]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
}

-(void)playImages
{
    NSArray *images = nil;
    if ([[msgDict objectForKey:DIRECT] isEqualToString:@"t"])
    {
        images = [NSArray arrayWithObjects:
                  [UIImage imageNamed:@"icon_sound_t1"],
                  [UIImage imageNamed:@"icon_sound_t2"],
                  [UIImage imageNamed:@"icon_sound_t"],nil];
    }
    else if ([[msgDict objectForKey:DIRECT] isEqualToString:@"f"])
    {
        images = [NSArray arrayWithObjects:
                  [UIImage imageNamed:@"icon_sound_f1"],
                  [UIImage imageNamed:@"icon_sound_f2"],
                  [UIImage imageNamed:@"icon_sound_f"],nil];
    }
    for (int i=0; [timer isValid] && (i<[images count]) ; i++)
    {
        [self.msgImageView setImage:[images objectAtIndex:i]];
        if (i == [images count]-1)
        {
            i = 0;
        }
    }
}

-(void)playFromImages
{
    NSString *msgContent = [msgDict objectForKey:@"content"];
    NSRange range = [msgContent rangeOfString:@"time="];
    int time = 0;
    if (range.length> 0)
    {
        time = [[msgContent substringFromIndex:range.location+range.length] intValue];
    }
    
    self.msgImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"icon_sound_f1"],
                                         [UIImage imageNamed:@"icon_sound_f2"],
                                         [UIImage imageNamed:@"icon_sound_f"],nil];
    self.msgImageView.animationDuration = 0.8;
    [self.msgImageView startAnimating];
}

-(void)playToImages
{
    NSString *msgContent = [msgDict objectForKey:@"content"];
    NSRange range = [msgContent rangeOfString:@"time="];
    int time = 0;
    if (range.length> 0)
    {
        time = [[msgContent substringFromIndex:range.location+range.length] intValue];
    }
    self.msgImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"icon_sound_t1"],
                                         [UIImage imageNamed:@"icon_sound_t2"],
                                         [UIImage imageNamed:@"icon_sound_t"],nil];
    self.msgImageView.animationDuration = 0.8;
    [self.msgImageView startAnimating];
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

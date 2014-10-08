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
@synthesize messageContentLabel,chatBg,soundButton,timeLabel,headerImageView,joinlable,msgImageView,msgDict,isGroup,nameLabel,fromImgIcon;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        fromImage = [Tools getImageFromImage:[UIImage imageNamed:@"f"] andInsets:UIEdgeInsetsMake(30, 30, 20, 30)];
        toImage = [Tools getImageFromImage:[UIImage imageNamed:@"t2"] andInsets:UIEdgeInsetsMake(30, 30, 20, 30)];
        
//        fromImage = [[UIImage imageNamed:@"f"] stretchableImageWithLeftCapWidth:90 topCapHeight:100];
//        toImage = [[UIImage imageNamed:@"t2"] stretchableImageWithLeftCapWidth:30 topCapHeight:100];
        
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
        
        messageContentLabel = [[UILabel alloc] init];
        messageContentLabel.backgroundColor = [UIColor clearColor];
        messageContentLabel.hidden = YES;
        messageContentLabel.lineBreakMode = NSLineBreakByCharWrapping;
        messageContentLabel.numberOfLines = 10000;
        messageContentLabel.userInteractionEnabled = YES;
        [self.contentView addSubview:messageContentLabel];
        
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
    CGFloat messageBgY = CHAT_MSG_SPACE;
    
    
    
    NSString *msgContent = [[dict objectForKey:@"content"] emojizedString];
    CGSize size = [SizeTools getSizeWithString:msgContent andWidth:SCREEN_WIDTH/2+20 andFont:MessageTextFont];
    headerTapTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerImageViewTap:)];
    [self.headerImageView addGestureRecognizer:headerTapTgr];
    self.headerImageView.userInteractionEnabled = YES;
    self.chatBg.hidden = YES;
    
    self.soundButton.hidden = YES;
    self.joinlable.hidden = YES;
    
    self.msgImageView.layer.cornerRadius = 3;
    self.msgImageView.clipsToBounds = YES;
    
    self.messageContentLabel.hidden = NO;
    self.timeLabel.hidden = YES;
    
    self.messageContentLabel.textColor = CHAT_CONTENT_COLOR;
    self.messageContentLabel.backgroundColor = [UIColor clearColor];
    self.messageContentLabel.font = MessageTextFont;
    
    if ([[dict objectForKey:DIRECT] isEqualToString:@"f"])
    {
        CGFloat leftSpace = 7.5+CHAT_TOP_IMAGE_SPACE;
        
        self.headerImageView.frame = CGRectMake(HEADER_EDGE_SPACE, messageBgY, 40, 40);
        CGFloat headerImageX = self.headerImageView.frame.size.width+headerImageView.frame.origin.x+6;
        NSString *extension =  [msgContent pathExtension];
        if ([extension isEqualToString:@"png"] || [extension isEqualToString:@"jpg"])
        {
            //图片
            self.chatBg.hidden = NO;
            self.messageContentLabel.hidden = YES;
            self.msgImageView.hidden = NO;
            NSString *timeStr = [Tools showTime:[dict objectForKey:@"time"]];
            self.timeLabel.text = timeStr;
            
            
            
            self.chatBg.frame = CGRectMake(headerImageX, messageBgY, MESSAGE_IMAGE_HEIGHT+leftSpace+CHAT_TOP_IMAGE_SPACE, MESSAGE_IMAGE_HEIGHT+CHAT_TOP_IMAGE_SPACE*2);
            [self.chatBg setImage:fromImage];
            
            self.msgImageView.frame = CGRectMake(self.chatBg.frame.origin.x+leftSpace, self.chatBg.frame.origin.y+CHAT_TOP_IMAGE_SPACE, MESSAGE_IMAGE_HEIGHT, MESSAGE_IMAGE_HEIGHT);
            self.msgImageView.layer.cornerRadius = 3;
            self.msgImageView.clipsToBounds = YES;
            
            [Tools fillImageView:self.msgImageView withImageFromURL:msgContent imageWidth:200 andDefault:@"3100"];
            
            
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
                self.chatBg.frame = CGRectMake(headerImageX, messageBgY+25, MESSAGE_IMAGE_HEIGHT+leftSpace+CHAT_TOP_IMAGE_SPACE, MESSAGE_IMAGE_HEIGHT+CHAT_TOP_IMAGE_SPACE*2);
                [self.chatBg setImage:fromImage];
                
                self.msgImageView.frame = CGRectMake(self.chatBg.frame.origin.x+leftSpace, self.chatBg.frame.origin.y+CHAT_TOP_IMAGE_SPACE, MESSAGE_IMAGE_HEIGHT, MESSAGE_IMAGE_HEIGHT);
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
            self.chatBg.hidden = YES;
            self.msgImageView.hidden = NO;
            NSString *timeStr = [Tools showTime:[dict objectForKey:@"time"]];
            self.timeLabel.text = timeStr;
            
            NSRange range = [msgContent rangeOfString:@"time="];
            NSString *timelength = @"";
            if (range.length > 0)
            {
                timelength = [NSString stringWithFormat:@"%@\"",[msgContent substringFromIndex:range.location+range.length]];
                self.messageContentLabel.text = timelength;
            }
            
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
            self.soundButton.frame = CGRectMake(headerImageX, messageBgY, soundLength, 40);
            [self.soundButton setBackgroundImage:fromImage forState:UIControlStateNormal];
            [self.soundButton addTarget:self action:@selector(playSound) forControlEvents:UIControlEventTouchUpInside];
            
            self.soundButton.backgroundColor = [UIColor clearColor];
            
            self.messageContentLabel.frame = CGRectMake(self.soundButton.frame.size.width+self.soundButton.frame.origin.x+7, self.soundButton.frame.origin.y+4, 40, 25);
            
            self.msgImageView.frame = CGRectMake(self.soundButton.frame.origin.x+leftSpace, self.soundButton.frame.origin.y+7.5, 25, 25);
            [self.msgImageView setImage:[UIImage imageNamed:@"icon_sound_f"]];
            
            UITapGestureRecognizer *playTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playSound)];
            self.soundButton.userInteractionEnabled = YES;
            [self.soundButton addGestureRecognizer:playTgr];
            
            
            self.headerImageView.frame = CGRectMake(HEADER_EDGE_SPACE, messageBgY, 40, 40);
            if(isGroup)
            {
                OperatDB *db = [[OperatDB alloc] init];
                NSString *by = [dict objectForKey:@"by"];
                NSDictionary *userDict = [[db findSetWithDictionary:@{@"uid":by} andTableName:USERICONTABLE] firstObject];
                NSString *img_icon = [userDict objectForKey:@"uicon"];
                NSString *name = [userDict objectForKey:@"username"];
                
                self.nameLabel.hidden = NO;
                self.nameLabel.frame = CGRectMake(headerImageX, self.headerImageView.frame.origin.y, 100, 20);
                self.nameLabel.text = name;
                self.soundButton.frame = CGRectMake(headerImageX, messageBgY+25, soundLength, 40);
                [self.soundButton setBackgroundImage:fromImage forState:UIControlStateNormal];
                self.messageContentLabel.frame = CGRectMake(self.soundButton.frame.size.width+self.soundButton.frame.origin.x+7, self.soundButton.frame.origin.y+7.5, 40, 25);
                self.msgImageView.frame = CGRectMake(self.soundButton.frame.origin.x+leftSpace, self.soundButton.frame.origin.y+7.5, 25, 25);
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
            self.messageContentLabel.hidden = NO;
            self.msgImageView.hidden = YES;
            NSString *timeStr = [Tools showTime:[dict objectForKey:@"time"]];
            self.timeLabel.text = timeStr;
            
            self.chatBg.frame = CGRectMake(headerImageX, messageBgY, size.width+leftSpace+CHAT_TOP_TEXT_SPACE, size.height+CHAT_TOP_TEXT_SPACE*2);
            [self.chatBg setImage:fromImage];
            
            self.messageContentLabel.frame = CGRectMake(self.chatBg.frame.origin.x + leftSpace,
                                                        self.chatBg.frame.origin.y + CHAT_TOP_TEXT_SPACE,
                                                        size.width, size.height);
            self.messageContentLabel.text = msgContent;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILongPressGestureRecognizer *longTgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(msgLongTgr:)];
            self.messageContentLabel.userInteractionEnabled = YES;
            [self.messageContentLabel addGestureRecognizer:longTgr];
            
            
            NSRange range = [msgContent rangeOfString:@"$!#"];
            if (range.length >0)
            {
                self.messageContentLabel.text = [msgContent substringFromIndex:range.location+range.length];
                
                size = [SizeTools getSizeWithString:[[msgContent substringFromIndex:range.location+range.length] emojizedString] andWidth:SCREEN_WIDTH/2+20 andFont:MessageTextFont];
                
                self.messageContentLabel.frame = CGRectMake(self.chatBg.frame.origin.x + leftSpace,
                                                            self.chatBg.frame.origin.y + CHAT_TOP_TEXT_SPACE,
                                                            size.width,
                                                            size.height);
                
                UITapGestureRecognizer *msgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(joinClass:)];
                self.chatBg.userInteractionEnabled = YES;
                [self.chatBg addGestureRecognizer:msgTap];
                self.chatBg.backgroundColor = [UIColor clearColor];
                
                self.messageContentLabel.userInteractionEnabled = YES;
                
                self.joinlable.frame = CGRectMake(15, size.height+10, size.width, 30);
                self.joinlable.text = @"点击查看详情";
                self.joinlable.backgroundColor = [UIColor clearColor];
                self.joinlable.hidden = NO;
                
                self.chatBg.frame = CGRectMake(headerImageX, messageBgY-0, size.width+CHAT_TOP_TEXT_SPACE+leftSpace, size.height+CHAT_TOP_TEXT_SPACE*2+20);
                
                self.joinlable.userInteractionEnabled = YES;
            }
            else
            {
                self.soundButton.hidden = YES;
            }
            
            self.headerImageView.frame = CGRectMake(HEADER_EDGE_SPACE, messageBgY, 40, 40);
            
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
                self.chatBg.frame = CGRectMake(headerImageX, messageBgY+25, size.width+leftSpace+CHAT_TOP_TEXT_SPACE, size.height+CHAT_TOP_TEXT_SPACE*2);
                self.messageContentLabel.frame = CGRectMake(self.chatBg.frame.origin.x + leftSpace,
                                                            self.chatBg.frame.origin.y + CHAT_TOP_TEXT_SPACE,
                                                            size.width,
                                                            size.height);
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
        CGFloat rightSpace = 14;
        
        CGFloat rightBgSpace = 8;
        
        self.nameLabel.hidden = YES;
        self.headerImageView.frame = CGRectMake(SCREEN_WIDTH-40-HEADER_EDGE_SPACE, messageBgY, 40, 40);
        CGFloat msgX = 40+HEADER_EDGE_SPACE + rightSpace;
        NSString *extension =  [msgContent pathExtension];
        if ([extension isEqualToString:@"png"] || [extension isEqualToString:@"jpg"])
        {
            self.chatBg.hidden = NO;
            self.messageContentLabel.hidden = YES;
            self.msgImageView.hidden = NO;
            
            NSString *timeStr = [Tools showTime:[dict objectForKey:@"time"]];
            self.timeLabel.text = timeStr;
            
            CGFloat x=7;
            if([[Tools device_version] integerValue] >= 7.0)
            {
                x=0;
            }
            self.chatBg.frame = CGRectMake(SCREEN_WIDTH - (msgX+MESSAGE_IMAGE_HEIGHT+CHAT_TOP_IMAGE_SPACE*2), messageBgY, MESSAGE_IMAGE_HEIGHT+CHAT_TOP_IMAGE_SPACE*2+rightBgSpace, MESSAGE_IMAGE_HEIGHT+CHAT_TOP_IMAGE_SPACE*2);
            [self.chatBg setImage:toImage];
            self.msgImageView.frame = CGRectMake(self.chatBg.frame.origin.x+CHAT_TOP_IMAGE_SPACE, self.chatBg.frame.origin.y+CHAT_TOP_IMAGE_SPACE, MESSAGE_IMAGE_HEIGHT, MESSAGE_IMAGE_HEIGHT);
            [Tools fillImageView:self.msgImageView withImageFromURL:msgContent imageWidth:200 andDefault:@"3100"];
            [Tools fillImageView:self.headerImageView withImageFromURL:[Tools header_image] andDefault:HEADERICON];
        }
        else if([msgContent rangeOfString:@"amr"].length > 0)
        {
            //语音
            self.chatBg.hidden = YES;
            
            [Tools fillImageView:self.headerImageView withImageFromURL:[Tools header_image] andDefault:HEADERICON];
            
            NSRange range = [msgContent rangeOfString:@"time="];
            NSString *timelength = @"";
            if (range.length > 0)
            {
                timelength = [NSString stringWithFormat:@"%@\"",[msgContent substringFromIndex:range.location+range.length]];
                self.messageContentLabel.text = timelength;
            }
            
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
            self.soundButton.frame = CGRectMake(SCREEN_WIDTH - (soundLength+msgX-rightBgSpace), messageBgY, soundLength, 40);
            [self.soundButton setBackgroundImage:toImage forState:UIControlStateNormal];
            [self.soundButton addTarget:self action:@selector(playSound) forControlEvents:UIControlEventTouchUpInside];
            
            self.msgImageView.hidden = NO;
            self.msgImageView.frame = CGRectMake(self.soundButton.frame.origin.x + self.soundButton.frame.size.width - 38, self.soundButton.frame.origin.y+7.5, 25, 25);
            [self.msgImageView setImage:[UIImage imageNamed:@"icon_sound_t"]];
            
            UITapGestureRecognizer *playTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playSound)];
            self.soundButton.userInteractionEnabled = YES;
            [self.soundButton addGestureRecognizer:playTgr];
            
            self.messageContentLabel.frame = CGRectMake(self.soundButton.frame.origin.x-30,
                                                        self.soundButton.frame.origin.y+self.soundButton.frame.size.height/2-12.5,
                                                        40,25);
        }
        else
        {
            self.chatBg.hidden = NO;
            self.msgImageView.hidden = YES;
            self.messageContentLabel.hidden = NO;
            NSString *timeStr = [Tools showTime:[dict objectForKey:@"time"]];
            self.timeLabel.text = timeStr;
            
            self.chatBg.frame = CGRectMake(SCREEN_WIDTH - (msgX+size.width+CHAT_TOP_TEXT_SPACE*2), messageBgY, size.width+CHAT_TOP_TEXT_SPACE*2+rightBgSpace, size.height+CHAT_TOP_TEXT_SPACE*2);
            [self.chatBg setImage:toImage];
            
            self.messageContentLabel.frame = CGRectMake(self.chatBg.frame.origin.x+CHAT_TOP_TEXT_SPACE,
                                                        self.chatBg.frame.origin.y+CHAT_TOP_TEXT_SPACE,
                                                        size.width,
                                                        size.height);
            self.messageContentLabel.text = msgContent;
            
            UILongPressGestureRecognizer *longTgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(msgLongTgr:)];
            self.messageContentLabel.userInteractionEnabled = YES;
            [self.messageContentLabel addGestureRecognizer:longTgr];
            
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            self.soundButton.hidden = YES;
            
            if ([[dict objectForKey:@"content"] rangeOfString:@"$!#"].length >0)
            {
                NSString *msgContent = [dict objectForKey:@"content"];
                NSRange range = [msgContent rangeOfString:@"$!#"];
                self.messageContentLabel.text = [msgContent substringFromIndex:range.location+range.length];
                size = [SizeTools getSizeWithString:[[msgContent substringFromIndex:range.location+range.length] emojizedString] andWidth:SCREEN_WIDTH/2+20 andFont:MessageTextFont];
                self.chatBg.frame = CGRectMake(SCREEN_WIDTH - (msgX+size.width+CHAT_TOP_TEXT_SPACE*2), messageBgY, size.width+rightBgSpace+CHAT_TOP_TEXT_SPACE*2, size.height+CHAT_TOP_TEXT_SPACE*2);
                self.messageContentLabel.frame = CGRectMake(self.chatBg.frame.origin.x+CHAT_TOP_TEXT_SPACE,
                                                            self.chatBg.frame.origin.y+CHAT_TOP_TEXT_SPACE,
                                                            size.width, size.height);
            }
            [Tools fillImageView:self.headerImageView withImageFromURL:[Tools header_image] andDefault:HEADERICON];
        }
    }
    self.timeLabel.frame = CGRectMake(SCREEN_WIDTH/2-50, 5, 100, 20);
    self.timeLabel.layer.cornerRadius = self.timeLabel.frame.size.height/2;
    self.timeLabel.clipsToBounds = YES;
    self.timeLabel.textColor = [UIColor whiteColor];
    self.headerImageView.layer.cornerRadius = 5;
    self.headerImageView.clipsToBounds = YES;
}

-(void)msgLongTgr:(UILongPressGestureRecognizer *)longTgr
{
    if (longTgr.state != UIGestureRecognizerStateBegan ||
        ![self becomeFirstResponder])
        return;
    CGRect viewRect = longTgr.view.frame;
    CGFloat menuX = 0;
    if ([[msgDict objectForKey:DIRECT] isEqualToString:@"t"])
    {
        menuX = viewRect.origin.x+viewRect.size.width/2-22;
    }
    else if ([[msgDict objectForKey:DIRECT] isEqualToString:@"f"])
    {
        menuX = viewRect.origin.x+viewRect.size.width/2-30;
    }
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copytext)];
    menu.menuItems = [NSArray arrayWithObjects:menuItem, nil];
    [menu setTargetRect:CGRectMake(menuX, viewRect.origin.y, 50, 50) inView:self];
    [menu setMenuVisible:YES animated:YES];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copytext));
}

-(void)copytext
{
    UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
    NSString *msgContent = [msgDict objectForKey:@"content"];
    NSRange range = [msgContent rangeOfString:@"$!#"];
    if (range.length > 0)
    {
        [generalPasteBoard setString:[msgContent substringFromIndex:range.location+range.length]];
    }
    else
    {
        [generalPasteBoard setString:msgContent];
    }
    
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
    if (range.length > 0)
    {
        NSString *filename = [lastcom substringToIndex:range.location-1];
        NSString *fileExtention = [filename pathExtension];
        NSRange extentionRange = [filename rangeOfString:fileExtention];
        NSString *notificationName = [NSString stringWithFormat:@"%@.wav",[filename substringToIndex:extentionRange.location-1]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
    }
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

//
//  MessageCell.m
//  XMPP1106
//
//  Created by mac120 on 13-11-6.
//  Copyright (c) 2013年 mac120. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell
@synthesize messageTf,chatBg,button,timeLabel,headerImageView,joinlable;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        headerImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:headerImageView];
        
        chatBg = [[UIImageView alloc] init];
        chatBg.hidden = YES;
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.hidden = YES;
//        [self.contentView addSubview:button];
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
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

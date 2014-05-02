//
//  MessageCell.m
//  XMPP1106
//
//  Created by mac120 on 13-11-6.
//  Copyright (c) 2013年 mac120. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell
@synthesize messageTf,chatBg,button,timeLabel,headerImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        headerImageView = [[UIImageView alloc] init];
        headerImageView.layer.cornerRadius = 5;
        headerImageView.clipsToBounds = YES;
        [self.contentView addSubview:headerImageView];
        
        chatBg = [[UIImageView alloc] init];
        chatBg.hidden = YES;
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.hidden = YES;
        //        button.layer.cornerRadius = 5;
        [self.contentView addSubview:button];
        [self.contentView addSubview:chatBg];
        
        messageTf = [[UITextView alloc] init];
        messageTf.editable = NO;
        messageTf.backgroundColor = [UIColor clearColor];
        messageTf.hidden = YES;
        messageTf.font = [UIFont systemFontOfSize:13];
        [chatBg addSubview:messageTf];
        
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

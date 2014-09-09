//
//  NotificationCell.m
//  School
//
//  Created by TeekerZW on 14-2-18.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "NotificationCell.h"
#import "Header.h"

@implementation NotificationCell
@synthesize iconImageView,bgImageView,contentLabel,timeLabel,statusLabel,contentTextView,nameLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
                
        bgImageView = [[UIImageView alloc] init];
        bgImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:bgImageView];
        
        iconImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:iconImageView];
        
        nameLabel = [[UILabel alloc] init];
        nameLabel.font = [UIFont systemFontOfSize:16];
        nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:nameLabel];
        
        contentLabel = [[MyLabel alloc] init];
        contentLabel.backgroundColor = [UIColor clearColor];
//        contentLabel.font = DongTaiContentFont;
        contentLabel.numberOfLines = 2;
        contentLabel.contentMode = UIViewContentModeTop;
        contentLabel.lineBreakMode = NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail;
        [self.contentView addSubview:contentLabel];
        
        timeLabel = [[UILabel alloc] init];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.font = [UIFont systemFontOfSize:18];
        [self.contentView addSubview:timeLabel];
        
        statusLabel = [[UILabel alloc] init];
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.font = [UIFont systemFontOfSize:10];
        statusLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:statusLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

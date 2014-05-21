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
@synthesize iconLabel,bgImageView,contentLabel,timeLabel,statusLabel,contentTextView,nameLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
                
        bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 10, SCREEN_WIDTH-6, 100)];
        bgImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:bgImageView];
        
        iconLabel = [[UILabel alloc] init];
//        iconLabel.backgroundColor = RGB(234, 234, 234, 1);
        [self.contentView addSubview:iconLabel];
        
        nameLabel = [[UILabel alloc] init];
        nameLabel.font = [UIFont systemFontOfSize:16];
        nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:nameLabel];
        
        contentLabel = [[MyLabel alloc] initWithFrame:CGRectMake(25, 20,  SCREEN_WIDTH-70, 75)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.font = [UIFont systemFontOfSize:14];
        contentLabel.numberOfLines = 3;
        contentLabel.lineBreakMode = NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail;
        [self.contentView addSubview:contentLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 15, 165, 20)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.font = [UIFont systemFontOfSize:18];
        timeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:timeLabel];
        
        statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 150, 95, 130, 10)];
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

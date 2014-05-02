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
@synthesize iconImageView,bgImageView,contentLabel,timeLabel,statusLabel,contentTextView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
        iconImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:iconImageView];
        
        bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 10, SCREEN_WIDTH-60, 100)];
        bgImageView.backgroundColor = [UIColor clearColor];
//        bgImageView.layer.cornerRadius = 5;
//        bgImageView.layer.masksToBounds = YES;
//        bgImageView.layer.borderColor = [UIColor grayColor].CGColor;
//        bgImageView.layer.borderWidth = 1.0f;
        [self.contentView addSubview:bgImageView];
        
        contentLabel = [[MyLabel alloc] initWithFrame:CGRectMake(55, 5,  SCREEN_WIDTH-70, 75)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.font = [UIFont systemFontOfSize:14];
        contentLabel.numberOfLines = 3;
        contentLabel.lineBreakMode = NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail;
        [self.contentView addSubview:contentLabel];
        
//        contentTextView = [[UITextView alloc] init];
//        contentTextView.backgroundColor = [UIColor clearColor];
//        contentTextView.editable = NO;
//        contentTextView.frame = CGRectMake(55, 8,  SCREEN_WIDTH-70, 75);
//        [self.contentView addSubview:contentTextView];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 180, 75, 165, 15)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.font = [UIFont systemFontOfSize:10];
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

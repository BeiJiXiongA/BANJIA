//
//  NotificationDetailCell.m
//  School
//
//  Created by TeekerZW on 14-2-19.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "NotificationDetailCell.h"
#import "Header.h"

@implementation NotificationDetailCell
@synthesize headerImageView,nameLabel,contactButton;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        headerImageView.backgroundColor = [UIColor clearColor];
        headerImageView.layer.cornerRadius = 5;
        headerImageView.clipsToBounds = YES;
        [self.contentView addSubview:headerImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, 150, 30)];
        nameLabel.backgroundColor = [UIColor greenColor];
        [self.contentView addSubview:nameLabel];
        
        contactButton = [UIButton buttonWithType:UIButtonTypeCustom];
        contactButton.frame = CGRectMake(SCREEN_WIDTH-60, 15, 80, 30);
        [contactButton setTitle:@"" forState:UIControlStateNormal];
        [contactButton setHidden:NO];
        contactButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:contactButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

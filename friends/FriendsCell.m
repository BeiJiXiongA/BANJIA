//
//  FriendsCell.m
//  School
//
//  Created by TeekerZW on 14-1-21.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "FriendsCell.h"

@implementation FriendsCell
@synthesize headerImageView,nameLabel,locationLabel,inviteButton;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        headerImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:headerImageView];
        
        nameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:nameLabel];
        
        locationLabel = [[UILabel alloc] init];
        locationLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:locationLabel];
        
        inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:inviteButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

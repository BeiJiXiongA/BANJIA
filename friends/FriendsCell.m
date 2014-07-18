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
        headerImageView.backgroundColor = [UIColor clearColor];
        headerImageView.layer.contentsGravity = kCAGravityResizeAspectFill;
        [self.contentView addSubview:headerImageView];
        
        nameLabel = [[UILabel alloc] init];
        nameLabel.textColor = COMMENTCOLOR;
        nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:nameLabel];
        
        locationLabel = [[UILabel alloc] init];
        locationLabel.backgroundColor = [UIColor clearColor];
        locationLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:locationLabel];
        
        inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:inviteButton];
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

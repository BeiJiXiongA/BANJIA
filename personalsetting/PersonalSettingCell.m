//
//  PersonalSettingCell.m
//  School
//
//  Created by TeekerZW on 14-2-15.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "PersonalSettingCell.h"
#import "Header.h"

@implementation PersonalSettingCell
@synthesize headerImageView,nameLabel,objectsLabel,authenticationSign,topImageView,arrowImageView,bgView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        bgView = [[UIView alloc] init];
        [self.contentView addSubview:bgView];
        
        topImageView = [[UIImageView alloc] initWithFrame:self.frame];
        topImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:topImageView];
        
        
        headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 50, 50)];
        headerImageView.backgroundColor = [UIColor clearColor];
        [headerImageView setImage:[UIImage imageNamed:HEADERBG]];
        headerImageView.layer.contentsGravity = kCAGravityResizeAspectFill;
        [self.contentView addSubview:headerImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 60, 30)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.textColor = TITLE_COLOR;
        [self.contentView addSubview:nameLabel];
        
        objectsLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 40, 100, 15)];
        objectsLabel.backgroundColor = [UIColor clearColor];
        objectsLabel.font = [UIFont systemFontOfSize:12];
        objectsLabel.textColor = TITLE_COLOR;
        [self.contentView addSubview:objectsLabel];
        
        authenticationSign = [[UIImageView alloc] init];
        authenticationSign.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:authenticationSign];
        
        arrowImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:arrowImageView];
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

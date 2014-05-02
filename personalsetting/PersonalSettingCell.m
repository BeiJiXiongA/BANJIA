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
@synthesize headerImageView,nameLabel,objectsLabel,authenticationSign;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 50, 50)];
        headerImageView.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:headerImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 60, 30)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:nameLabel];
        
        objectsLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 40, 100, 15)];
        objectsLabel.backgroundColor = [UIColor clearColor];
        objectsLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:objectsLabel];
        
        authenticationSign = [[UIImageView alloc] init];
        authenticationSign.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:authenticationSign];
        
//        UIImageView *arrowsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 10, 30, 60)];
//        arrowsImageView.backgroundColor = [UIColor yellowColor];
//        [self.contentView addSubview:arrowsImageView];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

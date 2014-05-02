//
//  HeaderCell.m
//  School
//
//  Created by TeekerZW on 14-2-21.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "HeaderCell.h"
#import "Header.h"

@implementation HeaderCell
@synthesize topImageView,schoolNameLabel,classNameLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,  SCREEN_WIDTH, 150)];
        topImageView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:topImageView];
        
        schoolNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 150, 90, 140, 20)];
        schoolNameLabel.backgroundColor = [UIColor clearColor];
        schoolNameLabel.font = [UIFont systemFontOfSize:14];
        schoolNameLabel.textColor = [UIColor whiteColor];
        schoolNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:schoolNameLabel];
        
        classNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 150, 120, 140, 20)];
        classNameLabel.backgroundColor = [UIColor clearColor];
        classNameLabel.font = [UIFont systemFontOfSize:14];
        classNameLabel.textColor = [UIColor whiteColor];
        classNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:classNameLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

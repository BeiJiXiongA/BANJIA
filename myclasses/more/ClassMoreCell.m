//
//  ClassMoreCell.m
//  School
//
//  Created by TeekerZW on 14-2-13.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "ClassMoreCell.h"
#import "Header.h"

@implementation ClassMoreCell

@synthesize nameLabel,contentLabel,switchView,button,lineImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        nameLabel = [[UILabel alloc] init];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:nameLabel];
        
        contentLabel = [[UILabel alloc] init];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textColor = [UIColor blueColor];
        contentLabel.textAlignment = NSTextAlignmentRight;
        contentLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:contentLabel];
        
        switchView = [[KLSwitch alloc] initWithFrame:CGRectMake( SCREEN_WIDTH-60, 7, 50, 30)];
        [switchView setOnTintColor:LIGHT_BLUE_COLOR];
        [self.contentView addSubview:switchView];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:button];
        
        lineImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:lineImageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

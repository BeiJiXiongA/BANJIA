//
//  ClassCell.m
//  School
//
//  Created by TeekerZW on 1/15/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "ClassCell.h"
#import "Header.h"

@implementation ClassCell
@synthesize headerImageView,
nameLabel,
contentLable,
timeLabel,
timeLabel2,
unReadImageView,
bgView,
arrowImageView,
lineImageView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        bgView = [[UIView alloc] init];
        [self.contentView addSubview:bgView];
        
        headerImageView = [[UIImageView alloc] init];
        headerImageView.layer.contentsGravity = kCAGravityResizeAspectFill;
        headerImageView.clipsToBounds = YES;
        [bgView addSubview:headerImageView];
        
        nameLabel = [[UILabel alloc] init];
        nameLabel.textColor = TITLE_COLOR;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:18];
        [bgView addSubview:nameLabel];
        
        contentLable = [[UILabel alloc] init];
        contentLable.textColor = UIColorFromRGB(0x666464);
        contentLable.backgroundColor = [UIColor clearColor];
        contentLable.font = [UIFont systemFontOfSize:13];
        [bgView addSubview:contentLable];
        
        timeLabel = [[cnvUILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [bgView addSubview:timeLabel];
        
        timeLabel2 = [[cnvUILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [bgView addSubview:timeLabel2];
        
        arrowImageView = [[UIImageView alloc] init];
        [bgView addSubview:arrowImageView];
        
        lineImageView = [[UIImageView alloc] init];
        [bgView addSubview:lineImageView];
        
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

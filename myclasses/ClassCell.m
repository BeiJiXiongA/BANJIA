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
@synthesize headerImageView,nameLabel,contentLable,timeLabel,unReadImageView,bgView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        bgView = [[UIView alloc] init];
        [self.contentView addSubview:bgView];
        
        headerImageView = [[UIImageView alloc] init];
        [bgView addSubview:headerImageView];
        
        nameLabel = [[UILabel alloc] init];
        nameLabel.textColor = UIColorFromRGB(0x666464);
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:18];
        [bgView addSubview:nameLabel];
        
        contentLable = [[UILabel alloc] init];
        contentLable.textColor = UIColorFromRGB(0x666464);
        contentLable.backgroundColor = [UIColor clearColor];
        contentLable.font = [UIFont systemFontOfSize:13];
        [bgView addSubview:contentLable];
        
        timeLabel = [[UILabel alloc] init];
        [bgView addSubview:timeLabel];
        
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

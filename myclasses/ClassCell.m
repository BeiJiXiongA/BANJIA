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
@synthesize headerImageView,nameLabel,contentLable,timeLabel,unReadImageView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
                
        headerImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:headerImageView];
        
        nameLabel = [[UILabel alloc] init];
        nameLabel.textColor = UIColorFromRGB(0x666464);
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:20.5];
        [self.contentView addSubview:nameLabel];
        
        contentLable = [[UILabel alloc] init];
        contentLable.textColor = UIColorFromRGB(0x666464);
        contentLable.backgroundColor = [UIColor clearColor];
        contentLable.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:contentLable];
        
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

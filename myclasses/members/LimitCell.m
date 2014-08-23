//
//  LimitCell.m
//  School
//
//  Created by TeekerZW on 3/19/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "LimitCell.h"

@implementation LimitCell
@synthesize contentLabel,mySwitch,markLabel,arrowImageView,lineImageView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 150, 30)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:contentLabel];
        
        mySwitch = [[KLSwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-80, 10, 50, 30)];
        [mySwitch setOnTintColor:LIGHT_BLUE_COLOR];
        [self.contentView addSubview:mySwitch];
        
        markLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 150, 15, 120, 30)];
        markLabel.textAlignment = NSTextAlignmentRight;
        markLabel.font = [UIFont systemFontOfSize:14];
        markLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:markLabel];
        
        arrowImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:arrowImageView];
        
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

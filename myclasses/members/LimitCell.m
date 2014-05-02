//
//  LimitCell.m
//  School
//
//  Created by TeekerZW on 3/19/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "LimitCell.h"

@implementation LimitCell
@synthesize contentLabel,mySwitch,markLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 150, 30)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:contentLabel];
        
        mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-100, 10, 80, 30)];
        [self.contentView addSubview:mySwitch];
        
        markLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 150, 15, 120, 30)];
        markLabel.textAlignment = NSTextAlignmentRight;
        markLabel.font = [UIFont systemFontOfSize:14];
        markLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:markLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

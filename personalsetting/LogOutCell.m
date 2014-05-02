//
//  LogOutCell.m
//  School
//
//  Created by TeekerZW on 14-2-28.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "LogOutCell.h"
#import "Header.h"

@implementation LogOutCell
@synthesize setLabel,markLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        setLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 7, 100, 30)];
        setLabel.font = [UIFont systemFontOfSize:14];
        setLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:setLabel];
        
        markLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 150, 7, 120, 30)];
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

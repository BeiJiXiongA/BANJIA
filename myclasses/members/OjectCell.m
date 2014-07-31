//
//  OjectCell.m
//  School
//
//  Created by TeekerZW on 3/18/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "OjectCell.h"

@implementation OjectCell
@synthesize nameLabel,selectButton;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, SCREEN_WIDTH-62, 38)];
        bgImageView.backgroundColor = RGB(74, 187, 192, 1);
        bgImageView.hidden = YES;
        [self.contentView addSubview:bgImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 6, 180, 28)];
        nameLabel.font = [UIFont boldSystemFontOfSize:17];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:nameLabel];
        
        selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectButton.frame = CGRectMake(SCREEN_WIDTH-32-70, 9, 21.5, 21.5);
        selectButton.backgroundColor = [UIColor grayColor];
        selectButton.layer.cornerRadius = 10.5;
        selectButton.clipsToBounds = YES;
        [self.contentView addSubview:selectButton];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

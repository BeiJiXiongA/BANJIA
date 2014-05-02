//
//  FooterCell.m
//
//
//  Created by mac120 on 13-12-10.
//  Copyright (c) 2013年 mac120. All rights reserved.
//

#import "FooterCell.h"

@implementation FooterCell
@synthesize footerLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        footerLabel = [[UILabel alloc] init];
        footerLabel.backgroundColor = [UIColor clearColor];
        footerLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:footerLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

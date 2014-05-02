//
//  AuthCell.m
//  School
//
//  Created by TeekerZW on 14-2-17.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "AuthCell.h"
#import "Header.h"

@implementation AuthCell
@synthesize desLabel,authButton;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        desLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 200, 20)];
        desLabel.backgroundColor = [UIColor clearColor];
        desLabel.font = [UIFont systemFontOfSize:12];
        desLabel.text = @"您尚未进行教师认证";
        [self.contentView addSubview:desLabel];
        
        authButton = [UIButton buttonWithType:UIButtonTypeCustom];
        authButton.frame = CGRectMake(SCREEN_WIDTH - 80, 3, 60, 24);
        [authButton setTitle:@"认证" forState:UIControlStateNormal];
        authButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [authButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.contentView addSubview:authButton];
        
        self.contentView.backgroundColor = [UIColor colorWithRed:248.00/255.00 green:196.00/255.00 blue:145.00/255.00 alpha:1.0f];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

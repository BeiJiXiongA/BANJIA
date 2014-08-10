//
//  NotificationDetailCell.m
//  School
//
//  Created by TeekerZW on 14-2-19.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "NotificationDetailCell.h"
#import "Header.h"

@implementation NotificationDetailCell
@synthesize headerImageView,nameLabel,contactButton,button2,textField,numLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        headerImageView.backgroundColor = [UIColor clearColor];
        headerImageView.layer.cornerRadius = 5;
        headerImageView.clipsToBounds = YES;
        [self.contentView addSubview:headerImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, 150, 30)];
        nameLabel.backgroundColor = [UIColor greenColor];
        [self.contentView addSubview:nameLabel];
        
        contactButton = [UIButton buttonWithType:UIButtonTypeCustom];
        contactButton.frame = CGRectMake(SCREEN_WIDTH-60, 15, 80, 30);
        [contactButton setTitle:@"" forState:UIControlStateNormal];
        [contactButton setHidden:NO];
        contactButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:contactButton];
        
        numLabel = [[UILabel alloc] init];
        numLabel.hidden = YES;
        [self.contentView addSubview:numLabel];
        
        button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        button2.hidden = YES;
        button2.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:button2];
        
        textField = [[MyTextField alloc] init];
        textField.background = nil;
        textField.layer.cornerRadius = 5;
        textField.clipsToBounds = YES;
        textField.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:textField];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

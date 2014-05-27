//
//  InfoCell.m
//  School
//
//  Created by TeekerZW on 3/19/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "InfoCell.h"

@implementation InfoCell
@synthesize nameLabel,contentLabel,button1,button2,headerImageView,nameBgView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        nameBgView = [[UIView alloc] init];
        [self.contentView addSubview:nameBgView];
        
        headerImageView = [[UIImageView alloc] init];
        headerImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:headerImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, 100, 20)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:nameLabel];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 150, 20)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:contentLabel];
        
        button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        button1.frame = CGRectMake(SCREEN_WIDTH - 120, 25, 30, 30);
        [button1 setImage:[UIImage imageNamed:@"icon_infor"] forState:UIControlStateNormal];
        button1.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:button1];
        
        button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        button2.frame = CGRectMake(SCREEN_WIDTH-70, 25, 30, 30);
        button2.backgroundColor = [UIColor clearColor];
        [button2 setImage:[UIImage imageNamed:@"icon_tel"] forState:UIControlStateNormal];
        [self.contentView addSubview:button2];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

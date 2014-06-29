//
//  RelatedCell.m
//  School
//
//  Created by TeekerZW on 14-2-17.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "RelatedCell.h"
#import "Header.h"

@implementation RelatedCell
@synthesize iconImageView,nametf,relateButton,bgImageView,contentLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 11, SCREEN_WIDTH-10, 35)];
        self.backgroundView = bgImageView;
        
        iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        iconImageView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:iconImageView];
        
        nametf = [[MyTextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-120, 5, 100, 20)];
        nametf.font = [UIFont systemFontOfSize:16];
        nametf.textAlignment = NSTextAlignmentRight;
        nametf.hidden = NO;
        nametf.background = nil;
        nametf.textColor = CONTENTCOLOR;
//        nametf.enabled = NO;
        [self.contentView addSubview:nametf];
        
        relateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        relateButton.frame = CGRectMake(SCREEN_WIDTH-100, 8.5, 80, 26);
        [relateButton setTitle:@"关联" forState:UIControlStateNormal];
        [relateButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
        [self.contentView addSubview:relateButton];
        
        contentLabel = [[UILabel alloc] init];
        contentLabel.textColor = CONTENTCOLOR;
        contentLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:contentLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

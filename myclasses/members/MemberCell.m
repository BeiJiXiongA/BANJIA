//
//  MemberCell.m
//  School
//
//  Created by TeekerZW on 14-2-20.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "MemberCell.h"
#import "Header.h"

@implementation MemberCell
@synthesize headerImageView,memNameLabel,button1,button2,remarkLabel,unreadedMsgLabel,contentLabel,markView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        unreadedMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 2, 20, 20)];
        unreadedMsgLabel.layer.cornerRadius = 10;
        unreadedMsgLabel.clipsToBounds = YES;
        unreadedMsgLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        unreadedMsgLabel.layer.borderWidth = 1;
        unreadedMsgLabel.font = [UIFont systemFontOfSize:11];
        unreadedMsgLabel.textAlignment = NSTextAlignmentCenter;
        unreadedMsgLabel.textColor = [UIColor whiteColor];
        unreadedMsgLabel.backgroundColor = [UIColor whiteColor];
        unreadedMsgLabel.hidden = YES;
        [self.contentView addSubview:unreadedMsgLabel];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 30, 150, 30)];
        contentLabel.textColor = [UIColor grayColor];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.hidden = YES;
        contentLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:contentLabel];
        
        memNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 150, 30)];
        memNameLabel.backgroundColor = [UIColor clearColor];
        memNameLabel.font = [UIFont systemFontOfSize:17];
        memNameLabel.textColor = CONTENTCOLOR;
        [self.contentView addSubview:memNameLabel];
        
        headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        headerImageView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:headerImageView];
        
        markView = [[UIImageView alloc] init];
        markView.hidden = YES;
        [self.contentView addSubview:markView];
        
        remarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 140, 15, 100, 30)];
        remarkLabel.backgroundColor = [UIColor clearColor];
        remarkLabel.font =[UIFont systemFontOfSize:14];
        remarkLabel.textColor = CONTENTCOLOR;
        remarkLabel.textAlignment = NSTextAlignmentRight;
        remarkLabel.hidden = YES;
        [self.contentView addSubview:remarkLabel];
        
        button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        button1.frame = CGRectMake(SCREEN_WIDTH-110, 15, 50, 30);
        [button1 setHidden:YES];
        [button1 setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
        button1.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:button1];
        
        button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        button2.frame = CGRectMake(SCREEN_WIDTH-70, 15, 50, 30);
        [button2 setHidden:YES];
        [button2 setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
        button2.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:button2];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

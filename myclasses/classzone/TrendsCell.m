//
//  TrendsCell.m
//  School
//
//  Created by TeekerZW on 14-2-22.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "TrendsCell.h"
#import "Header.h"

@implementation TrendsCell
@synthesize headerImageView,nameLabel,timeLabel,locationLabel,contentLabel,imagesScrollView,imagesView,transmitButton,praiseButton,commentButton,praiseImageView,commentImageView,bgView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
        bgView.layer.borderWidth = 0.5;
        [self.contentView addSubview:bgView];
        
        headerImageView = [[UIImageView alloc] init];
        headerImageView.frame = CGRectMake(5, 5, 50, 50);
        headerImageView.backgroundColor = [UIColor clearColor];
        [bgView addSubview:headerImageView];
        
        nameLabel = [[UILabel alloc] init];
        nameLabel.frame = CGRectMake(60, 5, 100, 30);
        nameLabel.font = [UIFont systemFontOfSize:18];
        nameLabel.backgroundColor = [UIColor clearColor];
        [bgView addSubview:nameLabel];
        
        timeLabel = [[UILabel alloc] init];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor lightGrayColor];
        timeLabel.font = [UIFont systemFontOfSize:12];
        [bgView addSubview:timeLabel];
        
        locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 35, SCREEN_WIDTH-170, 20)];
        locationLabel.backgroundColor = [UIColor clearColor];
        locationLabel.textColor = [UIColor lightGrayColor];
        locationLabel.font = [UIFont systemFontOfSize:12];
        [bgView addSubview:locationLabel];
        
        contentLabel = [[UILabel alloc] init];
        contentLabel.frame = CGRectMake(10, 60, SCREEN_WIDTH-20, 35);
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.numberOfLines = 2;
        contentLabel.lineBreakMode = NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail;
        contentLabel.font = [UIFont systemFontOfSize:14];
        [bgView addSubview:contentLabel];
        
        imagesScrollView = [[UIScrollView alloc] init];
        imagesScrollView.frame = CGRectMake(5, contentLabel.frame.size.height+contentLabel.frame.origin.y, SCREEN_WIDTH-10, 120);
        imagesScrollView.backgroundColor = [UIColor clearColor];
        [bgView addSubview:imagesScrollView];
        
        imagesView = [[UIView alloc] init];
        imagesView.frame = CGRectMake(5, contentLabel.frame.size.height+contentLabel.frame.origin.y, SCREEN_WIDTH-10, 120);
        imagesView.backgroundColor = [UIColor clearColor];
        imagesView.hidden = YES;
        [bgView addSubview:imagesView];
        
        transmitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        transmitButton.frame = CGRectMake(5, imagesScrollView.frame.size.height+imagesScrollView.frame.origin.y, 40, 30);
        transmitButton.backgroundColor = [UIColor clearColor];
        [transmitButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        transmitButton.titleLabel.font = [UIFont systemFontOfSize:12];
        transmitButton.hidden = YES;
        [bgView addSubview:transmitButton];
        
        praiseImageView = [[UIImageView alloc] init];
        [praiseImageView setImage:[UIImage imageNamed:@"icon_heart"]];
        [self.contentView addSubview:praiseImageView];
        
        praiseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        praiseButton.frame = CGRectMake(10, imagesScrollView.frame.size.height+imagesScrollView.frame.origin.y, (SCREEN_WIDTH-20)/2, 30);
        praiseButton.backgroundColor = [UIColor clearColor];
        praiseButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [praiseButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [bgView addSubview:praiseButton];
        
        commentImageView = [[UIImageView alloc] init];
        [commentImageView setImage:[UIImage imageNamed:@"icon_comment"]];
        [bgView addSubview:commentImageView];
        
        commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        commentButton.frame = CGRectMake((SCREEN_WIDTH - 20)/2, imagesScrollView.frame.size.height+imagesScrollView.frame.origin.y, (SCREEN_WIDTH-20)/2, 30);
        commentButton.backgroundColor = [UIColor clearColor];
        commentButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [commentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [bgView addSubview:commentButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

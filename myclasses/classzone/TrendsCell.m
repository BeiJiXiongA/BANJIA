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
@synthesize headerImageView,nameLabel,timeLabel,locationLabel,contentLabel,imagesScrollView,imagesView,transmitButton,praiseButton,commentButton,praiseImageView,commentImageView,bgView,nameTextField,transmitImageView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        nameTextField = [[MyTextField alloc] init];
        nameTextField.hidden = YES;
        [self.contentView addSubview:nameTextField];
        
        bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
        bgView.layer.borderWidth = 0.5;
        [self.contentView addSubview:bgView];
        
        headerImageView = [[UIImageView alloc] init];
        headerImageView.frame = CGRectMake(5, 5, 50, 50);
        headerImageView.hidden = YES;
        [bgView addSubview:headerImageView];
        
        nameLabel = [[UILabel alloc] init];
        nameLabel.frame = CGRectMake(60, 5, 100, 30);
        nameLabel.font = [UIFont systemFontOfSize:18];
        nameLabel.hidden = YES;
        [bgView addSubview:nameLabel];
        
        timeLabel = [[UILabel alloc] init];
        timeLabel.textColor = [UIColor lightGrayColor];
        timeLabel.font = [UIFont systemFontOfSize:12];
        timeLabel.hidden = YES;
        [bgView addSubview:timeLabel];
        
        locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 35, SCREEN_WIDTH-170, 20)];
        locationLabel.textColor = [UIColor lightGrayColor];
        locationLabel.hidden = YES;
        locationLabel.font = [UIFont systemFontOfSize:12];
        [bgView addSubview:locationLabel];
        
        contentLabel = [[UITextView alloc] init];
        contentLabel.frame = CGRectMake(10, 60, SCREEN_WIDTH-20, 35);
        contentLabel.scrollEnabled = NO;
        contentLabel.showsVerticalScrollIndicator = NO;
        contentLabel.editable = NO;
        contentLabel.hidden = YES;
        contentLabel.font = [UIFont systemFontOfSize:15];
        [bgView addSubview:contentLabel];
        
        imagesScrollView = [[UIScrollView alloc] init];
        imagesScrollView.frame = CGRectMake(5, contentLabel.frame.size.height+contentLabel.frame.origin.y, SCREEN_WIDTH-10, 120);
//        [bgView addSubview:imagesScrollView];
        
        imagesView = [[UIView alloc] init];
        imagesView.frame = CGRectMake(5, contentLabel.frame.size.height+contentLabel.frame.origin.y, SCREEN_WIDTH-10, 120);
        [bgView addSubview:imagesView];
        
//        CGFloat imageViewHeight = 60.0f;
//        CGFloat imageViewWidth = 60.0f;
//        NSInteger ImageCountPerRow = 4;
//        
//        for (int i=0; i < 12; ++i)
//        {
//            UIImageView *imageView = [[UIImageView alloc] init];
//            imageView.frame = CGRectMake((i%(NSInteger)ImageCountPerRow)*(imageViewWidth+5), (imageViewWidth+5)*(i/(NSInteger)ImageCountPerRow), imageViewWidth, imageViewHeight);
//            imageView.userInteractionEnabled = YES;
//            imageView.tag = 33333+i;
//            imageView.userInteractionEnabled = YES;
//            
//            // 内容模式
//            imageView.clipsToBounds = YES;
//            imageView.contentMode = UIViewContentModeScaleAspectFill;
//            imageView.hidden = YES;
//            [imagesView addSubview:imageView];
//        }
        
        transmitImageView = [[UIImageView alloc] init];
        transmitImageView.hidden = YES;
        [transmitImageView setImage:[UIImage imageNamed:@"icon_forwarding"]];
        [bgView addSubview:transmitImageView];
        
        transmitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [transmitButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        transmitButton.titleLabel.font = [UIFont systemFontOfSize:14];
        transmitButton.hidden = YES;
        [transmitButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        transmitButton.layer.borderColor = RGB(234, 234, 234, 1).CGColor;
        transmitButton.layer.borderWidth = 0.5;
        [bgView addSubview:transmitButton];
        
        praiseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        praiseButton.frame = CGRectMake(10, imagesScrollView.frame.size.height+imagesScrollView.frame.origin.y, (SCREEN_WIDTH-20)/2, 30);
        praiseButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [praiseButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        praiseButton.layer.borderColor = RGB(234, 234, 234, 1).CGColor;
        praiseButton.layer.borderWidth = 0.5;
        praiseButton.hidden = YES;
        [bgView addSubview:praiseButton];
        
        praiseImageView = [[UIImageView alloc] init];
        praiseImageView.hidden = YES;
        [praiseImageView setImage:[UIImage imageNamed:@"icon_heart"]];
        [self.contentView addSubview:praiseImageView];
        
        commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        commentButton.frame = CGRectMake((SCREEN_WIDTH - 20)/2, imagesScrollView.frame.size.height+imagesScrollView.frame.origin.y, (SCREEN_WIDTH-20)/2, 30);
        commentButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [commentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        commentButton.layer.borderColor = RGB(234, 234, 234, 1).CGColor;
        commentButton.layer.borderWidth = 0.5;
        commentButton.hidden = YES;
        [bgView addSubview:commentButton];
        
        commentImageView = [[UIImageView alloc] init];
        commentImageView.hidden = YES;
        [commentImageView setImage:[UIImage imageNamed:@"icon_comment"]];
        [bgView addSubview:commentImageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

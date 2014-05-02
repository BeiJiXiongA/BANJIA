//
//  TrendsCell.h
//  School
//
//  Created by TeekerZW on 14-2-22.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrendsCell : UITableViewCell
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UITextView *contentLabel;
@property (nonatomic, strong) UIScrollView *imagesScrollView;
@property (nonatomic, strong) UIView *imagesView;
@property (nonatomic, strong) UIButton *transmitButton;
@property (nonatomic, strong) UIButton *praiseButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIImageView *praiseImageView;
@property (nonatomic, strong) UIImageView *commentImageView;
@end

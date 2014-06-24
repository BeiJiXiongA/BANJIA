//
//  TrendsCell.h
//  School
//
//  Created by TeekerZW on 14-2-22.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyButton.h"

@interface TrendsCell : UITableViewCell<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UITextView *contentLabel;
@property (nonatomic, strong) UIScrollView *imagesScrollView;
@property (nonatomic, strong) UIView *imagesView;
@property (nonatomic, strong) MyButton *transmitButton;
@property (nonatomic, strong) MyButton *praiseButton;
@property (nonatomic, strong) MyButton *commentButton;
@property (nonatomic, strong) MyTextField *nameTextField;
@property (nonatomic, strong) UITableView *commentsTableView;
@property (nonatomic, strong) NSArray *commentsArray;
@property (nonatomic, strong) NSArray *praiseArray;
@end

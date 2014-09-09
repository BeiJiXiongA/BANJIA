//
//  CommentCell.h
//  BANJIA
//
//  Created by TeekerZW on 6/17/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell
@property (nonatomic, strong) UIButton *nameButton;
@property (nonatomic, strong) UILabel *nameLable;
@property (nonatomic, strong) UILabel *commentContentLabel;
@property (nonatomic, strong) NSDictionary *commentDict;
@property (nonatomic, strong) UIView *praiseView;
@property (nonatomic, strong) UIButton *openPraiseButton;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *lineImageView;
@end

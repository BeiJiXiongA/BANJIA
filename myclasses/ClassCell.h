//
//  ClassCell.h
//  School
//
//  Created by TeekerZW on 1/15/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassCell : UITableViewCell
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLable;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *unReadImageView;
@end

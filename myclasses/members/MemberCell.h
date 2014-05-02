//
//  MemberCell.h
//  School
//
//  Created by TeekerZW on 14-2-20.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberCell : UITableViewCell
@property (nonatomic, strong) UIImageView *markView;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *unreadedMsgLabel;
@property (nonatomic, strong) UILabel *memNameLabel;
@property (nonatomic, strong) UILabel *remarkLabel;
@property (nonatomic, strong) UIButton *button1;
@property (nonatomic, strong) UIButton *button2;
@property (nonatomic, strong) UILabel *contentLabel;
@end

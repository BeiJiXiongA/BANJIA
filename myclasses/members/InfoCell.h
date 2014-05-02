//
//  InfoCell.h
//  School
//
//  Created by TeekerZW on 3/19/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Header.h"

@interface InfoCell : UITableViewCell
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *button1;
@property (nonatomic, strong) UIButton *button2;

@property (nonatomic, strong) UIView *nameBgView;
@end

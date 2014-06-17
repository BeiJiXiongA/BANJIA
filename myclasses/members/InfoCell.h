//
//  InfoCell.h
//  School
//
//  Created by TeekerZW on 3/19/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Header.h"
#import "MyButton.h"

@interface InfoCell : UITableViewCell
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) MyButton *button1;
@property (nonatomic, strong) MyButton *button2;

@property (nonatomic, strong) UIView *nameBgView;
@end

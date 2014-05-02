//
//  LimitCell.h
//  School
//
//  Created by TeekerZW on 3/19/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Header.h"
#import "KLSwitch.h"

@interface LimitCell : UITableViewCell
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) KLSwitch *mySwitch;
@property (nonatomic, strong) UILabel *markLabel;
@end

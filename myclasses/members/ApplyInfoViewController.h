//
//  ApplyInfoViewController.h
//  School
//
//  Created by TeekerZW on 14-2-22.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@protocol ApplyInfoDelegate;

@interface ApplyInfoViewController : XDContentViewController
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSString *j_id;
@property (nonatomic, strong) NSString *applyName;
@property (nonatomic, strong) NSString *title;
@end

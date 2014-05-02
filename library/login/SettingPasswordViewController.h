//
//  SettingPasswordViewController.h
//  School
//
//  Created by TeekerZW on 3/17/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@interface SettingPasswordViewController : XDContentViewController
@property (nonatomic, strong) NSString *phoneNum;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, assign) BOOL forgetPwd;
@end

//
//  SettingStateLimitViewController.h
//  School
//
//  Created by TeekerZW on 3/19/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@protocol UpdateUserSettingDelegate <NSObject>

-(void)updateUserSeting;

@end

@interface SettingStateLimitViewController : XDContentViewController
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *userid;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSMutableDictionary *userOptDict;

@property (nonatomic, assign) id<UpdateUserSettingDelegate> updateUserSettingDel;
@end

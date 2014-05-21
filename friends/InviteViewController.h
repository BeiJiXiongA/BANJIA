//
//  InviteViewController.h
//  School
//
//  Created by TeekerZW on 14-1-20.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@interface InviteViewController : XDContentViewController
@property (nonatomic, retain) NSMutableDictionary *userInfoDic;
@property (nonatomic, retain) NSMutableArray *tempArr;
@property (nonatomic, retain) NSMutableArray *friendsArr;
@property (nonatomic, retain) NSMutableArray *followersArr;
@property (nonatomic, retain) NSMutableArray *bilateralFriendsArr;
@property (nonatomic, assign) BOOL fromClass;
@end

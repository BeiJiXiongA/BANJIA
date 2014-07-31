//
//  GroupInfoViewController.h
//  BANJIA
//
//  Created by TeekerZW on 7/23/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "XDContentViewController.h"
@protocol updateGroupInfoDelegate;

@interface GroupInfoViewController : XDContentViewController
@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, strong) NSMutableArray *groupUsers;
@property (nonatomic, strong) NSString *builderID;
@property (nonatomic, strong) NSString *g_a_f;
@property (nonatomic, strong) NSString *g_r_a;
@property (nonatomic, assign) id<updateGroupInfoDelegate> updateGroupInfoDel;
@end

@protocol updateGroupInfoDelegate <NSObject>

-(void)updateGroupInfo:(BOOL)update;

@end

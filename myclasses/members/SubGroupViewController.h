//
//  SubGroupViewController.h
//  School
//
//  Created by TeekerZW on 14-3-5.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"
@protocol SubGroupDelegate;
@protocol OperateFriends;

@interface SubGroupViewController : XDContentViewController
@property (nonatomic, strong) NSMutableArray *tmpArray;
@property (nonatomic, strong) NSString *classID;
@property (nonatomic, assign) BOOL admin;
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, assign) id<SubGroupDelegate> subGroupDel;

@property (nonatomic, assign) id<OperateFriends> operateFriDel;
@end

@protocol SubGroupDelegate <NSObject>

-(void)subGroupUpdate:(BOOL)update;

@end

@protocol OperateFriends <NSObject>

-(void)updataFriends:(BOOL)uperate;

@end
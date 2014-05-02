//
//  MemberDetailViewController.h
//  School
//
//  Created by TeekerZW on 14-2-24.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@protocol MemberDetailDelegate <NSObject>

-(void)updateListWith:(BOOL)update;

@end

@interface MemberDetailViewController : XDContentViewController
@property (nonatomic, strong) NSString *classID;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSString *j_id;
@property (nonatomic, strong) NSString *applyName;
@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *teacherName;
@property (nonatomic, strong) NSString *teacherID;

@property (nonatomic, assign) BOOL admin;
@property (nonatomic, strong) NSString *headerImg;
@property (nonatomic, strong) id<MemberDetailDelegate> memDel;
@end

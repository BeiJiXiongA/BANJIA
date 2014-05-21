//
//  ParentsDetailViewController.h
//  School
//
//  Created by TeekerZW on 14-3-1.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@protocol PareberDetailDelegate <NSObject>

-(void)updateListWith:(BOOL)update;

@end

@interface ParentsDetailViewController : XDContentViewController
@property (nonatomic, strong) NSString *parentName;
@property (nonatomic, strong) NSString *parentID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL admin;
@property (nonatomic, strong) NSString *headerImg;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) id<PareberDetailDelegate> memDel;
@end

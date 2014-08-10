//
//  AlreadyInStudentsListViewController.h
//  BANJIA
//
//  Created by TeekerZW on 8/6/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "XDContentViewController.h"

@protocol StuListDelegate <NSObject>

-(void)selectUninstu:(NSString *)uninstuId;

@end

@interface AlreadyInStudentsListViewController : XDContentViewController
@property (nonatomic, strong) NSMutableArray *studentsArray;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, assign) id<StuListDelegate> stulistdel;
@property (nonatomic, strong) NSDictionary *applyDict;
@end



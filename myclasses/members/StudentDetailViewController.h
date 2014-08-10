//
//  StudentDetailViewController.h
//  School
//
//  Created by TeekerZW on 14-2-20.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"
#import "ReportViewController.h"

@protocol StuDetailDelegate <NSObject>

-(void)updateListWith:(BOOL)update;

@end

@interface StudentDetailViewController : XDContentViewController
@property (nonatomic, strong) NSString *studentName;
@property (nonatomic, strong) NSString *studentID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL admin;
@property (nonatomic, strong) NSString *headerImg;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) id<StuDetailDelegate> memDel;
@property (nonatomic, strong) NSMutableArray *pArray;
@property (nonatomic, strong) NSString *studentNum;
@end
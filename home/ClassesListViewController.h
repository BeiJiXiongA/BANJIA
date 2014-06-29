//
//  ClassesListViewController.h
//  BANJIA
//
//  Created by TeekerZW on 14-6-26.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "XDContentViewController.h"


@protocol SelectClasses;

@interface ClassesListViewController : XDContentViewController
@property (nonatomic, assign) id<SelectClasses> selectClassdel;
@end

@protocol SelectClasses <NSObject>

-(void)selectClasses:(NSArray *)selectClassesArray;

@end
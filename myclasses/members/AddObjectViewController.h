//
//  AddObjectViewController.h
//  BANJIA
//
//  Created by TeekerZW on 14-6-29.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "XDContentViewController.h"

@protocol AddObjectDel;

@interface AddObjectViewController : XDContentViewController
@property (nonatomic, assign) id<AddObjectDel> addobjectDel;
@property (nonatomic, assign) BOOL fromTeacher;

@end

@protocol AddObjectDel <NSObject>

-(void)addObject:(NSString *)objectName;

@end
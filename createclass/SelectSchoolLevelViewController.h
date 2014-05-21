//
//  SelectSchoolLevelViewController.h
//  BANJIA
//
//  Created by TeekerZW on 5/13/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "XDContentViewController.h"

@protocol SelectSchoolLevelDel <NSObject>

-(void)updateSchoolLevelWith:(NSString *)schoolLevelName andId:(NSString *)schoolId;

@end

@interface SelectSchoolLevelViewController : XDContentViewController
@property (nonatomic, assign) id<SelectSchoolLevelDel> selectSchoolLevelDel;
@property (nonatomic, assign) BOOL fromCreate;
@end

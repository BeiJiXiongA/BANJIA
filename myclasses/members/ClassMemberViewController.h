//
//  ClassMemberViewController.h
//  School
//
//  Created by TeekerZW on 14-1-17.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@interface ClassMemberViewController : XDContentViewController
@property (nonatomic, strong) NSString *classID;
@property (nonatomic)BOOL fromMsg;

@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *schoolName;
@end

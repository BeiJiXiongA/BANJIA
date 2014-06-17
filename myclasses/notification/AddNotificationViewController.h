//
//  AddNotificationViewController.h
//  School
//
//  Created by TeekerZW on 14-2-18.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@protocol updateDelegate;

@interface AddNotificationViewController : XDContentViewController
@property (nonatomic, strong) NSString *classID;
@property (nonatomic, assign) id<updateDelegate> updel;
@property (nonatomic, assign) BOOL fromClass;
@end

@protocol updateDelegate <NSObject>

-(void)update:(BOOL)update;

@end

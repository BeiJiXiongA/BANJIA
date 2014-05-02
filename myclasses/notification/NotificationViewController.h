//
//  NotificationViewController.h
//  School
//
//  Created by TeekerZW on 14-1-17.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@protocol ReadNoticeDelegate <NSObject>

-(void)readNotice:(BOOL)read;

@end

@interface NotificationViewController : XDContentViewController
@property (nonatomic, strong) NSString *classID;
@property (nonatomic)BOOL fromMsg;
@property (nonatomic, assign) id<ReadNoticeDelegate> readNoticedel;
@end

//
//  NotificationDetailViewController.h
//  School
//
//  Created by TeekerZW on 14-2-18.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@protocol NotificationDetailDelegate <NSObject>

-(void)readNotificationDetail:(NSDictionary *)noticeDict deleted:(BOOL)deleted;

@end

@interface NotificationDetailViewController : XDContentViewController
@property (nonatomic, strong) NSString *noticeContent;
@property (nonatomic, strong) NSString *noticeID;
@property (nonatomic, strong) NSString *c_read;
@property (nonatomic, strong) NSString *byID;
@property (nonatomic, assign) BOOL isnew;

@property (nonatomic, strong) NSDictionary *noticeDict;
@property (nonatomic, assign) id<NotificationDetailDelegate> readnotificationDetaildel;
@property (nonatomic, assign) BOOL fromClass;
@property (nonatomic, strong) NSString *markString;
@end

//
//  ChatViewController.h
//  School
//
//  Created by TeekerZW on 14-3-4.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@protocol ChatVCDelegate <NSObject>

-(void)updateChatList:(BOOL)update;

@end

@protocol FriendListDelegate <NSObject>

-(void)updateFriendList:(BOOL)updata;

@end

@interface ChatViewController : XDContentViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *toID;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, assign) BOOL fromClass;
@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, strong) id<ChatVCDelegate> chatVcDel;
@property (nonatomic, strong) id<FriendListDelegate> friendVcDel;

@property (nonatomic, strong) NSString *number;

@property (nonatomic, strong) NSString *timeStr;

@property (nonatomic, assign) int unReadedNumber;

@property (nonatomic, assign) int unreadCount;

@end

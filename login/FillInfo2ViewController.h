//
//  FillInfo2ViewController.h
//  BANJIA
//
//  Created by TeekerZW on 14-6-29.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "XDContentViewController.h"

@interface FillInfo2ViewController : XDContentViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) NSString *headerIcon;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *accountID;
@property (nonatomic, strong) NSString *accountType;
@property (nonatomic, strong) NSString *userid;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, assign) BOOL fromRoot;
@end

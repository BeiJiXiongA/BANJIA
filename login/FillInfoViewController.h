//
//  FillInfoViewController.h
//  School
//
//  Created by TeekerZW on 14-1-23.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@interface FillInfoViewController : XDContentViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) NSString *headerIcon;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *accountID;
@property (nonatomic, strong) NSString *accountType;
@property (nonatomic, strong) NSString *userid;
@property (nonatomic, assign) BOOL fromRoot;
@end

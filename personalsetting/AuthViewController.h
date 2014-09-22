//
//  AuthViewController.h
//  School
//
//  Created by TeekerZW on 14-2-17.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@protocol AuthImageDone <NSObject>

-(void)authImageDone;

@end

@interface AuthViewController : XDContentViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImagePickerController *imagePickerController;
}
@property (nonatomic, strong) NSString *img_id;
@property (nonatomic, strong) NSString *img_tcard;
@property (nonatomic, strong) id<AuthImageDone> authImageDoneDel;
@end

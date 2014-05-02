//
//  AuthViewController.h
//  School
//
//  Created by TeekerZW on 14-2-17.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@interface AuthViewController : XDContentViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImagePickerController *imagePickerController;
}
@end

//
//  ClassInfoViewController.h
//  BANJIA
//
//  Created by TeekerZW on 5/12/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "XDContentViewController.h"

@protocol moreDelegate <NSObject>

-(void)signOutClass:(BOOL)signOut;

@end

@interface ClassInfoViewController : XDContentViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) id<moreDelegate> signOutDel;
@property (nonatomic, strong) NSDictionary *classinfoDict;
@end

//
//  EditNameViewController.h
//  BANJIA
//
//  Created by TeekerZW on 14-7-3.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "XDContentViewController.h"

@protocol EditNameDone <NSObject>

-(void)editNameDone:(NSString *)name;

@end

@interface EditNameViewController : XDContentViewController
@property (nonatomic, strong) id<EditNameDone> editnameDoneDel;
@property (nonatomic, strong) NSString *name;
@end

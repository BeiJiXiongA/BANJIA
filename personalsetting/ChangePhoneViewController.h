//
//  ChangePhoneViewController.h
//  School
//
//  Created by TeekerZW on 4/3/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"
@protocol ChangePhoneNum <NSObject>

-(void)changePhoneNum:(BOOL)changed;

@end
@interface ChangePhoneViewController : XDContentViewController
@property (nonatomic, assign) id<ChangePhoneNum> changePhoneDel;
@end

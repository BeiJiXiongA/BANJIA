//
//  AddDongTaiViewController.h
//  School
//
//  Created by TeekerZW on 14-1-24.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@protocol ClassZoneDelegate;

@interface AddDongTaiViewController : XDContentViewController
@property (nonatomic, strong) NSString *classID;
@property (nonatomic, assign) id<ClassZoneDelegate> classZoneDelegate;
@end

@protocol ClassZoneDelegate <NSObject>

-(void)haveAddDonfTai:(BOOL)add;

@end
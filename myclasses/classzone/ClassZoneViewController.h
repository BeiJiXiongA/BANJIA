//
//  ClassZoneViewController.h
//  School
//
//  Created by TeekerZW on 14-1-17.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@protocol FreshClassZone <NSObject>

-(void)reFreshClassZone:(BOOL)refresh;

@end

@interface ClassZoneViewController : XDContentViewController
@property (nonatomic) BOOL isApply;
@property (nonatomic) BOOL fromMsg;
@property (nonatomic, assign) id<FreshClassZone> refreshDel;
@end

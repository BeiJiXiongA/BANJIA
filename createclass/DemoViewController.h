//
//  DemoViewController.h
//  HtmlDemo
//
//  Created by TeekerZW on 1/15/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDContentViewController.h"

@protocol SelectArea <NSObject>

-(void)updateAreaWithId:(NSString *)areaID areaName:(NSString *)areaName;

@end

@interface DemoViewController : XDContentViewController
@property (nonatomic, assign) id<SelectArea> selectArea;
@end

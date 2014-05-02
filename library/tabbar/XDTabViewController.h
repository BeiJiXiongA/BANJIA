//
//  XDTabViewController.h
//  XDCommonApp
//
//  Created by  on 13-6-5.
//  Copyright (c) 2013年 xin wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDTabBar.h"
#import "Header.h"
#import "XDViewControllerDelegate.h"
#import "XDContentViewController.h"

@interface XDTabViewController : XDContentViewController <XDTabBarDelegate>

@property (nonatomic, strong) XDTabBar *tabBar;
@property (nonatomic, strong) NSArray *tabBarContents;
@property (nonatomic) NSInteger preItemIndex;
@property (nonatomic, retain) UILabel *label0;
@property (nonatomic, retain) UILabel *label1;
@property (nonatomic, retain) UILabel *label2;
@property (nonatomic, retain) UILabel *label3;
@property (nonatomic, strong) NSString *classID;

+(XDTabViewController *)sharedTabViewController;

- (void)selectItemAtIndex:(NSInteger)index;
- (void)setTabBarHidden:(BOOL)isHidden;

@end

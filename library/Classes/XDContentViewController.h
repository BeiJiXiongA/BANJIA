//
//  LoginViewController.m
//  XMPP1106
//
//  Created by mac120 on 13-11-6.
//  Copyright (c) 2013年 mac120. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDViewControllerDelegate.h"


@interface XDContentViewController : UIViewController
{
    UIPanGestureRecognizer *panGestureRecognier;
}

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, weak)  id<XDViewControllerDelegate> lenghtDelegate;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *stateView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIImageView *navigationBarBg;
@property (nonatomic, strong) UIView *navigationBarView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImage *topbarImage;
@property (nonatomic, strong) UILabel *unReadLabel;
@property (nonatomic, strong) UIImageView *returnImageView;

- (void) setRecognierEnable:(BOOL) isEnable;
-(void)showSelfViewController: (UIViewController*) parentViewCon;
- (void)unShowSelfViewController;

@end

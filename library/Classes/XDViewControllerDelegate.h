//
//  LoginViewController.m
//  XMPP1106
//
//  Created by mac120 on 13-11-6.
//  Copyright (c) 2013年 mac120. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XDViewControllerDelegate <NSObject>

@required
-(void) viewPanThroughRatio:(CGFloat) length;

@end

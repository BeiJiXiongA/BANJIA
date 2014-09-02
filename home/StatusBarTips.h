//
//  StatusBarTips.h
//  BANJIA
//
//  Created by TeekerZW on 14/8/26.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TipsDelegate;

@interface StatusBarTips : UIWindow

@property (nonatomic, strong) NSString *tipsMessage;
@property (nonatomic, strong) NSString *messageType;
@property (nonatomic, strong) NSDictionary *dataDict;
@property (nonatomic, assign) id<TipsDelegate> tipsDelegate;


+(StatusBarTips *)shareTipsWindow;

-(void)showTips:(NSString *)tips;

-(void)showTipsWithImage:(UIImage *)tipsImage message:(NSString *)message messageType:(NSString *)type tipDelegate:(id)delegate;

-(void)showTipsWithImage:(UIImage *)tipsImage message:(NSString *)message hideAfterDelay:(NSInteger)seconds;

-(void)hideTips;

@end

@protocol TipsDelegate <NSObject>

-(void)tapTipsWithData:(NSDictionary *)dataDict;

@end

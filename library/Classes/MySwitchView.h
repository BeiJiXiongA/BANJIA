//
//  MySwitchView.h
//  School
//
//  Created by TeekerZW on 14-1-24.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MySwitchDel;
@interface MySwitchView : UIView
{
    UIView *selectView;
}
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UIView *selectView;
@property (nonatomic, assign) id<MySwitchDel> mySwitchDel;
-(BOOL)isOpen;
-(void)close;
-(void)open;
@end

@protocol MySwitchDel <NSObject>
@optional
-(void)setOn;
-(void)setOff;
-(void)switchStateChanged:(MySwitchView *)mySwitchView;
@end

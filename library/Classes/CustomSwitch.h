//
//  CustomSwitch.h
//  School
//
//  Created by TeekerZW on 14-1-17.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSwitch : UISlider
{
    BOOL on;
    UIColor *tintColor;
    UIView *clippingView;
    UILabel *rightLabel;
    UILabel *leftLabel;
    
    BOOL m_touchedSelf;
}

@property (nonatomic, assign) BOOL on;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIView *clippingView;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UILabel *leftLabel;

+(CustomSwitch *)switchWithLeftText:(NSString *)leftText
                       andRightText:(NSString *)rightText;
-(void)setOn:(BOOL)on animated:(BOOL)animated;
@end

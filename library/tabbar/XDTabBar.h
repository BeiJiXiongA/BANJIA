//
//  XDTabBar.h
//  XDCommonApp
//
//  Created by  on 13-6-5.
//  Copyright (c) 2013年 xin wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XDTabBar;

@protocol XDTabBarDelegate

- (UIImage*)imageFor:(XDTabBar*)tabBar atIndex:(NSUInteger)itemIndex;
- (UIImage*)hightlightedImageFor:(XDTabBar*)tabBar
                         atIndex:(NSUInteger)itemIndex;
- (UIImage*)backgroundImage;
- (UIImage*)selectedItemBackgroundImage;
- (UIImage*)selectedItemImage;
- (UIImage*)tabBarArrowImage;

@optional
- (void)touchUpInsideItemAtIndex:(NSUInteger)itemIndex;
- (void)touchDownAtItemAtIndex:(NSUInteger)itemIndex;

@end


@interface XDTabBar : UIView {
    NSObject <XDTabBarDelegate> *delegate;
    NSMutableArray* buttons;
}

@property (nonatomic, retain) NSMutableArray* buttons;
@property (nonatomic, retain) UIButton *button0;
@property (nonatomic, retain) UIButton *button1;
@property (nonatomic, retain) UIButton *button2;
@property (nonatomic, retain) UIButton *button3;
@property (nonatomic, retain) UILabel *label0;
@property (nonatomic, retain) UILabel *label1;
@property (nonatomic, retain) UILabel *label2;
@property (nonatomic, retain) UILabel *label3;

- (id)initWithItemCount:(NSUInteger)itemCount
               itemSize:(CGSize)itemSize
                    tag:(NSInteger)objectTag
               delegate:(NSObject <XDTabBarDelegate>*)YCTabBarDelegate;

- (void)selectItemAtIndex:(NSInteger)index;

@end

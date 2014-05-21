//
//  HeaderVIew.h
//  BANJIA
//
//  Created by TeekerZW on 5/15/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TOP_HEIGHT   120.0f

@protocol HeaderActionDelegate <NSObject>

-(void)refreshAction;

@end

@interface HeaderVIew : UIView<UIScrollViewDelegate>
{
    CGFloat angle;
    BOOL stopRatating;
}
@property (nonatomic, assign, readonly) BOOL isLoading;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) UIImageView *refreshImageView;
@property (assign, nonatomic) id<HeaderActionDelegate> headerDel;
@property (assign, nonatomic) CGRect contentRect;

-(void)setRefreshImage:(UIImage *)image;

-(void)setBgImage:(UIImage *)image;

@property (strong, nonatomic) UIView *contentView;

-(void)endUpdate;

@end

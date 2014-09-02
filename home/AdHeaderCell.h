//
//  HeaderCell.h
//  优佳齿科
//
//  Created by mac120 on 13-11-22.
//  Copyright (c) 2013年 mac120. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol headerDelegate;

@interface ADHeaderCell : UITableViewCell<UIScrollViewDelegate>
{
    UIScrollView *headerScrollView;
    UIPageControl *headerPageControl;
}
@property (nonatomic,strong)UIScrollView *headerScrollView;
@property (nonatomic,strong)UIPageControl *headerPageControl;
@property (nonatomic,assign)id<headerDelegate> headerDel;
@property (nonatomic,strong) UIButton *closeAd;
@end

@protocol headerDelegate <NSObject>
-(void)getHeaderIndex:(ADHeaderCell *)cell andIndex:(int)headerIndex;
@end
//
//  FooterView.h
//  BANJIA
//
//  Created by TeekerZW on 14-5-29.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#define REFRESH_REGION_HEIGHT  65.0f

//typedef enum {
//    EGOPullRefreshPulling = 0,
//    EGOPullRefreshNormal,
//    EGOPullRefreshLoading,
//}EGOPullRefreshState;

typedef enum {
    EGORefreshHeader = 0,
    EGORefreshFooter
}EGORefreshPos;

@protocol EGORefreshTableDelegate;

@interface FooterView : UIView
{
    EGOPullRefreshState _state;
    
    UIScrollView* _scrollView;
    
    BOOL _pagingEnabled;
    
	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
}
@property (nonatomic, assign) id <EGORefreshTableDelegate> delegate;

- (id)initWithScrollView:(UIScrollView* )scrollView;

- (void)refreshLastUpdatedDate;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end

@protocol EGORefreshTableDelegate <NSObject>

-(void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos;
-(BOOL)egoRefreshTableDataSourceIsLoading:(UIView *)view;

@optional
-(NSDate *)egoRefreshTableDataSourceLastUpdated:(UIView *)view;
@end
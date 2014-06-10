//
//  DemoVIew.h
//  MyProject
//
//  Created by TeekerZW on 14-5-31.
//  Copyright (c) 2014年 ZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "FooterView.h"

@interface DemoVIew : UIView<
UITableViewDataSource,
UITableViewDelegate,
EGORefreshTableDelegate,
EGORefreshTableHeaderDelegate>
{
    EGORefreshTableHeaderView *headerView;
    FooterView *footerView;
    
    BOOL _reloading;
}
@property (nonatomic, strong) UITableView *demoTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
-(void)layoutView;
@end

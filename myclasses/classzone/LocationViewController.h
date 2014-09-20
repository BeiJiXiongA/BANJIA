//
//  LocationViewController.h
//  BANJIA
//
//  Created by TeekerZW on 14/9/19.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "XDContentViewController.h"

@interface LocationViewController : XDContentViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *locationListTableView;
    NSMutableArray *locationArray;
}
@end

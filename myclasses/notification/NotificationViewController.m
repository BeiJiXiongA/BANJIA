//
//  NotificationViewController.m
//  School
//
//  Created by TeekerZW on 14-1-17.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "NotificationViewController.h"
#import "XDTabViewController.h"
#import "NotificationCell.h"
#import "AddNotificationViewController.h"
#import "NotificationDetailViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "FooterView.h"

@interface NotificationViewController ()<
UITableViewDataSource,
UITableViewDelegate,
EGORefreshTableHeaderDelegate,
updateDelegate,
NotificationDetailDelegate,
EGORefreshTableDelegate>
{
    UITableView *notificationTableView;
    NSMutableArray *tmpArray;
    NSInteger page;
    
    EGORefreshTableHeaderView *pullRefreshView;
    FooterView *footerView;
    BOOL _reloading;
    
    NSString *month;
    
    OperatDB *db;
    
    UILabel *tipLabel;
    
    NSString *classID;
}
@end

@implementation NotificationViewController
@synthesize classID,fromMsg;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.titleLabel.text = @"班级公告";
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    page = 0;
    month = @"";
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
        
    db = [[OperatDB alloc] init];
    
    if (fromMsg)
    {
        [self.backButton addTarget:self action:@selector(mybackClick) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [self.backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    }
    tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setTitle:@"添加" forState:UIControlStateNormal];
    addButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [addButton addTarget:self action:@selector(addClick) forControlEvents:UIControlEventTouchUpInside];
    [addButton setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
    
    DDLOG(@"class set%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"set"]);
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] ==2)
    {
        [self.navigationBarView addSubview:addButton];
    }
    else if([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:AdminSendNotice] integerValue] == 1)
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] ==1)
        {
            [self.navigationBarView addSubview:addButton];
        }
    }
    notificationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - UI_NAVIGATION_BAR_HEIGHT-UI_TAB_BAR_HEIGHT) style:UITableViewStylePlain];
    notificationTableView.delegate = self;
    notificationTableView.dataSource = self;
    notificationTableView.backgroundColor = self.bgView.backgroundColor;
    notificationTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:notificationTableView];
    
    pullRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:notificationTableView orientation:EGOPullOrientationDown];
    pullRefreshView.delegate = self;
    
    
    [self getCacheNotices];
    [self getNotifications];
    
    tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(40, 100, SCREEN_WIDTH-80, 80);
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textColor = TITLE_COLOR;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = @"班级目前还没有任何公告！";
    tipLabel.hidden = YES;
    [notificationTableView addSubview:tipLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)readNotificationDetail
{
    page = 0;
    month = @"";
    [self getNotifications];
}

-(void)mybackClick
{
    [self unShowSelfViewController];
}

-(void)update:(BOOL)update
{
    if (update)
    {
        page = 0;
        month = @"";
        [self getNotifications];
    }
}

#pragma mark - egodelegate
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    page = 0;
    month = @"";
    [self getNotifications];
}

-(void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
    [self getMoreNotifications];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _reloading;
}

-(BOOL)egoRefreshTableDataSourceIsLoading:(UIView *)view
{
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [pullRefreshView egoRefreshScrollViewDidScroll:notificationTableView];
    if (scrollView.contentOffset.y+(scrollView.frame.size.height) > scrollView.contentSize.height+65)
    {
        [footerView egoRefreshScrollViewDidScroll:notificationTableView];
    }

}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pullRefreshView egoRefreshScrollViewDidEndDragging:notificationTableView];
    [footerView egoRefreshScrollViewDidEndDragging:notificationTableView];
}

-(void)backClick
{
    [[XDTabViewController sharedTabViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)addClick
{
    AddNotificationViewController *addNotificationViewController = [[AddNotificationViewController alloc] init];
    addNotificationViewController.classID = classID;
    addNotificationViewController.updel = self;
    [[XDTabViewController sharedTabViewController].navigationController pushViewController:addNotificationViewController animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (page == 0 && [month length] == 0)
    {
        if ([tmpArray count] == 0)
        {
            tipLabel.hidden = NO;
        }
    }
    return [tmpArray count]>0?([tmpArray count]):(0);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString *notiCell = @"notiCell";
        NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:notiCell];
        if (cell == nil)
        {
            cell = [[NotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:notiCell];
        }
        
        NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
        
        [cell.bgImageView setImage:[UIImage imageNamed:@"noticeBg"]];
        cell.iconLabel.frame = CGRectMake(8, 20, 40, 40);
        
        NSString *byName = [[dict objectForKey:@"by"] objectForKey:@"name"];
        
        cell.iconLabel.layer.cornerRadius = 20;
        cell.iconLabel.clipsToBounds = YES;
        
        cell.iconLabel.textAlignment = NSTextAlignmentCenter;
        cell.iconLabel.text = [byName substringFromIndex:[byName length]-1];
        cell.iconLabel.textColor = [UIColor grayColor];
        cell.iconLabel.layer.borderWidth = 1;
        
        cell.nameLabel.frame = CGRectMake(60, 20, 100, 20);
        cell.nameLabel.text = byName;
        
        CGFloat he = 0;
        if (SYSVERSION>=7)
        {
            he = 5;
        }
        
        cell.contentLabel.text = [dict objectForKey:@"content"];
        cell.contentLabel.backgroundColor = [UIColor clearColor];
        cell.contentLabel.font = [UIFont systemFontOfSize:14];
        cell.contentLabel.textColor = TITLE_COLOR;
        cell.contentLabel.contentMode = UIViewContentModeTop;
        cell.contentLabel.frame = CGRectMake(60, 40, SCREEN_WIDTH-70, 55+he);
        
        cell.statusLabel.textColor = TITLE_COLOR;
        
        cell.timeLabel.frame = CGRectMake(SCREEN_WIDTH-160, 20, 150, 20);
        cell.timeLabel.textAlignment = NSTextAlignmentRight;
        cell.timeLabel.font = [UIFont systemFontOfSize:13];
        cell.timeLabel.text = [Tools showTime:[NSString stringWithFormat:@"%d",[[[dict objectForKey:@"created"] objectForKey:@"sec"] integerValue]]];
        cell.timeLabel.textColor = TITLE_COLOR;
        
        if (![[[dict objectForKey:@"by"] objectForKey:@"_id"] isEqualToString:[Tools user_id]])
        {
            if ([[dict objectForKey:@"new"] integerValue] == 0)
            {
                cell.iconLabel.textColor = [UIColor grayColor];
                cell.iconLabel.layer.borderColor = [UIColor grayColor].CGColor;
            }
            else if([[dict objectForKey:@"new"] integerValue] == 1)
            {
                cell.iconLabel.textColor = [UIColor redColor];
                cell.iconLabel.layer.borderColor = [UIColor redColor].CGColor;
            }
        }
        else
        {
            cell.iconLabel.layer.borderColor = [UIColor grayColor].CGColor;
        }
        
        if ([[dict objectForKey:@"c_read"] integerValue] == 0)
        {
            cell.statusLabel.hidden = YES;
        }
        else
        {
            if ([[[dict objectForKey:@"by"] objectForKey:@"_id"] isEqualToString:[Tools user_id]])
            {
                cell.statusLabel.text =[NSString stringWithFormat:@"%d人已读 %d人未读",[[dict objectForKey:@"read_num"] integerValue],[[dict objectForKey:@"unread_num"] integerValue]];
            }
            else
            {
                cell.statusLabel.text =[NSString stringWithFormat:@"%d人已读 %d人未读",[[dict objectForKey:@"read_num"] integerValue],[[dict objectForKey:@"unread_num"] integerValue]];
            }
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
}
-(void)getMoreNotifications
{
    page++;
    [self getNotifications];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
    NotificationDetailViewController *notificationDetailViewController = [[NotificationDetailViewController alloc] init];
    notificationDetailViewController.noticeID = [dict objectForKey:@"_id"];
    notificationDetailViewController.noticeContent = [dict objectForKey:@"content"];
    notificationDetailViewController.c_read = [dict objectForKey:@"c_read"];
    notificationDetailViewController.readnotificationDetaildel = self;
    notificationDetailViewController.byID = [[dict objectForKey:@"by"] objectForKey:@"_id"];
    if ([[dict objectForKey:@"new"] integerValue] == 1)
    {
        notificationDetailViewController.isnew = YES;
        
        int newNoticeNum = [[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@-notice",classID]] integerValue];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",--newNoticeNum ] forKey:[NSString stringWithFormat:@"%@-notice",classID]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[XDTabViewController sharedTabViewController] viewWillAppear:YES];
    }
    else
    {
        notificationDetailViewController.isnew = NO;
    }
    [[XDTabViewController sharedTabViewController].navigationController pushViewController:notificationDetailViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)getNotifications
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      @"month":[month length]>0?month:@"",
                                                                      @"page":[NSNumber numberWithInteger:page]
                                                                      } API:GETNOTIFICATIONS];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"notifications responseDict==%@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"posts"] count] > 0)
                {
                    if (page == 0)
                    {
                        [tmpArray removeAllObjects];
                        NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",GETNOTIFICATIONS,[Tools user_id],classID];
                        NSString *key = [requestUrlStr MD5Hash];
                        [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
                    }
                    NSArray *array = [[responseDict objectForKey:@"data"] objectForKey:@"posts"];
                    for (int i = 0; i<[array count]; i++)
                    {
                        if (![[array objectAtIndex:i] isEqual:[NSNull null]])
                        {
                            [tmpArray addObject:[array objectAtIndex:i]];
                        }
                    }
                    page = [[[responseDict objectForKey:@"data"] objectForKey:@"page"] intValue];
                    month = [NSString stringWithFormat:@"%@",[[responseDict objectForKey:@"data"] objectForKey:@"month"]];
                    
                    [db deleteRecordWithDict:@{@"uid":[Tools user_id],@"type":@"notice"} andTableName:@"notice"];
                    
                    if ([[responseDict objectForKey:@"data"] objectForKey:@"posts"] > 0)
                    {
                        tipLabel.hidden = YES;
                    }
                    else if(page == 0)
                    {
                        tipLabel.hidden = NO;
                    }
                    else
                    {
                        tipLabel.hidden = YES;
                    }
                    
                    if ([self.readNoticedel respondsToSelector:@selector(readNotice:)])
                    {
                        [self.readNoticedel readNotice:YES];
                    }
                }
                else
                {
                    if (page ==0)
                    {
                        if ([tmpArray count] > 0)
                        {
                            tipLabel.hidden = YES;
                        }
                        else
                        {
                            tipLabel.hidden = NO;
                        }
                        
                    }
                    else
                    {
                        [Tools showAlertView:@"没有更多公告了！" delegateViewController:nil];
                    }
                    
                    if (page == 0 && [month length] == 0)
                    {
                        [tmpArray removeAllObjects];
                    }
                }
                [notificationTableView reloadData];
                if (footerView)
                {
                    [footerView removeFromSuperview];
                    footerView = [[FooterView alloc] initWithScrollView:notificationTableView];
                    footerView.delegate = self;
                }
                else
                {
                    footerView = [[FooterView alloc] initWithScrollView:notificationTableView];
                    footerView.delegate = self;
                }
                _reloading = NO;
                [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:notificationTableView];
                [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:notificationTableView];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
        _reloading = NO;
        [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:notificationTableView];
        [self getCacheNotices];
    }
}

-(void)getCacheNotices
{
    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",GETNOTIFICATIONS,[Tools user_id],classID];
    NSString *key = [requestUrlStr MD5Hash];
    NSData *notifications = [FTWCache objectForKey:key];
    NSString *responseString = [[NSString alloc] initWithData:notifications encoding:NSUTF8StringEncoding];
    NSDictionary *responseDict = [Tools JSonFromString:responseString];
    if ([[responseDict objectForKey:@"code"] intValue]== 1)
    {
        [tmpArray removeAllObjects];
        NSArray *array = [[responseDict objectForKey:@"data"] objectForKey:@"posts"];
        for (int i = 0; i<[array count]; i++)
        {
            if (![[array objectAtIndex:i] isEqual:[NSNull null]])
            {
                [tmpArray addObject:[array objectAtIndex:i]];
            }
        }
        [notificationTableView reloadData];
    }
    if ([tmpArray count] <= 0)
    {
        tipLabel.hidden = NO;
    }
}
@end

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

@interface NotificationViewController ()<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,updateDelegate>
{
    UITableView *notificationTableView;
    NSMutableArray *tmpArray;
    NSInteger page;
    
    EGORefreshTableHeaderView *pullRefreshView;
    BOOL _reloading;
    
    NSString *month;
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
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] > 0)
    {
        [self.navigationBarView addSubview:addButton];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
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
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pullRefreshView egoRefreshScrollViewDidEndDragging:notificationTableView];
}


-(void)backClick
{
//    [[XDTabViewController sharedTabViewController] dismissViewControllerAnimated:YES completion:nil];
    [[XDTabViewController sharedTabViewController] unShowSelfViewController];
}

-(void)addClick
{
    AddNotificationViewController *addNotificationViewController = [[AddNotificationViewController alloc] init];
    addNotificationViewController.classID = classID;
    addNotificationViewController.updel = self;
    [addNotificationViewController showSelfViewController:[XDTabViewController sharedTabViewController]];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tmpArray count]+1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==[tmpArray count])
    {
        return 40;
    }
    return 120;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row<[tmpArray count])
    {
        static NSString *notiCell = @"notiCell";
        NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:notiCell];
        if (cell == nil)
        {
            cell = [[NotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:notiCell];
        }
        
        NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
        
        [cell.bgImageView setImage:[UIImage imageNamed:@"noticeBg"]];
        [cell.iconImageView setImage:[UIImage imageNamed:@"noticeIcon"]];
        
        
        cell.contentLabel.text = [dict objectForKey:@"content"];
        cell.contentLabel.backgroundColor = [UIColor clearColor];
        cell.contentLabel.font = [UIFont systemFontOfSize:16];
        cell.contentLabel.textColor = TITLE_COLOR;
        
        cell.statusLabel.textColor = TITLE_COLOR;
        cell.timeLabel.text = [Tools showTime:[NSString stringWithFormat:@"%d",[[[dict objectForKey:@"created"] objectForKey:@"sec"] integerValue]]];
        cell.timeLabel.textColor = TITLE_COLOR;
        if ([[dict objectForKey:@"c_read"] integerValue] == 0)
        {
            cell.statusLabel.hidden = YES;
        }
        else
        {
            cell.statusLabel.text =[NSString stringWithFormat:@"%d人已读 %d人未读",[[dict objectForKey:@"read_num"] integerValue],[[dict objectForKey:@"read_num"] integerValue]];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    else if(indexPath.row == [tmpArray count])
    {
        static NSString *buttomCell = @"buttom";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:buttomCell];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:buttomCell];
        }
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
        button.backgroundColor = [UIColor clearColor];
        if (notificationTableView.contentSize.height > notificationTableView.frame.size.height)
        {
            button.enabled = YES;
            [button setTitle:@"加载更多" forState:UIControlStateNormal];
        }
        else
        {
            button.enabled = NO;
            [button setTitle:@"" forState:UIControlStateNormal];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(getMoreDongTai) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    return nil;
}
-(void)getMoreDongTai
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
    notificationDetailViewController.classID = classID;
    
    if ([[dict objectForKey:@"c_read"] integerValue] == 1)
    {
        [self readNotice:[dict objectForKey:@"_id"]];
    }
    
    [notificationDetailViewController showSelfViewController:[XDTabViewController sharedTabViewController]];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)readNotice:(NSString *)noticeID
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":noticeID,
                                                                      @"c_id":classID
                                                                      } API:READNTICES];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"classInfo responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                DDLOG(@"read success!");
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
                [tmpArray removeAllObjects];
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"posts"] count] > 0)
                {
                    if (page == 0)
                    {
                        NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",GETNOTIFICATIONS,[Tools user_id],classID];
                        NSString *key = [requestUrlStr MD5Hash];
                        [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
                    }
                    if ([[[responseDict objectForKey:@"data"] objectForKey:@"month"] integerValue] == 0)
                    {
                        [Tools showAlertView:@"没有更多公告了！" delegateViewController:nil];
                        return ;
                    }
                    [tmpArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"posts"]];
                    page = [[[responseDict objectForKey:@"data"] objectForKey:@"page"] intValue];
                    month = [NSString stringWithFormat:@"%@",[[responseDict objectForKey:@"data"] objectForKey:@"month"]];
                    [notificationTableView reloadData];
                    _reloading = NO;
                    [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:notificationTableView];
                }
                else
                {
                    [Tools showAlertView:@"班级目前还没有任何公告！" delegateViewController:nil];
                }
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
        [tmpArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"posts"]];
        [notificationTableView reloadData];
    }
}
@end

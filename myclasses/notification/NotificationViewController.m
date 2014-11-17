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
#import "SearchSchoolViewController.h"

@interface NotificationViewController ()<
UITableViewDataSource,
UITableViewDelegate,
EGORefreshTableHeaderDelegate,
updateDelegate,
NotificationDetailDelegate,
EGORefreshTableDelegate>
{
    UITableView *notificationTableView;
    NSMutableArray *readedArray;
    NSMutableArray *unreadedArray;
    NSInteger page;
    
    EGORefreshTableHeaderView *pullRefreshView;
    FooterView *footerView;
    BOOL _reloading;
    
    BOOL haveMore;
    
    NSString *month;
    
    OperatDB *db;
    
    UILabel *tipLabel;
    
    NSString *classID;
    
    UIImageView *tipImageView;
    UIImageView *tapLabel;
    
    NSInteger currentReadNoticeIndex;
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
    self.titleLabel.text = @"班级通知";
    page = 0;
    currentReadNoticeIndex = -1;
    month = @"";
    haveMore = YES;
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNewNotice) name:RECEIVENEWNOTICE object:nil];
    
    db = [[OperatDB alloc] init];
    
    if (fromMsg)
    {
        [self.backButton addTarget:self action:@selector(mybackClick) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [self.backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    }
    readedArray = [[NSMutableArray alloc] initWithCapacity:0];
    unreadedArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(SCREEN_WIDTH - 52, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [addButton addTarget:self action:@selector(addClick) forControlEvents:UIControlEventTouchUpInside];
    [addButton setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    
    notificationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - UI_NAVIGATION_BAR_HEIGHT-UI_TAB_BAR_HEIGHT) style:UITableViewStylePlain];
    notificationTableView.delegate = self;
    notificationTableView.dataSource = self;
    notificationTableView.backgroundColor = self.bgView.backgroundColor;
    notificationTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:notificationTableView];
    
    pullRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:notificationTableView orientation:EGOPullOrientationDown];
    pullRefreshView.delegate = self;
    
    
    [self getCacheNotices];
    [self getNotifications:NO];
    
    tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(40, 100, SCREEN_WIDTH-80, 80);
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textColor = TITLE_COLOR;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = @"班级目前还没有任何公告！";
    tipLabel.hidden = YES;
    [notificationTableView addSubview:tipLabel];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (ShowTips == 1)
    {
        [ud removeObjectForKey:@"classnoticetip1"];
        [ud removeObjectForKey:@"classnoticetip2"];
        [ud synchronize];
    }
    if (![ud objectForKey:@"classnoticetip1"])
    {
        self.unReadLabel.hidden = YES;
        
        tipImageView = [[UIImageView alloc] init];
        tipImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 568);
        if (SYSVERSION >= 7)
        {
            [tipImageView setImage:[UIImage imageNamed:@"classnoticetip1"]];
        }
        else
        {
            [tipImageView setImage:[UIImage imageNamed:@"classnoticetip16"]];
        }
        tipImageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        [[XDTabViewController sharedTabViewController].bgView addSubview:tipImageView];
        tipImageView.hidden = YES;
        
        
        UITapGestureRecognizer *outTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outTap)];
        tipImageView.userInteractionEnabled = YES;
        [tipImageView addGestureRecognizer:outTap];
        
        
        tapLabel = [[UIImageView alloc] init];
        tapLabel.frame = CGRectMake(15, 100, 290, 60);
        tapLabel.backgroundColor = [UIColor clearColor];
        [[XDTabViewController sharedTabViewController].bgView addSubview:tapLabel];

        
        UITapGestureRecognizer *tipTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkTip)];
        tapLabel.userInteractionEnabled = YES;
        [tapLabel addGestureRecognizer:tipTap];
    }
    
    NSDictionary *dict = [[db findSetWithDictionary:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE] firstObject];
    NSInteger userAdmin = [[dict objectForKey:@"admin"] integerValue];
    if (userAdmin == 2 || [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
    {
        [self.navigationBarView addSubview:addButton];
        tipImageView.hidden = NO;
    }
    else if([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:AdminSendNotice] integerValue] == 1)
    {
        if (userAdmin ==1)
        {
            [self.navigationBarView addSubview:addButton];
            tipImageView.hidden = NO;
        }
    }

}

-(void)outTap
{
    
}

-(void)checkTip
{
    NSString *schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud objectForKey:@"classnoticetip1"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] intValue] == 2 && ([schoolName isEqualToString:@"未指定学校"] || [schoolName isEqualToString:@"未设置学校"]))
    {
        tapLabel.frame = CGRectMake(15, 160, 290, 70);
        if (SYSVERSION >= 7)
        {
            [tipImageView setImage:[UIImage imageNamed:@"classnoticetip2"]];
        }
        else
        {
            [tipImageView setImage:[UIImage imageNamed:@"classnoticetip26"]];
        }
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@"1" forKey:@"classnoticetip1"];
        [ud synchronize];
    }
    else if(![ud objectForKey:@"classnoticetip2"])
    {
        [tapLabel removeFromSuperview];
        [tipImageView removeFromSuperview];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@"1" forKey:@"classnoticetip2"];
        [ud synchronize];
    }
    else
    {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@"1" forKey:@"classnoticetip1"];
        [ud synchronize];
        [tapLabel removeFromSuperview];
        [tipImageView removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)readNotificationDetail:(NSDictionary *)noticeDict deleted:(BOOL)deleted
{
//    page = 0;
//    month = @"";
//    [self getNotifications:NO];
    
    BOOL isNew = ([[noticeDict objectForKey:@"new"] intValue]==1)?YES:NO;
    
    if (isNew)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR_NUMBER object:nil];
    }
    if (deleted && isNew)
    {
        [unreadedArray removeObject:noticeDict];
        [notificationTableView reloadData];
    }
    else if(deleted && !isNew)
    {
        [readedArray removeObject:noticeDict];
        [notificationTableView reloadData];
    }
    else if(!deleted && isNew)
    {
        [unreadedArray removeObject:noticeDict];
        [readedArray insertObject:noticeDict atIndex:0];
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithDictionary:noticeDict];
        [tmpDict setObject:@"0" forKey:@"new"];
        for (int i=0; i<[readedArray count]; i++)
        {
            NSDictionary *readDict = [readedArray objectAtIndex:i];
            if ([[[noticeDict objectForKey:@"created"] objectForKey:@"sec"] intValue] >= [[[readDict objectForKey:@"created"] objectForKey:@"sec"] intValue])
            {
                [readedArray insertObject:tmpDict atIndex:i];
                [notificationTableView reloadData];
                break;
            }
        }
    }
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
        [self getNotifications:NO];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVENEWNOTICE object:nil];
}

#pragma mark - egodelegate
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    page = 0;
    month = @"";
    [self getNotifications:NO];
}
//@""
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
    [[NSUserDefaults standardUserDefaults] setObject:NOTFROMCLASS forKey:FROMWHERE];
    [[NSUserDefaults standardUserDefaults] objectForKey:@"admin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)addClick
{
    AddNotificationViewController *addNotificationViewController = [[AddNotificationViewController alloc] init];
    addNotificationViewController.classID = classID;
    addNotificationViewController.updel = self;
    addNotificationViewController.fromClass = YES;
    [[XDTabViewController sharedTabViewController].navigationController pushViewController:addNotificationViewController animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0;
    }
    else if (section == 1)
    {
        if ([unreadedArray count] > 0)
        {
            return 35;
        }
    }
    else if(section == 2)
    {
        if ([readedArray count] > 0)
        {
            return 35;
        }
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
    headerView.backgroundColor = UIColorFromRGB(0xf1f0ec);
    
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.backgroundColor = UIColorFromRGB(0xf1f0ec);
    headerLabel.font = [UIFont systemFontOfSize:18];
    headerLabel.textColor = COMMENTCOLOR;
    [headerView addSubview:headerLabel];
    if (section == 1)
    {
        if ([unreadedArray count] > 0)
        {
            headerLabel.text = @"   未读通知";
            headerLabel.frame = CGRectMake(0, 2.5, headerView.frame.size.width, 30);
            return headerView;
        }
    }
    
    if (section == 2)
    {
        if ([readedArray count] > 0)
        {
            headerLabel.text = @"   已读通知";
            headerLabel.frame = CGRectMake(0, 2.5, headerView.frame.size.width, 30);
            return headerView;
        }
    }
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else if (section == 1)
    {
        if ([unreadedArray count] > 0)
        {
            return [unreadedArray count];
        }
    }
    else if (section ==2)
    {
        if ([readedArray count] > 0)
        {
            return [readedArray count];
        }
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            NSString *schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
            if ([schoolName isEqualToString:@"未指定学校"] || [schoolName isEqualToString:@"未设置学校"])
            {
                return 56;
            }
            return 0;
        }
        else if(indexPath.row == 1)
        {
            if ([unreadedArray count] > 0 || [readedArray count] > 0)
            {
                return 0;
            }
            return 0;
        }
    }
    return 88;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *notiCell = @"notiCell";
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:notiCell];
    if (cell == nil)
    {
        cell = [[NotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:notiCell];
    }
    cell.contentLabel.hidden = YES;
    cell.nameLabel.hidden = YES;
    cell.contentLabel.backgroundColor = [UIColor clearColor];
    
    if (indexPath.section == 0)
    {
        cell.timeLabel.hidden = YES;
        cell.statusLabel.hidden = YES;
        cell.bgImageView.hidden = YES;
        if (indexPath.row == 0)
        {
            NSString *schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
            if ([schoolName isEqualToString:@"未指定学校"] || [schoolName isEqualToString:@"未设置学校"])
            {
                cell.contentLabel.hidden = NO;
                cell.nameLabel.hidden = NO;
                cell.nameLabel.backgroundColor = RGB(255, 241, 134, 1);
                cell.nameLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH, 56);
                cell.contentLabel.frame = CGRectMake(10, 0, SCREEN_WIDTH-20, 56);
                cell.contentLabel.backgroundColor = RGB(255, 241, 134, 1);
                cell.contentLabel.numberOfLines = 2;
                cell.contentLabel.font = [UIFont systemFontOfSize:16];
                cell.contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
                cell.contentLabel.text = @"您的班级未设置学校，设置班级后成员可以通过短信接收班级通知。";
                cell.contentLabel.textColor = RGB(255, 102, 0, 1);
                
                UITapGestureRecognizer *setSchoolTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setSchool)];
                cell.contentLabel.userInteractionEnabled = YES;
                [cell.contentLabel addGestureRecognizer:setSchoolTap];
            }
            else
            {
                cell.contentLabel.hidden = YES;
                cell.nameLabel.hidden = YES;
                
            }
        }
        else if(indexPath.row == 1)
        {
                cell.contentLabel.hidden = YES;
                cell.nameLabel.hidden = YES;
        }
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }
    else
    {
        NSDictionary *dict;
        if (indexPath.section == 1)
        {
            if ([unreadedArray count] > 0)
            {
                dict = [unreadedArray objectAtIndex:indexPath.row];
            }
        }
        else if (indexPath.section == 2)
        {
            if([readedArray count] > 0)
            {
                dict = [readedArray objectAtIndex:indexPath.row];
            }
        }
        cell.timeLabel.hidden = NO;
        cell.statusLabel.hidden = NO;
        cell.bgImageView.hidden = NO;
        cell.contentLabel.hidden = NO;
        cell.nameLabel.hidden = NO;
        cell.contentLabel.backgroundColor = [UIColor whiteColor];
        cell.nameLabel.backgroundColor = [UIColor clearColor];
        
        NSString *byName = [[dict objectForKey:@"by"] objectForKey:@"name"];
        
        CGFloat he = 0;
        if (SYSVERSION>=7)
        {
            he = 5;
        }
        
        NSString *noticeContent = [dict objectForKey:@"content"];
        CGSize size = [Tools getSizeWithString:noticeContent andWidth:SCREEN_WIDTH-80 andFont:[UIFont systemFontOfSize:16]];
        
        CGFloat height = size.height>40?40:size.height;
        
        [cell.bgImageView setImage:[UIImage imageNamed:@"noticeBg"]];
        cell.bgImageView.layer.cornerRadius = 10;
        cell.bgImageView.clipsToBounds = YES;
        cell.bgImageView.frame = CGRectMake(8, 4, SCREEN_WIDTH-16, 80);
        
        NSRange range = [noticeContent rangeOfString:@"$!#"];
        if (range.length > 0)
        {
            noticeContent = [noticeContent substringFromIndex:range.location+range.length];
        }
        
        cell.contentLabel.text = [noticeContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        cell.contentLabel.font = DongTaiContentFont;
        cell.contentLabel.textColor = CONTENTCOLOR;
        cell.contentLabel.contentMode = UIViewContentModeTop;
        
        if (indexPath.section == 1)
        {
            cell.iconImageView.hidden = NO;
            cell.iconImageView.frame = CGRectMake(20, 17, 12, 12);
            //        [cell.iconImageView setImage:[UIImage imageNamed:@"unreadicon"]];
            cell.iconImageView.layer.cornerRadius = 6;
            cell.iconImageView.clipsToBounds = YES;
            cell.iconImageView.backgroundColor = RGB(228, 76, 76, 1);
            cell.iconImageView.layer.borderColor = RGB(227, 63, 64, 1).CGColor;
            cell.iconImageView.layer.borderWidth = 1;
            
            cell.contentLabel.frame = CGRectMake(40, 15, SCREEN_WIDTH-62, height);
            cell.timeLabel.frame = CGRectMake(40, 58, 200, 20);
            
        }
        else
        {
            cell.contentLabel.frame = CGRectMake(25, 15, SCREEN_WIDTH-42, height);
            cell.iconImageView.frame = CGRectMake(20, 17, 0, 0);
            cell.timeLabel.frame = CGRectMake(25, 58, 200, 20);
        }
        
        
        cell.statusLabel.textColor = COMMENTCOLOR;
        cell.statusLabel.frame = CGRectMake(SCREEN_WIDTH-150, 60.5, 130, 15);
        
        
        cell.timeLabel.font = [UIFont systemFontOfSize:13];
        cell.timeLabel.text = [NSString stringWithFormat:@"%@发布于%@",byName,[Tools showTime:[NSString stringWithFormat:@"%d",[[[dict objectForKey:@"created"] objectForKey:@"sec"] intValue]]]];
        cell.timeLabel.textColor = COMMENTCOLOR;
        
        DDLOG(@"%@===%@",noticeContent,NSStringFromCGRect(cell.contentLabel.frame));
        
        cell.statusLabel.text =[NSString stringWithFormat:@"%d人已读 %d人未读",[[dict objectForKey:@"read_num"] intValue],[[dict objectForKey:@"unread_num"] intValue]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    return nil;
}
-(void)getMoreNotifications
{
    if (!haveMore)
    {
        [Tools showTips:@"没有更多公告了！" toView:self.bgView];
        return ;
    }
    page++;
    [self getNotifications:NO];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict;
    if (indexPath.section == 1)
    {
        dict = [unreadedArray objectAtIndex:indexPath.row];
    }
    else if(indexPath.section == 2)
    {
        dict = [readedArray objectAtIndex:indexPath.row];
    }
    else
    {
        return ;
    }
    NotificationDetailViewController *notificationDetailViewController = [[NotificationDetailViewController alloc] init];
    notificationDetailViewController.noticeDict = dict;
    notificationDetailViewController.c_read = @"1";
    notificationDetailViewController.readnotificationDetaildel = self;
    notificationDetailViewController.fromClass = YES;
    if ([[dict objectForKey:@"new"] integerValue] == 1)
    {
        int newNoticeNum = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-notice",classID]] integerValue];
        if (newNoticeNum > 0)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",newNoticeNum-1] forKey:[NSString stringWithFormat:@"%@-notice",classID]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        notificationDetailViewController.isnew = YES;
        
    }
    else
    {
        notificationDetailViewController.isnew = NO;
    }
    currentReadNoticeIndex = indexPath.row;
    [[XDTabViewController sharedTabViewController].navigationController pushViewController:notificationDetailViewController animated:YES];
   
    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)receiveNewNotice
{
    page = 0;
    month = @"";
    [self getNotifications:YES];
}

-(void)getNotifications:(BOOL)receive
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
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"notifications responseDict==%@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"posts"] count] > 0)
                {
                    if (page == 0)
                    {
                        [readedArray removeAllObjects];
                        [unreadedArray removeAllObjects];
                        NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",GETNOTIFICATIONS,[Tools user_id],classID];
                        NSString *key = [requestUrlStr MD5Hash];
                        [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
                    }
                    NSArray *array = [[responseDict objectForKey:@"data"] objectForKey:@"posts"];
                    for (int i = 0; i<[array count]; i++)
                    {
                        if (![[array objectAtIndex:i] isEqual:[NSNull null]])
                        {
                            NSDictionary *noticeDict = [array objectAtIndex:i];
                            if ([[noticeDict objectForKey:@"new"] integerValue] == 0)
                            {
                                [readedArray addObject:noticeDict];
                            }
                            else if ([[noticeDict objectForKey:@"new"] integerValue] == 1)
                            {
                                [unreadedArray addObject:noticeDict];
                            }
                        }
                    }
                    
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
                    if (receive)
                    {
                        int newNoticeNum = [unreadedArray count];
                        if (newNoticeNum > 0)
                        {
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",newNoticeNum] forKey:[NSString stringWithFormat:@"%@-notice",classID]];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        [[XDTabViewController sharedTabViewController] viewWillAppear:NO];
                    }
                }
                
                page = [[[responseDict objectForKey:@"data"] objectForKey:@"page"] intValue];
                month = [NSString stringWithFormat:@"%@",[[responseDict objectForKey:@"data"] objectForKey:@"month"]];
                if (page == 0 && [month length] > 0 && [month intValue] == 0)
                {
                    haveMore = NO;
                }
                if(page == 0)
                {
                    if ([readedArray count] > 0 || [unreadedArray count] > 0)
                    {
                        tipLabel.hidden = YES;
                    }
                    else
                    {
                        tipLabel.hidden = NO;
                    }
                }
                
                if (page == 0 && [month length] == 0)
                {
                    [readedArray removeAllObjects];
                    [unreadedArray removeAllObjects];
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
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            [Tools hideProgress:self.bgView];
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [Tools showProgress:self.bgView];
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
        [readedArray removeAllObjects];
        [unreadedArray removeAllObjects];
        NSArray *array = [[responseDict objectForKey:@"data"] objectForKey:@"posts"];
        for (int i = 0; i<[array count]; i++)
        {
            if (![[array objectAtIndex:i] isEqual:[NSNull null]])
            {
                NSDictionary *noticeDict = [array objectAtIndex:i];
                if ([[noticeDict objectForKey:@"new"] integerValue] == 0)
                {
                    [readedArray addObject:noticeDict];
                }
                else if ([[noticeDict objectForKey:@"new"] integerValue] == 1)
                {
                    [unreadedArray addObject:noticeDict];
                }
            }

        }
        [notificationTableView reloadData];
    }
    if ([readedArray count] == 0 && [unreadedArray count] == 0)
    {
        tipLabel.hidden = NO;
    }
}

-(void)setSchool
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] intValue] < 2)
    {
        return ;
    }
    SearchSchoolViewController  *searchSchoolInfoViewController = [[SearchSchoolViewController alloc] init];
    [[NSUserDefaults standardUserDefaults] setObject:BINDCLASSTOSCHOOL forKey:SEARCHSCHOOLTYPE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[XDTabViewController sharedTabViewController].navigationController pushViewController:searchSchoolInfoViewController animated:YES];
}
@end

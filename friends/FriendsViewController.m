//
//  FriendsViewController.m
//  School
//
//  Created by TeekerZW on 1/14/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "FriendsViewController.h"
#import "XDContentViewController+JDSideMenu.h"
#import "Header.h"
#import "InviteViewController.h"
#import "MemberCell.h"
#import "ChatViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "AppDelegate.h"
#import "NSString+Emojize.h"
#import "UINavigationController+JDSideMenu.h"

@interface FriendsViewController ()<UITableViewDataSource,
UITableViewDelegate,
EGORefreshTableHeaderDelegate,
ChatDelegate,
MsgDelegate,FriendListDelegate>
{
    UITableView *friendsListTableView;
    NSMutableArray *tmpArray;
    NSMutableArray *newFriendsApply;
    
    EGORefreshTableHeaderView *pullRefreshView;
    BOOL _reloading;
    
    NSMutableArray *newMessageArray;
    
    OperatDB *db;
    UILabel *tipLabel;
}
@end

@implementation FriendsViewController

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
    self.titleLabel.text = @"好友";
    [[self.bgView layer] setShadowOffset:CGSizeMake(-5.0f, 5.0f)];
    [[self.bgView layer] setShadowColor:[UIColor darkGrayColor].CGColor];
    [[self.bgView layer] setShadowOpacity:1.0f];
    [[self.bgView layer] setShadowRadius:3.0f];
    self.returnImageView.hidden = YES;
        
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = self;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = self;
    
    db = [[OperatDB alloc] init];
    
    newMessageArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    newFriendsApply = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.backButton setHidden:YES];
    
    friendsListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    friendsListTableView.delegate = self;
    friendsListTableView.dataSource = self;
    friendsListTableView.backgroundColor = [UIColor clearColor];
    friendsListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:friendsListTableView];
    
    _reloading = NO;
    pullRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:friendsListTableView orientation:EGOPullOrientationDown];
    pullRefreshView.delegate = self;
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(5, 4, 42, 34);
    [moreButton setImage:[UIImage imageNamed:@"icon_list"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreOpen) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:moreButton];
    
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setTitle:@"邀请" forState:UIControlStateNormal];
    [inviteButton setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
    inviteButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [inviteButton addTarget:self action:@selector(inviteClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:inviteButton];
    
    if([Tools NetworkReachable])
    {
        [self operateFriendsList:[db findSetWithDictionary:@{@"uid":[Tools user_id]} andTableName:FRIENDSTABLE] andDataType:@"database"];
        [self getFriendList];
    }
    else
    {
        [self operateFriendsList:[db findSetWithDictionary:@{@"uid":[Tools user_id]} andTableName:FRIENDSTABLE] andDataType:@"database"];
    }
    tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(40, CENTER_POINT.y-80, SCREEN_WIDTH-80, 80);
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textColor = TITLE_COLOR;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = @"您还没有好友";
    tipLabel.hidden = YES;
    [friendsListTableView addSubview:tipLabel];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self haveNewMsg] || [self haveNewNotice])
    {
        self.unReadLabel.hidden = NO;
    }
    else
    {
        self.unReadLabel.hidden = YES;
    }

    [self dealNewChatMsg:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = nil;
}
-(BOOL)haveNewMsg
{
    NSMutableArray *array = [db findSetWithDictionary:@{@"readed":@"0",@"userid":[Tools user_id]} andTableName:@"chatMsg"];
    if ([array count] > 0 || [[[NSUserDefaults standardUserDefaults] objectForKey:NewChatMsgNum] integerValue]>0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    return NO;
}
-(BOOL)haveNewNotice
{
    NSMutableArray *array = [db findSetWithDictionary:@{@"readed":@"0",@"uid":[Tools user_id],@"type":@"f_apply"} andTableName:@"notice"];
    if ([array count] > 0)
    {
        return YES;
    }
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - msgDelegate
-(void)dealNewMsg:(NSDictionary *)dict
{
    [self getFriendList];
}

#pragma mark -chatDelegate
-(void)dealNewChatMsg:(NSDictionary *)dict
{
    [newMessageArray removeAllObjects];
    [newMessageArray addObjectsFromArray:[db findSetWithDictionary:@{@"readed":@"0"} andTableName:@"chatMsg"]];
    [friendsListTableView reloadData];
}

-(NSInteger)newMsgCountOfUser:(NSString *)fid
{
    NSInteger count = 0;
    for (int i=0; i<[newMessageArray count]; ++i)
    {
        NSDictionary *dict = [newMessageArray objectAtIndex:i];
        if ([[dict objectForKey:@"fid"] isEqualToString:fid])
        {
            count++;
        }
    }
    return count;
}

-(NSDictionary *)findLastMsgWithUser:(NSString *)fid
{
    NSMutableArray *array = [db findChatLogWithUid:[Tools user_id] andOtherId:fid andTableName:@"chatMsg"];
    return [array lastObject];
}

#pragma mark - egodelegate
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self getFriendList];
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
    [pullRefreshView egoRefreshScrollViewDidScroll:friendsListTableView];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pullRefreshView egoRefreshScrollViewDidEndDragging:friendsListTableView];
}


-(void)moreOpen
{
    if (![[self.navigationController sideMenuController] isMenuVisible])
    {
        [[self.navigationController sideMenuController] showMenuAnimated:YES];
    }
    else
    {
        [[self.navigationController sideMenuController] hideMenuAnimated:YES];
    }
}

-(void)inviteClick
{
    InviteViewController *inviteViewController = [[InviteViewController alloc] init];
    inviteViewController.fromClass = NO;
    [self.navigationController pushViewController:inviteViewController animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tmpArray count]+1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if ([newFriendsApply count] > 0)
        {
            return 28;
        }
        else
            return 0;
    }
    return 28;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 1, SCREEN_WIDTH-15, 26)];
        headerLabel.text = [NSString stringWithFormat:@"   好友申请"];
        headerLabel.backgroundColor = RGB(234, 234, 234, 1);
        headerLabel.font = [UIFont boldSystemFontOfSize:16];
        headerLabel.textColor = TITLE_COLOR;
        return headerLabel;
    }
    else
    {
        NSDictionary *groupDict = [tmpArray objectAtIndex:section-1];
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 1, SCREEN_WIDTH-15, 26)];
        headerLabel.text = [NSString stringWithFormat:@"   %@",[groupDict objectForKey:@"key"]];
        headerLabel.backgroundColor = RGB(234, 234, 234, 1);
        headerLabel.font = [UIFont boldSystemFontOfSize:16];
        headerLabel.textColor = TITLE_COLOR;
        return headerLabel;
    }
    return nil;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return [newFriendsApply count];
    }
    else
    {
        NSDictionary *groupDict = [tmpArray objectAtIndex:section-1];
        NSArray *array = [groupDict objectForKey:@"array"];
        return  [array count];
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        static NSString *friendsCell = @"newapplyCell";
        MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:friendsCell];
        if (cell == nil)
        {
            cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:friendsCell];
        }
        NSDictionary *friendDict = [newFriendsApply objectAtIndex:indexPath.row];
        
        cell.headerImageView.frame = CGRectMake(10, 7, 46, 46);
        cell.headerImageView.layer.cornerRadius = cell.headerImageView.frame.size.width/2;
        cell.headerImageView.clipsToBounds = YES;
        
        cell.unreadedMsgLabel.hidden = YES;
        
        [Tools fillImageView:cell.headerImageView withImageFromURL:[friendDict objectForKey:@"ficon"] andDefault:HEADERDEFAULT];
        
        cell.memNameLabel.frame = CGRectMake(70, 10, 150, 30);
        cell.memNameLabel.text = [friendDict objectForKey:@"fname"];
        
        cell.button1.hidden = NO;
        cell.button2.hidden = NO;
        [cell.button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cell.button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cell.button1 setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
        [cell.button2 setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
        cell.button1.frame = CGRectMake(SCREEN_WIDTH-120, 15, 50, 30);
        cell.button2.frame = CGRectMake(SCREEN_WIDTH-60, 15, 50, 30);
        
        [cell.button1 setTitle:@"同意" forState:UIControlStateNormal];
        cell.button1.tag =indexPath.section*1000 + indexPath.row;
        [cell.button1 addTarget:self action:@selector(addFriend:) forControlEvents:UIControlEventTouchUpInside];
        [cell.button2 setTitle:@"忽略" forState:UIControlStateNormal];
        cell.button2.tag = indexPath.section*1000 + indexPath.row;
        [cell.button2 addTarget:self action:@selector(refuseFriend:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *bgImageBG = [[UIImageView alloc] init];
        bgImageBG.image = [UIImage imageNamed:@"cell_bg"];
        cell.backgroundView = bgImageBG;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        static NSString *friendsCell = @"friendCell";
        MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:friendsCell];
        if (cell == nil)
        {
            cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:friendsCell];
        }
        NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
        NSArray *array = [groupDict objectForKey:@"array"];
        NSDictionary *friendDict = [array objectAtIndex:indexPath.row];
        
        cell.headerImageView.frame = CGRectMake(10, 7, 46, 46);
        cell.headerImageView.layer.cornerRadius = cell.headerImageView.frame.size.width/2;
        cell.headerImageView.clipsToBounds = YES;
        
        cell.unreadedMsgLabel.hidden = YES;
        [Tools fillImageView:cell.headerImageView withImageFromURL:[friendDict objectForKey:@"ficon"] andDefault:HEADERICON];
        
        cell.memNameLabel.frame = CGRectMake(70, 7, 150, 20);
        cell.memNameLabel.text = [friendDict objectForKey:@"fname"];
        
        UIImageView *bgImageBG = [[UIImageView alloc] init];
        bgImageBG.image = [UIImage imageNamed:@"cell_bg"];
        cell.backgroundView = bgImageBG;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        
    }
    else
    {
        NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
        NSArray *array = [groupDict objectForKey:@"array"];
        NSDictionary *dict = [array objectAtIndex:indexPath.row];
        
        [db updeteKey:@"readed" toValue:@"1" withParaDict:@{@"fid":[dict objectForKey:@"fid"]} andTableName:@"chatMsg"];
        [self dealNewChatMsg:nil];
        
        ChatViewController *chatViewController = [[ChatViewController alloc] init];
        chatViewController.name = [dict objectForKey:@"fname"];
        chatViewController.toID = [dict objectForKey:@"fid"];
        chatViewController.imageUrl = [dict objectForKey:@"ficon"];
        chatViewController.friendVcDel = self;
        [self.sideMenuController hideMenuAnimated:YES];
        [self.navigationController pushViewController:chatViewController animated:YES];

    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - friendsdelegate
-(void)updateFriendList:(BOOL)updata
{
    if (updata)
    {
        [self operateFriendsList:[db findSetWithDictionary:@{@"uid":[Tools user_id]} andTableName:FRIENDSTABLE] andDataType:@"database"];
    }
}

-(void)addFriend:(UIButton *)button
{
    NSDictionary *dict = [newFriendsApply objectAtIndex:button.tag%1000];
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"f_id":[dict objectForKey:@"fid"]
                                                                      } API:MB_ADD_FRIEND];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"addfriends responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([db updeteKey:@"checked" toValue:@"1" withParaDict:@{@"fid":[dict objectForKey:@"fid"],@"uid":[Tools user_id]} andTableName:FRIENDSTABLE])
                {
                    DDLOG(@"delete friend apply success");
                }
                [self operateFriendsList:[db findSetWithDictionary:@{@"uid":[Tools user_id]} andTableName:FRIENDSTABLE] andDataType:@"database"];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools hideProgress:self.bgView];
        }];
        [Tools showProgress:self.bgView];
        [request startAsynchronous];
    }

    
}
-(void)refuseFriend:(UIButton *)button
{
    NSDictionary *dict = [newFriendsApply objectAtIndex:button.tag%1000];
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"f_id":[dict objectForKey:@"fid"]
                                                                      } API:MB_REFUSE_FRIEND];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"refusefriends responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([db deleteRecordWithDict:@{@"fid":[dict objectForKey:@"fid"],@"uid":[Tools user_id]} andTableName:FRIENDSTABLE])
                {
                    DDLOG(@"delete friend apply success");
                }
                [self operateFriendsList:[db findSetWithDictionary:@{@"uid":[Tools user_id]} andTableName:FRIENDSTABLE] andDataType:@"database"];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools hideProgress:self.bgView];
        }];
        [Tools showProgress:self.bgView];
        [request startAsynchronous];
    }

}

#pragma mark - getFriendList
-(void)getFriendList
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token]                                                                     } API:MB_FRIENDLIST];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"friendsList responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if (![[responseDict objectForKey:@"data"] isEqual:[NSNull null]])
                {
                    NSArray *array = [responseDict objectForKey:@"data"];
                    [self operateFriendsList:array andDataType:@"network"];
                    
                    _reloading = NO;
                    [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:friendsListTableView];
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
            _reloading = NO;
            [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:friendsListTableView];
        }];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

-(void)operateFriendsList:(NSArray *)tmpFriendsList andDataType:(NSString *)datatype
{
    [newFriendsApply removeAllObjects];
    [tmpArray removeAllObjects];
    if ([tmpFriendsList count] > 0)
    {
        [db deleteRecordWithDict:@{@"uid":[Tools user_id]} andTableName:FRIENDSTABLE];
        if ([datatype isEqualToString:@"database"])
        {
            for (int i=0; i<[tmpFriendsList count]; ++i)
            {
                NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                NSDictionary *dict = [tmpFriendsList objectAtIndex:i];
                [tmpDict setObject:[Tools user_id] forKey:@"uid"];
                [tmpDict setObject:[dict objectForKey:@"fid"] forKey:@"fid"];
                [tmpDict setObject:[NSString stringWithFormat:@"%d",[[dict objectForKey:@"checked"] intValue]] forKey:@"checked"];
                [tmpDict setObject:[dict objectForKey:@"ficon"] forKey:@"ficon"];
                [tmpDict setObject:[dict objectForKey:@"fname"] forKey:@"fname"];
                [tmpDict setObject:@"" forKey:@"phone"];
                [db insertRecord:tmpDict andTableName:FRIENDSTABLE];
            }
        }
        else if([datatype isEqualToString:@"network"])
        {
            for (int i=0; i<[tmpFriendsList count]; ++i)
            {
                NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                NSDictionary *dict = [tmpFriendsList objectAtIndex:i];
                [tmpDict setObject:[Tools user_id] forKey:@"uid"];
                [tmpDict setObject:[dict objectForKey:@"_id"] forKey:@"fid"];
                [tmpDict setObject:[NSString stringWithFormat:@"%d",[[dict objectForKey:@"checked"] intValue]] forKey:@"checked"];
                [tmpDict setObject:[dict objectForKey:@"img_icon"] forKey:@"ficon"];
                [tmpDict setObject:[dict objectForKey:@"name"] forKey:@"fname"];
                [tmpDict setObject:@"" forKey:@"phone"];
                [db insertRecord:tmpDict andTableName:FRIENDSTABLE];
            }
        }
    }
    else
    {
        [db deleteRecordWithDict:@{@"uid":[Tools user_id]} andTableName:FRIENDSTABLE];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UCFRIENDSUM];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [newFriendsApply addObjectsFromArray:[db findSetWithDictionary:@{@"uid":[Tools user_id],@"checked":@"0"} andTableName:FRIENDSTABLE]];
    NSArray *tmpListArray = [db findSetWithDictionary:@{@"uid":[Tools user_id],@"checked":@"1"} andTableName:FRIENDSTABLE];
    [tmpArray addObjectsFromArray:[Tools getSpellSortArrayFromChineseArray:tmpListArray andKey:@"fname"]];
    [friendsListTableView reloadData];
    
    if ([newFriendsApply count] > 0 || [tmpArray count] > 0)
    {
        tipLabel.hidden = YES;
    }
    else
    {
        tipLabel.hidden = NO;
    }
}
@end

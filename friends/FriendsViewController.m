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

#import "SubGroupViewController.h"
#import "PersonDetailViewController.h"

#define MinSortCount 20

@interface FriendsViewController ()<UITableViewDataSource,
UITableViewDelegate,
EGORefreshTableHeaderDelegate,
ChatDelegate,
MsgDelegate,FriendListDelegate,
OperateFriends>
{
    UITableView *friendsListTableView;
    NSMutableArray *tmpArray;
    NSMutableArray *newFriendsApply;
    
    EGORefreshTableHeaderView *pullRefreshView;
    BOOL _reloading;
    
    NSMutableArray *newMessageArray;
    
    OperatDB *db;
    UILabel *tipLabel;
    
    NSMutableArray *groupChatArray;
    NSMutableArray *tmpListArray;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFriendList) name:UPDATEFRIENDSLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFriendList) name:UPDATEGROUPCHATLIST object:nil];
    
    db = [[OperatDB alloc] init];
    
    newMessageArray = [[NSMutableArray alloc] initWithCapacity:0];
    groupChatArray = [[NSMutableArray alloc] initWithCapacity:0];
    tmpListArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    newFriendsApply = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.backButton setHidden:YES];
    
    friendsListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    friendsListTableView.delegate = self;
    friendsListTableView.dataSource = self;
    friendsListTableView.backgroundColor = [UIColor clearColor];
    friendsListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    friendsListTableView.sectionIndexTrackingBackgroundColor=[UIColor grayColor];
    if (SYSVERSION>=7)
    {
        friendsListTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }

    [self.bgView addSubview:friendsListTableView];
    
    _reloading = NO;
    pullRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:friendsListTableView orientation:EGOPullOrientationDown];
    pullRefreshView.delegate = self;
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(5, self.backButton.frame.origin.y, 42, NAV_RIGHT_BUTTON_HEIGHT);;
    [moreButton setImage:[UIImage imageNamed:@"icon_list"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreOpen) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:moreButton];
    
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setTitle:@"邀请" forState:UIControlStateNormal];
    [inviteButton setTitleColor:RightCornerTitleColor forState:UIControlStateNormal];
    inviteButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [inviteButton addTarget:self action:@selector(inviteClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:inviteButton];
    
    
    tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(40, CENTER_POINT.y-80, SCREEN_WIDTH-80, 80);
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textColor = TITLE_COLOR;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = @"您还没有好友";
    tipLabel.hidden = YES;
    [friendsListTableView addSubview:tipLabel];
    
    [self getData];
}

-(void)getData
{
    if([Tools NetworkReachable])
    {
//        NSArray *array = [db findSetWithDictionary:@{@"uid":[Tools user_id]} andTableName:FRIENDSTABLE];
//        [self operateFriendsList:array andDataType:@"database"];
        [self getFriendList];
    }
    else
    {
        [self operateFriendsList:[db findSetWithDictionary:@{@"uid":[Tools user_id]} andTableName:FRIENDSTABLE] andDataType:@"database"];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = self;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = self;
    if ([self haveNewMsg] || [self haveNewNotice])
    {
        self.unReadLabel.hidden = NO;
    }
    else
    {
        self.unReadLabel.hidden = YES;
    }
}
-(void)dealloc
{
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = nil;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATEGROUPCHATLIST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATEFRIENDSLIST object:nil];
}
-(BOOL)haveNewMsg
{
    NSMutableArray *array = [db findSetWithDictionary:@{@"readed":@"0",@"userid":[Tools user_id]} andTableName:@"chatMsg"];
    if ([array count] > 0 ||
        [[[NSUserDefaults standardUserDefaults] objectForKey:NewChatMsgNum] integerValue]>0 ||
        [[[NSUserDefaults standardUserDefaults] objectForKey:NewClassNum] integerValue]>0)
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
    if ([[Tools user_id] length] == 0)
    {
        return ;
    }
    [self getFriendList];
}

#pragma mark -chatDelegate
-(void)dealNewChatMsg:(NSDictionary *)dict
{
    if ([[Tools user_id] length] == 0)
    {
        return ;
    }
    [self viewWillAppear:YES];
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
    if ([tmpListArray count] > 0 && [tmpListArray count] < MinSortCount)
    {
        return 0;
    }
    if (section == 0)
    {
        return 0;
    }
    return 26.5;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([tmpListArray count] > MinSortCount)
    {
        NSMutableArray *sectionArray = [[NSMutableArray alloc] initWithCapacity:0];
       NSArray *letters = [NSArray arrayWithObjects:@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z", nil];
        [sectionArray addObject:@"*"];
        for (int i=0; i<[letters count]; ++i)
        {
            NSString *letter = [letters objectAtIndex:i];
            for (int j=0; j<[tmpArray count]; ++j)
            {
                NSString *first = [[tmpArray objectAtIndex:j] objectForKey:@"key"];
                if ([letter isEqualToString:first])
                {
                    if (![sectionArray containsObject:letter])
                    {
                        [sectionArray addObject:letter];
                    }
                }
            }
        }
        [sectionArray addObject:@"#"];
        return sectionArray;
    }
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([tmpListArray count] > 0 && [tmpListArray count] < MinSortCount)
    {
        return nil;
    }
    if (section > 0)
    {
        NSDictionary *groupDict = [tmpArray objectAtIndex:section-1];
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 1, SCREEN_WIDTH-15, 26)];
        headerLabel.text = [NSString stringWithFormat:@"   %@",[groupDict objectForKey:@"key"]];
        headerLabel.backgroundColor = RGB(196, 192, 200, 1);
        headerLabel.font = [UIFont systemFontOfSize:14];
        headerLabel.textColor = [UIColor whiteColor];
        return headerLabel;
    }
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 2;
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
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0 && [newFriendsApply count] > 0)
        {
            return 52;
        }
        else if (indexPath.row == 1 && [groupChatArray count] > 0)
        {
            return 52;
        }
        return 0;
    }
    return 50;
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
        if (indexPath.row == 0 && [newFriendsApply count] > 0)
        {
            
            static NSString *studentCell = @"newapply";
            MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:studentCell];
            if (cell == nil)
            {
                cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:studentCell];
            }
            
            CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
            UIImageView *lineImageView = [[UIImageView alloc] init];
            lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0);
            lineImageView.backgroundColor = LineBackGroudColor;
            [cell.contentView addSubview:lineImageView];
            
            cell.contentView.backgroundColor = [UIColor whiteColor];
            if (indexPath.row < [friendsListTableView numberOfRowsInSection:indexPath.section]-1)
            {
                lineImageView.frame = CGRectMake( 60, cellHeight-0.5, cell.frame.size.width, 0);
            }
            
            cell.headerImageView.hidden = YES;
            cell.headerImageView.layer.cornerRadius = 3;
            cell.headerImageView.clipsToBounds = YES;
            cell.remarkLabel.hidden = NO;
            cell.button2.hidden = YES;
            cell.memNameLabel.text = nil;
            cell.remarkLabel.text = nil;
            cell.memNameLabel.frame = CGRectMake(60, 15, 130, 30);
            
            cell.markView.frame = CGRectMake(10, 10, 40, 40);
            cell.markView.layer.cornerRadius = 3;
            cell.markView.clipsToBounds = YES;
            
            if (indexPath.row == 0)
            {
                if ([newFriendsApply count] > 0)
                {
                    cell.headerImageView.hidden = NO;
                    cell.headerImageView.frame = CGRectMake(87, 20, 22, 20);
                    [cell.headerImageView setImage:[UIImage imageNamed:@"newapplyheader"]];
                    
                    cell.contentLabel.frame = CGRectMake(75, 8.5, 178, 47);
                    cell.contentLabel.layer.cornerRadius = 8;
                    cell.contentLabel.clipsToBounds = YES;
                    cell.contentLabel.hidden = NO;
                    cell.contentLabel.backgroundColor = [UIColor whiteColor];
                    cell.contentLabel.layer.borderColor = TIMECOLOR.CGColor;
                    cell.contentLabel.layer.borderWidth = 0.3;
                    
                    cell.memNameLabel.hidden = NO;
                    cell.memNameLabel.textColor = COMMENTCOLOR;
                    cell.memNameLabel.frame = CGRectMake(120, 16, 105, 30);
                    cell.memNameLabel.text = [NSString stringWithFormat:@"%d个新申请",(int)[newFriendsApply count]];
                    
                    cell.markView.frame = CGRectMake(226, 25, 8, 12);
                    [cell.markView setImage:[UIImage imageNamed:@"discovery_arrow"]];
                    cell.markView.hidden = NO;
                    cell.backgroundColor = self.bgView.backgroundColor;
                }
                else
                {
                    cell.memNameLabel.hidden = YES;
                    cell.markView.hidden = YES;
                    cell.remarkLabel.hidden = YES;
                    cell.headerImageView.hidden = YES;
                    cell.contentLabel.hidden = YES;
                }
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                return cell;
            }
        }
        
        else  if(indexPath.row == 1 && [groupChatArray count] > 0)
        {
            cell.headerImageView.hidden = NO;
            cell.headerImageView.frame = CGRectMake(14, 9, 34, 34);
            [cell.headerImageView setImage:[UIImage imageNamed:@"groupchatheader"]];
            
            cell.contentLabel.frame = CGRectMake(60, 1.5, 178, 47);
            cell.contentLabel.hidden = NO;
            cell.contentLabel.backgroundColor = [UIColor whiteColor];
            
            cell.memNameLabel.frame = CGRectMake(60, 11, 115, 30);
            cell.memNameLabel.hidden = NO;
            cell.memNameLabel.text = [NSString stringWithFormat:@"群聊(%d)",[groupChatArray count]];
            
            cell.markView.frame = CGRectMake(SCREEN_WIDTH-20, 19, 8, 12);
            [cell.markView setImage:[UIImage imageNamed:@"discovery_arrow"]];
            cell.markView.hidden = NO;
        }
        else
        {
            cell.headerImageView.hidden = YES;
            cell.contentLabel.hidden = YES;
            cell.memNameLabel.hidden = YES;
            cell.markView.hidden = YES;
        }
        CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
        UIImageView *lineImageView = [[UIImageView alloc] init];
        lineImageView.frame = CGRectMake(60, cellHeight-0.5, cell.frame.size.width, 0.5);
        lineImageView.backgroundColor = LineBackGroudColor;
        [cell.contentView addSubview:lineImageView];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
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
        
        CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
        UIImageView *lineImageView = [[UIImageView alloc] init];
        lineImageView.frame = CGRectMake(60, cellHeight-0.5, cell.frame.size.width, 0.5);
        lineImageView.backgroundColor = LineBackGroudColor;
        [cell.contentView addSubview:lineImageView];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1 && [tmpListArray count] > MinSortCount)
        {
            lineImageView.frame = CGRectMake( 0, cellHeight-0.5, cell.frame.size.width, 0.5);
        }
        NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
        NSArray *array = [groupDict objectForKey:@"array"];
        NSDictionary *friendDict = [array objectAtIndex:indexPath.row];
        
        cell.headerImageView.frame = CGRectMake(14, 7, 34, 34);
        cell.headerImageView.layer.cornerRadius = 5;
        cell.headerImageView.clipsToBounds = YES;
        
        cell.unreadedMsgLabel.hidden = YES;
        [Tools fillImageView:cell.headerImageView withImageFromURL:[friendDict objectForKey:@"ficon"] imageWidth:68 andDefault:HEADERICON];
        
        cell.memNameLabel.frame = CGRectMake(60, 10, 150, 30);
        cell.memNameLabel.text = [friendDict objectForKey:@"fname"];
        return cell;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            SubGroupViewController *newApplyVC = [[SubGroupViewController alloc] init];
            newApplyVC.titleString = @"好友申请";
            newApplyVC.tmpArray = newFriendsApply;
            newApplyVC.operateFriDel = self;
            [self.navigationController pushViewController:newApplyVC animated:YES];
        }
        else if(indexPath.row == 1)
        {
            SubGroupViewController *newApplyVC = [[SubGroupViewController alloc] init];
            newApplyVC.titleString = @"群聊";
            newApplyVC.tmpArray = groupChatArray;
            newApplyVC.operateFriDel = self;
            [self.navigationController pushViewController:newApplyVC animated:YES];
        }
    }
    else
    {
        NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
        NSArray *array = [groupDict objectForKey:@"array"];
        NSDictionary *dict = [array objectAtIndex:indexPath.row];
        
        PersonDetailViewController *personDetailVC = [[PersonDetailViewController alloc] init];
        personDetailVC.personName = [dict objectForKey:@"fname"];
        personDetailVC.personID = [dict objectForKey:@"fid"];
        [self.sideMenuController hideMenuAnimated:YES];
        [self.navigationController pushViewController:personDetailVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - operatefrienddel
-(void)updataFriends:(BOOL)uperate
{
    if (uperate)
    {
        [self getFriendList];
    }
}

#pragma mark - friendsdelegate
-(void)updateFriendList:(BOOL)updata
{
    if (updata)
    {
        [self operateFriendsList:[db findSetWithDictionary:@{@"uid":[Tools user_id]} andTableName:FRIENDSTABLE] andDataType:@"database"];
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
            DDLOG(@"friendsList responsedict %@",responseString);
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
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        [request setFailedBlock:^{
            [Tools hideProgress:self.bgView];
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            _reloading = NO;
            [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:friendsListTableView];
        }];
        [Tools showProgress:self.bgView];
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
    [groupChatArray removeAllObjects];
    [tmpListArray removeAllObjects];
    DDLOG(@"dict+++ %@",tmpFriendsList);
    if ([tmpFriendsList count] > 0)
    {
        if ([db deleteRecordWithDict:@{@"uid":[Tools user_id]} andTableName:FRIENDSTABLE])
        {
            DDLOG(@"clear chat success!");
        }
        if ([datatype isEqualToString:@"database"])
        {
            for (int i=0; i < [tmpFriendsList count]; ++i)
            {
                NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                NSDictionary *dict = [tmpFriendsList objectAtIndex:i];
                [tmpDict setObject:[Tools user_id] forKey:@"uid"];
                [tmpDict setObject:[dict objectForKey:@"cgroup"] forKey:@"cgroup"];
                [tmpDict setObject:[dict objectForKey:@"fid"] forKey:@"fid"];
                [tmpDict setObject:[NSString stringWithFormat:@"%d",[[dict objectForKey:@"checked"] intValue]] forKey:@"checked"];
                [tmpDict setObject:[dict objectForKey:@"ficon"] forKey:@"ficon"];
                [tmpDict setObject:[dict objectForKey:@"fname"] forKey:@"fname"];
                [tmpDict setObject:@"" forKey:@"phone"];
                [db insertRecord:tmpDict andTableName:FRIENDSTABLE];
                
                
                
                NSDictionary *userIconDict = @{@"uid":[dict objectForKey:@"_id"],
                                               @"uicon":[dict objectForKey:@"img_icon"],
                                               @"username":[dict objectForKey:@"name"],
                                               @"unum":[dict objectForKey:@"number"]};
                
                if ([[db findSetWithDictionary:@{@"unum":[dict objectForKey:@"number"]} andTableName:USERICONTABLE] count] > 0)
                {
                    if ([db deleteRecordWithDict:@{@"unum":[dict objectForKey:@"number"]} andTableName:USERICONTABLE])
                    {
                        [db insertRecord:userIconDict andTableName:USERICONTABLE];
                    }
                    
                }
                else
                {
                    [db insertRecord:userIconDict andTableName:USERICONTABLE];
                }

            }
        }
        else if([datatype isEqualToString:@"network"])
        {
            for (int i=0; i < [tmpFriendsList count]; ++i)
            {
                NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                NSDictionary *dict = [tmpFriendsList objectAtIndex:i];
                DDLOG(@"dict+++ %@",dict);
                
                [tmpDict setObject:[Tools user_id] forKey:@"uid"];
                [tmpDict setObject:[dict objectForKey:@"cgroup"] forKey:@"cgroup"];
                [tmpDict setObject:[dict objectForKey:@"_id"] forKey:@"fid"];
                [tmpDict setObject:[NSString stringWithFormat:@"%d",[[dict objectForKey:@"checked"] intValue]] forKey:@"checked"];
                if ([dict objectForKey:@"img_icon"])
                {
                    [tmpDict setObject:[dict objectForKey:@"img_icon"] forKey:@"ficon"];
                }
                
                [tmpDict setObject:[dict objectForKey:@"name"] forKey:@"fname"];
                [tmpDict setObject:@"" forKey:@"phone"];
                [db insertRecord:tmpDict andTableName:FRIENDSTABLE];
                
                
                if ([dict objectForKey:@"number"] &&
                    [dict objectForKey:@"_id"] &&
                    [dict objectForKey:@"img_icon"])
                {
                    NSDictionary *userIconDict = @{@"uid":[dict objectForKey:@"_id"],
                                                   @"uicon":[dict objectForKey:@"img_icon"],
                                                   @"username":[dict objectForKey:@"name"],
                                                   @"unum":[dict objectForKey:@"number"]};
                    
                    if ([[db findSetWithDictionary:@{@"unum":[dict objectForKey:@"number"]} andTableName:USERICONTABLE] count] > 0)
                    {
                        if ([db deleteRecordWithDict:@{@"unum":[dict objectForKey:@"number"]} andTableName:USERICONTABLE])
                        {
                            [db insertRecord:userIconDict andTableName:USERICONTABLE];
                        }
                    }
                    else
                    {
                        [db insertRecord:userIconDict andTableName:USERICONTABLE];
                    }
                }
            }
        }
    }
    else
    {
        if ([db deleteRecordWithDict:@{@"uid":[Tools user_id]} andTableName:FRIENDSTABLE])
        {
            DDLOG(@"clear chat success!");
        }
    }
    [newFriendsApply addObjectsFromArray:[db findSetWithDictionary:@{@"uid":[Tools user_id],@"checked":@"0",@"cgroup":@"0"} andTableName:FRIENDSTABLE]];
    [groupChatArray addObjectsFromArray:[db findSetWithDictionary:@{@"uid":[Tools user_id],@"cgroup":@"1"} andTableName:FRIENDSTABLE]];
    tmpListArray = [db findSetWithDictionary:@{@"uid":[Tools user_id],@"checked":@"1",@"cgroup":@"0"} andTableName:FRIENDSTABLE];

    [tmpArray addObjectsFromArray:[Tools getSpellSortArrayFromChineseArray:tmpListArray andKey:@"fname"]];
    
    [friendsListTableView reloadData];
    
    [Tools hideProgress:self.bgView];
    
    if ([newFriendsApply count] > 0 || [tmpArray count] > 0 || [groupChatArray count] > 0)
    {
        tipLabel.hidden = YES;
    }
    else
    {
        tipLabel.hidden = NO;
    }
}
@end

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

@interface FriendsViewController ()<UITableViewDataSource,
UITableViewDelegate,
EGORefreshTableHeaderDelegate,
ChatDelegate>
{
    UITableView *friendsListTableView;
    NSMutableArray *tmpArray;
    
    EGORefreshTableHeaderView *pullRefreshView;
    BOOL _reloading;
    
    NSMutableArray *newMessageArray;
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
    
    newMessageArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.backButton setHidden:YES];
    
    friendsListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    friendsListTableView.delegate = self;
    friendsListTableView.dataSource = self;
    friendsListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:friendsListTableView];
    
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
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *unfriendsnum = [ud objectForKey:@"ucfriendsnum"];
    if ([unfriendsnum integerValue] > 0)
    {
        [self getFriendList];
    }
    else
    {
        [self getFriendCache];
    }
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
-(BOOL)haveNewMsg
{
    OperatDB *db = [[OperatDB alloc] init];
    NSMutableArray *array = [db findSetWithDictionary:@{@"readed":@"0"} andTableName:@"chatMsg"];
    if ([array count] > 0)
    {
        return YES;
    }
    return NO;
}
-(BOOL)haveNewNotice
{
    OperatDB *db = [[OperatDB alloc] init];
    NSMutableArray *array = [db findSetWithDictionary:@{@"readed":@"0",@"uid":[Tools user_id]} andTableName:@"notice"];
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

#pragma mark -chatDelegate
-(void)dealNewChatMsg:(NSDictionary *)dict
{
    [newMessageArray removeAllObjects];
    OperatDB *db = [[OperatDB alloc] init];
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
    OperatDB *db = [[OperatDB alloc] init];
    NSMutableArray *array = [db findSetWithDictionary:@{@"fid":fid,@"tid":[Tools user_id]} andTableName:@"chatMsg"];
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
    if (![self.sideMenuController isMenuVisible])
    {
        [self.sideMenuController showMenuAnimated:YES];
    }
    else
    {
        [self.sideMenuController hideMenuAnimated:YES];
    }
}

-(void)inviteClick
{
    InviteViewController *inviteViewController = [[InviteViewController alloc] init];
    [inviteViewController showSelfViewController:self];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tmpArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 28;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary *groupDict = [tmpArray objectAtIndex:section];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 1, SCREEN_WIDTH-15, 26)];
    headerLabel.text = [NSString stringWithFormat:@"   %@",[groupDict objectForKey:@"key"]];
    headerLabel.backgroundColor = RGB(207, 207, 209, 1);
    headerLabel.font = [UIFont boldSystemFontOfSize:16];
    headerLabel.textColor = [UIColor whiteColor];
    return headerLabel;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *groupDict = [tmpArray objectAtIndex:section];
    NSArray *array = [groupDict objectForKey:@"array"];
    return  [array count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *friendsCell = @"friendCell";
    MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:friendsCell];
    if (cell == nil)
    {
        cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:friendsCell];
    }
    NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section];
    NSArray *array = [groupDict objectForKey:@"array"];
    NSDictionary *friendDict = [array objectAtIndex:indexPath.row];
    
    cell.headerImageView.layer.cornerRadius = 5;
    cell.headerImageView.clipsToBounds = YES;
    
    cell.unreadedMsgLabel.hidden = YES;
    if ([self newMsgCountOfUser:[friendDict objectForKey:@"_id"]]>0)
    {
        cell.unreadedMsgLabel.hidden = NO;
        cell.unreadedMsgLabel.text = [NSString stringWithFormat:@"%d",[self newMsgCountOfUser:[friendDict objectForKey:@"_id"]]];
    }
    cell.contentLabel.hidden = NO;
    NSDictionary *lastDict = [self findLastMsgWithUser:[friendDict objectForKey:@"_id"]];
    cell.contentLabel.text = [lastDict objectForKey:@"content"];
    
    [Tools fillImageView:cell.headerImageView withImageFromURL:[friendDict objectForKey:@"img_icon"] andDefault:HEADERDEFAULT];
    
    cell.memNameLabel.frame = CGRectMake(70, 10, 150, 30);
    cell.memNameLabel.text = [friendDict objectForKey:@"name"];
    cell.button1.hidden = YES;
    cell.button2.hidden = YES;
    if ([[friendDict objectForKey:@"checked"] integerValue] == 0)
    {
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
    }
    UIImageView *bgImageBG = [[UIImageView alloc] init];
    bgImageBG.image = [UIImage imageNamed:@"cell_bg"];
    cell.backgroundView = bgImageBG;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section];
    NSArray *array = [groupDict objectForKey:@"array"];
    NSDictionary *dict = [array objectAtIndex:indexPath.row];
    
    OperatDB *db = [[OperatDB alloc] init];
    [db updeteKey:@"readed" toValue:@"1" withParaDict:@{@"fid":[dict objectForKey:@"_id"]} andTableName:@"chatMsg"];
    [self dealNewChatMsg:nil];
    
    ChatViewController *chatViewController = [[ChatViewController alloc] init];
    chatViewController.name = [dict objectForKey:@"name"];
    chatViewController.toID = [dict objectForKey:@"_id"];
    chatViewController.imageUrl = [dict objectForKey:@"img_icon"];
    self.sideMenuController.panGestureEnabled = NO;
    [self.sideMenuController hideMenuAnimated:YES];
    [chatViewController showSelfViewController:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)addFriend:(UIButton *)button
{
    NSDictionary *groupDict = [tmpArray objectAtIndex:button.tag/1000];
    NSArray *array = [groupDict objectForKey:@"array"];
    NSDictionary *dict = [array objectAtIndex:button.tag%1000];
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"f_id":[dict objectForKey:@"_id"]
                                                                      } API:MB_ADD_FRIEND];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"addfriends responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [self getFriendList];
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
    NSDictionary *groupDict = [tmpArray objectAtIndex:button.tag/1000];
    NSArray *array = [groupDict objectForKey:@"array"];
    NSDictionary *dict = [array objectAtIndex:button.tag%1000];
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"f_id":[dict objectForKey:@"_id"]
                                                                      } API:MB_REFUSE_FRIEND];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"refusefriends responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [self getFriendList];
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
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"friendsList responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if (![[responseDict objectForKey:@"data"] isEqual:[NSNull null]])
                {
                    [tmpArray removeAllObjects];
                    
                    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@",MB_FRIENDLIST,[Tools user_id]];
                    NSString *key = [requestUrlStr MD5Hash];
                    [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
                    
                    NSArray *array = [responseDict objectForKey:@"data"];
                    [tmpArray addObjectsFromArray:[Tools getSpellSortArrayFromChineseArray:array andKey:@"name"]];
                    [friendsListTableView reloadData];
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
            [Tools hideProgress:self.bgView];
        }];
        [Tools showProgress:self.bgView];
        [request startAsynchronous];
    }
}

-(void)getFriendCache
{
    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@",MB_FRIENDLIST,[Tools user_id]];
    NSString *key = [requestUrlStr MD5Hash];
    NSData *cacheData = [FTWCache objectForKey:key];
    if ([cacheData length] > 0)
    {
        NSString *responseString = [[NSString alloc] initWithData:cacheData encoding:NSUTF8StringEncoding];
        NSDictionary *responseDict = [Tools JSonFromString:responseString];
        if ([[responseDict objectForKey:@"code"] intValue]== 1)
        {
            if (![[responseDict objectForKey:@"data"] isEqual:[NSNull null]])
            {
                NSArray *array = [responseDict objectForKey:@"data"];
                [tmpArray addObjectsFromArray:[Tools getSpellSortArrayFromChineseArray:array  andKey:@"name"]];
                [self dealNewChatMsg:nil];
            }
        }
        else
        {
            [Tools dealRequestError:responseDict fromViewController:self];
        }
    }
    else
    {
        [self getFriendList];
    }
}

@end

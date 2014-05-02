//
//  MessageViewController.m
//  School
//
//  Created by TeekerZW on 1/14/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "MessageViewController.h"
#import "XDContentViewController+JDSideMenu.h"
#import "Header.h"
#import "FriendsCell.h"
#import "AppDelegate.h"
#import "ChatViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "MemberCell.h"

#import "ClassZoneViewController.h"
#import "NotificationViewController.h"
#import "ClassMemberViewController.h"
#import "MoreViewController.h"
#import "XDTabViewController.h"

#import "ClassZoneViewController.h"
#import "ClassMemberViewController.h"
#import "NotificationViewController.h"

#define CHATMSGTAG  2000
#define NOTICETAG  3000
#define REPLAYTAG  10000

@interface MessageViewController ()<UITableViewDataSource,UITableViewDelegate,ChatDelegate,EGORefreshTableHeaderDelegate>
{
    UITableView *friendsListTableView;
    NSMutableArray *chatFriendArray;
    NSMutableArray *newMessageArray;
    
    EGORefreshTableHeaderView *pullRefreshView;
    BOOL _reloading;
    
    OperatDB *db;
}
@end

@implementation MessageViewController

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
    
    self.titleLabel.text = @"私聊";
    [[self.bgView layer] setShadowOffset:CGSizeMake(-5.0f, 5.0f)];
    [[self.bgView layer] setShadowColor:[UIColor darkGrayColor].CGColor];
    [[self.bgView layer] setShadowOpacity:1.0f];
    [[self.bgView layer] setShadowRadius:3.0f];
    self.returnImageView.hidden = YES;
    
    db = [[OperatDB alloc] init];
    
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = self;

    
    [self.backButton setHidden:YES];
    
    newMessageArray = [[NSMutableArray alloc] initWithCapacity:0];
    chatFriendArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(5, 4, 42, 34);
    [moreButton setImage:[UIImage imageNamed:@"icon_list"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreOpen) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:moreButton];
    
    friendsListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    friendsListTableView.delegate = self;
    friendsListTableView.dataSource = self;
    friendsListTableView.tag = CHATMSGTAG;
    friendsListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:friendsListTableView];
    
    pullRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:friendsListTableView orientation:EGOPullOrientationDown];
    pullRefreshView.delegate = self;
    
    [self getChatList];
    
//    [self dealNewChatMsg:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)getChatList
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],@"token":[Tools client_token]} API:GETCHATLIST];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"newchatlist responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
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
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }

}

#pragma mark -chatDelegate
-(void)dealNewChatMsg:(NSDictionary *)dict
{
    [chatFriendArray removeAllObjects];
    [chatFriendArray addObjectsFromArray:[db findChatUseridWithTableName:@"chatMsg"]];
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
    NSMutableArray *array = [db findSetWithDictionary:@{@"fid":fid,@"tid":[Tools user_id]} andTableName:@"chatMsg"];
    return [array lastObject];
}

#pragma mark - egodelegate
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self dealNewChatMsg:nil];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - chatdelegate

#pragma mark - tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [chatFriendArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString *chatCell = @"chatcell";
        MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:chatCell];
        if (cell == nil)
        {
            cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:chatCell];
        }
        NSDictionary *dict = [chatFriendArray objectAtIndex:indexPath.row];
        cell.headerImageView.frame = CGRectMake(10, 5, 50, 50);
        [Tools fillImageView:cell.headerImageView withImageFromURL:[dict objectForKey:@"ficon"] andDefault:HEADERDEFAULT];
        cell.headerImageView.layer.cornerRadius = 5;
        cell.headerImageView.clipsToBounds = YES;
        
        cell.memNameLabel.frame = CGRectMake(70, 7, 150, 30);
        cell.memNameLabel.text = [dict objectForKey:@"fname"];
        cell.unreadedMsgLabel.hidden = YES;
        if ([self newMsgCountOfUser:[dict objectForKey:@"fid"]]>0)
        {
            cell.unreadedMsgLabel.hidden = NO;
            cell.unreadedMsgLabel.text = [NSString stringWithFormat:@"%d",[self newMsgCountOfUser:[dict objectForKey:@"fid"]]];
        }
        cell.contentLabel.hidden = NO;
        NSDictionary *lastDict = [self findLastMsgWithUser:[dict objectForKey:@"fid"]];
        cell.contentLabel.text = [lastDict objectForKey:@"content"];
        UIImageView *bgImageBG = [[UIImageView alloc] init];
        bgImageBG.image = [UIImage imageNamed:@"cell_bg"];
        cell.backgroundView = bgImageBG;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [chatFriendArray objectAtIndex:indexPath.row];
    
    [db updeteKey:@"readed" toValue:@"1" withParaDict:@{@"fid":[dict objectForKey:@"fid"]} andTableName:@"chatMsg"];
    [self dealNewChatMsg:nil];
    
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.name = [dict objectForKey:@"fname"];
    chat.toID = [dict objectForKey:@"fid"];
    chat.imageUrl = [dict objectForKey:@"ficon"];
    [chat showSelfViewController:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
@end

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

#import "NSString+Emojize.h"

#import "UINavigationController+JDSideMenu.h"

#define CHATMSGTAG  2000
#define NOTICETAG  3000
#define REPLAYTAG  10000

@interface MessageViewController ()<
UITableViewDataSource,
UITableViewDelegate,
ChatDelegate,
MsgDelegate,
EGORefreshTableHeaderDelegate,
ChatVCDelegate>
{
    UITableView *friendsListTableView;
    NSMutableArray *chatFriendArray;
    
    UILabel *tipLabel;
    
    NSMutableArray *newMessageArray;
    
    EGORefreshTableHeaderView *pullRefreshView;
    BOOL _reloading;
    
    OperatDB *db;
    
    UIButton *editButton;
    BOOL edittingTableView;
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
    
    self.titleLabel.text = @"聊天记录";
    [[self.bgView layer] setShadowOffset:CGSizeMake(-5.0f, 5.0f)];
    [[self.bgView layer] setShadowColor:[UIColor darkGrayColor].CGColor];
    [[self.bgView layer] setShadowOpacity:1.0f];
    [[self.bgView layer] setShadowRadius:3.0f];
    self.returnImageView.hidden = YES;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:NewChatMsgNum];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    edittingTableView = NO;
    editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    editButton.backgroundColor = [UIColor clearColor];
    [editButton setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editTableView) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:editButton];

    
    db = [[OperatDB alloc] init];
    
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
    friendsListTableView.backgroundColor = [UIColor clearColor];
    friendsListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:friendsListTableView];
    
    _reloading = NO;
    pullRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:friendsListTableView orientation:EGOPullOrientationDown];
    pullRefreshView.delegate = self;
    
    tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(40, 100, SCREEN_WIDTH-80, 80);
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textColor = TITLE_COLOR;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = @"您还没有消息记录";
    tipLabel.hidden = YES;
    [friendsListTableView addSubview:tipLabel];
    
    [self manageChatList];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).ChatDelegate = self;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = self;
    
    [self dealNewChatMsg:nil];
    [self dealNewMsg:nil];

}

-(void)dealloc
{
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).ChatDelegate = nil;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = nil;
}

-(void)dealNewMsg:(NSDictionary *)dict
{
    if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"checked":@"0"} andTableName:FRIENDSTABLE] count] > 0)
    {
        self.unReadLabel.hidden = NO;
    }
}
-(void)getChatList
{
    DDLOG_CURRENT_METHOD;
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],@"token":[Tools client_token]} API:GETCHATLIST];
        
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"newchatlist responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([[responseDict objectForKey:@"data"] isKindOfClass:[NSDictionary class]])
                {
                    NSArray *array = [[responseDict objectForKey:@"data"] allValues];
                    for (int i=0; i<[array count]; ++i)
                    {
                        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                        NSDictionary *dict = [array objectAtIndex:i];
                        [tmpDict setObject:[dict objectForKey:@"tid"] forKey:@"fid"];
                        if ([dict objectForKey:@"img_icon"])
                        {
                            [tmpDict setObject:[dict objectForKey:@"img_icon"] forKey:@"ficon"];
                        }
                        if ([dict objectForKey:@"r_name"])
                        {
                            [tmpDict setObject:[dict objectForKey:@"r_name"] forKey:@"fname"];
                        }
                        NSString *mid = [[dict objectForKey:@"l_n"] objectForKey:@"_id"];
                        [tmpDict setObject:mid forKey:@"mid"];
                        [tmpDict setObject:[[dict objectForKey:@"l_n"] objectForKey:@"msg"] forKey:@"content"];
                        [tmpDict setObject:[[dict objectForKey:@"l_n"] objectForKey:@"t"] forKey:@"time"];
                        [tmpDict setObject:@"0" forKey:@"readed"];
                        [tmpDict setObject:@"f" forKey:@"direct"];
                        [tmpDict setObject:[Tools user_id] forKey:@"userid"];
                        [tmpDict setObject:@"text" forKey:@"msgType"];
                        [tmpDict setObject:[Tools user_id] forKey:@"tid"];
                        
                        if ([[db findSetWithDictionary:@{@"mid":mid,@"userid":[Tools user_id]} andTableName:CHATTABLE] count] <= 0)
                        {
                            if ([db insertRecord:tmpDict andTableName:@"chatMsg"])
                            {
                                DDLOG(@"new msg insert success!");
                            }
                            else
                            {
                                DDLOG(@"new msg insert failed!");
                            }
                        }
                    }
                }
                [self manageChatList];
                _reloading = NO;
                [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:friendsListTableView];
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

#pragma mark -chatDelegate
-(void)dealNewChatMsg:(NSDictionary *)dict
{
    if ([Tools NetworkReachable])
    {
        [self getChatList];
    }
    else
    {
        [self manageChatList];
    }
}

-(void)manageChatList
{
    
    [chatFriendArray removeAllObjects];
    [chatFriendArray addObjectsFromArray:[db findChatUseridWithTableName:CHATTABLE]];
    [friendsListTableView reloadData];
    if ([chatFriendArray count] > 0)
    {
        editButton.hidden = NO;
        tipLabel.hidden = YES;
    }
    else
    {
        editButton.hidden = YES;
        tipLabel.hidden = NO;
    }
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:NewChatMsgNum] integerValue] > 0)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:NewChatMsgNum];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(NSInteger)newMsgCountOfUser:(NSString *)fid
{
    NSArray *newMsgs = [db findSetWithDictionary:@{@"userid":[Tools user_id],@"fid":fid,@"readed":@"0"} andTableName:CHATTABLE];
    return [newMsgs count];
}

-(NSDictionary *)findLastMsgWithUser:(NSString *)fid
{
    NSMutableArray *array = [db findChatLogWithUid:[Tools user_id] andOtherId:fid andTableName:@"chatMsg"];
    return [array lastObject];
}

#pragma mark - egodelegate
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self getChatList];
//    [self dealNewChatMsg:nil];
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
-(void)editTableView
{
    if (edittingTableView)
    {
        friendsListTableView.editing = NO;
        [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    }
    else
    {
        friendsListTableView.editing = YES;
        [editButton setTitle:@"完成" forState:UIControlStateNormal];
    }
    edittingTableView = !edittingTableView;
}


-(NSString *)getNameFromString:(NSString *)text
{
    if (![text isEqual:[NSNull null]])
    {
        NSMutableString *tmpStr = [[NSMutableString alloc] initWithString:text];
        NSRange range1 = [tmpStr rangeOfString:@"["];
        if (range1.length>0)
        {
            [tmpStr deleteCharactersInRange:range1];
            
        }
        NSRange range2 = [tmpStr rangeOfString:@"]"];
        if (range2.length>0)
        {
            [tmpStr deleteCharactersInRange:range2];
        }
        return tmpStr;
    }
    return @"";
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [chatFriendArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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
    cell.headerImageView.frame = CGRectMake(10, 7, 46, 46);
    
    if (![[dict objectForKey:@"ficon"] isEqual:[NSNull null]])
    {
        if ([[dict objectForKey:@"ficon"] length] > 10)
        {
            [Tools fillImageView:cell.headerImageView withImageFromURL:[dict objectForKey:@"ficon"] andDefault:HEADERBG];
        }
        else
        {
            NSArray *array = [db findSetWithDictionary:@{@"uid":[dict objectForKey:@"fid"]} andTableName:CLASSMEMBERTABLE];
            if ([array count] > 0)
            {
                NSDictionary *memDict = [array firstObject];
                if (![[memDict objectForKey:@"img_icon"] isEqual:[NSNull null]])
                {
                    if ([[memDict objectForKey:@"img_icon"] length] >10)
                    {
                        [Tools fillImageView:cell.headerImageView withImageFromURL:[memDict objectForKey:@"img_icon"] andDefault:HEADERBG];
                    }
                    else
                    {
                        [cell.headerImageView setImage:[UIImage imageNamed:HEADERBG]];
                    }
                }
            }
        }
    }
    
    cell.headerImageView.layer.cornerRadius = cell.headerImageView.frame.size.width/2;
    cell.headerImageView.clipsToBounds = YES;
    
    cell.memNameLabel.frame = CGRectMake(70, 7, 150, 20);
    cell.memNameLabel.text = [self getNameFromString:[dict objectForKey:@"fname"]];
    cell.memNameLabel.textColor = [UIColor blackColor];
    cell.memNameLabel.font = [UIFont boldSystemFontOfSize:16];
    cell.unreadedMsgLabel.hidden = YES;
    
    if ([self newMsgCountOfUser:[dict objectForKey:@"fid"]] > 0)
    {
        cell.unreadedMsgLabel.text = [NSString stringWithFormat:@"%d",[self newMsgCountOfUser:[dict objectForKey:@"fid"]]];
        cell.unreadedMsgLabel.hidden = NO;
    }
    
    NSDictionary *lastMsgDict = [self findLastMsgWithUser:[dict objectForKey:@"fid"]];
    cell.contentLabel.hidden = NO;
    cell.contentLabel.font = [UIFont systemFontOfSize:14];
    cell.contentLabel.text = [[lastMsgDict  objectForKey:@"content"]emojizedString];
    if ([[lastMsgDict objectForKey:@"content"] rangeOfString:@"$!#"].length >0)
    {
        
        NSString *msgContent = [lastMsgDict objectForKey:@"content"];
        NSRange range = [msgContent rangeOfString:@"$!#"];
        cell.contentLabel.text = [msgContent substringFromIndex:range.location+range.length];
    }
   
    cell.remarkLabel.frame = CGRectMake(SCREEN_WIDTH-120, 7, 100, 15);
    cell.remarkLabel.font = [UIFont systemFontOfSize:10];
    cell.remarkLabel.hidden = NO;
    cell.remarkLabel.text = [Tools showTime:[dict objectForKey:@"time"]];

    UIImageView *bgImageBG = [[UIImageView alloc] init];
    bgImageBG.image = [UIImage imageNamed:@"cell_bg"];
    cell.backgroundView = bgImageBG;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = [chatFriendArray objectAtIndex:indexPath.row];
    
    [db updeteKey:@"readed" toValue:@"1" withParaDict:@{@"fid":[dict objectForKey:@"fid"],@"userid":[Tools user_id]} andTableName:@"chatMsg"];
    [self dealNewChatMsg:nil];
    
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.name = [self getNameFromString:[dict objectForKey:@"fname"]];
    chat.toID = [dict objectForKey:@"fid"];
    chat.imageUrl = [dict objectForKey:@"ficon"];
    chat.chatVcDel = self;
    chat.fromClass = NO;
    [self.navigationController pushViewController:chat animated:YES];
}

-(void)updateChatList:(BOOL)update
{
    if (update)
    {
        [self dealNewChatMsg:nil];
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [chatFriendArray objectAtIndex:indexPath.row];
//    DDLOG(@"dict == %@",dict);
    
    if ([db deleteRecordWithDict:@{@"userid":[Tools user_id],@"fid":[dict objectForKey:@"fid"]} andTableName:CHATTABLE])
    {
        DDLOG(@"delete chat log of %@ success",[dict objectForKey:@"fname"]);
    }
    [chatFriendArray removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
    [tableView reloadData];
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
@end

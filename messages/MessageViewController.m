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
    
    db = [[OperatDB alloc] init];
    
    edittingTableView = NO;
    editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    editButton.backgroundColor = [UIColor clearColor];
    [editButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editTableView) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:editButton];
    
    [self.backButton setHidden:YES];
    
    newMessageArray = [[NSMutableArray alloc] initWithCapacity:0];
    chatFriendArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(5, self.backButton.frame.origin.y, 42, NAV_RIGHT_BUTTON_HEIGHT);
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
    
    [self getChatList];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).ChatDelegate = self;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealNewChatMsg:) name:RECEIVENEWMSG object:nil];
    
    [self dealNewChatMsg:nil];
    [self dealNewMsg:nil];

}

-(void)dealloc
{
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).ChatDelegate = nil;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVENEWMSG object:nil];
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
                    [newMessageArray removeAllObjects];
                    
                    NSArray *tmpArray = [[responseDict objectForKey:@"data"] allValues];
                    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                    for (NSDictionary *dict in tmpArray)
                    {
                        [tmpDict setObject:[dict objectForKey:@"tid"] forKey:@"fid"];
                        [tmpDict setObject:[dict objectForKey:@"r_name"] forKey:@"fname"];
                        [tmpDict setObject:[Tools user_id] forKey:@"tid"];
                        [tmpDict setObject:[Tools user_id] forKey:@"userid"];
                        
                        NSDictionary *msgDict = [dict objectForKey:@"l_n"];
                        [tmpDict setObject:[msgDict objectForKey:@"msg"] forKey:@"content"];
                        [tmpDict setObject:[msgDict objectForKey:@"t"] forKey:@"time"];
                        [tmpDict setObject:[msgDict objectForKey:@"_id"] forKey:@"mid"];
                        [tmpDict setObject:@"f" forKey:@"direct"];
                        [tmpDict setObject:@"0" forKey:@"readed"];
                        if([[dict objectForKey:@"cgroup"] integerValue] == 1)
                        {
                            
                            [tmpDict setObject:[msgDict objectForKey:@"by"] forKey:@"by"];
                        }
                        
                        NSDictionary *userIconDict = @{@"uid":[dict objectForKey:@"tid"],
                                                       @"uicon":[dict objectForKey:@"img_icon"],
                                                       @"username":[dict objectForKey:@"r_name"]};
                        if ([[db findSetWithDictionary:@{@"uid":[dict objectForKey:@"tid"]} andTableName:USERICONTABLE] count] > 0)
                        {
                            [db deleteRecordWithDict:@{@"uid":[dict objectForKey:@"tid"]} andTableName:USERICONTABLE];
                            [db insertRecord:userIconDict andTableName:USERICONTABLE];
                        }
                        else
                        {
                            [db insertRecord:userIconDict andTableName:USERICONTABLE];
                        }
                        
                        if ([[db findSetWithDictionary:@{@"mid":[msgDict objectForKey:@"_id"],@"userid":[Tools user_id]} andTableName:CHATTABLE] count] == 0)
                        {
                            if ([db insertRecord:tmpDict  andTableName:CHATTABLE])
                            {
                                DDLOG(@"insert chat success in msg log");
                            }
                        }
                    }
                }
                [self dealNewChatMsg:nil];
                _reloading = NO;
                [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:friendsListTableView];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
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
    if(dict)
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
    else
    {
        [self manageChatList];
    }
}

-(void)manageChatList
{
    
    [newMessageArray removeAllObjects];
    [newMessageArray addObjectsFromArray:[db findChatUseridWithTableName:CHATTABLE]];
    [friendsListTableView reloadData];
    DDLOG(@"new msg array %@",newMessageArray);
    if ([newMessageArray count] > 0)
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

-(NSDictionary *)findLastMsgWithUser:(NSString *)fid
{
    NSMutableArray *array = [db findChatLogWithUid:[Tools user_id] andOtherId:fid andTableName:CHATTABLE];
    return [array lastObject];
}

-(int)findCountOfUserId:(NSString *)fid
{
    NSMutableArray *array = [db findSetWithDictionary:@{@"userid":[Tools user_id],@"fid":fid,@"readed":@"0"} andTableName:CHATTABLE];
    return [array count];
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
    return [newMessageArray count];
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
    CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
    UIImageView *lineImageView = [[UIImageView alloc] init];
    lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
    lineImageView.image = [UIImage imageNamed:@"sepretorline"];
    [cell.contentView addSubview:lineImageView];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    if (indexPath.row < [tableView numberOfRowsInSection:indexPath.section]-1)
    {
        lineImageView.frame = CGRectMake( 70, cellHeight-0.5, cell.frame.size.width, 0.5);
    }
//    NSDictionary *dict = [newMessageArray objectAtIndex:indexPath.row];
    NSString *otherid = [[[newMessageArray objectAtIndex:indexPath.row] allValues] firstObject];
    cell.headerImageView.frame = CGRectMake(10, 7, 46, 46);
    cell.headerImageView.layer.cornerRadius = 5;
    cell.headerImageView.clipsToBounds = YES;
    
    cell.memNameLabel.frame = CGRectMake(70, 7, 190, 20);
    cell.memNameLabel.textColor = TITLE_COLOR;
    cell.memNameLabel.font = [UIFont systemFontOfSize:16];
    cell.unreadedMsgLabel.hidden = YES;
    
   
    
    int unreadMsgCount = [self findCountOfUserId:otherid];
    if (unreadMsgCount > 0)
    {
        cell.unreadedMsgLabel.text = [NSString stringWithFormat:@"%d",unreadMsgCount];
        cell.unreadedMsgLabel.hidden = NO;
        cell.unreadedMsgLabel.backgroundColor = [UIColor redColor];
        [cell.contentView bringSubviewToFront:cell.unreadedMsgLabel];
    }
    else
    {
        cell.unreadedMsgLabel.hidden = YES;
    }
    
    NSDictionary *lastMsgDict = [self findLastMsgWithUser:otherid];
    
    NSDictionary *userIconDIct = [ImageTools iconDictWithUserID:otherid];
    DDLOG(@"%@==%@",otherid,[userIconDIct objectForKey:@"username"]);
    if(userIconDIct)
    {
        [Tools fillImageView:cell.headerImageView withImageFromURL:[userIconDIct objectForKey:@"uicon"] andDefault:HEADERICON];
        cell.memNameLabel.text = [userIconDIct objectForKey:@"username"];
        
        if (lastMsgDict)
        {
            cell.contentLabel.hidden = NO;
            cell.contentLabel.font = [UIFont systemFontOfSize:14];
            if (![[userIconDIct objectForKey:@"username"] isEqual:[NSNull null]] && [[userIconDIct objectForKey:@"username"] length] > 0  && [[userIconDIct objectForKey:@"username"] rangeOfString:@"人)"].length > 0)
            {
                NSDictionary *userIconDict = [ImageTools iconDictWithUserID:[lastMsgDict objectForKey:@"by"]];
                NSString *byName;
                if (userIconDict)
                {
                    byName = [userIconDict objectForKey:@"username"];
                }
                if ( !byName)
                {
                    if ([lastMsgDict objectForKey:@"byname"] && ![[lastMsgDict objectForKey:@"byname"] isEqual:[NSNull null]]) {
                        byName = [lastMsgDict objectForKey:@"byname"];
                    }
                }
                NSString *msgContent = [[lastMsgDict objectForKey:@"content"] emojizedString];
                if ([[msgContent pathExtension] isEqualToString:@"png"] || [[msgContent pathExtension] isEqualToString:@"jpg"])
                {
                    cell.contentLabel.text = [NSString stringWithFormat:@"%@:%@",byName,@"图片"];
                }
                else
                {
                    cell.contentLabel.text = [[NSString stringWithFormat:@"%@:%@",byName,[lastMsgDict objectForKey:@"content"]] emojizedString];
                }
            }
            else
            {
                NSString *msgContent = [[lastMsgDict objectForKey:@"content"] emojizedString];
                if ([[msgContent pathExtension] isEqualToString:@"png"] || [[msgContent pathExtension] isEqualToString:@"jpg"])
                {
                    cell.contentLabel.text = [NSString stringWithFormat:@"%@",@"一张图片"];
                }
                else
                {
                    cell.contentLabel.text = [[NSString stringWithFormat:@"%@",[lastMsgDict objectForKey:@"content"]] emojizedString];
                }
            }
        }
    }

    if ([[lastMsgDict objectForKey:@"content"] rangeOfString:@"$!#"].length >0)
    {
        NSString *msgContent = [lastMsgDict objectForKey:@"content"];
        NSRange range = [msgContent rangeOfString:@"$!#"];
        cell.contentLabel.text = [msgContent substringFromIndex:range.location+range.length];
    }
   
    cell.remarkLabel.frame = CGRectMake(SCREEN_WIDTH-60, 7, 50, 25);
    cell.remarkLabel.font = [UIFont systemFontOfSize:10];
    cell.remarkLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.remarkLabel.numberOfLines = 2;
    cell.remarkLabel.hidden = NO;
    cell.remarkLabel.text = [Tools showTime:[lastMsgDict objectForKey:@"time"]];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *otherid = [[[newMessageArray objectAtIndex:indexPath.row] allValues] firstObject];
   
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.toID = otherid;
    chat.chatVcDel = self;
    chat.fromClass = NO;
    
    NSDictionary *userIconDIct = [ImageTools iconDictWithUserID:otherid];
    if(userIconDIct)
    {
        if ([[userIconDIct objectForKey:@"username"] rangeOfString:@"人)"].length == 0)
        {
            chat.isGroup = NO;
        }
        else if([[userIconDIct objectForKey:@"username"] rangeOfString:@"人)"].length > 0)
        {
            chat.isGroup = YES;
        }
        chat.name = [userIconDIct objectForKey:@"username"];
        chat.imageUrl = [userIconDIct objectForKey:@"uicon"];
    }
    
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
    NSString *otherid = [[[newMessageArray objectAtIndex:indexPath.row] allValues] firstObject];
    
    if ([db deleteRecordWithDict:@{@"userid":[Tools user_id],@"fid":otherid,@"direct":@"f"} andTableName:CHATTABLE] &&
        [db deleteRecordWithDict:@{@"userid":[Tools user_id],@"tid":otherid,@"direct":@"t"} andTableName:CHATTABLE])
    {
        DDLOG(@"delete chat log  success");
    }
    [newMessageArray removeObjectAtIndex:indexPath.row];
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

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
    
    NSMutableDictionary *unreadCountDict;
    
    NSString *currentId;
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

-(void)uploadLastViewTime
{
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getChatList) name:UPDATE_MSG_LIST object:nil];
    
    db = [[OperatDB alloc] init];
    
    edittingTableView = NO;
    editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    editButton.backgroundColor = [UIColor clearColor];
    [editButton setTitleColor:RightCornerTitleColor forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editTableView) forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationBarView addSubview:editButton];
    
    [self.backButton setHidden:YES];
    
    newMessageArray = [[NSMutableArray alloc] initWithCapacity:0];
    chatFriendArray = [[NSMutableArray alloc] initWithCapacity:0];
    unreadCountDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
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
    [[StatusBarTips shareTipsWindow] hideTips];
    [super viewWillAppear:animated];
    [[NSUserDefaults standardUserDefaults] setObject:@"chat" forKey:@"viewtype"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    currentId = @"";
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] setObject:@"notchat" forKey:@"viewtype"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATE_MSG_LIST object:nil];
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
                [newMessageArray removeAllObjects];
                
                if ([[responseDict objectForKey:@"data"] isKindOfClass:[NSDictionary class]])
                {
                    NSArray *tmpArray = [[responseDict objectForKey:@"data"] allValues];
                    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                    for (int i=0;i<[tmpArray count];i++)
                    {
                        NSDictionary *dict = [tmpArray objectAtIndex:i];
                        if (currentId && ![currentId isEqualToString:[dict objectForKey:@"tid"]])
                        {
                            [unreadCountDict setObject:[NSString stringWithFormat:@"%d",[[dict objectForKey:@"new"] intValue]]
                                                forKey:[dict objectForKey:@"tid"]];
                        }
                        else if(!currentId)
                        {
                            [unreadCountDict setObject:[NSString stringWithFormat:@"%d",[[dict objectForKey:@"new"] intValue]]
                                                forKey:[dict objectForKey:@"tid"]];
                        }
                        
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
                        [tmpDict setObject:@"0" forKey:@"l"];
                        if([[dict objectForKey:@"cgroup"] integerValue] == 1)
                        {
                            
                            [tmpDict setObject:[msgDict objectForKey:@"by"] forKey:@"by"];
                        }
                        
                        if ([dict objectForKey:@"tid"])
                        {
                            NSDictionary *userIconDict;
                            if ([dict objectForKey:@"number"])
                            {
                                userIconDict = @{@"uid":[dict objectForKey:@"tid"],
                                                 @"uicon":[dict objectForKey:@"img_icon"],
                                                 @"username":[dict objectForKey:@"r_name"],
                                                 @"unum":[dict objectForKey:@"number"]};
                            }
                            else
                            {
                                userIconDict = @{@"uid":[dict objectForKey:@"tid"],
                                                 @"uicon":[dict objectForKey:@"img_icon"],
                                                 @"username":[dict objectForKey:@"r_name"],
                                                 @"unum":@""};
                            }
                            
                            //更新用户表
                            if ([[db findSetWithDictionary:@{@"uid":[dict objectForKey:@"tid"]} andTableName:USERICONTABLE] count] > 0)
                            {
                                if ([db deleteRecordWithDict:@{@"uid":[dict objectForKey:@"tid"]} andTableName:USERICONTABLE])
                                {
                                    [db insertRecord:userIconDict andTableName:USERICONTABLE];
                                }
                            }
                            else
                            {
                                [db insertRecord:userIconDict andTableName:USERICONTABLE];
                            }
                        }
                        //更新聊天记录的number -》id
                        NSArray *notiChatArray = [db findSetWithDictionary:@{@"mid":[msgDict objectForKey:@"_id"],@"userid":[Tools user_id]} andTableName:CHATTABLE];
                        if ([notiChatArray count] > 0)
                        {
                            if ([dict objectForKey:@"tid"] &&
                                [[dict objectForKey:@"tid"] isEqual:[NSNull null]] &&
                                [[dict objectForKey:@"tid"] length] == [[Tools user_id] length])
                            {
                                //私人聊天
                                if ([db updeteKey:@"fid" toValue:[dict objectForKey:@"tid"] withParaDict:@{@"mid":[msgDict objectForKey:@"_id"],@"userid":[Tools user_id]} andTableName:CHATTABLE] &&
                                    [db updeteKey:@"tid" toValue:[Tools user_id] withParaDict:@{@"userid":[Tools user_id],@"mid":[msgDict objectForKey:@"_id"]} andTableName:CHATTABLE])
                                {
                                    DDLOG(@"update number to tid success");
                                }
                            }
                            else
                            {
                                //群聊消息
                                if ([db updeteKey:@"fid" toValue:[dict objectForKey:@"tid"] withParaDict:@{@"mid":[msgDict objectForKey:@"_id"],@"userid":[Tools user_id]} andTableName:CHATTABLE] &&
                                    [db updeteKey:@"tid" toValue:[Tools user_id] withParaDict:@{@"userid":[Tools user_id],@"mid":[msgDict objectForKey:@"_id"]} andTableName:CHATTABLE] &&
                                    [db updeteKey:@"by" toValue:[msgDict objectForKey:@"by"] withParaDict:@{@"userid":[Tools user_id],@"mid":[msgDict objectForKey:@"_id"]} andTableName:CHATTABLE])
                                {
                                    DDLOG(@"update number to tid success");
                                }
                            }
                            
                            if(![[[notiChatArray firstObject] objectForKey:@"l"] isEqual:[NSNull null]] &&
                               [[[notiChatArray firstObject] objectForKey:@"l"] intValue] == 1)
                            {
                                if ([db updeteKey:@"content" toValue:[msgDict objectForKey:@"msg"] withParaDict:@{@"mid":[msgDict objectForKey:@"_id"],@"userid":[Tools user_id]} andTableName:CHATTABLE])
                                {
                                    DDLOG(@"updata msg content success!");
                                }
                            }
                        }
                        else
                        {
                            if ([db insertRecord:tmpDict andTableName:CHATTABLE])
                            {
                                DDLOG(@"insert chat success in messageviewcontroller!");
                            }
                        }
                    }
                    [self manageChatList];
                }
                else
                {
                    [self manageChatList];
                }
                
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

-(void)dealNewMsg:(NSDictionary *)dict
{
    if ([[Tools user_id] length] == 0)
    {
        return ;
    }
    if([[dict objectForKey:@"type"]isEqualToString:@"f_apply"])
    {
        if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"checked":@"0"} andTableName:FRIENDSTABLE] count] > 0)
        {
            self.unReadLabel.hidden = NO;
        }
    }
}

-(void)manageChatList
{
    [newMessageArray removeAllObjects];
    [newMessageArray addObjectsFromArray:[db findChatUseridWithTableName:CHATTABLE]];
    DDLOG(@"%@",newMessageArray);
    
    for(int i = 0;i<[newMessageArray count];i++)
    {
        NSDictionary *dict = [newMessageArray objectAtIndex:i];
        NSString *fid = [dict objectForKey:@"fid"];
        if ([fid length] < 8)
        {
            if ([[UserIconTools uidFromNum:fid] length] > 7)
            {
                [newMessageArray replaceObjectAtIndex:i withObject:@{@"fid":[UserIconTools uidFromNum:fid]}];
            }
        }
    }
    
    NSArray *array = [[NSArray alloc] initWithArray:newMessageArray];
    [newMessageArray removeAllObjects];
    for (int i = 0; i <[array count]; i++)
    {
        if (![newMessageArray containsObject:[array objectAtIndex:i]])
        {
            [newMessageArray addObject:[array objectAtIndex:i]];
        }
    }
    DDLOG(@"%@",newMessageArray);
    
    
    //时间由大到小排序
    if ([newMessageArray count] > 0)
    {
        for(int i = 0; i < [newMessageArray count]-1; i++)
        {
            NSString *tid = [[[newMessageArray objectAtIndex:i] allValues] firstObject];
            NSDictionary *messageDict = [self findLastMsgWithUser:tid];
            int msgTime = [[messageDict objectForKey:@"time"] intValue];
            for (int j= 0; j<[newMessageArray count]-i; j++)
            {
                NSString *tmpTid = [[[newMessageArray objectAtIndex:j] allValues] firstObject];
                NSDictionary *tmpMessageDict = [self findLastMsgWithUser:tmpTid];
                int tmpMsgTime = [[tmpMessageDict objectForKey:@"time"] intValue];
                if (msgTime > tmpMsgTime)
                {
                    [newMessageArray exchangeObjectAtIndex:i withObjectAtIndex:j];
                }
            }
        }
    }
    
    for (int i=0; i<[newMessageArray count]; i++)
    {
        NSString *tid = [[[newMessageArray objectAtIndex:i] allValues] firstObject];
        NSDictionary *userIconDIct = [ImageTools iconDictWithUserID:tid];
        if (!userIconDIct && [tid length] == [[Tools user_id] length])
        {
            [newMessageArray removeObjectAtIndex:i];
        }
    }
    [friendsListTableView reloadData];
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
}

-(NSDictionary *)findLastMsgWithUser:(NSString *)fid
{
    NSMutableArray *array = [db findChatLogWithUid:[Tools user_id] andOtherId:fid andTableName:CHATTABLE];
    return [array lastObject];
}

-(int)findCountOfUserId:(NSString *)fid
{
    DDLOG(@"%@",[unreadCountDict objectForKey:fid]);
    if ([unreadCountDict objectForKey:fid] && [[unreadCountDict objectForKey:fid] intValue] > 0)
    {
        DDLOG(@"%@",[unreadCountDict objectForKey:fid]);
        return [[unreadCountDict objectForKey:fid] intValue];
    }
    
    NSArray *userIconArray = [db findSetWithDictionary:@{@"uid":fid} andTableName:USERICONTABLE];
    NSString *uNumber = @"";
    if ([userIconArray count] > 0)
    {
        NSDictionary *userIconDict = [userIconArray firstObject];
        
        if ([userIconDict objectForKey:@"unum"] &&
            ![[userIconDict objectForKey:@"unum"] isEqual:[NSNull null]] &&
            [[userIconDict objectForKey:@"unum"] length] > 0)
        {
            uNumber = [userIconDict objectForKey:@"unum"];
        }
    }
    
    NSArray *array = [db findSetWithDictionary:@{@"userid":[Tools user_id],@"fid":fid,@"readed":@"0"} andTableName:CHATTABLE];
    NSArray *array1 = [db findSetWithDictionary:@{@"userid":[Tools user_id],@"fid":uNumber} andTableName:CHATTABLE];
    for (NSDictionary *dbDict in array1)
    {
        if ([db updeteKey:@"fid" toValue:fid withParaDict:@{@"mid":[dbDict objectForKey:@"mid"],@"userid":[Tools user_id]} andTableName:CHATTABLE] &&
            [db updeteKey:@"tid" toValue:[Tools user_id] withParaDict:@{@"userid":[Tools user_id],@"mid":[dbDict objectForKey:@"mid"]} andTableName:CHATTABLE])
        {
            DDLOG(@"updata fid and tid success!");
        }
    }
    return [array count] + [array1 count];
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
    DDLOG(@"unreadCountDict+++%@",unreadCountDict);
    return [newMessageArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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
    lineImageView.backgroundColor = LineBackGroudColor;
    [cell.contentView addSubview:lineImageView];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    if (indexPath.row < [tableView numberOfRowsInSection:indexPath.section]-1)
    {
        lineImageView.frame = CGRectMake( 55, cellHeight-0.5, cell.frame.size.width, 0.5);
    }
    NSString *otherid = [[[newMessageArray objectAtIndex:indexPath.row] allValues] firstObject];
    cell.headerImageView.frame = CGRectMake(14, 8, 34, 34);
    cell.headerImageView.layer.cornerRadius = 5;
    cell.headerImageView.clipsToBounds = YES;
    
    cell.memNameLabel.frame = CGRectMake(55, 5, 190, 20);
    cell.memNameLabel.textColor = [UIColor blackColor];
    cell.memNameLabel.font = LIST_NAME_FONT;
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
   
    
    if(userIconDIct && ![[userIconDIct objectForKey:@"username"] isEqual:[NSNull null]]) //NTNjMzg0OWUzNGRhYjVmMTY2OGI0NmNj
    {
        [Tools fillImageView:cell.headerImageView withImageFromURL:[userIconDIct objectForKey:@"uicon"] imageWidth:68 andDefault:HEADERICON];
        cell.memNameLabel.text = [userIconDIct objectForKey:@"username"];
        
        NSString *fname = [userIconDIct objectForKey:@"username"];
        if (![fname isEqual:[NSNull null]])
        {
            NSRange range = [fname rangeOfString:@"("];
            NSRange range1 = [fname rangeOfString:@"人"];
            if ([fname length] > 8 && range.length > 0 && range1.length > 0)
            {
                cell.memNameLabel.text = [NSString stringWithFormat:@"%@...%@",[fname substringToIndex:4],[fname substringFromIndex:range.location]];
            }
            else
            {
                cell.memNameLabel.text = fname;
            }
        }
        if (lastMsgDict)
        {
            cell.contentLabel.hidden = NO;
            if (![fname isEqual:[NSNull null]] && [fname length] > 0 && [fname rangeOfString:@"人)"].length > 0)
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
                    cell.contentLabel.text = [NSString stringWithFormat:@"%@:%@",byName,@"[图片]"];
                }
                else if([msgContent rangeOfString:@"amr"].length > 0)
                {
                    cell.contentLabel.text = [NSString stringWithFormat:@"%@:%@",byName,@"[语音]"];
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
                    cell.contentLabel.text = [NSString stringWithFormat:@"%@",@"[图片]"];
                }
                else if([msgContent rangeOfString:@"amr"].length > 0)
                {
                    cell.contentLabel.text = [NSString stringWithFormat:@"%@",@"[语音]"];
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
        NSString *name = [userIconDIct objectForKey:@"username"];
        chat.name = name;
        
        if ([name rangeOfString:@"人)"].length > 0)
        {
            chat.isGroup = YES;
        }
        else
        {
            chat.isGroup = NO;
        }
        chat.imageUrl = [userIconDIct objectForKey:@"uicon"];
    }
    chat.unReadedNumber = ([unreadCountDict objectForKey:otherid])?([[unreadCountDict objectForKey:otherid] intValue]):0;
    currentId = otherid;
    [self.navigationController pushViewController:chat animated:YES];
    [unreadCountDict setObject:@"0" forKey:otherid];
    [tableView reloadData];
}

-(void)updateChatList:(BOOL)update
{
    if (update)
    {
        [self getChatList];
//        [self dealNewChatMsg:nil];
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

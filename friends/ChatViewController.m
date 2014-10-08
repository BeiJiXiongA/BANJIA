//
//  ChatViewController.m
//  School
//
//  Created by TeekerZW on 14-3-4.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "ChatViewController.h"
#import "Header.h"
#import "MessageCell.h"
#import "AppDelegate.h"
#import "OperatDB.h"
#import "InputTableBar.h"
#import "ClassZoneViewController.h"
#import "UIImageView+WebCache.h"
#import "ReportViewController.h"
#import "PersonDetailViewController.h"
#import "GroupInfoViewController.h"
#import "ScoreDetailViewController.h"
#import "ScoreMemListViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "Downloader.h"


#define DIRECT  @"direct"
#define TYPE    @"msgType"
#define TEXTMEG  @"text"
#define IMAGEMSG  @"image"

#define Image_H 180
#define additonalH  90
#define MoreACTag   1000
#define SelectPicTag 2000


@interface ChatViewController ()<UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate,
UIActionSheetDelegate,
UIAlertViewDelegate,
AVAudioPlayerDelegate,
ChatDelegate,
ReturnFunctionDelegate,
MessageDelegate,
DownloaderDelegate,
updateGroupInfoDelegate,
EGORefreshTableHeaderDelegate>
{
    NSMutableArray *messageArray;
    UITableView *messageTableView;
    
    NSMutableArray *showTimesArray;
    
    UIImagePickerController *imagePickerController;
    UIButton*editButton;
    BOOL edittingTableView;
    
    InputTableBar *inputTabBar;
    
    OperatDB *db;
    
    UIImage *fromImage;
    UIImage *toImage;
    
    NSInteger currentSec;
    
    CGFloat tmpheight;
    CGFloat keyboardHeight;
    
    CGSize inputSize;
    
    CGFloat faceViewHeight;
    
    BOOL iseditting;
    
    NSString *fromImageStr;
    
    UITapGestureRecognizer *headerTapTgr;
    
    NSArray *users;
    NSString *builder;
    
    NSString *g_a_f;
    NSString *g_r_a;
    
    NSString *scoreid;
    
    CGFloat inputTabBarH;
    
    AVAudioPlayer *audioPlayer;
    
    EGORefreshTableHeaderView *pullRefreshView;
    BOOL _reloading;
    int page;
    
    UIButton *moreButton;
    
    UIView *recordingIndicatorView;
    UIImageView *recordingImageView;
    UILabel *recordingLabel;
    
    
    UIImage *fromHeaderImage;
    UIImage *selfHeaderImage;
}
@end

@implementation ChatViewController
@synthesize name,toID,imageUrl,chatVcDel,fromClass,isGroup,unreadCount,number,timeStr,unReadedNumber;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)groupInfo
{
    GroupInfoViewController *groupInfoVC = [[GroupInfoViewController alloc] init];
    groupInfoVC.groupID = toID;
    [groupInfoVC.groupUsers addObjectsFromArray:users];
    groupInfoVC.builderID = builder;
    groupInfoVC.updateGroupInfoDel = self;
    scoreid = @"";
    if(![g_a_f isEqual:[NSNull null]] && ![g_r_a isEqual:[NSNull null]])
    {
        groupInfoVC.g_a_f = g_a_f;
        groupInfoVC.g_r_a = g_r_a;
    }
    else
    {
        groupInfoVC.g_a_f = @"";
        groupInfoVC.g_r_a = @"";
    }
    [self.navigationController pushViewController:groupInfoVC animated:YES];
}

-(void)updateGroupInfo:(BOOL)update
{
    if (update)
    {
        [self getGroupInfo];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.titleLabel.text = name;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRecord) name:STARTRECORD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopRecord) name:STOPRECORD object:nil];
    
    if (SYSVERSION > 7.0)
    {
        self.edgesForExtendedLayout =UIRectEdgeTop;
    }
    
    db = [[OperatDB alloc] init];
    
//    [db deleteRecordWithDict:@{@"userid":[Tools user_id]} andTableName:CHATTABLE];
    timeStr = @"0";
    currentSec = 0;
    iseditting = NO;
    page = 0;
    faceViewHeight = 0;
    
    showTimesArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (toID && name)
    {
        NSDictionary *userDict = [[NSDictionary alloc] initWithObjectsAndKeys:toID,@"uid",name,@"username",imageUrl,@"uicon", nil];
        if ([[db findSetWithDictionary:userDict andTableName:USERICONTABLE] count] == 0)
        {
            [db insertRecord:userDict andTableName:USERICONTABLE];
        }
        else
        {
            [db deleteRecordWithDict:@{toID:@"uid"} andTableName:USERICONTABLE];
            [db insertRecord:userDict andTableName:USERICONTABLE];
        }
    }
    
    
    moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(SCREEN_WIDTH-CORNERMORERIGHT, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    if (![toID isEqualToString:OurTeamID])
    {
        [self.navigationBarView addSubview:moreButton];
    }
    
    inputSize = CGSizeMake(250, 30);
    
    if (imageUrl && [imageUrl length]>10)
    {
        fromImageStr = [NSString stringWithFormat:@"%@",imageUrl];
    }
    else if([[db findSetWithDictionary:@{@"uid":toID} andTableName:CLASSMEMBERTABLE] count] > 0)
    {
        NSArray *array = [db findSetWithDictionary:@{@"uid":toID} andTableName:CLASSMEMBERTABLE];
        
        fromImageStr = [NSString stringWithFormat:@"%@",[[array firstObject] objectForKey:@"img_icon"]];
    }
    else
    {
        fromImageStr = HEADERICON;
    }
   
    edittingTableView = NO;
    editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    editButton.backgroundColor = [UIColor clearColor];
    [editButton setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editTableView) forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationBarView addSubview:editButton];
    
    messageArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    
    messageTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-40) style:UITableViewStylePlain];
    messageTableView.delegate = self;
    messageTableView.dataSource = self;
    messageTableView.backgroundColor = self.bgView.backgroundColor;
    messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:messageTableView];
    
    _reloading = NO;
    pullRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:messageTableView orientation:EGOPullOrientationDown];
    pullRefreshView.delegate = self;
    
    if ([Tools NetworkReachable])
    {
        if (isGroup)
        {
            [self getGroupInfo];
        }
        else
        {
            
            [self getChatLog];
        }
    }
    else
    {
        [self dealNewChatMsg:nil];
    }
    
    if (isGroup)
    {
        [moreButton setImage:[UIImage imageNamed:@"newapplyheader"] forState:UIControlStateNormal];
        [moreButton addTarget:self action:@selector(groupInfo) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [moreButton setImage:[UIImage imageNamed:CornerMore] forState:UIControlStateNormal];
        [moreButton addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = self;
    
    CGFloat hei = 20;
    inputTabBarH = 40;
    if ([toID isEqual:AssistantID])
    {
        inputTabBarH = 0;
        hei = 0;
        moreButton.hidden = YES;
    }
    DDLOG(@"%f",SCREEN_HEIGHT);
    inputTabBar = [[InputTableBar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT+hei-inputTabBarH, SCREEN_WIDTH, inputTabBarH)];
    
    inputTabBar.backgroundColor = [UIColor whiteColor];
    inputTabBar.returnFunDel = self;
    inputTabBar.notOnlyFace = YES;
    if ([toID isEqualToString:OurTeamID])
    {
        inputTabBar.hideSoundButton = YES;
    }
    inputTabBar.layer.anchorPoint = CGPointMake(0.5, 1);
    messageTableView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-inputTabBarH);
    [self.bgView addSubview:inputTabBar];
    [inputTabBar setLayout];
    
    
}

-(void)startEditWord
{
    [inputTabBar.inputTextView becomeFirstResponder];
}

-(void)moreClick
{
    UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报此人", nil];
    ac.tag = MoreACTag;
    [ac showInView:self.bgView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"chat-%@",toID] forKey:@"viewtype"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewDidEndDragging:willDecelerate:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startEditWord) name:UIKeyboardWillShowNotification object:nil];
    
    [MobClick beginLogPageView:@"PageOne"];
    [self uploadLastViewTime];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
    [self uploadLastViewTime];
    [[NSNotificationCenter defaultCenter]  postNotificationName:UIKeyboardWillHideNotification object:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"notchat" forKey:@"viewtype"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

-(void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVENEWMSG object:nil];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = nil;
    inputTabBar.returnFunDel = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:inputTabBar];
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 下拉刷新
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    if ([messageArray count] > 0)
    {
        NSArray *cacheChatArray = [db findChatLogWithUid:[Tools user_id]
                                              andOtherId:toID
                                            andTableName:CHATTABLE
                                                   start:[messageArray count] count:10];
        if ([cacheChatArray count] > 0)
        {
            for (int i=0; i<[cacheChatArray count]; i++)
            {
                [messageArray insertObject:[cacheChatArray objectAtIndex:i] atIndex:0];
            }
            [self reloadTableView];
        }
        else
        {
            NSDictionary *firstDict = [messageArray firstObject];
            timeStr = [firstDict objectForKey:@"time"];
            [self getChatLog];
        }
    }
    else
    {
        timeStr = @"9999999999";
        [self getChatLog];
    }
    
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
    [pullRefreshView egoRefreshScrollViewDidScroll:messageTableView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pullRefreshView egoRefreshScrollViewDidEndDragging:messageTableView];
    [inputTabBar backKeyBoard];
    if (iseditting)
    {
        [self backInput];
    }
}

#pragma mark - 刷新消息列表
-(void)reloadTableView
{
    [showTimesArray removeAllObjects];
    for (int i=0; i<[messageArray count]; ++i)
    {
        NSDictionary *tmpDict = [messageArray objectAtIndex:i];
        if ((ABS(([[tmpDict objectForKey:@"time"] integerValue] - currentSec)) >= 60*3) || i==0)
        {
            if ([[tmpDict objectForKey:@"time"] intValue] == 0)
            {
                continue ;
            }
            currentSec = [[tmpDict objectForKey:@"time"] integerValue];
            if(!isGroup)
            {
                if(([toID isEqualToString:OurTeamID] &&
                    [[tmpDict objectForKey:DIRECT] isEqualToString:@"t"])
                   ||![toID isEqualToString:OurTeamID])
                {
                    if (![showTimesArray containsObject:[tmpDict objectForKey:@"time"]])
                    {
                        [showTimesArray addObject:[tmpDict objectForKey:@"time"]];
                    }
                }
            }
            else if((isGroup && [[tmpDict objectForKey:DIRECT] isEqualToString:@"t"]))
            {
                if (![showTimesArray containsObject:[tmpDict objectForKey:@"time"]])
                {
                    [showTimesArray addObject:[tmpDict objectForKey:@"time"]];
                }
            }
        }
    }
    
    if ([db updeteKey:@"readed" toValue:@"1" withParaDict:@{@"fid":toID,@"userid":[Tools user_id]} andTableName:CHATTABLE])
    {
        DDLOG(@"update chat readed success!");
    }
    [messageTableView reloadData];
    
    if (tmpheight > 0)
    {
        //显示键盘
        if(messageTableView.frame.size.height - messageTableView.contentSize.height < tmpheight)
        {
            //聊天内容被盖住
            messageTableView.contentOffset = CGPointMake(0, (tmpheight - (messageTableView.frame.size.height - messageTableView.contentSize.height)));
        }
    }
    else
    {
        //收起键盘
        if (messageTableView.contentSize.height - messageTableView.frame.size.height > 0)
        {
            //列表内容大于列表高度
            messageTableView.contentOffset = CGPointMake(0, messageTableView.contentSize.height-messageTableView.frame.size.height+tmpheight);
        }
    }
}



#pragma mark - 获得聊天记录
-(void)getChatLog
{
    if ([Tools NetworkReachable])
    {
        NSDictionary *paraDict;
        if(isGroup)
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"g_id":toID,
                         @"time":timeStr
                         };
        }
        else
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"t_id":toID,
                         @"time":timeStr
                         };
        }
        
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:paraDict API:GETCHATLOG];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"chat=log=responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                //NTNhM2U1OWIzNGRhYjVkODFjOGI0NWIy
                
                if ([timeStr length] > 1 && ![timeStr isEqualToString:@"9999999999"] && [[responseDict objectForKey:@"data"] count] == 0)
                {
                    [Tools showTips:@"已经没有历史消息了" toView:self.bgView];
                    return ;
                }
                
                NSArray *array = [[NSArray alloc] initWithArray:[responseDict objectForKey:@"data"]];
                if ([timeStr isEqualToString:@"0"] && [array count] == 0)
                {
                    NSArray *cacheChatArray = [db findChatLogWithUid:[Tools user_id]
                                                          andOtherId:toID
                                                        andTableName:CHATTABLE
                                                               start:[messageArray count] count:10];
                    if ([cacheChatArray count] > 0)
                    {
                        for (int i=0; i<[cacheChatArray count]; i++)
                        {
                            [messageArray insertObject:[cacheChatArray objectAtIndex:i] atIndex:0];
                        }
                        [self reloadTableView];
                    }
                    else
                    {
                        timeStr = @"9999999999";
                        [self getChatLog];
                    }
                    
                }
                for (int i=0; i<[array count]; ++i)
                {
                    NSMutableDictionary *chatDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                    NSDictionary *dict = [array objectAtIndex:i];
                    
                    [chatDict setObject:[dict objectForKey:@"_id"] forKey:@"mid"];
                    [chatDict setObject:[Tools user_id] forKey:@"userid"];
                    [chatDict setObject:[dict objectForKey:@"msg"] forKey:@"content"];
                    [chatDict setObject:[NSString stringWithFormat:@"%d",[[dict objectForKey:@"t"] integerValue]] forKey:@"time"];
                    [chatDict setObject:imageUrl?imageUrl:@"" forKey:@"ficon"];
                    [chatDict setObject:@"1" forKey:@"readed"];
                    [chatDict setObject:TEXTMEG forKey:@"msgType"];
                    if ([[dict objectForKey:@"by"] isEqualToString:[Tools user_id]])
                    {
                        [chatDict setObject:toID forKey:@"tid"];
                        [chatDict setObject:@"t" forKey:DIRECT];
                        [chatDict setObject:[Tools user_id] forKey:@"fid"];
                    }
                    else
                    {
                        [chatDict setObject:[Tools user_id] forKey:@"tid"];
                        [chatDict setObject:toID forKey:@"fid"];
                        [chatDict setObject:@"f" forKey:DIRECT];
                    }
                    if (isGroup)
                    {
                        [chatDict setObject:[dict objectForKey:@"by"] forKey:@"by"];
                    }
                    
                    if ([db findSetWithDictionary:@{@"userid":[Tools user_id],@"mid":[dict objectForKey:@"_id"]} andTableName:CHATTABLE] == 0)
                    {
                        [db insertRecord:chatDict andTableName:CHATTABLE];
                    }
                    else
                    {
                        [db deleteRecordWithDict:@{@"userid":[Tools user_id],@"mid":[dict objectForKey:@"_id"]} andTableName:CHATTABLE];
                        [db insertRecord:chatDict andTableName:CHATTABLE];
                    }
                    [messageArray insertObject:chatDict atIndex:0];
                }
                if ([array count] > 0 && [messageArray count] > 0)
                {
                    [self reloadTableView];
                }
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [request startAsynchronous];
    }

}

-(void)getMsgContentWithMid:(NSString *)mid
{
    if ([Tools NetworkReachable])
    {
        NSDictionary *paraDict;
        if(isGroup)
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"g_id":toID,
                         @"m_id":mid
                         };
        }
        else
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"t_id":toID,
                         @"m_id":mid
                         };
        }
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:paraDict API:GETCHATLOGBYID];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"chat msg content =responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSDictionary *fullChatDict = [responseDict objectForKey:@"data"];
                if ([fullChatDict isKindOfClass:[NSDictionary class]])
                {
                    NSArray *chatLogArray = [db findSetWithDictionary:@{@"userid":[Tools user_id],@"mid":[[responseDict objectForKey:@"data"] objectForKey:@"_id"]} andTableName:CHATTABLE];
                    if ([chatLogArray count] > 0)
                    {
                        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithDictionary:[chatLogArray firstObject]];
                        if (isGroup)
                        {
                            [tmpDict setObject:[fullChatDict objectForKey:@"msg"] forKey:@"content"];
                            [tmpDict setObject:toID forKey:@"fid"];
                            [tmpDict setObject:[fullChatDict objectForKey:@"by"] forKey:@"by"];
                            if(([db updeteKey:@"content" toValue:[fullChatDict objectForKey:@"msg"]
                                  withParaDict:@{@"userid":[Tools user_id],@"mid":[[responseDict objectForKey:@"data"] objectForKey:@"_id"]}
                                  andTableName:CHATTABLE])&&
                                ([db updeteKey:@"fid" toValue:toID
                                  withParaDict:@{@"userid":[Tools user_id],@"mid":[[responseDict objectForKey:@"data"] objectForKey:@"_id"]}
                                  andTableName:CHATTABLE]) &&
                                ([db updeteKey:@"by" toValue:[fullChatDict objectForKey:@"by"] withParaDict:@{@"userid":[Tools user_id],@"mid":[[responseDict objectForKey:@"data"] objectForKey:@"_id"]} andTableName:CHATTABLE]) &&
                               ([db updeteKey:@"readed" toValue:@"1" withParaDict:@{@"userid":[Tools user_id],@"mid":[[responseDict objectForKey:@"data"] objectForKey:@"_id"]} andTableName:CHATTABLE]))
                            {
                                DDLOG(@"update full chat log success!");
                            }
                            [messageArray insertObject:tmpDict atIndex:[messageArray count]];
                            [self reloadTableView];
                        }
                        else
                        {
                            
                            [tmpDict setObject:[fullChatDict objectForKey:@"msg"] forKey:@"content"];
                            [tmpDict setObject:toID forKey:@"fid"];
                            if (([db updeteKey:@"content" toValue:[fullChatDict objectForKey:@"msg"]
                                  withParaDict:@{@"userid":[Tools user_id],@"mid":[[responseDict objectForKey:@"data"] objectForKey:@"_id"]}
                                  andTableName:CHATTABLE])&&
                                ([db updeteKey:@"fid" toValue:toID
                                  withParaDict:@{@"userid":[Tools user_id],@"mid":[[responseDict objectForKey:@"data"] objectForKey:@"_id"]}
                                  andTableName:CHATTABLE]) &&
                                ([db updeteKey:@"readed" toValue:@"1" withParaDict:@{@"userid":[Tools user_id],@"mid":[[responseDict objectForKey:@"data"] objectForKey:@"_id"]} andTableName:CHATTABLE]))
                            {
                                DDLOG(@"update full chat log success!");
                            }
                            [messageArray insertObject:tmpDict atIndex:[messageArray count]];
                            [self reloadTableView];
                        }
                    }
                }
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
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

-(void)getGroupInfo
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"g_id":toID
                                                                      } API:GETGROUPINFO];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"get froup info responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"builder"] isEqual:[NSNull null]])
                {
                    
                    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该群聊已经被群主解散了！" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
                    al.tag = 77777;
                    [al show];
                    
                    if ([db deleteRecordWithDict:@{@"userid":[Tools user_id],@"fid":toID,@"direct":@"f"} andTableName:CHATTABLE] &&
                        [db deleteRecordWithDict:@{@"userid":[Tools user_id],@"tid":toID,@"direct":@"t"} andTableName:CHATTABLE])
                    {
                        DDLOG(@"delete chat log  success");
                    }
                    
                    return ;
                }
                users = [[responseDict objectForKey:@"data"] objectForKey:@"users"];
                self.titleLabel.text = [[responseDict objectForKey:@"data"] objectForKey:@"name"];

                
                NSString *fname = [[responseDict objectForKey:@"data"] objectForKey:@"name"];
                if (![fname isEqual:[NSNull null]])
                {
                    NSRange range = [fname rangeOfString:@"("];
                    NSRange range1 = [fname rangeOfString:@"人"];
                    if ([fname length] > 8 && range.length > 0 && range1.length > 0)
                    {
                        self.titleLabel.text = [NSString stringWithFormat:@"%@...%@",[fname substringToIndex:4],[fname substringFromIndex:range.location]];
                    }
                    else
                    {
                        self.titleLabel.text = fname;
                    }
                }
                
                for(NSDictionary *dict in users)
                {
                    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                    [tmpDict setObject:[dict objectForKey:@"_id"]forKey:@"uid"];
                    if ([dict objectForKey:@"img_icon"])
                    {
                        [tmpDict setObject:[dict objectForKey:@"img_icon"] forKey:@"uicon"];
                    }
                    else
                    {
                        [tmpDict setObject:@"" forKey:@"uicon"];
                    }
                    [tmpDict setObject:[dict objectForKey:@"r_name"] forKey:@"username"];
                    [tmpDict setObject:[NSString stringWithFormat:@"%d",[[dict objectForKey:@"number"] intValue]] forKey:@"unum"];
                    if ([[db findSetWithDictionary:@{@"uid":[dict objectForKey:@"_id"]} andTableName:USERICONTABLE] count]>0)
                    {
                        [db deleteRecordWithDict:@{@"uid":[dict objectForKey:@"_id"]} andTableName:USERICONTABLE];
                        [db insertRecord:tmpDict andTableName:USERICONTABLE];
                    }
                    else
                    {
                        [db insertRecord:tmpDict andTableName:USERICONTABLE];
                    }
                }
                if (![[[responseDict objectForKey:@"data"] objectForKey:@"builder"] isEqual:[NSNull null]])
                {
                    builder = [[responseDict objectForKey:@"data"] objectForKey:@"builder"];
                }
                else
                {
                    builder = @"";
                }
                
                name = [[responseDict objectForKey:@"data"] objectForKey:@"name"];
                NSDictionary *userIconDict = @{@"uid":toID,@"username":name,@"uicon":@"",@"unum":@""};
                if ([[db findSetWithDictionary:@{@"uid":toID} andTableName:USERICONTABLE] count] > 0)
                {
                    [db deleteRecordWithDict:@{@"uid":toID} andTableName:USERICONTABLE];
                    [db insertRecord:userIconDict andTableName:USERICONTABLE];
                }
                else
                {
                    [db insertRecord:userIconDict andTableName:USERICONTABLE];
                }
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"opt"] count] > 0)
                {
                    g_a_f = [[[responseDict objectForKey:@"data"] objectForKey:@"opt"] objectForKey:@"g_a_f"];
                    g_r_a = [[[responseDict objectForKey:@"data"] objectForKey:@"opt"] objectForKey:@"g_r_a"];
                }
                else
                {
                    g_r_a = @"";
                    g_a_f = @"";
                }
                NSArray *cacheChatArray = [db findChatLogWithUid:[Tools user_id]
                                                      andOtherId:toID
                                                    andTableName:CHATTABLE
                                                           start:[messageArray count] count:10];
                if ([cacheChatArray count] > 0 && [cacheChatArray count] >= unReadedNumber)
                {
                    for (int i=0; i<[cacheChatArray count]; i++)
                    {
                        [messageArray insertObject:[cacheChatArray objectAtIndex:i] atIndex:0];
                    }
                    [self reloadTableView];
                }
                else
                {
                    timeStr = @"9999999999";
                    [self getChatLog];
                }
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
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

#pragma mark - 更新聊天时间
-(void)uploadLastViewTime
{
    if ([[Tools user_id] length] == 0)
    {
        return ;
    }
    if ([Tools NetworkReachable])
    {
        
        NSDictionary *paraDict;
        if(isGroup)
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"g_id":toID,
                         };
        }
        else
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"t_id":toID,
                         };
        }
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:paraDict API:LASTVIEWTIME];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"update chat last time responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATECHATSNUMBER object:nil];
                
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
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

#pragma mark - 关于键盘
-(void)selectPic:(int)selectPicTag
{
    [inputTabBar backKeyBoard];
    if (iseditting)
    {
        [self backInput];
    }
    if (selectPicTag == TakePhotoTag)
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else
        {
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"" message:@"相机不可用！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            al.tag = 9999;
            [al show];
        }
        [self presentViewController:imagePickerController animated:YES completion:^{
            
        }];
    }
    else if(selectPicTag == AlbumTag)
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

-(void)myReturnFunction
{
    if (inputTabBar.inputTextView.text.length == 0)
    {
        [Tools showAlertView:@"消息不能为空！" delegateViewController:nil];
        return ;
    }
    if ([inputTabBar.inputTextView.text length]>0)
    {
        inputSize = CGSizeMake(250, 30);
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10-tmpheight, SCREEN_WIDTH, inputSize.height+10+ tmpheight);
        [self sendMsgWithString:[inputTabBar analyString:inputTabBar.inputTextView.text]];
    }
}

-(void)showKeyBoard:(CGFloat)keyBoardHeight
{
    [UIView animateWithDuration:0.2 animations:^{
        tmpheight = keyBoardHeight;
        keyboardHeight = keyBoardHeight;
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10-keyboardHeight, SCREEN_WIDTH, inputSize.height+10+ FaceViewHeight);
        if (tmpheight > 0)
        {
            if (messageTableView.frame.size.height - messageTableView.contentSize.height < tmpheight)
            {
                messageTableView.contentOffset = CGPointMake(0, (tmpheight - (messageTableView.frame.size.height - messageTableView.contentSize.height)));
            }
            else
            {
                if (messageTableView.contentSize.height > tmpheight)
                {
                    messageTableView.contentOffset = CGPointMake(0, messageTableView.contentSize.height-messageTableView.frame.size.height+tmpheight);
                }
            }
        }
        iseditting = YES;
    }];
}

-(void)backInput
{
    [UIView animateWithDuration:0.2 animations:^{
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10, SCREEN_WIDTH, inputSize.height+10);
        messageTableView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-inputSize.height-10);
        if (messageTableView.contentSize.height>SCREEN_HEIGHT-80)
        {
           messageTableView.contentOffset = CGPointMake(0, messageTableView.contentSize.height-messageTableView.frame.size.height);
        }
        else
        {
            messageTableView.contentOffset = CGPointZero;
        }
        tmpheight = 0;
        iseditting = NO;
    }];
}

-(void)changeInputType:(NSString *)changeType
{
    if ([changeType isEqualToString:@"face"])
    {
        tmpheight = FaceViewHeight;
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10-tmpheight, SCREEN_WIDTH, inputSize.height+10 + tmpheight);
    }
    else if([changeType isEqualToString:@"keyboard"])
    {
        if(keyboardHeight > 0)
        {
            tmpheight = keyboardHeight;
        }
        else
        {
            tmpheight = inputSize.height;
        }
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10-tmpheight, SCREEN_WIDTH, inputSize.height+10 + tmpheight);
    }
    iseditting = YES;
}

-(void)changeInputViewSize:(CGSize)size
{
    inputSize = size;
    [UIView animateWithDuration:0.2 animations:^{
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-size.height-10-tmpheight, SCREEN_WIDTH, size.height+10+tmpheight);
        
        if (messageTableView.contentSize.height>tmpheight)
        {
            if (inputSize.height>30)
            {
                messageTableView.contentOffset = CGPointMake(0, messageTableView.contentSize.height-messageTableView.frame.size.height+tmpheight+inputSize.height-40);
            }
        }
    }];
}

#pragma mark - 聊天代理
-(void)dealNewChatMsg:(NSDictionary *)dict
{
    NSArray *usericonArray = [db findSetWithDictionary:@{@"unum":[dict objectForKey:@"fid"],@"uid":toID} andTableName:USERICONTABLE];
    if ([usericonArray count] == 0)
    {
        return ;
    }
    if (dict && [dict count] > 0)
    {
        if ([[dict objectForKey:DIRECT] isEqualToString:@"t"])
        {
            [messageArray replaceObjectAtIndex:[messageArray count]-1 withObject:dict];
            [self reloadTableView];
            return ;
        }
        if ([[dict objectForKey:@"l"] intValue] == 1)
        {
            [self getMsgContentWithMid:[dict objectForKey:@"mid"]];
            return;
        }
        if (isGroup)
        {
            NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
            NSArray *usericonArray = [db findSetWithDictionary:@{@"unum":[dict objectForKey:@"by"]} andTableName:USERICONTABLE];
            if ([usericonArray count] > 0)
            {
                NSDictionary *userIcon = [usericonArray firstObject];
                [tmpDict setObject:[userIcon objectForKey:@"uid"] forKey:@"by"];
                [tmpDict setObject:[Tools user_id] forKey:[Tools user_id]];
                if([db updeteKey:@"by" toValue:[userIcon objectForKey:@"uid"] withParaDict:@{@"userid":[Tools user_id],@"mid":[dict objectForKey:@"mid"]} andTableName:CHATTABLE] &&
                   [db updeteKey:@"tid" toValue:[Tools user_id] withParaDict:@{@"userid":[Tools user_id],@"mid":[dict objectForKey:@"mid"]} andTableName:CHATTABLE] &&
                   [db updeteKey:@"readed" toValue:@"1" withParaDict:@{@"userid":[Tools user_id],@"mid":[dict objectForKey:@"mid"]} andTableName:CHATTABLE])
                {
                    DDLOG(@"update full chat log success!");
                }
            }
            [messageArray insertObject:tmpDict atIndex:[messageArray count]];
            [self reloadTableView];
            return;
        }
        else
        {
            NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
            NSArray *usericonArray = [db findSetWithDictionary:@{@"unum":[dict objectForKey:@"fid"]} andTableName:USERICONTABLE];
            if ([usericonArray count] > 0)
            {
                NSDictionary *userIcon = [usericonArray firstObject];
                [tmpDict setObject:[userIcon objectForKey:@"uid"] forKey:@"fid"];
                [tmpDict setObject:[Tools user_id] forKey:@"tid"];
                [tmpDict setObject:[Tools user_id] forKey:@"tid"];
                [tmpDict setObject:@"1" forKey:@"readed"];
                
                if([db updeteKey:@"fid" toValue:[userIcon objectForKey:@"uid"] withParaDict:@{@"userid":[Tools user_id],@"mid":[dict objectForKey:@"mid"]} andTableName:CHATTABLE] &&
                   [db updeteKey:@"tid" toValue:[Tools user_id] withParaDict:@{@"userid":[Tools user_id],@"mid":[dict objectForKey:@"mid"]} andTableName:CHATTABLE] &&
                   [db updeteKey:@"readed" toValue:@"1" withParaDict:@{@"userid":[Tools user_id],@"mid":[dict objectForKey:@"mid"]} andTableName:CHATTABLE])
                {
                    DDLOG(@"update full chat log success!");
                }
                
            }
            [messageArray addObject:tmpDict];
        }
        
        [self reloadTableView];
        return;
    }
    else if ([[Tools user_id] length] > 0)
    {
        NSArray *tmpArray = [db findChatLogWithUid:[Tools user_id] andOtherId:toID andTableName:CHATTABLE];
        if ([tmpArray count] > 0)
        {
            [messageArray addObjectsFromArray:tmpArray];
            [self reloadTableView];
            return ;
        }
    }
    
    if (dict && ![[dict objectForKey:@"fid"] isEqualToString:toID])
    {
        return ;
    }
    
    
    
    if ([self.chatVcDel respondsToSelector:@selector(updateChatList:)])
    {
        [self.chatVcDel updateChatList:YES];
    }
}

#pragma mark - 选照片

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == MoreACTag)
    {
        if (buttonIndex == 0)
        {
            ReportViewController *reportVC = [[ReportViewController alloc] init];
            reportVC.reportType = @"people";
            reportVC.reportUserid = toID;
            reportVC.reportContentID = @"";
            [self.navigationController pushViewController:reportVC animated:YES];
        }
    }
    else if(actionSheet.tag == SelectPicTag)
    {
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 3333)
    {
        if (buttonIndex == 1)
        {
            [self releaseFriend];
        }
    }
    else if(alertView.tag == 77777)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//加为好友

-(void)addFriend
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"f_id":toID
                                                                      } API:MB_APPLY_FRIEND];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"memberByClass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showTips:@"请求已申请，请等待对方答复！" toView:self.bgView];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
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

//拒绝好友

-(void)releaseFriend
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"f_id":toID
                                                                      } API:MB_RMFRIEND];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"addfriends responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([db deleteRecordWithDict:@{@"uid":[Tools user_id],@"fid":toID} andTableName:FRIENDSTABLE])
                {
                    DDLOG(@"delete friend success");
                    if ([self.friendVcDel respondsToSelector:@selector(updateFriendList:)])
                    {
                        [self.friendVcDel updateFriendList:YES];
                    }
                }
                
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
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


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [imagePickerController dismissViewControllerAnimated:YES completion:^{
        DDLOG(@"image info %@",info);
        UIImage *originaImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(originaImage, nil, nil, nil);
        originaImage = [ImageTools getNormalImageFromImage:originaImage];
        [self sendImage:originaImage];
    }];
    
}


-(void)sendImage:(UIImage *)image
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools upLoadImageFiles:[NSArray arrayWithObject:image]
                                                 withSubURL:UPLOADCHATFILE
                                                andParaDict:@{@"u_id":[Tools user_id],                                                                                                                                    @"token":[Tools client_token]}];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"upload image responsedict %@",responseDict);
            
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [self sendMsgWithString:[[responseDict objectForKey:@"data"] objectForKey:@"files"]];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
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


-(void)sendSound:(int)length andFilePath:(NSString *)filePath
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools upLoadSoundFiles:[NSArray arrayWithObject:filePath]
                                                      withSubURL:[NSString stringWithFormat:@"%@",UPLOADCHATFILE]
                                                     andParaDict:@{@"u_id":[Tools user_id],                                                                                                                                    @"token":[Tools client_token]}  timeLength:length];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"upload image responsedict %@",responseDict);
            
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSString *filesUrl = [[responseDict objectForKey:@"data"] objectForKey:@"files"];
                [self sendMsgWithString:[NSString stringWithFormat:@"%@?time=%d",filesUrl,length]];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
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


#pragma mark - tableview

-(void)editTableView
{
    if (edittingTableView)
    {
        messageTableView.editing = NO;
        [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    }
    else
    {
        messageTableView.editing = YES;
        [editButton setTitle:@"完成" forState:UIControlStateNormal];
    }
    edittingTableView = !edittingTableView;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DDLOG(@"messageArray=%@",messageArray);
    return [messageArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 0;
    NSDictionary *dict = [messageArray objectAtIndex:indexPath.row];
    NSString *msgContent = [[messageArray objectAtIndex:indexPath.row] objectForKey:@"content"];
    CGSize size = [SizeTools getSizeWithString:[msgContent emojizedString] andWidth:SCREEN_WIDTH/2+20 andFont:MessageTextFont];
    rowHeight = size.height+CHAT_TOP_TEXT_SPACE*2;
    if ([[dict objectForKey:@"content"] rangeOfString:@"$!#"].length >0)
    {
        NSString *msgContent = [dict objectForKey:@"content"];
        NSRange range = [msgContent rangeOfString:@"$!#"];
        msgContent = [msgContent substringFromIndex:range.location+range.length];
        size = [SizeTools getSizeWithString:[msgContent emojizedString] andWidth:SCREEN_WIDTH/2+20 andFont:MessageTextFont];
        if ([[dict objectForKey:DIRECT] isEqualToString:@"f"])
        {
            rowHeight = size.height + CHAT_TOP_TEXT_SPACE * 2 + 21;
        }
        else
        {
            rowHeight = size.height + CHAT_TOP_TEXT_SPACE * 2 +1;
        }
    }
    if ([[msgContent pathExtension] isEqualToString:@"png"] || [[msgContent pathExtension] isEqualToString:@"jpg"])
    {
        rowHeight = MESSAGE_IMAGE_HEIGHT+CHAT_TOP_IMAGE_SPACE*2;
    }
    else if ([msgContent rangeOfString:@"amr"].length > 0)
    {
        rowHeight = 40;
    }
    
    if (rowHeight < 40)
    {
        rowHeight = 40;
    }

    if ([showTimesArray containsObject:[dict objectForKey:@"time"]])
    {
        rowHeight += 25;
    }
    
    if ([[dict objectForKey:DIRECT] isEqualToString:@"f"] && isGroup)
    {
        rowHeight += 25;
    }
    return rowHeight+ CHAT_MSG_SPACE * 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *messageCell = @"messageCell";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:messageCell];
    if (cell == nil)
    {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:messageCell];
    }
    NSDictionary *dict = [messageArray objectAtIndex:indexPath.row];
    cell.isGroup = isGroup;
    [cell setCellWithDict:dict];
    
    cell.msgImageView.tag = indexPath.row;
    [cell.msgImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)]];
    cell.msgImageView.userInteractionEnabled = YES;
    
    if (!isGroup)
    {
        cell.fromImgIcon = imageUrl;
    }
    cell.msgDelegate = self;
    
    cell.timeLabel.hidden = YES;
    if ([showTimesArray containsObject:[dict objectForKey:@"time"]])
    {
        if(([toID isEqualToString:OurTeamID] && [[dict objectForKey:DIRECT] isEqualToString:@"t"]) ||
           ![toID isEqualToString:OurTeamID])
        {
            cell.timeLabel.hidden = NO;
            NSString *time = [Tools showTime:[dict objectForKey:@"time"]];
            cell.timeLabel.text = time;
            CGRect headerImageRect = cell.headerImageView.frame;
            CGRect chatBgRect = cell.chatBg.frame;
            CGRect msgContentLabelRect = cell.messageContentLabel.frame;
            
            CGRect msgImageViewRect = cell.msgImageView.frame;
            CGRect soundButtonRect = cell.soundButton.frame;
            
            if (!isGroup || [[dict objectForKey:DIRECT] isEqualToString:@"t"])
            {
                cell.headerImageView.frame = CGRectMake(headerImageRect.origin.x, headerImageRect.origin.y+25, headerImageRect.size.width, headerImageRect.size.height);
                cell.chatBg.frame = CGRectMake(chatBgRect.origin.x, chatBgRect.origin.y+25, chatBgRect.size.width, chatBgRect.size.height);
                cell.messageContentLabel.frame = CGRectMake(msgContentLabelRect.origin.x, msgContentLabelRect.origin.y+25, msgContentLabelRect.size.width, msgContentLabelRect.size.height);
                cell.msgImageView.frame = CGRectMake(msgImageViewRect.origin.x, msgImageViewRect.origin.y+25, msgImageViewRect.size.width, msgImageViewRect.size.height);
                cell.soundButton.frame = CGRectMake(soundButtonRect.origin.x, soundButtonRect.origin.y+25, soundButtonRect.size.width, soundButtonRect.size.height);
            }

        }
        
    }
    else
    {
        cell.timeLabel.hidden = YES;
        NSString *time = [Tools showTime:[dict objectForKey:@"time"]];
        cell.timeLabel.text = time;
        CGRect headerImageRect = cell.headerImageView.frame;
        CGRect chatBgRect = cell.chatBg.frame;
        CGRect msgContentLabelRect = cell.messageContentLabel.frame;
        
        CGRect msgImageViewRect = cell.msgImageView.frame;
        CGRect soundButtonRect = cell.soundButton.frame;
        cell.headerImageView.frame = headerImageRect;
        cell.chatBg.frame = chatBgRect;
        cell.messageContentLabel.frame = msgContentLabelRect;
        cell.msgImageView.frame = msgImageViewRect;
        cell.soundButton.frame = soundButtonRect;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = self.bgView.backgroundColor;
    return cell;
}

-(void)soundTap:(NSString *)msgContent andImageView:(UIImageView *)soundImageView
{
    NSRange range = [msgContent rangeOfString:@"?"];
    NSString *subUrl = [msgContent substringToIndex:range.location];
    NSString *extention = [subUrl pathExtension];
    NSString *fileName = [[subUrl lastPathComponent] substringToIndex:[[subUrl lastPathComponent] rangeOfString:extention].location-1];
    NSString *cacheFilePath = [NSString stringWithFormat:@"%@/%@.wav",[DirectyTools soundDir],fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath])
    {
        [self playRecordFile:cacheFilePath andImageView:soundImageView];
    }
    else
    {
        [[Downloader defaultDownloader] adiDownloadWithUrl:[NSString stringWithFormat:@"%@%@",MEDIAURL,subUrl]];
        [Downloader defaultDownloader].downloaderDel = self;
    }
}

-(void)stopPlay:(NSString *)soundPath
{
    [audioPlayer stop];
}

-(void)showTips:(NSString *)tipString
{
    [Tools showTips:tipString toView:self.bgView];
}

-(void)downloadDone:(NSString *)filePath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [self playRecordFile:filePath andImageView:nil];
    }
}

#pragma mark - 录音相关
-(void)startRecord
{
//    recordingIndicatorView = [[UIView alloc] init];
//    recordingIndicatorView.frame = CGRectMake((SCREEN_WIDTH-150)/2, (SCREEN_HEIGHT-40-UI_NAVIGATION_BAR_HEIGHT-200)/2, 150, 200);
//    recordingIndicatorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
//    recordingIndicatorView.layer.cornerRadius = 5;
//    recordingIndicatorView.clipsToBounds = YES;
//    [self.bgView addSubview:recordingIndicatorView];
}
-(void)stopRecord
{
    [recordingIndicatorView removeFromSuperview];
}

#pragma mark - 播放原wav
- (void)playRecordFile:(NSString *)filePath andImageView:(UIImageView *)soundImageView
{
    if (filePath.length > 0)
    {
        if (audioPlayer)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:[[audioPlayer.url absoluteString] lastPathComponent] object:nil];
        }
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath] error:nil];
        audioPlayer.delegate = self;
        [audioPlayer prepareToPlay];
        [audioPlayer play];
    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:[[player.url absoluteString] lastPathComponent] object:nil];
    }
}

-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    DDLOG_CURRENT_METHOD;
}


-(void)tapImage:(UITapGestureRecognizer *)tap
{
    NSDictionary *dict = [messageArray objectAtIndex:tap.view.tag];
    NSString *msgContent = [dict objectForKey:@"content"];
    if ([[msgContent pathExtension] isEqualToString:@"png"] || [[msgContent pathExtension] isEqualToString:@"jpg"])
    {
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEURL,msgContent]];
        photo.srcImageView = (UIImageView *)tap.view;
        MJPhotoBrowser *photoBroser = [[MJPhotoBrowser alloc] init];
        photoBroser.photos = [NSArray arrayWithObject:photo];
        [photoBroser show];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (iseditting)
    {
        [inputTabBar backKeyBoard];
        [self backInput];
    }
}

-(void)toPersonDetail:(NSDictionary *)personDict
{
    PersonDetailViewController *personDetailVC = [[PersonDetailViewController alloc] init];
    if (isGroup)
    {
        if([[personDict objectForKey:DIRECT] isEqualToString:@"t"])
        {
            personDetailVC.personName = [Tools user_name];
            personDetailVC.personID = [Tools user_id];
        }
        else
        {
            NSDictionary *usericondict = [ImageTools iconDictWithUserID:[personDict objectForKey:@"by"]];
            if (usericondict)
            {
                personDetailVC.personName = [usericondict objectForKey:@"username"];
            }
            personDetailVC.personID = [personDict objectForKey:@"by"];
        }
    }
    else
    {
        if([[personDict objectForKey:DIRECT] isEqualToString:@"t"])
        {
            personDetailVC.personName = [Tools user_name];
            personDetailVC.personID = [Tools user_id];
        }
        else
        {
            NSDictionary *usericondict = [ImageTools iconDictWithUserID:[personDict objectForKey:@"fid"]];
            if (usericondict)
            {
                personDetailVC.personName = [usericondict objectForKey:@"username"];
            }
            
            personDetailVC.personID = [personDict objectForKey:@"fid"];
        }
    }
    if (!isGroup)
    {
        personDetailVC.fromChat = YES;
    }
    [self.navigationController pushViewController:personDetailVC animated:YES];
    
}

-(BOOL)isInThisClass:(NSString *)classId
{
    if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"classid":classId} andTableName:MYCLASSTABLE] count]> 0)
    {
        return YES;
    }
    return NO;
}

-(void)joinClassWithMsgContent:(NSString *)msgContent
{
    NSRange range = [msgContent rangeOfString:@"$!#"];
    NSString *jsonStr = [msgContent substringToIndex:range.location];
    if ([[Tools JSonFromString:jsonStr] isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = [Tools JSonFromString:jsonStr];
        if ([[dict objectForKey:@"t"] isEqualToString:@"e_p"])
        {
            scoreid = [dict objectForKey:@"e_id"];
            [self getScoreDetail];
        }
        else if ([[dict objectForKey:@"t"] isEqualToString:@"c_i"])
        {
//            NSString *classID = [dict objectForKey:@"c_id"];
            NSString *classID = jsonStr;
            
            NSRange range2 = [msgContent rangeOfString:@"["];
            NSRange range3 = [msgContent rangeOfString:@"—"];
            NSRange range4 = [msgContent rangeOfString:@"]"];
            if ([self isInThisClass:classID])
            {
                [Tools showAlertView:@"您已经是这个班的一员了" delegateViewController:nil];
                return;
            }
            
            NSString *schoolName;
            if (range2.length >0 && range4.length > 0 && range3.length > 0)
            {
                schoolName = [msgContent substringWithRange:NSMakeRange(range2.location+1,range4.location-range2.location-1)];
            }
            else
            {
                schoolName = @"";
            }
            
            NSString *className;
            if (range3.length >0 && range4.length>0)
            {
                className = [msgContent substringWithRange:NSMakeRange(range3.location+1, range4.location-range3.location-1)];
            }
            else
            {
                className = [msgContent substringWithRange:NSMakeRange(range2.location+1, range4.location-range2.location-1)];
            }
            
            ClassZoneViewController *classZone = [[ClassZoneViewController alloc] init];
            classZone.isApply = YES;
            [[NSUserDefaults standardUserDefaults] setObject:classID forKey:@"classid"];
            [[NSUserDefaults standardUserDefaults] setObject:className forKey:@"classname"];
            [[NSUserDefaults standardUserDefaults] setObject:schoolName forKey:@"schoolname"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.navigationController pushViewController:classZone animated:YES];
        }
    }
    else
    {
//        1411142370
        
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
    return NO;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [messageArray objectAtIndex:indexPath.row];
    [db deleteRecordWithDict:dict andTableName:@"chatMsg"];
    [self dealNewChatMsg:nil];
}

#pragma mark - 发送消息
-(void)sendMsgWithString:(NSString *)msgContent
{
    NSMutableDictionary *tmpChatDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [tmpChatDict setObject:@"" forKey:@"mid"];
    
    [tmpChatDict setObject:@"" forKey:@"time"];
    [tmpChatDict setObject:msgContent forKey:@"content"];
    [tmpChatDict setObject:[Tools user_id] forKey:@"userid"];
    [tmpChatDict setObject:[Tools user_id] forKey:@"fid"];
    [tmpChatDict setObject:[Tools user_name] forKey:@"fname"];
    [tmpChatDict setObject:[Tools header_image] forKey:@"ficon"];
    [tmpChatDict setObject:@"t" forKey:@"direct"];
    [tmpChatDict setObject:@"text" forKey:@"msgType"];
    [tmpChatDict setObject:toID forKey:@"tid"];
    [tmpChatDict setObject:@"1" forKey:@"readed"];
    [messageArray insertObject:tmpChatDict atIndex:[messageArray count]];
    [self reloadTableView];
    
    if ([Tools NetworkReachable])
    {
        NSDictionary *paraDict;
        NSString *subUrl;
        if (isGroup)
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"g_id":toID,
                         @"content":msgContent
                         };
            subUrl = GROUPCHAT;
        }
        else
        {
            paraDict = @{@"u_id":[Tools user_id],
              @"token":[Tools client_token],
              @"t_id":toID,
              @"content":msgContent
                         };
            subUrl = CREATE_CHAT_MSG;
        }
        
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:paraDict API:subUrl];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"chat responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSMutableDictionary *chatDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                NSString *messageID = [[responseDict objectForKey:@"data"] objectForKey:@"m_id"];
                
                [chatDict setObject:messageID forKey:@"mid"];
            
                [chatDict setObject:[CommonFunc from16To10:[messageID substringToIndex:8]] forKey:@"time"];
                [chatDict setObject:msgContent forKey:@"content"];
                [chatDict setObject:[Tools user_id] forKey:@"userid"];
                [chatDict setObject:[Tools user_id] forKey:@"fid"];
                [chatDict setObject:[Tools user_name] forKey:@"fname"];
                [chatDict setObject:@"null" forKey:@"ficon"];
                [chatDict setObject:@"t" forKey:@"direct"];
                [chatDict setObject:@"text" forKey:@"msgType"];
                [chatDict setObject:toID forKey:@"tid"];
                [chatDict setObject:@"1" forKey:@"readed"];
                
                
                
                if (isGroup)
                {
                    [chatDict setObject:[Tools user_id] forKey:@"by"];
                }
                
                if ([[db findSetWithDictionary:@{@"mid":messageID,@"userid":[Tools user_id]} andTableName:CHATTABLE] count] == 0)
                {
                    [db insertRecord:chatDict andTableName:CHATTABLE];
                }
                if ([self.chatVcDel respondsToSelector:@selector(updateChatList:)])
                {
                    [self.chatVcDel updateChatList:YES];
                }
                [self dealNewChatMsg:chatDict];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
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
    }
}

-(void)getScoreDetail
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"e_id":scoreid,
                                                                      } API:SCOREDETAIL];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"score detail responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
                
                NSArray *objectArray = [[responseDict objectForKey:@"data"] objectForKey:@"details"];
                if ([[responseDict objectForKey:@"isTeacher"] integerValue] == 0)
                {
                    ScoreDetailViewController *scoreDetailViewController = [[ScoreDetailViewController alloc] init];
                    scoreDetailViewController.scoreId = scoreid;
                    scoreDetailViewController.testName = [[responseDict objectForKey:@"data"] objectForKey:@"name"];
                    [self.navigationController pushViewController:scoreDetailViewController animated:YES];
                }
                else if([[responseDict objectForKey:@"isTeacher"] integerValue] == 1)
                {
                    ScoreMemListViewController *memlist = [[ScoreMemListViewController alloc] init];
                    memlist.scoreid = scoreid;
                    [memlist.memListArray addObjectsFromArray:objectArray];
                    [self.navigationController pushViewController:memlist animated:YES];
                }
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
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

-(void)recordFinished:(NSString *)filePath andFileName:(NSString *)fileName voiceLength:(int)length
{
    NSString *fileExtetion = [filePath pathExtension];
    NSRange range = [filePath rangeOfString:fileExtetion];
    NSString *pathStr = [filePath substringToIndex:range.location-1];
    [VoiceConverter wavToAmr:filePath amrSavePath:[NSString stringWithFormat:@"%@.amr",pathStr]];
    [self sendSound:length andFilePath:[NSString stringWithFormat:@"%@.amr",pathStr]];
    
    if ([[NSFileManager defaultManager] removeItemAtPath:filePath error:nil])
    {
        DDLOG(@"删除wav源文件成功！");
    }
    
    NSRange extentionRange = [filePath rangeOfString:[filePath pathExtension]];
    NSString *amrPath = [NSString stringWithFormat:@"%@.amr",[filePath substringToIndex:extentionRange.location-1]];
    if ([[NSFileManager defaultManager] removeItemAtPath:amrPath error:nil])
    {
        DDLOG(@"删除源amr文件成功！");
    }
    
}
@end

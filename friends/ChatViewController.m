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
ChatDelegate,
ReturnFunctionDelegate,
MessageDelegate,
updateGroupInfoDelegate>
{
    NSMutableArray *messageArray;
    UITableView *messageTableView;
    
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
}
@end

@implementation ChatViewController
@synthesize name,toID,imageUrl,chatVcDel,fromClass,isGroup;
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
    
    if (SYSVERSION > 7.0)
    {
        self.edgesForExtendedLayout =UIRectEdgeTop;
    }
    
    db = [[OperatDB alloc] init];
    
    currentSec = 0;
    iseditting = NO;
    
    faceViewHeight = 0;
    
    
    if (toID && name)
    {
        NSDictionary *userDict = [[NSDictionary alloc] initWithObjectsAndKeys:toID,@"uid",name,@"username",imageUrl,@"uicon", nil];
        if ([[db findSetWithDictionary:@{toID:@"uid"} andTableName:USERICONTABLE] count] == 0)
        {
            [db insertRecord:userDict andTableName:USERICONTABLE];
        }
        else
        {
            [db deleteRecordWithDict:@{toID:@"uid"} andTableName:USERICONTABLE];
            [db insertRecord:userDict andTableName:USERICONTABLE];
        }
    }
    
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(SCREEN_WIDTH-CORNERMORERIGHT, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
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
    
    if ([Tools NetworkReachable])
    {
        if(isGroup)
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
    [self dealNewChatMsg:nil];
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = self;
    
    inputTabBarH = 40;
    if ([toID isEqual:AssistantID])
    {
        inputTabBarH = 0;
        moreButton.hidden = YES;
    }
    
    inputTabBar = [[InputTableBar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-inputTabBarH+YSTART, SCREEN_WIDTH, inputTabBarH)];
    inputTabBar.backgroundColor = [UIColor whiteColor];
    inputTabBar.returnFunDel = self;
    inputTabBar.notOnlyFace = YES;
    inputTabBar.layer.anchorPoint = CGPointMake(0.5, 1);
    messageTableView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-inputTabBarH);
    [self.bgView addSubview:inputTabBar];
    [inputTabBar setLayout];
}

-(void)moreClick
{
//    if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"fid":toID} andTableName:FRIENDSTABLE] count] > 0)
//    {
//        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"解除好友关系",@"举报此人", nil];
//        ac.tag = MoreACTag;
//        [ac showInView:self.bgView];
//    }
//    else
//    {
//        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"添加为好友",@"举报此人", nil];
//        ac.tag = MoreACTag;
//        [ac showInView:self.bgView];
//    }
    
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报此人", nil];
        ac.tag = MoreACTag;
        [ac showInView:self.bgView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"chat" forKey:@"viewtype"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [MobClick beginLogPageView:@"PageOne"];
    [self uploadLastViewTime];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
    [self uploadLastViewTime];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"notchat" forKey:@"viewtype"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)dealloc
{
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

#pragma mark - getchatlog
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
                         };
        }
        else
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"t_id":toID,
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
                NSArray *array = [[NSArray alloc] initWithArray:[responseDict objectForKey:@"data"]];
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
                }
                [self dealNewChatMsg:nil];
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
                users = [[responseDict objectForKey:@"data"] objectForKey:@"users"];
                self.titleLabel.text = [[responseDict objectForKey:@"data"] objectForKey:@"name"];
                
                NSString *fname = [[responseDict objectForKey:@"data"] objectForKey:@"name"];
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
                NSDictionary *userIconDict = @{@"uid":toID,@"username":name,@"uicon":@""};
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
                [self getChatLog];
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

#pragma mark - lastViewTime
-(void)uploadLastViewTime
{
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
            DDLOG(@"friendsList responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
                
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

#pragma mark - returnfunctionDelegate
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
        if (messageTableView.contentSize.height>tmpheight)
        {
            messageTableView.contentOffset = CGPointMake(0, messageTableView.contentSize.height-messageTableView.frame.size.height+keyBoardHeight);
        }
        iseditting = YES;
    }];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [inputTabBar backKeyBoard];
    if (iseditting)
    {
        [self backInput];
    }
    
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
    else if([changeType isEqualToString:@"key"])
    {
        tmpheight = inputSize.height;
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
#pragma mark - chatDelegate
-(void)dealNewChatMsg:(NSDictionary *)dict
{
    [messageArray removeAllObjects];
    [messageArray addObjectsFromArray:[db findChatLogWithUid:[Tools user_id] andOtherId:toID andTableName:CHATTABLE]];
    if(dict)
    {
        if ([[dict objectForKey:@"content"] isEqualToString:@"给您发来一条新消息"]||
            [[dict objectForKey:@"content"] isEqualToString:@"给您发来一条新邀请"])
        {
            [self getChatLog];
        }
        else if(isGroup)
        {
            [self getChatLog];
        }
    }
    else
    {
        for (int i=0; i<[messageArray count]; ++i)
        {
            NSDictionary *tmpDict = [messageArray objectAtIndex:i];
            [db updeteKey:@"readed" toValue:@"1" withParaDict:@{@"fid":[tmpDict objectForKey:@"fid"],@"userid":[Tools user_id]} andTableName:CHATTABLE];
        }
        [messageTableView reloadData];
    }
    
    if (messageTableView.contentSize.height>messageTableView.frame.size.height)
    {
        messageTableView.contentOffset = CGPointMake(0, messageTableView.contentSize.height-messageTableView.frame.size.height+tmpheight);
    }
    if ([self.chatVcDel respondsToSelector:@selector(updateChatList:)])
    {
        [self.chatVcDel updateChatList:YES];
    }
}

#pragma mark - takepicture

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == MoreACTag)
    {
//        if (buttonIndex == 0)
//        {
//            if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"fid":toID} andTableName:FRIENDSTABLE] count] > 0)
//            {
//                UIAlertView *al = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"您确定与%@解除好友关系吗？",name] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定解除", nil];
//                al.tag = 3333;
//                [al show];
//            }
//            else
//            {
//                //添加为好友
//                [self addFriend];
//            }
//        }
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
}

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
        UIImage *originaImage = [info objectForKey:UIImagePickerControllerOriginalImage];
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
    return [messageArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block CGFloat rowHeight = 0;
    NSDictionary *dict = [messageArray objectAtIndex:indexPath.row];
    NSString *msgContent = [[messageArray objectAtIndex:indexPath.row] objectForKey:@"content"];
    CGSize size = [SizeTools getSizeWithString:[msgContent emojizedString] andWidth:SCREEN_WIDTH/2+20 andFont:[UIFont systemFontOfSize:14]];
    rowHeight = size.height+20;
    if ([[dict objectForKey:@"content"] rangeOfString:@"$!#"].length >0)
    {
        NSString *msgContent = [dict objectForKey:@"content"];
        NSRange range = [msgContent rangeOfString:@"$!#"];
        msgContent = [msgContent substringFromIndex:range.location+range.length];
        size = [SizeTools getSizeWithString:[msgContent emojizedString] andWidth:SCREEN_WIDTH/2+20 andFont:[UIFont systemFontOfSize:14]];
        rowHeight = size.height+40;
    }
    if ([[msgContent pathExtension] isEqualToString:@"png"] || [[msgContent pathExtension] isEqualToString:@"jpg"])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *imageUrlStr = [NSString stringWithFormat:@"%@/%@",IMAGEURL,msgContent];
            UIImage *msgImage = [ImageTools imageWithUrl:imageUrlStr];
            CGSize imageSize = [ImageTools getSizeFromImage:msgImage];
            rowHeight = imageSize.height;
        });
        
        
    }
    if (([[dict objectForKey:@"time"] integerValue] - currentSec) > 60*3  || indexPath.row == 0)
    {
//        currentSec = [[dict objectForKey:@"time"] integerValue];
//        rowHeight+=20;
    }
    if ([[dict objectForKey:DIRECT] isEqualToString:@"f"] && isGroup)
    {
        rowHeight += 20;
    }
    return rowHeight+20+20;
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
    
    if (([[dict objectForKey:@"time"] integerValue] - currentSec) > 60*3  || indexPath.row == 0)
    {
        cell.timeLabel.hidden = NO;
        currentSec = [[dict objectForKey:@"time"] integerValue];
    }
    else
    {
        cell.timeLabel.hidden = YES;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = self.bgView.backgroundColor;
    return cell;
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
        scoreid = [dict objectForKey:@"e_id"];
        [self getScoreDetail];
    }
    else
    {
//        1411142370
        NSRange range1 = [msgContent rangeOfString:@"$!#"];
        NSRange range2 = [msgContent rangeOfString:@"["];
        NSRange range3 = [msgContent rangeOfString:@"—"];
        NSRange range4 = [msgContent rangeOfString:@"]"];
        //    NSRange range5 = [msgContent rangeOfString:@"("];
        NSString *classID = [msgContent substringToIndex:range1.location];

        if ([self isInThisClass:classID])
        {
            [Tools showAlertView:@"您已经是这个班的一员了" delegateViewController:nil];
            return;
        }

        NSString *schoolName;
        if (range2.length >0 && range4.length > 0)
        {
            schoolName = [msgContent substringWithRange:NSMakeRange(range2.location+1,range4.location-range2.location-1)];
        }

        NSString *className;
        if (range3.length>0 && range4.length>0)
        {
            className = [msgContent substringWithRange:NSMakeRange(range3.location+1, range4.location-range3.location-1)];
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

#pragma mark - sendMsg
-(void)sendMsgWithString:(NSString *)msgContent
{
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
                    [chatDict setObject:msgContent forKey:@"content"];
                    [chatDict setObject:[Tools user_id] forKey:@"userid"];
                    [chatDict setObject:[Tools user_id] forKey:@"fid"];
                    [chatDict setObject:[Tools user_name] forKey:@"fname"];
                    [chatDict setObject:@"null" forKey:@"ficon"];
                    [chatDict setObject:[NSString stringWithFormat:@"%d",[[[responseDict objectForKey:@"data"] objectForKey:@"time"] integerValue]] forKey:@"time"];
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
                    [self dealNewChatMsg:nil];
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


@end

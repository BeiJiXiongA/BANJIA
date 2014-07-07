//
//  HomeViewController.m
//  BANJIA
//
//  Created by TeekerZW on 14-5-31.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "HomeViewController.h"
#import "MMProgressHUD.h"
#import "MMProgressHUDOverlayView.h"
#import "KKNavigationController.h"
#import "KKNavigationController+JDSideMenu.h"
#import "UINavigationController+JDSideMenu.h"
#import "PopView.h"
#import "DemoVIew.h"
#import "NotificationCell.h"
#import "AddDongTaiViewController.h"
#import "AddNotificationViewController.h"
#import "NotificationDetailViewController.h"
#import "TrendsCell.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "InputTableBar.h"
#import "MyButton.h"
#import "DongTaiDetailViewController.h"
#import "SearchClassViewController.h"
#import "CreateClassViewController.h"

#define ImageViewTag  9999
#define HeaderImageTag  7777
#define CellButtonTag   33333

#define SectionTag  999999
#define RowTag     100

#define ImageHeight  65.5f

#define ImageCountPerRow  4

@interface HomeViewController ()<
UITableViewDataSource,
UITableViewDelegate,
EGORefreshTableHeaderDelegate,
EGORefreshTableDelegate,
UIActionSheetDelegate,
ReturnFunctionDelegate,
NameButtonDel,
ClassZoneDelegate,
NotificationDetailDelegate,
NameButtonDel,
ChatDelegate,
MsgDelegate,
DongTaiDetailAddCommentDelegate>
{
    UIView *tipView;
    
    NSString *page;
    
    CGFloat commentHeight;
    
    BOOL addOpen;
    UIView *addView;
    MyButton *addNoticeButton;
    MyButton *addDiaryButton;
    NSDictionary *waitTransmitDict;
    NSDictionary *waitCommentDict;
    DemoVIew *demoView;
    
    CGFloat tmpheight;
    CGSize inputSize;
    CGFloat faceViewHeight;
    
    UITapGestureRecognizer *tapTgr;
    
    UITableView *classTableView;
    
    UIImageView *navImageView;
    
    NSMutableArray *noticeArray;
    NSMutableArray *diariesArray;
    NSMutableArray *groupDiaries;
    OperatDB *db;
    
    EGORefreshTableHeaderView *egoheaderView;
    FooterView *footerView;
    
    BOOL _reloading;
    
    InputTableBar *inputTabBar;
    
    UITapGestureRecognizer *backTgr;
    
    UIButton *addButton;
    
    UIButton *joinClassButton;
    UIButton *createClassButton;
    UILabel *tipLabel;
}
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)joinClass
{

    SearchClassViewController *searchclassVC = [[SearchClassViewController alloc] init];
    [[NSUserDefaults standardUserDefaults] setObject:CREATENEWCLASS forKey:SEARCHSCHOOLTYPE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController pushViewController:searchclassVC animated:YES];

}
-(void)createClass
{
    CreateClassViewController *createClassViewController = [[CreateClassViewController alloc] init];
    [[NSUserDefaults standardUserDefaults] setObject:CREATENEWCLASS forKey:SEARCHSCHOOLTYPE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController pushViewController:createClassViewController animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    page = @"0";
    
    commentHeight = 0;
    tmpheight = 0;
    
    db = [[OperatDB alloc]init];
    
    self.backButton.hidden = YES;
    self.returnImageView.hidden = YES;
    self.titleLabel.text = @"首页";
    self.titleLabel.frame = CGRectMake((SCREEN_WIDTH - [self.titleLabel.text length]*19)/2, self.titleLabel.frame.origin.y, [self.titleLabel.text length]*19, 30);
    self.titleLabel.hidden = YES;
    
    addOpen = NO;
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).ChatDelegate = self;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = self;
    
    backTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backInput)];
    
    noticeArray = [[NSMutableArray alloc] initWithCapacity:0];
    diariesArray = [[NSMutableArray alloc] initWithCapacity:0];
    groupDiaries = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIButton *navButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navButton setTitle:@"首页" forState:UIControlStateNormal];
    navButton.frame = CGRectMake((SCREEN_WIDTH - [self.titleLabel.text length]*20)/2, self.titleLabel.frame.origin.y, [self.titleLabel.text length]*20, 30);
    navButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [navButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [self.navigationBarView addSubview:navButton];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(5, 4, 42, 34);
    [moreButton setImage:[UIImage imageNamed:@"icon_list"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreOpen) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:moreButton];
    
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.backgroundColor = [UIColor clearColor];
    [addButton setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    addButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [addButton addTarget:self action:@selector(addButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:addButton];
    
    classTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    classTableView.delegate = self;
    classTableView.dataSource = self;
    classTableView.showsVerticalScrollIndicator = NO;
    classTableView.backgroundColor = [UIColor clearColor];
    classTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:classTableView];
    if ([classTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [classTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    egoheaderView = [[EGORefreshTableHeaderView alloc] initWithScrollView:classTableView orientation:EGOPullOrientationDown];
    egoheaderView.delegate = self;
    
    footerView = [[FooterView alloc] initWithScrollView:classTableView];
    footerView.delegate = self;
    
    addView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-147, UI_NAVIGATION_BAR_HEIGHT-10, 129, 95)];
//    addView.point = CGPointMake(90, 0);
//    addView.wid = 2;
    addView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:addView];
    
    DDLOG(@"ShareContent  %@",[[NSUserDefaults standardUserDefaults] objectForKey:ShareContentKey]);
    
    
    UIImageView *addBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, addView.frame.size.width, addView.frame.size.height)];
    [addBg setImage:[UIImage imageNamed:@"bor_bg"]];
    [addView addSubview:addBg];
    
    
    addNoticeButton = [MyButton buttonWithType:UIButtonTypeCustom];
    addNoticeButton.frame = CGRectMake(4, 54.5, 120, 38);
    addNoticeButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    addNoticeButton.alpha = 0;
    [addNoticeButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
//    [addNoticeButton setTitle:@"      添加通知" forState:UIControlStateNormal];
    [addNoticeButton setBackgroundImage:[UIImage imageNamed:@"release"] forState:UIControlStateNormal];
    [addNoticeButton setBackgroundImage:[UIImage imageNamed:@"release_on"] forState:UIControlStateHighlighted];
    [addView addSubview:addNoticeButton];
    [addNoticeButton addTarget:self action:@selector(addNotice) forControlEvents:UIControlEventTouchUpInside];
    
    addDiaryButton = [MyButton buttonWithType:UIButtonTypeCustom];
    addDiaryButton.frame = CGRectMake(4, 9, 120, 38);
    addDiaryButton.alpha = 0;
    [addDiaryButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    addDiaryButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
//    [addDiaryButton setTitle:@"      添加空间" forState:UIControlStateNormal];
    [addView addSubview:addDiaryButton];
    [addDiaryButton setBackgroundImage:[UIImage imageNamed:@"publish"] forState:UIControlStateNormal];
    [addDiaryButton setBackgroundImage:[UIImage imageNamed:@"publish_on"] forState:UIControlStateHighlighted];
    [addDiaryButton addTarget:self action:@selector(addDongtai) forControlEvents:UIControlEventTouchUpInside];
    
    
    addView.alpha = 0;
    addNoticeButton.alpha = 0;
    addDiaryButton.alpha = 0;
    
    if ([Tools NetworkReachable])
    {
        [self getHomeData];
        [self getHomeData];
    }
    else
    {
        [self getHomeCache];
    }
    
    inputTabBar = [[InputTableBar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 40)];
    inputTabBar.backgroundColor = [UIColor grayColor];
    inputTabBar.returnFunDel = self;
    [self.bgView addSubview:inputTabBar];
    inputSize = CGSizeMake(250, 30);
    
    
    tipView = [[UIView alloc] initWithFrame:CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT+90, SCREEN_WIDTH-20, 300)];
    tipView.backgroundColor = self.bgView.backgroundColor;
    [self.bgView addSubview:tipView];
    
    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-40, 70)];
    tipLabel.backgroundColor = self.bgView.backgroundColor;
    tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
    tipLabel.numberOfLines = 3;
    tipLabel.textColor = CONTENTCOLOR;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = @"您还没有加入任何一个班级，快来加入一个班级或创建一个自己的班级吧！";
    [tipView addSubview:tipLabel];
    
    joinClassButton = [UIButton buttonWithType:UIButtonTypeCustom];
    joinClassButton.frame = CGRectMake(80, 80, 140, 40);
    [joinClassButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [joinClassButton addTarget:self action:@selector(joinClass) forControlEvents:UIControlEventTouchUpInside];
    [joinClassButton setTitle:@"加入班级" forState:UIControlStateNormal];
    [tipView addSubview:joinClassButton];
    
    createClassButton = [UIButton buttonWithType:UIButtonTypeCustom];
    createClassButton.frame = CGRectMake(80, 130, 140, 40);
    [createClassButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [createClassButton addTarget:self action:@selector(createClass) forControlEvents:UIControlEventTouchUpInside];
    [createClassButton setTitle:@"创建班级" forState:UIControlStateNormal];
    [tipView addSubview:createClassButton];
    
    tipView.hidden = YES;

}

-(void)dealloc
{
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = nil;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = nil;
    inputTabBar.returnFunDel = nil;
}

-(void)dealNewChatMsg:(NSDictionary *)dict
{
    db = [[OperatDB alloc] init];
    NSMutableArray *array = [db findSetWithDictionary:@{@"userid":[Tools user_id],@"readed":@"0"} andTableName:CHATTABLE];
    if ([array count] > 0 || [[[NSUserDefaults standardUserDefaults] objectForKey:NewChatMsgNum] integerValue]>0)
    {
        self.unReadLabel.hidden = NO;
    }
    else
    {
        self.unReadLabel.hidden = YES;
    }
    DDLOG(@"new chatmsg array=%d",[array count]);
}

-(void)dealNewMsg:(NSDictionary *)dict
{
    if([[dict objectForKey:@"type"]isEqualToString:@"f_apply"])
    {
        if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"checked":@"0"} andTableName:FRIENDSTABLE] count] > 0)
        {
            self.unReadLabel.hidden = NO;
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self backInput];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self backInput];
    [self dealNewChatMsg:nil];
    [self dealNewMsg:nil];
}

-(void)getHomeData
{
    if ([Tools NetworkReachable])
    {
        NSDictionary *paraDict;
        if ([page intValue] == 0)
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token]};
        }
        else
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"page":page};
        }
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:paraDict
                                                                API:HOMEDATA];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"home responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([page integerValue] == 0)
                {
                    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@",HOMEDATA,[Tools user_id]];
                    NSString *key = [requestUrlStr MD5Hash];
                    [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
                    
                    [noticeArray removeAllObjects];
                    [diariesArray removeAllObjects];
                }
                addButton.hidden = NO;
                [noticeArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"notices"]];
                [diariesArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"diaries"]];
                
                if ([noticeArray count] == 0 && [diariesArray count] == 0)
                {
                    tipLabel.text = @"";
                    [joinClassButton setTitle:@"发表空间" forState:UIControlStateNormal];
                    [joinClassButton addTarget:self action:@selector(addDongtai) forControlEvents:UIControlEventTouchUpInside];
                    
                    [createClassButton setTitle:@"发布通知" forState:UIControlStateNormal];
                    [createClassButton addTarget:self action:@selector(addNotice) forControlEvents:UIControlEventTouchUpInside];
                    tipLabel.hidden = NO;
                }
                
                [self groupByTime:diariesArray];
//                [classTableView reloadData];
            }
            else
            {
                if ([[[[responseDict objectForKey:@"message"] allKeys] firstObject] isEqualToString:@"NO_CLASS"])
                {
                    tipView.hidden = NO;
                    addButton.hidden = YES;
                    return ;
                }
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
            _reloading = NO;
            [egoheaderView egoRefreshScrollViewDataSourceDidFinishedLoading:classTableView];
            [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:classTableView];
            if ([page integerValue] > 0)
            {
                if (footerView)
                {
                    [footerView removeFromSuperview];
                    footerView = [[FooterView alloc] initWithScrollView:classTableView];
                    footerView.delegate = self;
                }
                else
                {
                    footerView = [[FooterView alloc] initWithScrollView:classTableView];
                    footerView.delegate = self;
                }
                _reloading = NO;
                [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:classTableView];
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

-(void)getHomeCache
{
    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@",HOMEDATA,[Tools user_id]];
    NSString *key = [requestUrlStr MD5Hash];
    NSData *cacheData = [FTWCache objectForKey:key];
    if ([cacheData length] > 0)
    {
        NSString *responseString = [[NSString alloc] initWithData:cacheData encoding:NSUTF8StringEncoding];
        NSDictionary *responseDict = [Tools JSonFromString:responseString];
        if ([[responseDict objectForKey:@"code"] intValue]== 1)
        {
            [noticeArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"notices"]];
            [diariesArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"diaries"]];
            [self groupByTime:diariesArray];
            //                [classTableView reloadData];
        }
        else
        {
            if ([[[[responseDict objectForKey:@"message"] allKeys] firstObject] isEqualToString:@"NO_CLASS"])
            {
                tipView.hidden = NO;
                return ;
            }
            [Tools dealRequestError:responseDict fromViewController:nil];
        }

    }
}

#pragma mark - inputtabbardel
-(void)myReturnFunction
{
    DDLOG(@"comment content in home %@",inputTabBar.inputTextView.text);
    if ([[inputTabBar analyString:inputTabBar.inputTextView.text] length] <= 0)
    {
        [Tools showAlertView:@"请输入评论内容！" delegateViewController:nil];
        return ;
    }
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":[waitCommentDict objectForKey:@"_id"],
                                                                      @"c_id":[waitCommentDict objectForKey:@"c_id"],
                                                                      @"content":[inputTabBar analyString:inputTabBar.inputTextView.text]
                                                                      } API:COMMENT_DIARY];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"commit diary responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
//                [Tools showTips:@"评论成功" toView:classTableView];
                [self getHomeData];
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

    
    inputSize = CGSizeMake(250, 30);
    [UIView animateWithDuration:0.2 animations:^{
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10, SCREEN_WIDTH, inputSize.height+10);
        [self backInput];
    }];
}


#pragma mark - egodelegate
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    page = @"0";
    [self getHomeData];
}

-(void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
    NSInteger pageNum = [page integerValue];
    page = [NSString stringWithFormat:@"%d",++pageNum];
    [self getHomeData];
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
    [egoheaderView egoRefreshScrollViewDidScroll:classTableView];
    if (scrollView.contentOffset.y+(scrollView.frame.size.height) > scrollView.contentSize.height+65)
    {
        [footerView egoRefreshScrollViewDidScroll:classTableView];
    }
    [self backInput];
    [inputTabBar backKeyBoard];
}
-(void)backInput
{
    [classTableView removeGestureRecognizer:backTgr];
    [UIView animateWithDuration:0.2 animations:^{
        [inputTabBar.inputTextView resignFirstResponder];
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, inputSize.height+10);
    }];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [egoheaderView egoRefreshScrollViewDidEndDragging:classTableView];
    [footerView egoRefreshScrollViewDidEndDragging:classTableView];
}


-(void)addNotice
{
    AddNotificationViewController *addnotification = [[AddNotificationViewController alloc] init];
    addnotification.fromClass = NO;
    if (addOpen)
    {
        addOpen = NO;
        [self closeAdd];
    }
    [self.navigationController pushViewController:addnotification animated:YES];
}
-(void)addDongtai
{
    AddDongTaiViewController *addDongtaiViewController = [[AddDongTaiViewController alloc] init];
    addDongtaiViewController.fromCLass = NO;
    addDongtaiViewController.classZoneDelegate = self;
    if (addOpen)
    {
        addOpen = NO;
        [self closeAdd];
    }
    [self.navigationController pushViewController:addDongtaiViewController animated:YES];
}

-(void)haveAddDonfTai:(BOOL)add
{
    if (add)
    {
        page = @"0";
        [self getHomeData];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [noticeArray count] + ([groupDiaries count]>0?([groupDiaries count]+1):0);
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([noticeArray count] > 0)
    {
        if (section == [noticeArray count])
        {
            return 40;
        }
        return 40;
    }
    else
    {
        if (section == 0)
        {
            return 40;
        }
        else
            return 40;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = UIColorFromRGB(0xf1f0ec);
    
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.font = [UIFont systemFontOfSize:16];
    headerLabel.backgroundColor = UIColorFromRGB(0xf1f0ec);
    headerLabel.textColor = TITLE_COLOR;
    if (section < [noticeArray count])
    {
        NSDictionary *noticeDict = [noticeArray objectAtIndex:section];
        headerLabel.text = [NSString stringWithFormat:@"    %@未读通知",[noticeDict objectForKey:@"name"]];
        headerLabel.frame = CGRectMake(0, 5, SCREEN_WIDTH, 30);
    }
    else if (section == [noticeArray count])
    {
        UIView *verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(34.75, 10, 1.5, 30)];
        verticalLineView.backgroundColor = UIColorFromRGB(0xe2e3e4);
        [headerView addSubview:verticalLineView];
        
        headerLabel.backgroundColor = RGB(64, 196, 110, 1);
        headerLabel.text = @"    班级空间";
        headerLabel.font = [UIFont boldSystemFontOfSize:15];
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.frame = CGRectMake(0, 5, SCREEN_WIDTH, 30);
    }
    else
    {
        
        UIView *verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(34.75, 0, 1.5, 40)];
        verticalLineView.backgroundColor = UIColorFromRGB(0xe2e3e4);
        [headerView addSubview:verticalLineView];
        
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(28, 12.5, 15, 15)];
        dotView.layer.cornerRadius = 7.5;
        dotView.clipsToBounds = YES;
        dotView.layer.borderColor = [UIColor whiteColor].CGColor;
        dotView.layer.borderWidth = 1.5;
        dotView.backgroundColor = RGB(64, 196, 110, 1);
        [headerView addSubview:dotView];
//        int cha = [noticeArray count]>0?([noticeArray count]+1):0;
        NSDictionary *groupDict = [groupDiaries objectAtIndex:section-[noticeArray count]-1];
//        headerLabel.backgroundColor = RGB(64, 196, 110, 1);
        headerLabel.text = [groupDict objectForKey:@"date"];
//        headerLabel.font = [UIFont boldSystemFontOfSize:15];
//        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.frame = CGRectMake(50, 5, SCREEN_WIDTH, 30);
        
    }
    [headerView addSubview:headerLabel];
    return headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < [noticeArray count])
    {
        return [[[noticeArray objectAtIndex:section] objectForKey:@"news"] count];
    }
    else if(section > [noticeArray count])
    {
        if ([noticeArray count] > 0)
        {
            int cha = [noticeArray count]>0?([noticeArray count]+1):0;
            NSDictionary *groupDict = [groupDiaries objectAtIndex:section-cha];
            NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
            return [tmpArray count];
        }
        else
        {
            NSDictionary *groupDict = [groupDiaries objectAtIndex:section-1];
            NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
            return [tmpArray count];
        }
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [noticeArray count])
    {
        return 88;
    }
    else if(indexPath.section > [noticeArray count])
    {
        CGFloat he=0;
        if (SYSVERSION>=7)
        {
            he = 5;
        }
            //                CGFloat imageWidth = 60;
        CGFloat imageViewHeight = ImageHeight;
        int cha = [noticeArray count]>0?([noticeArray count]+1):0;
        NSDictionary *groupDict;
        if ([noticeArray count] > 0)
        {
            groupDict = [groupDiaries objectAtIndex:indexPath.section-cha];
        }
        else
        {
            groupDict = [groupDiaries objectAtIndex:indexPath.section-1];
        }
        
        NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
        NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
        NSString *content = [[dict objectForKey:@"detail"] objectForKey:@"content"];
        NSArray *imgsArray = [[[dict objectForKey:@"detail"] objectForKey:@"img"] count]>0?[[dict objectForKey:@"detail"] objectForKey:@"img"]:nil;
        NSInteger imageCount = [imgsArray count];
        NSInteger row = 0;
        if (imageCount % ImageCountPerRow > 0)
        {
            row = (imageCount/ImageCountPerRow+1) > 3 ? 3:(imageCount / ImageCountPerRow + 1);
        }
        else
        {
            row = (imageCount/ImageCountPerRow) > 3 ? 3:(imageCount / ImageCountPerRow);
        }
        
        CGFloat imgsHeight = row * (imageViewHeight+5);
        CGFloat contentHtight = [content length]>0?(45+he):5;
        CGFloat tmpcommentHeight = 0;
        if ([[dict objectForKey:@"comments_num"] integerValue] > 0)
        {
            NSArray *array = [[dict objectForKey:@"detail"] objectForKey:@"comments"];
            for (int i=0; i<([array count]>6?6:[array count]); ++i)
            {
                NSDictionary *dict = [array objectAtIndex:i];
                NSString *name = [[dict objectForKey:@"by"] objectForKey:@"name"];
                NSString *content = [dict objectForKey:@"content"];
                NSString *contentString = [NSString stringWithFormat:@"%@:%@",name,content];
                CGSize s = [Tools getSizeWithString:contentString andWidth:200 andFont:[UIFont systemFontOfSize:14]];
                tmpcommentHeight += (s.height > 25 ? (s.height+13):35);
            }
            if ([array count] >6)
            {
                tmpcommentHeight += 35;
            }
        }
        if ([[dict objectForKey:@"likes_num"] integerValue] > 0)
        {
//            int row = [[dict objectForKey:@"likes_num"] integerValue]%4 == 0 ? ([[dict objectForKey:@"likes_num"] integerValue]/4):([[dict objectForKey:@"likes_num"] integerValue]/4+1);
            tmpcommentHeight += 36;
        }
        return 60+imgsHeight+contentHtight+50 + tmpcommentHeight+6;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [noticeArray count])
    {
        static NSString *notiCell = @"homenotiCell";
        NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:notiCell];
        if (cell == nil)
        {
            cell = [[NotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:notiCell];
        }
        
        NSDictionary *noticeDict = [noticeArray objectAtIndex:indexPath.section];
        NSArray *tmpArray = [noticeDict objectForKey:@"news"];
        
        NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
        
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
        
        cell.contentLabel.text = noticeContent;
        cell.contentLabel.backgroundColor = [UIColor clearColor];
        cell.contentLabel.font = [UIFont systemFontOfSize:16];
        cell.contentLabel.textColor = CONTENTCOLOR;
        cell.contentLabel.contentMode = UIViewContentModeTop;
        cell.contentLabel.frame = CGRectMake(40, 15, SCREEN_WIDTH-62, height);
        
       
        
        cell.statusLabel.textColor = TIMECOLOR;
        cell.statusLabel.frame = CGRectMake(SCREEN_WIDTH-150, 60.5, 130, 15);
        
        cell.timeLabel.frame = CGRectMake(40, 58, 240, 20);
        cell.timeLabel.font = [UIFont systemFontOfSize:12];
        cell.timeLabel.text = [NSString stringWithFormat:@"%@发布于%@",byName,[Tools showTime:[NSString stringWithFormat:@"%d",[[[dict objectForKey:@"created"] objectForKey:@"sec"] integerValue]]]];
        cell.timeLabel.textColor = TIMECOLOR;
        
         cell.iconImageView.frame = CGRectMake(20, 17, 12, 12);
//        [cell.iconImageView setImage:[UIImage imageNamed:@"unreadicon"]];
        cell.iconImageView.layer.cornerRadius = 6;
        cell.iconImageView.clipsToBounds = YES;
        cell.iconImageView.backgroundColor = RGB(228, 76, 76, 1);
        cell.iconImageView.layer.borderColor = RGB(227, 63, 64, 1).CGColor;
        cell.iconImageView.layer.borderWidth = 1;
        
        cell.statusLabel.text =[NSString stringWithFormat:@"%d人已读 %d人未读",[[dict objectForKey:@"read_num"] integerValue],[[dict objectForKey:@"unread_num"] integerValue]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    else if(indexPath.section > [noticeArray count])
    {
        static NSString *topImageView = @"hometrendcell";
        TrendsCell *cell = [tableView dequeueReusableCellWithIdentifier:topImageView];
        if (cell == nil)
        {
            cell = [[TrendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topImageView];
        }
        
        CGFloat left = 9.5;
        cell.showAllComments = NO;
        cell.nameButtonDel = self;
        NSDictionary *groupDict = [groupDiaries objectAtIndex:indexPath.section-[noticeArray count]-1];
        NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
        NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
        cell.diaryDetailDict = dict;
        NSString *name = [[dict objectForKey:@"by"] objectForKey:@"name"];
        
        NSString *nameStr = name;
        
        cell.headerImageView.hidden = NO;
        cell.nameLabel.hidden = NO;
        cell.timeLabel.hidden = NO;
        cell.locationLabel.hidden = NO;
        cell.praiseButton.hidden = NO;
        cell.commentButton.hidden = NO;
        cell.transmitButton.hidden = NO;
        
        cell.commentsTableView.frame = CGRectMake(0, 0, 0, 0);
        
        cell.nameLabel.frame = CGRectMake(60, 5, [nameStr length]*18>170?170:([nameStr length]*18), 25);
        cell.nameLabel.text = nameStr;
        cell.nameLabel.font = NAMEFONT;
        cell.nameLabel.textColor = NAMECOLOR;
        
        NSString *timeStr = [Tools showTimeOfToday:[NSString stringWithFormat:@"%d",[[[dict objectForKey:@"created"] objectForKey:@"sec"] integerValue]]];
        NSString *c_name = [dict objectForKey:@"c_name"];
        cell.timeLabel.text = c_name;
        cell.timeLabel.frame = CGRectMake(SCREEN_WIDTH-[c_name length]*18-30, 2, [c_name length]*18, 35);
        cell.timeLabel.textAlignment = NSTextAlignmentRight;
        cell.timeLabel.numberOfLines = 2;
        cell.timeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.timeLabel.textColor = COMMENTCOLOR;
        
        cell.headerImageView.backgroundColor = [UIColor clearColor];
        
        [Tools fillImageView:cell.headerImageView withImageFromURL:[[dict objectForKey:@"by"] objectForKey:@"img_icon"] andDefault:HEADERBG];
        cell.locationLabel.frame = CGRectMake(60, cell.headerImageView.frame.origin.y+cell.headerImageView.frame.size.height-LOCATIONLABELHEI, SCREEN_WIDTH-90, LOCATIONLABELHEI);
        cell.locationLabel.text = [NSString stringWithFormat:@"于%@在%@",timeStr,[[dict objectForKey:@"detail"] objectForKey:@"add"]];
        cell.locationLabel.numberOfLines = 1;
        cell.locationLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
        
        cell.contentLabel.hidden = YES;
        cell.contentLabel.backgroundColor = [UIColor clearColor];
        
        int cha = [noticeArray count]+1;
        
        for(UIView *v in cell.imagesView.subviews)
        {
            if ([v isKindOfClass:[UIImageView class]])
            {
                [v removeFromSuperview];
            }
        }
        if (![[[dict objectForKey:@"detail"] objectForKey:@"content"] length] <=0)
        {
            CGFloat he = 0;
            if (SYSVERSION >= 7)
            {
                he = 5;
            }
            //有文字
            NSString *content = [[[dict objectForKey:@"detail"] objectForKey:@"content"] emojizedString];
            cell.contentLabel.hidden = NO;
            cell.contentLabel.editable = NO;
            cell.contentLabel.textColor = CONTENTCOLOR;
            if ([content length] > 40)
            {
                cell.contentLabel.text  = [NSString stringWithFormat:@"%@...",[content substringToIndex:37]];
            }
            else
            {
                cell.contentLabel.text = content;
            }
            cell.contentLabel.frame = CGRectMake(10, 55, SCREEN_WIDTH-20, 45);
        }
        else
        {
            cell.contentLabel.frame = CGRectMake(10, 60, 0, 0);
        }
        
        CGFloat imageViewHeight = ImageHeight;
        CGFloat imageViewWidth = ImageHeight;
        if ([[[dict objectForKey:@"detail"] objectForKey:@"img"] count] > 0)
        {
            //有图片
            
            NSArray *imgsArray = [[dict objectForKey:@"detail"] objectForKey:@"img"];
            NSInteger imageCount = [imgsArray count];
            if (imageCount == -1)
            {
                cell.imagesView.frame = CGRectMake((SCREEN_WIDTH-ImageHeight*ImageCountPerRow)/2,
                                                   cell.contentLabel.frame.size.height +
                                                   cell.contentLabel.frame.origin.y+7,
                                                   100, 100);
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.frame = CGRectMake(0, 0, 100, 100);
                imageView.userInteractionEnabled = YES;
                imageView.tag = (indexPath.section-[noticeArray count]-1)*SectionTag+indexPath.row*RowTag+333;
                
                imageView.userInteractionEnabled = YES;
                [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
                
                // 内容模式
                imageView.clipsToBounds = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                [Tools fillImageView:imageView withImageFromURL:[imgsArray firstObject] imageWidth:100.0f andDefault:@"3100"];
                //                    [Tools fillImageView:imageView withImageFromURL:[imgsArray firstObject] ];
                [cell.imagesView addSubview:imageView];
            }
            else
            {
                NSInteger row = 0;
                if (imageCount % ImageCountPerRow > 0)
                {
                    row = (imageCount/ImageCountPerRow+1) > 3 ? 3:(imageCount / ImageCountPerRow + 1);
                }
                else
                {
                    row = (imageCount/ImageCountPerRow) > 3 ? 3:(imageCount / ImageCountPerRow);
                }
                cell.imagesView.frame = CGRectMake(12,
                                                   cell.contentLabel.frame.size.height +
                                                   cell.contentLabel.frame.origin.y+7,
                                                   SCREEN_WIDTH-44, (imageViewHeight+5) * row);
                
                for (int i=0; i<[imgsArray count]; ++i)
                {
                    UIImageView *imageView = [[UIImageView alloc] init];
                    imageView.frame = CGRectMake((i%(NSInteger)ImageCountPerRow)*(imageViewWidth+5), (imageViewWidth+5)*(i/(NSInteger)ImageCountPerRow), imageViewWidth, imageViewHeight);
                    imageView.userInteractionEnabled = YES;
                    imageView.tag = (indexPath.section-[noticeArray count]-1)*SectionTag+indexPath.row*RowTag+i+333;
                    
                    imageView.userInteractionEnabled = YES;
                    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
                    
                    // 内容模式
                    imageView.clipsToBounds = YES;
                    imageView.contentMode = UIViewContentModeScaleAspectFill;
                    [Tools fillImageView:imageView withImageFromURL:[imgsArray objectAtIndex:i] andDefault:@"3100"];
                    [cell.imagesView addSubview:imageView];
                }
                
            }
        }
        else
        {
            cell.imagesView.frame = CGRectMake(5, cell.contentLabel.frame.size.height+cell.contentLabel.frame.origin.y, SCREEN_WIDTH-10, 0);
        }
        
        CGFloat cellHeight = cell.headerImageView.frame.size.height+cell.contentLabel.frame.size.height+cell.imagesView.frame.size.height+18;
        
        CGFloat he = 0;
        //            if (SYSVERSION >= 7.0)
        {
            he = 5;
        }
        
        CGFloat buttonHeight = 37;
        CGFloat iconH = 18;
        CGFloat iconTop = 9;
        
        cell.transmitButton.frame = CGRectMake(0, cellHeight+13, (SCREEN_WIDTH-left*2)/3, buttonHeight);
        [cell.transmitButton setTitle:@"   转发" forState:UIControlStateNormal];
        cell.transmitButton.iconImageView.image = [UIImage imageNamed:@"icon_forwarding"];
        cell.transmitButton.tag = (indexPath.section-cha)*SectionTag+indexPath.row;
        [cell.transmitButton addTarget:self action:@selector(transmitDiary:) forControlEvents:UIControlEventTouchUpInside];
        cell.transmitButton.iconImageView.frame = CGRectMake(18, iconTop+1, iconH, iconH);
        cell.transmitButton.backgroundColor = UIColorFromRGB(0xfcfcfc);
        
        
        if ([[dict objectForKey:@"likes_num"] integerValue] > 0)
        {
            [cell.praiseButton setTitle:[NSString stringWithFormat:@"    %d",[[dict objectForKey:@"likes_num"] integerValue]] forState:UIControlStateNormal];
        }
        else
        {
            [cell.praiseButton setTitle:@" 赞" forState:UIControlStateNormal];
        }
        if ([self havePraisedThisDiary:dict])
        {
            cell.praiseButton.iconImageView.image = [UIImage imageNamed:@"praised"];
            cell.praiseButton.iconImageView.frame = CGRectMake(27, iconTop, iconH, iconH);
        }
        else
        {
            cell.praiseButton.iconImageView.image = [UIImage imageNamed:@"icon_heart"];
            cell.praiseButton.iconImageView.frame = CGRectMake(25, iconTop, iconH, iconH);
        }
        
        [cell.praiseButton addTarget:self action:@selector(praiseDiary:) forControlEvents:UIControlEventTouchUpInside];
        cell.praiseButton.tag = (indexPath.section-cha)*SectionTag+indexPath.row;
        cell.praiseButton.frame = CGRectMake((SCREEN_WIDTH-left*2)/3, cellHeight+13, (SCREEN_WIDTH-left*2)/3, buttonHeight);
        cell.praiseButton.backgroundColor = UIColorFromRGB(0xfcfcfc);
        
        
        if ([[dict objectForKey:@"comments_num"] integerValue] > 0)
        {
            [cell.commentButton setTitle:[NSString stringWithFormat:@"   %d",[[dict objectForKey:@"comments_num"] integerValue]] forState:UIControlStateNormal];
            cell.commentButton.iconImageView.frame = CGRectMake(25, iconTop, iconH, iconH);
        }
        else
        {
            [cell.commentButton setTitle:@"  评论" forState:UIControlStateNormal];
            cell.commentButton.iconImageView.frame = CGRectMake(18, iconTop, iconH, iconH);
        }
        cell.commentButton.frame = CGRectMake((SCREEN_WIDTH-left*2)/3*2, cellHeight+13, (SCREEN_WIDTH-left*2)/3, buttonHeight);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.commentButton.backgroundColor = UIColorFromRGB(0xfcfcfc);
        cell.commentButton.tag = (indexPath.section-cha)*SectionTag+indexPath.row;
        [cell.commentButton addTarget:self action:@selector(commentDiary:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.geduan1.hidden = NO;
        cell.geduan2.hidden = NO;
        
        cell.geduan1.frame = CGRectMake(cell.transmitButton.frame.size.width+cell.transmitButton.frame.origin.x, cell.transmitButton.frame.origin.y+9.5, 1, 18);
        cell.geduan2.frame = CGRectMake(cell.praiseButton.frame.size.width+cell.praiseButton.frame.origin.x, cell.praiseButton.frame.origin.y+9.5, 1, 18);
        
        cell.backgroundColor = [UIColor clearColor];
        
        if ([[dict objectForKey:@"comments_num"] integerValue] > 0 || [dict objectForKey:@"likes_num"] > 0)
        {
            NSArray *comArray = [[dict objectForKey:@"detail"] objectForKey:@"comments"];
            if ([comArray count] > 0)
            {
                cell.commentsArray = comArray;
            }
            else
            {
                cell.commentsArray = nil;
            }
            NSArray *praiseArray = [[dict objectForKey:@"detail"] objectForKey:@"likes"];
            if ([praiseArray count] > 0)
            {
                cell.praiseArray = praiseArray;
            }
            else
            {
                cell.praiseArray = nil;
            }
            [cell.commentsTableView reloadData];
            cell.commentsTableView.frame = CGRectMake(0, cell.praiseButton.frame.size.height+cell.praiseButton.frame.origin.y, SCREEN_WIDTH, cell.commentsTableView.contentSize.height);
            cell.bgView.frame = CGRectMake(left, 0, SCREEN_WIDTH-left*2,
                                           cell.commentsTableView.frame.size.height+
                                           cell.commentsTableView.frame.origin.y);
        }
        else
        {
            cell.commentsArray = nil;
            cell.praiseArray = nil;
            [cell.commentsTableView reloadData];
            cell.bgView.frame = CGRectMake(left, 0, SCREEN_WIDTH-left*2,
                                           cell.praiseButton.frame.size.height+
                                           cell.praiseButton.frame.origin.y);
        }
        cell.bgView.layer.cornerRadius = 5;
        cell.bgView.clipsToBounds = YES;
        cell.bgView.backgroundColor = [UIColor whiteColor];
        
        cell.verticalLineView.frame = CGRectMake(34.75, 0, 1.5, cell.bgView.frame.size.height+10);
        
        return cell;
    }
    return nil;
}

-(BOOL)havePraisedThisDiary:(NSDictionary *)diaryDict
{
    NSArray *praiseArray = [[diaryDict objectForKey:@"detail"] objectForKey:@"likes"];
    for (int i = 0; i < [praiseArray count]; i++)
    {
        NSDictionary *dict = [praiseArray objectAtIndex:i];
        DDLOG(@"praise dict %@",dict);
        if ([[[dict objectForKey:@"by"] objectForKey:@"_id"] isEqualToString:[Tools user_id]])
        {
            return YES;
        }
    }
    return NO;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [noticeArray count])
    {
        NSDictionary *dict = [[[noticeArray objectAtIndex:indexPath.section] objectForKey:@"news"] objectAtIndex:indexPath.row];
        DDLOG(@"home notice dict %@",dict);
        NotificationDetailViewController *notificationDetailViewController = [[NotificationDetailViewController alloc] init];
        notificationDetailViewController.noticeID = [dict objectForKey:@"_id"];
        notificationDetailViewController.noticeContent = [dict objectForKey:@"content"];
        notificationDetailViewController.c_read = @"1";
        notificationDetailViewController.markString = [NSString stringWithFormat:@"%@发布于%@",[[dict objectForKey:@"by"] objectForKey:@"name"],[Tools showTime:[NSString stringWithFormat:@"%d",[[[dict objectForKey:@"created"] objectForKey:@"sec"] integerValue]]]];
        notificationDetailViewController.readnotificationDetaildel = self;
        notificationDetailViewController.isnew = YES;
        notificationDetailViewController.fromClass = NO;
        notificationDetailViewController.byID = [[dict objectForKey:@"by"] objectForKey:@"_id"];
        [self.navigationController pushViewController:notificationDetailViewController animated:YES];
    }
    else
    {
        NSDictionary *groupDict = [groupDiaries objectAtIndex:indexPath.section-[noticeArray count]-1];
        NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
        NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
        DongTaiDetailViewController *dongtaiDetailViewController = [[DongTaiDetailViewController alloc] init];
        dongtaiDetailViewController.dongtaiId = [dict objectForKey:@"_id"];
        dongtaiDetailViewController.fromclass = NO;
        dongtaiDetailViewController.addComDel = self;
        
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"c_id"] forKey:@"classid"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
//        dongtaiDetailViewController.addComDel = self;
        [self.navigationController pushViewController:dongtaiDetailViewController animated:YES];
    }
}

-(void)readNotificationDetail
{
    [self getHomeData];
}

- (void)tapImage:(UITapGestureRecognizer *)tap
{
    if ([inputTabBar.inputTextView isFirstResponder])
    {
        [self backInput];
        [inputTabBar backKeyBoard];
    }
    
    NSDictionary *groupDict = [groupDiaries objectAtIndex:(tap.view.tag-333)/SectionTag];
    NSArray *array = [groupDict objectForKey:@"diaries"];
    NSDictionary *dict = [array objectAtIndex:(tap.view.tag-333)%SectionTag/RowTag];
    NSArray *imgs = [[dict objectForKey:@"detail"] objectForKey:@"img"];
    int count = [imgs count];
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        NSString *url = [NSString stringWithFormat:@"%@%@",IMAGEURL,imgs[i]];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:url];
        photo.srcImageView = (UIImageView *)[self.bgView viewWithTag:tap.view.tag]; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = ((tap.view.tag-333)%SectionTag)%RowTag; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}


-(void)praiseDiary:(UIButton *)button
{
    NSDictionary *groupDict = [groupDiaries objectAtIndex:button.tag/SectionTag];
    NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
    NSDictionary *dict = [tmpArray objectAtIndex:button.tag%SectionTag];
    DDLOG(@"home diary %@",[[dict objectForKey:@"detail"] objectForKey:@"content"]);
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":[dict objectForKey:@"_id"],
                                                                      @"c_id":[dict objectForKey:@"c_id"],
                                                                      } API:LIKE_DIARY];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"commit diary responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
//                [Tools showTips:@"赞成功" toView:classTableView];
                [self getHomeData];
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

-(void)addComment:(BOOL)add
{
    if (add)
    {
        [self getHomeData];
    }
}


-(void)commentDiary:(UIButton *)button
{
    NSDictionary *groupDict = [groupDiaries objectAtIndex:button.tag/SectionTag];
    NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
    waitCommentDict = [tmpArray objectAtIndex:button.tag%SectionTag];
    [inputTabBar.inputTextView becomeFirstResponder];
}

-(void)showKeyBoard:(CGFloat)keyBoardHeight
{
    [classTableView addGestureRecognizer:backTgr];
    [UIView animateWithDuration:0.2 animations:^{
        tmpheight = keyBoardHeight;
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10-keyBoardHeight, SCREEN_WIDTH, inputSize.height+10+ FaceViewHeight);
    }];
}

-(void)changeInputType:(NSString *)changeType
{
    if ([changeType isEqualToString:@"face"])
    {
        faceViewHeight = FaceViewHeight;
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10-faceViewHeight, SCREEN_WIDTH, inputSize.height+10 + faceViewHeight);
    }
    else if([changeType isEqualToString:@"key"])
    {
        faceViewHeight = inputSize.height;
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10-tmpheight, SCREEN_WIDTH, inputSize.height+10 + faceViewHeight);
    }
}

-(void)changeInputViewSize:(CGSize)size
{
    inputSize = size;
    [UIView animateWithDuration:0.2 animations:^{
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-size.height-10-tmpheight, SCREEN_WIDTH, size.height+10+faceViewHeight);
    }];
}


-(void)groupByTime:(NSArray *)array
{
    NSString *timeStr;
    int index = 0;
    [groupDiaries removeAllObjects];
    for (int i=index; i<[array count]; i++)
    {
        NSDictionary *dict = [array objectAtIndex:i];
        if ([dict isEqual:[NSNull null]])
        {
            continue ;
        }
        CGFloat sec = [[[dict objectForKey:@"created"] objectForKey:@"sec"] floatValue];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MM月dd日"];
        NSDate *datetimeDate = [NSDate dateWithTimeIntervalSince1970:sec];
        timeStr = [dateFormatter stringFromDate:datetimeDate];
        
        NSMutableDictionary *groupDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [groupDict setObject:timeStr forKey:@"date"];
        NSMutableArray *array2 = [[NSMutableArray alloc] initWithCapacity:0];
        [array2 addObject:dict];
        
        for (int j=i+1; j<[array count]; j++)
        {
            NSDictionary *dict2 = [array objectAtIndex:j];
            if ([dict2 isEqual:[NSNull null]])
            {
                continue;
            }
            CGFloat sec2 = [[[dict2 objectForKey:@"created"] objectForKey:@"sec"] floatValue];
            NSDate *datetimeDate2 = [NSDate dateWithTimeIntervalSince1970:sec2];
            NSString * timeStr2 = [dateFormatter stringFromDate:datetimeDate2];
            if ([timeStr2 isEqualToString:timeStr])
            {
                [array2 addObject:dict2];
            }
            else
            {
                index = j;
                break;
            }
        }
        if ([array2 count] > 0)
        {
            if (![self haveThisTime:timeStr])
            {
                [groupDict setObject:array2 forKey:@"diaries"];
                [groupDiaries addObject:groupDict];
            }
        }
    }
//    if ([tmpArray count]>0)
//    {
//        noneDongTaiLabel.hidden = YES;
//    }
//    else
//    {
//        noneDongTaiLabel.hidden = NO;
//    }
    [classTableView reloadData];
    if (footerView)
    {
        [footerView removeFromSuperview];
        footerView = [[FooterView alloc] initWithScrollView:classTableView];
        footerView.delegate = self;
    }
    else
    {
        footerView = [[FooterView alloc] initWithScrollView:classTableView];
        footerView.delegate = self;
    }
}

-(BOOL)haveThisTime:(NSString *)timeStr
{
    for (int i=0; i<[groupDiaries count]; i++)
    {
        NSDictionary *dict = [groupDiaries objectAtIndex:i];
        if ([[dict objectForKey:@"date"] isEqualToString:timeStr])
        {
            return YES;
        }
    }
    return NO;
}

-(void)addButtonClick
{
    if (addOpen)
    {
        //close
        [self closeAdd];
        self.navigationController.sideMenuController.panGestureEnabled = YES;
        self.navigationController.sideMenuController.tapGestureEnabled = YES;
    }
    else
    {
        //open
        [self openAdd];
        self.navigationController.sideMenuController.panGestureEnabled = NO;
        self.navigationController.sideMenuController.tapGestureEnabled = NO;
    }
    addOpen = !addOpen;
}

-(void)openAdd
{
    [UIView animateWithDuration:0.2 animations:^{
        addView.alpha = 1;
        addNoticeButton.alpha = 1;
        addDiaryButton.alpha = 1;
        classTableView.userInteractionEnabled = NO;
    }];
    
}

-(void)closeAdd
{
    [UIView animateWithDuration:0.2 animations:^{
        addNoticeButton.alpha = 0;
        addDiaryButton.alpha = 0;
        addView.alpha = 0;
        self.navigationController.sideMenuController.panGestureEnabled = YES;
        self.navigationController.sideMenuController.tapGestureEnabled = YES;
        classTableView.userInteractionEnabled = YES;
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *t in touches)
    {
        if(!CGRectContainsPoint(addView.frame, [t locationInView:addView]))
        {
            if (addOpen)
            {
                addOpen = NO;
                [self closeAdd];
            }
        }
    }
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

-(void)transmitDiary:(UIButton *)button
{
    NSDictionary *groupDict = [groupDiaries objectAtIndex:button.tag/SectionTag];
    NSArray *array = [groupDict objectForKey:@"diaries"];
    waitTransmitDict = [[array objectAtIndex:button.tag%SectionTag] objectForKey:@"detail"];
    [self shareAPP:nil];
}
//-(void)nameButtonClick:(NSDictionary *)dict
//{
//    DDLOG(@"person dict %@",dict);
//    PersonDetailViewController *personDetailVC = [[PersonDetailViewController alloc] init];
//    personDetailVC.personName = [[dict objectForKey:@"by"] objectForKey:@"name"];
//    personDetailVC.personID = [[dict objectForKey:@"by"] objectForKey:@"_id"];
//    [self.sideMenuController hideMenuAnimated:YES];
//    [self.navigationController pushViewController:personDetailVC animated:YES];
//}

-(void)nameButtonClick:(NSDictionary *)dict
{
    
    DDLOG(@"home %@",dict);
    DongTaiDetailViewController *dongtaiDetailViewController = [[DongTaiDetailViewController alloc] init];
    dongtaiDetailViewController.dongtaiId = [dict objectForKey:@"_id"];
    dongtaiDetailViewController.fromclass = NO;
    dongtaiDetailViewController.addComDel = self;
    [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"c_id"] forKey:@"classid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //        dongtaiDetailViewController.addComDel = self;
    [self.navigationController pushViewController:dongtaiDetailViewController animated:YES];
}

-(void)cellCommentDiary:(NSDictionary *)dict
{
    waitCommentDict = dict;
    [inputTabBar.inputTextView becomeFirstResponder];
}

#pragma mark - shareAPP
-(void)shareAPP:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"转发到" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"新浪微博",@"QQ空间",@"腾讯微博",@"QQ好友",@"微信朋友圈",@"人人网", nil];
    [actionSheet showInView:self.bgView];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DDLOG(@"waittransdict %@",waitTransmitDict);
    switch (buttonIndex)
    {
        case 0:
            [self shareToSinaWeiboClickHandler:nil];
            break;
        case 1:
            [self shareToQQSpaceClickHandler:nil];
            break;
        case 2:
            [self shareToTencentWeiboClickHandler:nil];
            break;
        case 3:
            [self shareToQQFriendClickHandler:nil];
            break;
        case 4:
            [self shareToWeixinTimelineClickHandler:nil];
            break;
        case 5:
            [self shareToRenRenClickHandler:nil];
            break;
        default:
            break;
    }
}

/**
 *	@brief	分享到QQ空间
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToQQSpaceClickHandler:(UIButton *)sender
{
    [self backInput];
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [waitTransmitDict objectForKey:@"content"];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        if ([[waitTransmitDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    
    //创建分享内容
    //    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    id<ISSContent> publishContent = [ShareSDK content:content
                                       defaultContent:@""
                                                image:[ShareSDK imageWithUrl:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:content
                                            mediaType:SSPublishContentMediaTypeText];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeQQSpace
                          container:container
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 [self backInput];
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                 }
                             }];
}

/**
 *	@brief	分享到新浪微博
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToSinaWeiboClickHandler:(UIButton *)sender
{
    [self backInput];
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [NSString stringWithFormat:@"%@%@",[waitTransmitDict objectForKey:@"content"],ShareUrl];
        }
    }
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        if ([[waitTransmitDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    
    //创建分享内容[ShareSDK imageWithUrl:imagePath]
    id<ISSContent> publishContent = [ShareSDK content:[content length]>0?content:ShareContent
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:[content length]>0?content:ShareContent
                                            mediaType:SSPublishContentMediaTypeNews];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    [container setIPhoneContainerWithViewController:self];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeSinaWeibo
                          container:container
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:nil
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 [self backInput];
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                 }
                             }];
}

/**
 *	@brief	分享到腾讯微博
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToTencentWeiboClickHandler:(UIButton *)sender
{
    [self backInput];
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [NSString stringWithFormat:@"%@%@",[waitTransmitDict objectForKey:@"content"],ShareUrl];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        if ([[waitTransmitDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:[content length]>0?content:ShareContent
                                       defaultContent:@""
                                                image:[ShareSDK imageWithUrl:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:[content length]>0?content:ShareContent
                                            mediaType:SSPublishContentMediaTypeText];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeTencentWeibo
                          container:container
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:nil
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 [self backInput];
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@") , [error errorCode], [error errorDescription]);
                                 }
                             }];
}
/**
 *	@brief	分享给QQ好友
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToQQFriendClickHandler:(UIButton *)sender
{
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [waitTransmitDict objectForKey:@"content"];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        if ([[waitTransmitDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:content
                                       defaultContent:@""
                                                image:[ShareSDK imageWithUrl:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:content
                                            mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeQQ
                          container:nil
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 [self backInput];
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                 }
                             }];
}

/**
 *	@brief	分享给微信朋友圈
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToWeixinTimelineClickHandler:(UIButton *)sender
{
    [self backInput];
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [waitTransmitDict objectForKey:@"content"];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        if ([[waitTransmitDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:[content length]>0?content:ShareContent
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:[content length]>0?content:ShareContent
                                            mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeWeixiTimeline
                          container:nil
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                 }
                             }];
}

/**
 *	@brief	分享到人人网
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToRenRenClickHandler:(UIButton *)sender
{
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [NSString stringWithFormat:@"%@%@",[waitTransmitDict objectForKey:@"content"],ShareUrl];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        if ([[waitTransmitDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:[content length]>0?content:ShareContent
                                       defaultContent:@""
                                                image:[ShareSDK imageWithUrl:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:[content length]>0?content:ShareContent
                                            mediaType:SSPublishContentMediaTypeText];
    
    //    //创建弹出菜单容器
    //    id<ISSContainer> container = [ShareSDK container];
    //    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    //
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeRenren
                          container:nil
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:nil
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 [self backInput];
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog( @"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
                                 }
                             }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(queue, ^{
//        [[MMProgressHUD sharedHUD] setOverlayMode:MMProgressHUDWindowOverlayModeGradient];
//        [MMProgressHUD showWithTitle:@"Title" status:@"Custom Animated Image" images:nil];
//        sleep(1);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MMProgressHUD dismissWithSuccess:@"success!"];
//        });
//
//    });

@end
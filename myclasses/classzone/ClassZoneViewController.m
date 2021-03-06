//
//  ClassZoneViewController.m
//  School
//
//  Created by TeekerZW on 14-1-17.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "ClassZoneViewController.h"
#import "XDTabViewController.h"
#import "AddDongTaiViewController.h"
#import "HeaderCell.h"
#import "XDTabViewController.h"
#import "TrendsCell.h"
#import "DongTaiDetailViewController.h"
#import "ChooseClassInfoViewController.h"
#import "XDContentViewController+JDSideMenu.h"
#import "NewDiariesViewController.h"

#import "EGORefreshTableHeaderView.h"
#import "FooterView.h"

#import "PersonalSettingCell.h"

#import "UIImageView+WebCache.h"
#import "InputTableBar.h"
#import "DiaryTools.h"
#import "UIActionSheet+Blocks.h"

#define ImageViewTag  9999
#define HeaderImageTag  7777
#define CellButtonTag   3333

#define SectionTag  1000
#define RowTag     100

#define ImageHeight  65.5f

#define ImageCountPerRow  4

@interface ClassZoneViewController ()<UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
NewDongtaiDelegate,
ClassZoneDelegate,
EGORefreshTableHeaderDelegate,
DongTaiDetailAddCommentDelegate,
EGORefreshTableDelegate,
UIActionSheetDelegate,
ReturnFunctionDelegate,
NameButtonDel,
ShareContentDelegate>
{
    UITableView *classZoneTableView;
    NSMutableArray *DongTaiArray;
    NSMutableArray *tmpArray;
    NSMutableDictionary *tmpDict;
    int page;
    NSString *monthStr;
    CGFloat bgImageViewHeight;
    
    UIImageView *bgImageView;
    
    BOOL isRefresh;
    
    UILabel *noneDongTaiLabel;
    
    BOOL haveNew;
    BOOL haveMore;
    
    int uncheckedCount;
    
    EGORefreshTableHeaderView *pullRefreshView;
    FooterView *footerView;
    BOOL _reloading;
    
    UIButton *addButton;
    
    OperatDB *db;
    NSDictionary *diaryDict;
    NSDictionary *waitTransmitDict;
    NSString *diaryID;
    
    NSDictionary *commentedDict;
    
    NSDictionary *waitCommentDict;
    
    NSString *className;
    NSString *classID;
    NSString *schoolID;
    NSString *schoolName;
    NSString *classTopImage;
    
    InputTableBar *inputTabBar;
    CGFloat tmpheight;
    CGSize inputSize;
    CGFloat faceViewHeight;
    
    UITapGestureRecognizer *backTgr;
    NSString *settingCacheString;
    
    int diaryCount;
    
    UIImageView *tipImageView;
    UIImageView *tapLabel;
    
    NSInteger waitCommentIndex;
    NSInteger waitCommentSection;
}
@end

@implementation ClassZoneViewController
@synthesize isApply,fromMsg,refreshDel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)selectPic:(int)selectPicTag
{
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGECLASSINFO object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    className = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
    schoolID = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolid"];
    schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
    classTopImage = [[NSUserDefaults standardUserDefaults] objectForKey:@"classtopimage"];
    
    if (!schoolName)
    {
        schoolName = @"未指定学校";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeClassInfo) name:CHANGECLASSINFO object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.titleLabel.text = @"班级空间";
    monthStr = @"";
    
    diaryID = @"";
    
    db = [[OperatDB alloc] init];
    
    page = 0;
    haveNew = NO;
    haveMore = YES;
    _reloading = NO;
    
    bgImageViewHeight = 150.0f;
    uncheckedCount = 0;
    diaryCount = 0;
    
    
    tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    DongTaiArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(SCREEN_WIDTH - 54, self.backButton.frame.origin.y-1, 50, NAV_RIGHT_BUTTON_HEIGHT);
    addButton.hidden = YES;
    [addButton setTitleColor:RightCornerTitleColor forState:UIControlStateNormal];
    [addButton setTitle:@"发布" forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addDongTaiClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:addButton];
    
    
    
    noneDongTaiLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, bgImageViewHeight+76, SCREEN_WIDTH-40, 60)];
    noneDongTaiLabel.text = @"这个班级还没有任何动态，你可以成为第一人发布动态的人哦！";
    noneDongTaiLabel.numberOfLines = 2;
    noneDongTaiLabel.lineBreakMode = NSLineBreakByWordWrapping;
    noneDongTaiLabel.hidden = YES;
    noneDongTaiLabel.textColor = TITLE_COLOR;
    noneDongTaiLabel.textAlignment = NSTextAlignmentCenter;
    noneDongTaiLabel.backgroundColor = [UIColor clearColor];
    
    classZoneTableView = [[UITableView alloc] init];
    if (isApply)
    {
        classZoneTableView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - UI_NAVIGATION_BAR_HEIGHT);
    }
    else
    {
        classZoneTableView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - UI_NAVIGATION_BAR_HEIGHT-UI_TAB_BAR_HEIGHT);
    }
    
    classZoneTableView.delegate = self;
    classZoneTableView.dataSource = self;
    classZoneTableView.tag = 10000;
    classZoneTableView.backgroundColor = self.bgView.backgroundColor;
//    classZoneTableView.backgroundColor = RGB(205, 205, 205, 1);
    classZoneTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    classZoneTableView.showsVerticalScrollIndicator = NO;
    [self.bgView addSubview:classZoneTableView];
    
    [classZoneTableView addSubview:noneDongTaiLabel];
    
    if(([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"students"]) &&
       [[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] isKindOfClass:[NSDictionary class]] &&
       ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:StudentSendDiary] integerValue] != 1))
    {
        addButton.hidden = YES;
    }
    else if(([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"parents"]) &&
            [[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] isKindOfClass:[NSDictionary class]] &&
            ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:ParentSendDiary] integerValue] != 1))
    {
        addButton.hidden = YES;
    }
    
    pullRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:classZoneTableView orientation:EGOPullOrientationDown];
    pullRefreshView.delegate = self;
    
    if ([Tools NetworkReachable])
    {
        addButton.hidden = YES;
        [self getCLassSettings];
    }
    else
    {
        [self getCacheSetting];
    }
    
    inputTabBar = [[InputTableBar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 40)];
    inputTabBar.backgroundColor = [UIColor grayColor];
    inputTabBar.returnFunDel = self;
    inputTabBar.notOnlyFace = NO;
    inputTabBar.maxTextLength = COMMENT_TEXT_LENGHT;
    [self.bgView addSubview:inputTabBar];
    inputSize = CGSizeMake(250, 30);
    [inputTabBar setLayout];
    
    backTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backInput)];
    
}

- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [self backInput];
}

-(void)outTap
{
    
}
-(void)showIntroduce
{
    if (addButton.hidden == YES)
    {
        return ;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (ShowTips == 1)
    {
        [ud removeObjectForKey:@"classzonetip"];
        [ud synchronize];
    }
    if (![ud objectForKey:@"classzonetip"])
    {
        self.unReadLabel.hidden = YES;
        
        tipImageView = [[UIImageView alloc] init];
        tipImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 568);
        
        if (SYSVERSION >= 7)
        {
            [tipImageView setImage:[UIImage imageNamed:@"classzonetip"]];
        }
        else
        {
            [tipImageView setImage:[UIImage imageNamed:@"classzonetip6"]];
        }
        tipImageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        [[XDTabViewController sharedTabViewController].bgView addSubview:tipImageView];
        
        UITapGestureRecognizer *outTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outTap)];
        tipImageView.userInteractionEnabled = YES;
        [tipImageView addGestureRecognizer:outTap];
        
        
        tapLabel = [[UIImageView alloc] init];
        tapLabel.frame = CGRectMake(15, 100, 290, 60);
        tapLabel.backgroundColor = [UIColor clearColor];
        [[XDTabViewController sharedTabViewController].bgView addSubview:tapLabel];
        
        UITapGestureRecognizer *tipTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkTip)];
        tapLabel.userInteractionEnabled = YES;
        [tapLabel addGestureRecognizer:tipTap];
    }
}

-(void)checkTip
{
    [tapLabel removeFromSuperview];
    [tipImageView removeFromSuperview];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@"1" forKey:@"classzonetip"];
    [ud synchronize];
}

-(void)backInput
{
    [classZoneTableView removeGestureRecognizer:backTgr];
    [UIView animateWithDuration:0.2 animations:^{
        [inputTabBar.inputTextView resignFirstResponder];
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, inputSize.height+10);
    }];
}

-(void)myReturnFunction
{
    DDLOG(@"input text %@",inputTabBar.inputTextView.text);
    if ([[inputTabBar analyString:inputTabBar.inputTextView.text] length] <= 0)
    {
        [Tools showAlertView:@"请输入评论内容！" delegateViewController:nil];
        return ;
    }
    
    if (commentedDict)
    {
        [self replayComment:commentedDict andDiaryDict:waitCommentDict content:inputTabBar.inputTextView.text];
        return ;
    }
    
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":[waitCommentDict objectForKey:@"_id"],
                                                                      @"c_id":classID,
                                                                      @"content":[inputTabBar analyString:inputTabBar.inputTextView.text]
                                                                      } API:COMMENT_DIARY];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"commit diary responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [self getDiaryDetail:[waitCommentDict objectForKey:@"_id"] inSection:waitCommentSection index:waitCommentIndex];
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.refreshDel = nil;
    
    inputTabBar.returnFunDel = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    inputTabBar.returnFunDel = self;
    inputSize = CGSizeMake(250, 30);
//    [UIView animateWithDuration:0.2 animations:^{
//        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10, SCREEN_WIDTH, inputSize.height+10);
        [self backInput];
//    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changeClassInfo
{
    [classZoneTableView reloadData];
}

-(void)unShowSelfViewController
{
    if (isApply)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [[XDTabViewController sharedTabViewController] dismissViewControllerAnimated:YES completion:nil];
        [[NSUserDefaults standardUserDefaults] setObject:NOTFROMCLASS forKey:FROMWHERE];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"admin"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - headerdelegate
-(void)refreshAction
{
    [self getDongTaiList];
}

#pragma mark - egodelegate
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    if (isApply)
    {
        [Tools showAlertView:@"您还没有进入这个班级，快去申请加入吧！" delegateViewController:self];
        return ;
    }
    page = 0;
    monthStr = @"";
    [self getCLassSettings];
}

-(void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
    if (isApply)
    {
        [Tools showAlertView:@"您还没有进入这个班级，快去申请加入吧！" delegateViewController:self];
        return ;
    }
    [self getMoreDongTai];
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
    [pullRefreshView egoRefreshScrollViewDidScroll:classZoneTableView];
    if (scrollView.contentOffset.y+(scrollView.frame.size.height) > scrollView.contentSize.height+65)
    {
        [footerView egoRefreshScrollViewDidScroll:classZoneTableView];
    }
    [self backInput];
    [inputTabBar backKeyBoard];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pullRefreshView egoRefreshScrollViewDidEndDragging:classZoneTableView];
    [footerView egoRefreshScrollViewDidEndDragging:classZoneTableView];
}

#pragma mark - classzoneDelegate
-(void)haveAddDonfTai:(BOOL)add
{
    if (add)
    {
        haveNew = YES;
        page = 0;
        monthStr = @"";
        [self getDongTaiList];
    }
}

#pragma mark - applyJoin
-(void)applyJoin
{
    ChooseClassInfoViewController *chooseClassInfo = [[ChooseClassInfoViewController alloc] init];
    chooseClassInfo.classID = classID;
    chooseClassInfo.className = className;
    chooseClassInfo.schoolName = schoolName;
    chooseClassInfo.schoolID = schoolID;
    [self.navigationController pushViewController:chooseClassInfo animated:YES];
}
-(void)addDongTaiClick
{
    AddDongTaiViewController *addDongTaiViewController = [[AddDongTaiViewController alloc] init];
    addDongTaiViewController.classID = classID;
    addDongTaiViewController.fromCLass = YES;
    addDongTaiViewController.classZoneDelegate = self;
    [[XDTabViewController sharedTabViewController].navigationController pushViewController:addDongTaiViewController animated:YES];
}

-(void)getCLassSettings
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID
                                                                      } API:GETSETTING];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"classsetting dict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",GETSETTING,[Tools user_id],classID];
                NSString *key = [requestUrlStr MD5Hash];
                [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"admin"] integerValue] == 2)
                {
                    addButton.hidden = NO;
                }
                [self dealClassSetting:responseDict];
                
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
            _reloading = NO;
            [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
            [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [request startAsynchronous];
    }
}
-(void)getCacheSetting
{
    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",GETSETTING,[Tools user_id],classID];
    NSString *key = [requestUrlStr MD5Hash];
    NSData *data = [FTWCache objectForKey:key];
    settingCacheString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *settingCacheDict = [Tools JSonFromString:settingCacheString];
    if ([settingCacheDict count] > 0)
    {
        [self dealClassSetting:settingCacheDict];
    }
}

-(void)dealClassSetting:(NSDictionary *)responseDict
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *role = @"";
    if ([EmptyTools isEmpty:[responseDict objectForKey:@"data"] key:@"role"])
    {
        role = [[responseDict objectForKey:@"data"] objectForKey:@"role"];
    }
    NSString *admin = @"";
    if ([EmptyTools isEmpty:[responseDict objectForKey:@"data"] key:@"admin"])
    {
        admin = [NSString stringWithFormat:@"%d",[[[responseDict objectForKey:@"data"] objectForKey:@"admin"] intValue]];
    }
    NSDictionary *set = nil;
    if ([EmptyTools isEmpty:[responseDict objectForKey:@"data"] key:@"set"])
    {
        set = [[responseDict objectForKey:@"data"] objectForKey:@"set"];
    }
    NSDictionary *opt = nil;
    if([[responseDict objectForKey:@"data"] objectForKey:@"opt"])
    {
        opt = [[responseDict objectForKey:@"data"] objectForKey:@"opt"];
    }
    [ud setObject:set forKey:@"set"];
    [ud setObject:role forKey:@"role"];
    [ud setObject:admin forKey:@"admin"];
    [ud setObject:opt forKey:@"opt"];
    [ud synchronize];
    
    if ([self canSendDiary])
    {
        addButton.hidden = NO;
    }
    else
    {
        addButton.hidden = YES;
    }
    
    if ([self isInAccessTime])
    {
        if ([Tools NetworkReachable])
        {
            [self getCacheData];
            [self getDongTaiList];
        }
        else
        {
            [self getCacheData];
        }
    }
    else
    {
        [tmpArray removeAllObjects];
        [classZoneTableView reloadData];
        addButton.hidden = YES;
    }
    
    if (isApply)
    {
        addButton.hidden = YES;
    }
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isApply)
    {
        return 2;
    }
    else
    {
        return [tmpArray count]+1;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section > 0 && !isApply)
    {
        UIView *headerView = [[UIView alloc] init];
        headerView.backgroundColor = UIColorFromRGB(0xf1f0ec);
        
        UILabel *headerLabel = [[UILabel alloc] init];
        headerLabel.font = [UIFont systemFontOfSize:14];
        headerLabel.backgroundColor = UIColorFromRGB(0xf1f0ec);
        headerLabel.textColor = COMMENTCOLOR;
        
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
        NSDictionary *groupDict = [tmpArray objectAtIndex:section-1];
        headerLabel.text = [groupDict objectForKey:@"date"];
        headerLabel.frame = CGRectMake(50, 5, SCREEN_WIDTH, 30);
        [headerView addSubview:headerLabel];
        return headerView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section > 0 && !isApply)
    {
        return 40;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isApply)
    {
        NSDictionary *setDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"set"];
        if(section == 0)
        {
            return 1;
        }
        else if([setDict isKindOfClass:[NSDictionary class]] && ([[setDict objectForKey:VisitorAccess] integerValue] == 1))
        {
            
            if ([DongTaiArray count] > 5)
            {
                return 5;
            }
            else
            {
                return [DongTaiArray count];
            }
        }
    }
    else
    {
        if (section >0)
        {
            if ([tmpArray count] > 0)
            {
                noneDongTaiLabel.hidden = YES;
            }
            else
            {
                noneDongTaiLabel.hidden = NO;
            }
            
            NSDictionary *dict = [tmpArray objectAtIndex:section-1];
            NSArray *array = [dict objectForKey:@"diaries"];
            return [array count];
        }
        else
            return 1;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if (indexPath.section >0 && !isApply)
    {
        if (indexPath.section < [tmpArray count])
        {
            
            NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
            NSArray *array = [groupDict objectForKey:@"diaries"];
            NSDictionary *dict = [array objectAtIndex:indexPath.row];
            
            return [DiaryTools heightWithDiaryDict:dict andShowAll:NO];
        }
        else
        {
            NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
            NSArray *array = [groupDict objectForKey:@"diaries"];
            if (indexPath.row < [array count])
            {
                NSDictionary *dict = [array objectAtIndex:indexPath.row];
                
                return [DiaryTools heightWithDiaryDict:dict andShowAll:NO];
            }
            else
            {
                return 40;
            }
        }
        
    }
    else if(indexPath.section >0 && isApply)
    {
        NSDictionary *dict = [DongTaiArray objectAtIndex:indexPath.row];
        return [DiaryTools heightWithDiaryDict:dict andShowAll:NO];;
    }
    else if(indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            if (isApply)
            {
                return bgImageViewHeight+72.5;
            }
            return bgImageViewHeight;
        }
        else if (uncheckedCount > 0)
        {
            return 30;
        }
    }
    return 0;
}

-(void)nameButtonClick:(NSDictionary *)dict andIndexPath:(NSIndexPath *)indexPath
{
    if (isApply)
    {
        [Tools showAlertView:@"请您先申请加入班级！" delegateViewController:nil];
        return ;
    }
    DongTaiDetailViewController *dongtaiDetailViewController = [[DongTaiDetailViewController alloc] init];
    dongtaiDetailViewController.dongtaiId = [dict objectForKey:@"_id"];
    dongtaiDetailViewController.fromclass = NO;
    dongtaiDetailViewController.addComDel = self;
    [[NSUserDefaults standardUserDefaults] setObject:classID forKey:@"classid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    waitCommentIndex = indexPath.row;
    waitCommentSection = indexPath.section;
    diaryID = [dict objectForKey:@"_id"];
    
    dongtaiDetailViewController.addComDel = self;
    [[XDTabViewController sharedTabViewController].navigationController pushViewController:dongtaiDetailViewController animated:YES];
}

#pragma mark - 删除日志评论

-(void)deleteCommentWithDiary:(NSDictionary *)diaryDetailDict
               andCommentDict:(NSDictionary *)commentDict
              andCommentIndex:(NSInteger)commentIndex
                 andIndexPath:(NSIndexPath *)indexPath
{
    NSString *diaryId = [diaryDetailDict objectForKey:@"_id"];
    [UIActionSheet showInView:self.bgView withTitle:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 0)
        {
            [self deleteCommentWithDiaryId:diaryId andCommentDict:commentDict inSection:indexPath.section index:indexPath.row];
        }
    }];
}

-(void)deleteCommentWithDiaryId:(NSString *)diaryId
                 andCommentDict:(NSDictionary *)commentDict
                      inSection:(NSInteger)section
                          index:(NSInteger)index
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":diaryId,
                                                                      @"c_id":classID,
                                                                      @"index":[commentDict objectForKey:@"_id"]
                                                                      } API:DEL_COMMENT];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"diary detail responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showTips:@"评论删除成功" toView:self.bgView];
                [self getDiaryDetail:diaryId inSection:section index:index];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools showAlertView:@"连接错误" delegateViewController:nil];
        }];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

#pragma mark - 回复评论
-(void)replayComment:(NSDictionary *)commentDict
        andDiaryDict:(NSDictionary *)diaryDict1
             content:(NSString *)content
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":[diaryDict1 objectForKey:@"_id"],
                                                                      @"c_id":classID,
                                                                      @"content":content,
                                                                      @"rp_id":[[commentDict objectForKey:@"by"] objectForKey:@"_id"],
                                                                      @"rp_name":[[commentDict objectForKey:@"by"] objectForKey:@"name"]
                                                                      } API:COMMENT_DIARY];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"diary detail responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showTips:@"回复成功！" toView:self.bgView];
                commentedDict = nil;
                inputTabBar.inputTextView.text = @"";
                [self getDiaryDetail:[diaryDict1 objectForKey:@"_id"] inSection:waitCommentSection index:waitCommentIndex];
                
                [inputTabBar backKeyBoard];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools showAlertView:@"连接错误" delegateViewController:nil];
        }];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

#pragma mark - 评论日志

-(void)cellCommentDiary:(NSDictionary *)dict andIndexPath:(NSIndexPath *)indexPath andCommentDict:(NSDictionary *)commentDict
{
    if (isApply)
    {
        [Tools showAlertView:@"游客不能评论班级日志,赶快加入吧!" delegateViewController:nil];
        return ;
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"parents"] &&
        [[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] isKindOfClass:[NSDictionary class]] &&
        [[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:ParentComment] intValue] == 0)
    {
        [Tools showAlertView:@"不好意思，这个班级不允许家长评论班级日志!" delegateViewController:nil];
        return ;
    }
    
    if([[[[NSUserDefaults standardUserDefaults] objectForKey:@"opt"] objectForKey:UserSendComment] integerValue] == 0)
    {
        [Tools showAlertView:@"您没有回复权限！" delegateViewController:nil];
        return ;
    }
    waitCommentSection = indexPath.section;
    waitCommentIndex = indexPath.row;
    waitCommentDict = dict;
    commentedDict = commentDict;
    NSString *commentUserName = [[commentDict objectForKey:@"by"] objectForKey:@"name"];
    [inputTabBar setPlaceHolderString:[NSString stringWithFormat:@"回复%@:",commentUserName]];
    [inputTabBar.inputTextView becomeFirstResponder];
}

-(void)showAllDiary
{
    if (isApply)
    {
        [Tools showTips:@"已经切换" toView:self.bgView];
        isApply = NO;
        [self getDongTaiList];
    }
}

-(void)copyC_id
{
    UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
    [generalPasteBoard setString:classID];
    [Tools showTips:@"copy c_id success!" toView:self.bgView];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            static NSString *headeViewCell = @"headerViewCell";
            TrendsCell *cell = [tableView dequeueReusableCellWithIdentifier:headeViewCell];
            if (cell == nil)
            {
                cell = [[TrendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headeViewCell];
            }
            cell.headerImageView.hidden = NO;
            cell.nameLabel.hidden = NO;
            cell.locationLabel.hidden = NO;
            cell.topImageView.hidden = NO;
            cell.nameButtonDel = self;
            
            cell.topImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, bgImageViewHeight);
            
            if (isApply)
            {
                UITapGestureRecognizer *navtap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAllDiary)];
                cell.nameLabel.userInteractionEnabled = YES;
                navtap.numberOfTapsRequired = 10;
                [cell.nameLabel addGestureRecognizer:navtap];
            }
            
            NSString *topurlstring = [[NSUserDefaults standardUserDefaults] objectForKey:@"classkbimage"];
            if ([topurlstring length] >10)
            {
                [Tools fillImageView:cell.topImageView withImageFromURL:topurlstring andDefault:@"toppic"];
            }
            else
            {
                UIImage *topImage = [UIImage imageNamed:@"toppic"];
                cell.topImageView.image = topImage;
            }
            
            cell.headerImageView.frame = CGRectMake(10, 84.5, 53, 53);
            cell.headerImageView.layer.contentsGravity = kCAGravityResizeAspectFill;
            cell.headerImageView.clipsToBounds = YES;
            cell.headerImageView.layer.cornerRadius = 5;
            cell.headerImageView.clipsToBounds = YES;
            cell.headerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            cell.headerImageView.layer.borderWidth = 2;
            
            
            cell.headerImageView.tag = SectionTag * indexPath.section + indexPath.row;

            
            CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
            UIView *verticalLineView = [[UIView alloc] init];
            verticalLineView.backgroundColor = UIColorFromRGB(0xe2e3e4);
            
            CGFloat verticalLineHeight = 0;
            if ([DongTaiArray count] == 0 ||
                (([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"visitor"]) &&
                 [[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] isKindOfClass:[NSDictionary class]] &&
                 ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:VisitorAccess] integerValue] == 0)))
            {
                verticalLineHeight = 13;
            }
            else
            {
                verticalLineHeight = cellHeight-cell.headerImageView.frame.size.height-cell.headerImageView.frame.origin.y;
            }
            
            verticalLineView.frame = CGRectMake(34.75, cell.headerImageView.frame.size.height+cell.headerImageView.frame.origin.y, 1.5, verticalLineHeight);
            [cell.bgView addSubview:verticalLineView];
            
            
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            if (![[ud objectForKey:@"classiconimage"] isEqual:[NSNull null]] && [[ud objectForKey:@"classiconimage"] length] > 10)
            {
                [Tools fillImageView:cell.headerImageView withImageFromURL:[ud objectForKey:@"classiconimage"] andDefault:@"headpic.jpg"];
            }
            else
            {
                [cell.headerImageView setImage:[UIImage imageNamed:@"headpic.jpg"]];
            }
            
            if (className)
            {
                cell.locationLabel.text = className;
            }
            
            cell.locationLabel.frame = CGRectMake(cell.headerImageView.frame.size.width+cell.headerImageView.frame.origin.x+7, cell.headerImageView.frame.origin.y+5, 190, 20);
            cell.locationLabel.font = [UIFont systemFontOfSize:18];
            cell.locationLabel.shadowColor = TITLE_COLOR;
            cell.locationLabel.shadowOffset = CGSizeMake(0.5, 0.5);
            cell.locationLabel.textAlignment = NSTextAlignmentLeft;
            cell.locationLabel.textColor = [UIColor whiteColor];
            cell.locationLabel.layer.shadowColor = [UIColor grayColor].CGColor;
            cell.locationLabel.layer.shadowOffset = CGSizeMake(5, 5);
            
            UITapGestureRecognizer *headertap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(copyC_id)];
            cell.locationLabel.userInteractionEnabled = YES;
            headertap.numberOfTapsRequired = 10;
            [cell.locationLabel addGestureRecognizer:headertap];

            
            cell.nameLabel.textAlignment = NSTextAlignmentLeft;
            cell.nameLabel.frame = CGRectMake(cell.headerImageView.frame.size.width+cell.headerImageView.frame.origin.x+7, cell.headerImageView.frame.origin.y+30, 190, 20);
            cell.nameLabel.shadowOffset = CGSizeMake(0.5, 0.5);
            cell.nameLabel.shadowColor = TITLE_COLOR;
            cell.nameLabel.font = [UIFont systemFontOfSize:16];
            cell.nameLabel.textColor = [UIColor whiteColor];
            if (schoolName)
            {
                cell.nameLabel.text = schoolName;
            }
            
            cell.nameLabel.layer.shadowColor = TITLE_COLOR.CGColor;
            cell.nameLabel.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
            
            if(SYSVERSION < 7)
            {
                cell.nameLabel.backgroundColor = [UIColor clearColor];
                cell.locationLabel.backgroundColor = [UIColor clearColor];
            }
            
            cell.backgroundColor = [UIColor clearColor];
            if (isApply)
            {
                cell.praiseButton.hidden = NO;
                cell.praiseButton.frame = CGRectMake(37, bgImageViewHeight+18, SCREEN_WIDTH-74, 42);
                [cell.praiseButton setTitle:@"申请加入" forState:UIControlStateNormal];
                [cell.praiseButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
                [cell.praiseButton addTarget:self action:@selector(applyJoin) forControlEvents:UIControlEventTouchUpInside];
                cell.praiseButton.titleLabel.font = [UIFont systemFontOfSize:18];
                [cell.praiseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                cell.bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, bgImageViewHeight+72.5);
            }
            cell.bgView.backgroundColor = self.bgView.backgroundColor;
            cell.bgView.layer.borderWidth = 0;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = self.bgView.backgroundColor;
            return cell;
        }
    }
    else if(indexPath.section > 0)
    {
        
        static NSString *topImageView = @"classtrendcell";
        TrendsCell *cell = [tableView dequeueReusableCellWithIdentifier:topImageView];
        if (cell == nil)
        {
            cell = [[TrendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topImageView];
        }
        cell.nameButtonDel = self;
        
        NSDictionary *dict;
        if (!isApply)
        {
            NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
            NSArray *array = [groupDict objectForKey:@"diaries"];
            dict = [array objectAtIndex:indexPath.row];
        }
        else
        {
            dict = [DongTaiArray objectAtIndex:indexPath.row];
        }
        
        cell.diaryDetailDict = dict;
        NSString *name = [[dict objectForKey:@"by"] objectForKey:@"name"];
        NSString *role = [[dict objectForKey:@"by"] objectForKey:@"role"];
        
        
        NSString *nameStr;
        if (role)
        {
            if ([role isEqualToString:@"teachers"])
            {
                nameStr = [NSString stringWithFormat:@"%@(%@)",name,@"老师"];
            }
            else if([role isEqualToString:@"parents"])
            {
                nameStr = [NSString stringWithFormat:@"%@(%@)",name,@"家长"];
            }
            else if([role isEqualToString:@"students"])
            {
                nameStr = [NSString stringWithFormat:@"%@(%@)",name,@"学生"];
            }
            else
            {
                nameStr = name;
            }
        }
        else
        {
            nameStr = name;
        }
        
        cell.headerImageView.hidden = NO;
        cell.nameLabel.hidden = NO;
        cell.timeLabel.hidden = NO;
        cell.locationLabel.hidden = NO;
        cell.praiseButton.hidden = NO;
        cell.commentButton.hidden = NO;
        cell.transmitButton.hidden = NO;
        
        cell.commentsTableView.frame = CGRectMake(0, 0, 0, 0);
        
        cell.nameLabel.frame = CGRectMake(50, cell.headerImageView.frame.origin.y-6 , [nameStr length]*18>170?170:([nameStr length]*18), 25);
        cell.nameLabel.text = nameStr;
        cell.nameLabel.font = NAMEFONT;
        cell.nameLabel.textColor = DongTaiNameColor;
        
        NSString *timeStr;
        if (isApply)
        {
            timeStr = [Tools showTime:[NSString stringWithFormat:@"%ld",(long)[[[dict objectForKey:@"created"] objectForKey:@"sec"] integerValue]] andFromat:@"MM-dd hh:mm"];
        }
        else
        {
           timeStr = [Tools showTimeOfToday:[NSString stringWithFormat:@"%ld",(long)[[[dict objectForKey:@"created"] objectForKey:@"sec"] integerValue]]];
        }
        
        NSString *c_name = [dict objectForKey:@"c_name"];
        cell.timeLabel.text = c_name;
        cell.timeLabel.frame = CGRectMake(SCREEN_WIDTH-[c_name length]*18-30, 2, [c_name length]*18, 35);
        cell.timeLabel.textAlignment = NSTextAlignmentRight;
        cell.timeLabel.numberOfLines = 2;
        cell.timeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        cell.headerImageView.backgroundColor = [UIColor clearColor];
        
        cell.headerImageView.tag = SectionTag * indexPath.section + indexPath.row;
        cell.headerImageView.frame = CGRectMake(12, 12, 32, 32);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerImageViewClicked:)];
        cell.headerImageView.userInteractionEnabled = YES;
        [cell.headerImageView addGestureRecognizer:tap];
        
        [Tools fillImageView:cell.headerImageView withImageFromURL:[[dict objectForKey:@"by"] objectForKey:@"img_icon"] andDefault:HEADERICON];
        cell.locationLabel.frame = CGRectMake(50, cell.headerImageView.frame.origin.y+cell.headerImageView.frame.size.height-LOCATIONLABELHEI+3, SCREEN_WIDTH-90, LOCATIONLABELHEI);
        if ([[dict objectForKey:@"detail"] objectForKey:@"add"] &&
            [[[dict objectForKey:@"detail"] objectForKey:@"add"] length] > 0)
        {
            cell.locationLabel.text = [NSString stringWithFormat:@"于%@在%@",timeStr,[[dict objectForKey:@"detail"] objectForKey:@"add"]];
        }
        else
        {
            cell.locationLabel.text = [NSString stringWithFormat:@"%@",timeStr];
        }
        cell.locationLabel.numberOfLines = 1;
        cell.locationLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
        
        cell.contentLabel.hidden = YES;
        cell.contentLabel.backgroundColor = [UIColor clearColor];
        
        for(UIView *v in cell.imagesView.subviews)
        {
            if ([v isKindOfClass:[UIImageView class]])
            {
                [v removeFromSuperview];
            }
        }
        if ([[[dict objectForKey:@"detail"] objectForKey:@"content"] length] > 0)
        {
            //有文字
            NSString *content = [[[dict objectForKey:@"detail"] objectForKey:@"content"] emojizedString];
            cell.contentLabel.hidden = NO;
            cell.contentLabel.textColor = CONTENTCOLOR;
            
            CGSize contentSize = [Tools getSizeWithString:content andWidth:SCREEN_WIDTH-DongTaiHorizantolSpace*2-16 andFont:DONGTAI_CONTENT_FONT];
            
            cell.contentLabel.textColor = CONTENTCOLOR;
            cell.contentLabel.tag = SectionTag * indexPath.section + indexPath.row;
            
            UITapGestureRecognizer *contentLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toDetail:)];
            cell.contentLabel.userInteractionEnabled = YES;
            [cell.contentLabel addGestureRecognizer:contentLabelTap];
            
            if (contentSize.height > 45)
            {
                cell.contentLabel.frame = CGRectMake(11, cell.headerImageView.frame.size.height+cell.headerImageView.frame.origin.y+DongTaiSpace, SCREEN_WIDTH-30, 45);
            }
            else
            {
                cell.contentLabel.frame = CGRectMake(11, cell.headerImageView.frame.size.height+cell.headerImageView.frame.origin.y+DongTaiSpace, SCREEN_WIDTH-30, contentSize.height+10);
            }
            
            if ([content length] > 40)
            {
                cell.contentLabel.text  = [NSString stringWithFormat:@"%@...",[content substringToIndex:37]];
            }
            else
            {
                cell.contentLabel.text = content;
            }
        }
        else
        {
            cell.contentLabel.frame = CGRectMake(10, cell.headerImageView.frame.size.height+cell.headerImageView.frame.origin.y+DongTaiSpace, 0, 0);
        }
        
        CGFloat imageViewHeight = ImageHeight;
        CGFloat imageViewWidth = ImageHeight;
        if ([[[dict objectForKey:@"detail"] objectForKey:@"img"] count] > 0)
        {
            //有图片
            
            NSArray *imgsArray = [[dict objectForKey:@"detail"] objectForKey:@"img"];
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
            
            if ([[[dict objectForKey:@"detail"] objectForKey:@"content"] length] > 0)
            {
                cell.imagesView.frame = CGRectMake(12,
                                                   cell.contentLabel.frame.size.height + cell.contentLabel.frame.origin.y+DongTaiSpace,
                                                   SCREEN_WIDTH-44, (imageViewHeight+5) * row);
            }
            else
            {
                cell.imagesView.frame = CGRectMake(12,
                                                   cell.headerImageView.frame.size.height + cell.headerImageView.frame.origin.y+DongTaiSpace,
                                                   SCREEN_WIDTH-44, (imageViewHeight+5) * row);
            }
            
            for (int i=0; i<[imgsArray count]; ++i)
            {
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.frame = CGRectMake((i%(NSInteger)ImageCountPerRow)*(imageViewWidth+5), (imageViewWidth+5)*(i/(NSInteger)ImageCountPerRow), imageViewWidth, imageViewHeight);
                imageView.userInteractionEnabled = YES;
                imageView.tag = (indexPath.section-0-1)*SectionTag+indexPath.row*RowTag+i+333;
                
                imageView.userInteractionEnabled = YES;
                [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
                
                // 内容模式
                imageView.clipsToBounds = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                [Tools fillImageView:imageView withImageFromURL:[imgsArray objectAtIndex:i] andDefault:@"3100"];
                [cell.imagesView addSubview:imageView];
            }
                
        }
        else
        {
            cell.imagesView.frame = CGRectMake(5, cell.contentLabel.frame.size.height+cell.contentLabel.frame.origin.y, SCREEN_WIDTH-10, 0);
        }
        
        CGFloat he = 0;
        {
            he = 5;
        }
        
        CGFloat buttonHeight = 37;
        CGFloat iconH = 18;
        CGFloat iconTop = 9;
        
        CGFloat cellHeight = 0 ;
        
        if ([[[dict objectForKey:@"detail"] objectForKey:@"content"] length] > 0 &&
            [[[dict objectForKey:@"detail"] objectForKey:@"img"] count] == 0)
        {
            cellHeight = cell.contentLabel.frame.size.height + cell.contentLabel.frame.origin.y + DongTaiSpace;
        }
        else
        {
            cellHeight = cell.imagesView.frame.size.height + cell.imagesView.frame.origin.y + DongTaiSpace;
        }

        
        cell.transmitButton.frame = CGRectMake(0, cellHeight, (SCREEN_WIDTH-10)/3, buttonHeight);
        [cell.transmitButton setTitle:@"      转发" forState:UIControlStateNormal];
        cell.transmitButton.iconImageView.image = [UIImage imageNamed:@"icon_forwarding"];
        cell.transmitButton.tag = indexPath.section*SectionTag+indexPath.row;
        [cell.transmitButton addTarget:self action:@selector(transmitDiary:) forControlEvents:UIControlEventTouchUpInside];
        cell.transmitButton.iconImageView.frame = CGRectMake(24, iconTop+1, iconH, iconH);
        cell.transmitButton.backgroundColor = UIColorFromRGB(0xfcfcfc);
        
        
        if ([[dict objectForKey:@"likes_num"] integerValue] > 0)
        {
            [cell.praiseButton setTitle:[NSString stringWithFormat:@"      %ld",(long)[[dict objectForKey:@"likes_num"] integerValue]] forState:UIControlStateNormal];
        }
        else
        {
            [cell.praiseButton setTitle:@"     赞" forState:UIControlStateNormal];
        }
        if ([self havePraisedThisDiary:dict])
        {
            cell.praiseButton.iconImageView.image = [UIImage imageNamed:@"praised"];
            cell.praiseButton.iconImageView.frame = CGRectMake(34, iconTop+1, iconH, iconH);
        }
        else
        {
            cell.praiseButton.iconImageView.image = [UIImage imageNamed:@"icon_heart"];
            cell.praiseButton.iconImageView.frame = CGRectMake(33, iconTop+1, iconH, iconH);
        }
        
        [cell.praiseButton addTarget:self action:@selector(praiseDiary:) forControlEvents:UIControlEventTouchUpInside];
        cell.praiseButton.tag = indexPath.section*SectionTag+indexPath.row;
        cell.praiseButton.frame = CGRectMake((SCREEN_WIDTH-10)/3, cellHeight, (SCREEN_WIDTH-10)/3, buttonHeight);
        cell.praiseButton.backgroundColor = UIColorFromRGB(0xfcfcfc);
        
        
        if ([[dict objectForKey:@"comments_num"] integerValue] > 0)
        {
            [cell.commentButton setTitle:[NSString stringWithFormat:@"      %ld",(long)[[dict objectForKey:@"comments_num"] integerValue]] forState:UIControlStateNormal];
            cell.commentButton.iconImageView.frame = CGRectMake(31, iconTop, iconH, iconH);
        }
        else
        {
            [cell.commentButton setTitle:@"     评论" forState:UIControlStateNormal];
            cell.commentButton.iconImageView.frame = CGRectMake(25, iconTop, iconH, iconH);
        }
        cell.commentButton.frame = CGRectMake((SCREEN_WIDTH-10)/3*2, cellHeight, (SCREEN_WIDTH-10)/3, buttonHeight);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.commentButton.backgroundColor = UIColorFromRGB(0xfcfcfc);
        cell.commentButton.tag = indexPath.section*SectionTag+indexPath.row;
        cell.diaryIndexPath = [NSIndexPath indexPathForRow:cell.commentButton.tag%SectionTag inSection:cell.commentButton.tag/SectionTag-1];
        
        [cell.commentButton addTarget:self action:@selector(commentDiary:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.geduan1.hidden = NO;
        cell.geduan2.hidden = NO;
        
        cell.geduan1.frame = CGRectMake(cell.transmitButton.frame.size.width+cell.transmitButton.frame.origin.x, cell.transmitButton.frame.origin.y+DongTaiHorizantolSpace, 1, 18);
        cell.geduan2.frame = CGRectMake(cell.praiseButton.frame.size.width+cell.praiseButton.frame.origin.x, cell.praiseButton.frame.origin.y+DongTaiHorizantolSpace, 1, 18);
        
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
            cell.bgView.frame = CGRectMake(DongTaiHorizantolSpace, 0, SCREEN_WIDTH-DongTaiHorizantolSpace*2,
                                           cell.commentsTableView.frame.size.height+
                                           cell.commentsTableView.frame.origin.y);
        }
        else
        {
            cell.commentsArray = nil;
            cell.praiseArray = nil;
            [cell.commentsTableView reloadData];
            cell.bgView.frame = CGRectMake(DongTaiHorizantolSpace, 0, SCREEN_WIDTH-DongTaiHorizantolSpace*2,
                                           cell.praiseButton.frame.size.height+
                                           cell.praiseButton.frame.origin.y);
        }
        
        cell.bgView.layer.cornerRadius = 5;
        cell.bgView.clipsToBounds = YES;
        cell.bgView.backgroundColor = [UIColor whiteColor];
        
        CGRect cellFrame = [tableView rectForRowAtIndexPath:indexPath];
        cell.verticalLineView.frame = CGRectMake(34.75, 0, 1.5, cellFrame.size.height);
        
        return cell;
    }
    return nil;
}

-(void)headerImageViewClicked:(UITapGestureRecognizer *)tap
{
    if (isApply)
    {
        [Tools showAlertView:@"游客不能查看班级成员信息,赶快加入吧!" delegateViewController:nil];
        return ;
    }
    int section = ((tap.view.tag)/SectionTag-1);
    int row = (tap.view.tag)%SectionTag;
    NSDictionary *groupDict = [tmpArray objectAtIndex:section];
    NSArray *tmpArray1 = [groupDict objectForKey:@"diaries"];
    NSDictionary *dict = [tmpArray1 objectAtIndex:row];
    DDLOG(@"diary dict %@",dict);
    PersonDetailViewController *personDetail = [[PersonDetailViewController alloc] init];
    personDetail.personID = [[dict objectForKey:@"by"] objectForKey:@"_id"];
    personDetail.personName = [[dict objectForKey:@"by"] objectForKey:@"name"];
    personDetail.headerImg = [[dict objectForKey:@"by"] objectForKey:@"img_icon"];
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"opt"] isKindOfClass:[NSDictionary class]])
    {
        [self.navigationController pushViewController:personDetail animated:YES];
    }
    else
    {
        [[XDTabViewController sharedTabViewController].navigationController pushViewController:personDetail animated:YES];
    }
    
}

-(void)toDetail:(UITapGestureRecognizer *)tap
{
    if (isApply)
    {
        [Tools showAlertView:@"请您先申请加入班级！" delegateViewController:nil];
        return ;
    }
    int section = ((tap.view.tag)/SectionTag-1);
    int row = (tap.view.tag)%SectionTag;
    NSDictionary *groupDict = [tmpArray objectAtIndex:section];
    NSArray *tmpArray1 = [groupDict objectForKey:@"diaries"];
    NSDictionary *dict = [tmpArray1 objectAtIndex:row];
    DongTaiDetailViewController *dongtaiDetailViewController = [[DongTaiDetailViewController alloc] init];
    dongtaiDetailViewController.dongtaiId = [dict objectForKey:@"_id"];
    dongtaiDetailViewController.fromclass = NO;
    dongtaiDetailViewController.addComDel = self;
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"opt"] isKindOfClass:[NSDictionary class]])
    {
        [self.navigationController pushViewController:dongtaiDetailViewController animated:YES];
    }
    else
    {
        [[XDTabViewController sharedTabViewController].navigationController pushViewController:dongtaiDetailViewController animated:YES];
    }
}


- (void)tapImage:(UITapGestureRecognizer *)tap
{
    if (isApply)
    {
        [Tools showAlertView:@"请您先申请加入班级！" delegateViewController:nil];
        return ;
    }
    
    if ([inputTabBar.inputTextView isFirstResponder])
    {
        [self backInput];
        [inputTabBar backKeyBoard];
    }
    
    NSDictionary *groupDict = [tmpArray objectAtIndex:(tap.view.tag-333)/SectionTag];
    NSArray *array = [groupDict objectForKey:@"diaries"];
    NSDictionary *dict = [array objectAtIndex:(tap.view.tag-333)%SectionTag/RowTag];
    NSArray *imgs = [[dict objectForKey:@"detail"] objectForKey:@"img"];
    
    
    NSMutableArray *smallImageArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSString *imageUrl in imgs)
    {
        NSString *smallUrlStr = [NSString stringWithFormat:@"%@100w",imageUrl];
        [smallImageArray addObject:smallUrlStr];
    }
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i=0; i<[imgs count]; i++)
    {
        //        NSString *url = [imgs[i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        NSString *url = imgs[i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        if ([Tools NetworkReachable])
        {
            if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi)
            {
                //wifi
                photo.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEURL,url]];
            }
            else if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN)
            {
                //蜂窝
                photo.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@@%dw",IMAGEURL,url,WWAN_IMAGE_WIDTH]];
            }
        }
        else
        {
            photo.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEURL,url]];
        }
        photo.srcImageView = (UIImageView *)tap.view;
        [photos addObject:photo];
    }
    MJPhotoBrowser *photoBroser = [[MJPhotoBrowser alloc] init];
    photoBroser.photos = photos;
    photoBroser.currentPhotoIndex = (tap.view.tag-333)%SectionTag%RowTag;
    [photoBroser show];
}


-(void)transmitDiary:(UIButton *)button
{
    if (isApply)
    {
        [Tools showAlertView:@"游客不能转发班级日志,赶快加入吧!" delegateViewController:nil];
        return ;
    }
    [self backInput];
    NSDictionary *groupDict = [tmpArray objectAtIndex:button.tag/SectionTag-1];
    NSArray *array = [groupDict objectForKey:@"diaries"];
    waitTransmitDict = [array objectAtIndex:button.tag%SectionTag];
    [self shareAPP:nil];
}

#pragma mark - shareAPP
-(void)shareAPP:(UIButton *)sender
{
    if ([WXApi isWXAppInstalled] && [QQApi isQQInstalled])
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"转发到" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"新浪微博",@"腾讯微博",@"人人网",@"微信朋友圈",@"QQ好友",@"QQ空间", nil];
        [actionSheet showInView:self.bgView];
    }
    else if([WXApi isWXAppInstalled] && ![QQApi isQQInstalled])
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"转发到" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"新浪微博",@"腾讯微博",@"人人网",@"微信朋友圈", nil];
        [actionSheet showInView:self.bgView];
    }
    else if(![WXApi isWXAppInstalled] && [QQApi isQQInstalled])
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"转发到" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"新浪微博",@"腾讯微博",@"人人网",@"QQ好友",@"QQ空间", nil];
        [actionSheet showInView:self.bgView];
    }
    else if (![WXApi isWXAppInstalled] && [QQApi isQQInstalled])
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"转发到" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"新浪微博",@"腾讯微博",@"人人网", nil];
        [actionSheet showInView:self.bgView];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DDLOG(@"waittransdict %@",waitTransmitDict);
    diaryID = [waitTransmitDict objectForKey:@"_id"];
    
    
    if (buttonIndex == [actionSheet numberOfButtons]-1)
    {
        return;
    }
    
    NSString *content;
    if ([[waitTransmitDict objectForKey:@"detail"] objectForKey:@"content"])
    {
        if ([[[waitTransmitDict objectForKey:@"detail"] objectForKey:@"content"] length] > 0)
        {
            content = [[waitTransmitDict objectForKey:@"detail"] objectForKey:@"content"];
        }
    }
    
    
    NSString *imagePath;
    if ([[waitTransmitDict objectForKey:@"detail"] objectForKey:@"img"])
    {
        NSArray *imageTmpArray = [[waitTransmitDict objectForKey:@"detail"] objectForKey:@"img"];
        if ([imageTmpArray count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@@150w",IMAGEURL,[[[waitTransmitDict objectForKey:@"detail"] objectForKey:@"img"] firstObject]];
        }
    }
    content = [content length]>0?content:ShareContent;
    NSString *tmpImagePath = [[NSBundle mainBundle] pathForResource:@"logo120" ofType:@"png"];
    id<ISSCAttachment> attchment= imagePath ? [ShareSDK imageWithUrl:imagePath]:[ShareSDK imageWithPath:tmpImagePath];
    NSString *url = ShareUrl;
    ShareType shareType;
    switch (buttonIndex)
    {
        case 0:
            shareType = ShareTypeSinaWeibo;
            break;
        case 1:
            shareType = ShareTypeTencentWeibo;
            break;
        case 2:
            shareType = ShareTypeRenren;
            break;
        case 3:
            if ([WXApi isWXAppInstalled])
            {
                shareType = ShareTypeWeixiTimeline;
            }
            else if(![WXApi isWXAppInstalled] && [QQApi isQQInstalled])
            {
                shareType = ShareTypeQQ;
            }
            break;
        case 4:
            if ([WXApi isWXAppInstalled])
            {
                shareType = ShareTypeQQ;
            }
            else if(![WXApi isWXAppInstalled] && [QQApi isQQInstalled])
            {
                shareType = ShareTypeQQSpace;
            }
            break;
        case 5:
            shareType = ShareTypeQQSpace;
            break;
        default:
            break;
    }

    ShareTools *shareTools = [[ShareTools alloc] init];
    shareTools.shareContentDel = self;
    [shareTools shareTo:shareType andShareContent:content andImage:attchment andMediaType:SSPublishContentMediaTypeNews description:content andUrl:url];
}

-(void)shareSuccess
{
    [Tools showTips:@"分享成功！" toView:self.bgView];
}


-(void)praiseDiary:(UIButton *)button
{
    [self backInput];
    if (isApply)
    {
        [Tools showAlertView:@"游客不能赞班级日志,赶快加入吧!" delegateViewController:nil];
        return ;
    }
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"opt"] isKindOfClass:[NSDictionary class]])
    {
        return ;
    }
    if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"opt"] objectForKey:UserSendLike] intValue] == 0)
    {
        [Tools showAlertView:@"您不能赞这个班的班级日志。" delegateViewController:nil];
        return ;
    }
    
    if ([Tools NetworkReachable])
    {
        NSDictionary *groupDict = [tmpArray objectAtIndex:button.tag/SectionTag-1];
        NSArray *array = [groupDict objectForKey:@"diaries"];
        NSDictionary *dict = [array objectAtIndex:button.tag%SectionTag];
        DDLOG(@"home diary %@",[[dict objectForKey:@"detail"] objectForKey:@"content"]);
        if ([Tools NetworkReachable])
        {
            __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                          @"token":[Tools client_token],
                                                                          @"p_id":[dict objectForKey:@"_id"],
                                                                          @"c_id":classID
                                                                          } API:LIKE_DIARY];
            [request setCompletionBlock:^{
                NSString *responseString = [request responseString];
                NSDictionary *responseDict = [Tools JSonFromString:responseString];
                DDLOG(@"commit diary responsedict %@",responseDict);
                if ([[responseDict objectForKey:@"code"] intValue]== 1)
                {
                    [self getDiaryDetail:[dict objectForKey:@"_id"] inSection:button.tag/SectionTag-1 index:button.tag%SectionTag];
                    
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
}
#pragma mark - 评论按钮评论日志
-(void)commentDiary:(UIButton *)button
{
 
    
    if (isApply)
    {
        [Tools showAlertView:@"游客不能评论班级日志,赶快加入吧!" delegateViewController:nil];
        return ;
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"parents"] &&
        [[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] isKindOfClass:[NSDictionary class]] &&
        [[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:ParentComment] intValue] == 0)
    {
        [Tools showAlertView:@"不好意思，这个班级不允许家长评论班级日志!" delegateViewController:nil];
        return ;
    }
    
    if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"opt"] objectForKey:UserSendComment] intValue] != 1)
    {
        [Tools showAlertView:@"您不能赞这个班的班级日志。" delegateViewController:nil];
        return ;
    }
    
    commentedDict = nil;
    [inputTabBar setPlaceHolderString:@"请输入评论内容"];
    NSDictionary *groupDict = [tmpArray objectAtIndex:button.tag/SectionTag-1];
    NSArray *array = [groupDict objectForKey:@"diaries"];
    NSDictionary *dict = [array objectAtIndex:button.tag%SectionTag];
    waitCommentDict = dict;
    waitCommentSection = button.tag/SectionTag-1;
    waitCommentIndex = button.tag%SectionTag;
    [inputTabBar.inputTextView becomeFirstResponder];
}


#pragma mark - getNetdata
-(void)getDiaryDetail:(NSString *)dongtaiId inSection:(NSInteger)section  index:(NSInteger)index
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":dongtaiId
                                                                      } API:GETDIARY_DETAIL];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"diary detail responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                DDLOG(@"%ld+++%ld",(long)section,(long)index);
                NSMutableDictionary *groupDict = [[NSMutableDictionary alloc] initWithDictionary:[tmpArray objectAtIndex:section]];
                NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:[groupDict objectForKey:@"diaries"]];
                NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:[responseDict objectForKey:@"data"]];
                [newArray replaceObjectAtIndex:index withObject:newDict];
                [groupDict setObject:newArray forKey:@"diaries"];
                [tmpArray replaceObjectAtIndex:section withObject:groupDict];
                [classZoneTableView reloadData];
                
                waitCommentIndex = 0;
                waitCommentSection = 0;
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools showAlertView:@"连接错误" delegateViewController:nil];
        }];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}


-(void)showKeyBoard:(CGFloat)keyBoardHeight
{
    [classZoneTableView addGestureRecognizer:backTgr];
    [UIView animateWithDuration:0.2 animations:^{
        tmpheight = keyBoardHeight;
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10-keyBoardHeight, SCREEN_WIDTH, inputSize.height+10+ FaceViewHeight);
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
}

-(void)changeInputViewSize:(CGSize)size
{
    inputSize = size;
    [UIView animateWithDuration:0.2 animations:^{
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-size.height-10-tmpheight, SCREEN_WIDTH, size.height+10+tmpheight);
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isApply && indexPath.section != 0 )
    {
        [Tools showAlertView:@"请您先申请加入班级！" delegateViewController:nil];
        return ;
    }
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1)
        {
            NewDiariesViewController *newDiary = [[NewDiariesViewController alloc] init];
            newDiary.classID = classID;
            newDiary.classZoneDelegate = self;
            [[XDTabViewController sharedTabViewController].navigationController pushViewController:newDiary animated:YES];
        }
    }
    else
    {
        NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
        NSArray *array = [groupDict objectForKey:@"diaries"];
        DongTaiDetailViewController *dongtaiDetailViewController = [[DongTaiDetailViewController alloc] init];
        dongtaiDetailViewController.dongtaiId = [[array objectAtIndex:indexPath.row] objectForKey:@"_id"];
        dongtaiDetailViewController.addComDel = self;
        dongtaiDetailViewController.fromclass = YES;
        
        waitCommentIndex = indexPath.row;
        waitCommentSection = indexPath.section-1;
        diaryID = [[array objectAtIndex:indexPath.row] objectForKey:@"_id"];
        
        [[XDTabViewController sharedTabViewController].navigationController pushViewController:dongtaiDetailViewController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(BOOL)havePraisedThisDiary:(NSDictionary *)diaryDict1
{
    NSArray *praiseArray = [[diaryDict1 objectForKey:@"detail"] objectForKey:@"likes"];
    for (int i = 0; i < [praiseArray count]; i++)
    {
        NSDictionary *dict = [praiseArray objectAtIndex:i];
        if ([[[dict objectForKey:@"by"] objectForKey:@"_id"] isEqualToString:[Tools user_id]])
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 删除日志评论

-(void)deleteCommentWithDiary:(NSDictionary *)diaryDetailDict andIndexPath:(NSIndexPath *)indexPath
{
    NSString *diaryId = [diaryDetailDict objectForKey:@"_id"];
    [self getDiaryDetail:diaryId inSection:indexPath.section index:indexPath.row];
}

#pragma mark - addCommetnDel
-(void)addComment:(NSDictionary *)detailDict
{
    if ([detailDict isKindOfClass:[NSDictionary class]])
    {
        
        NSMutableDictionary *groupDict = [[NSMutableDictionary alloc] initWithDictionary:[tmpArray objectAtIndex:waitCommentSection]];
        NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:[groupDict objectForKey:@"diaries"]];
        NSMutableDictionary *tmpDict1 = [[NSMutableDictionary alloc] initWithDictionary:detailDict];
        [newArray replaceObjectAtIndex:waitCommentIndex withObject:tmpDict1];
        [groupDict setObject:newArray forKey:@"diaries"];
        [tmpArray replaceObjectAtIndex:waitCommentSection withObject:groupDict];
        [classZoneTableView reloadData];
        
        waitCommentIndex = 0;
        waitCommentSection = 0;
    }
}

-(void)delDiary:(BOOL)del
{
    if (del)
    {
        NSMutableDictionary *groupDict = [[NSMutableDictionary alloc] initWithDictionary:[tmpArray objectAtIndex:waitCommentSection]];
        NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:[groupDict objectForKey:@"diaries"]];
        [newArray removeObjectAtIndex:waitCommentIndex];
        if ([newArray count] > 0)
        {
            [groupDict setObject:newArray forKey:@"diaries"];
            [tmpArray replaceObjectAtIndex:waitCommentSection withObject:groupDict];
        }
        else
        {
            [tmpArray removeObjectAtIndex:waitCommentSection];
        }
        [classZoneTableView reloadData];
        
        waitCommentIndex = 0;
        waitCommentSection = 0;
        
    }
}

-(void)getMoreDongTai
{
    if (!haveMore)
    {
        [Tools showTips:@"没有更多动态了" toView:self.bgView];
        return ;
    }

    page ++;
    [self getDongTaiList];
}

#pragma mark - aboutNetWork
-(void)getDongTaiList
{
    if ([Tools NetworkReachable])
    {
        NSDictionary *paraDict;
        if (page == 0)
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"c_id":classID};
        }
        else
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"c_id":classID,
                         @"page":[NSString stringWithFormat:@"%d",page],
                         @"month":monthStr};
        }
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:paraDict API:GETDIARIESLIST];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"diaries list responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if (page== 0)
                {
                    [tmpArray removeAllObjects];
                    [DongTaiArray removeAllObjects];
                    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",GETDIARIESLIST,[Tools user_id],classID];
                    NSString *key = [requestUrlStr MD5Hash];
                    [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
                    
                    if ([self.refreshDel respondsToSelector:@selector(reFreshClassZone:)])
                    {
                        [self.refreshDel reFreshClassZone:YES];
                    }
                }
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"posts"] count]>0)
                {
                    NSArray *array = [[responseDict objectForKey:@"data"] objectForKey:@"posts"];
                    if ([array count] > 0)
                    {
                        classZoneTableView.hidden = NO;
                        [DongTaiArray addObjectsFromArray:array];
                    }
                    
                }
                else if (page == 0 && [monthStr length] == 0 )
                {
                    noneDongTaiLabel.hidden = NO;
                }
                
                page = [[[responseDict objectForKey:@"data"] objectForKey:@"page"] intValue];
                monthStr = [NSString stringWithFormat:@"%@",[[responseDict objectForKey:@"data"] objectForKey:@"month"]];
                if (page == 0 && [monthStr length] > 0 && [monthStr intValue] == 0)
                {
                    haveMore = NO;
                }
                
                if (!isApply)
                {
                    [self groupByTime:DongTaiArray];
                }
                else
                {
                    [classZoneTableView reloadData];
                }
                
                _reloading = NO;
                [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
                [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            [Tools hideProgress:self.bgView];
            [Tools showAlertView:@"连接错误" delegateViewController:nil];
            _reloading = NO;
            [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [Tools showProgress:self.bgView];
        [request startAsynchronous];
    }
    else
    {
        _reloading = NO;
        [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
        [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

-(void)groupByTime:(NSArray *)array
{
    NSString *timeStr;
    int index = 0;
    [tmpArray removeAllObjects];
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
                [tmpArray addObject:groupDict];
            }
        }
    }
    if ([tmpArray count] > 0)
    {
        noneDongTaiLabel.hidden = YES;
    }
    else
    {
        noneDongTaiLabel.hidden = NO;
    }
    [classZoneTableView reloadData];
    
    [self showIntroduce];
    if (footerView)
    {
        [footerView removeFromSuperview];
        footerView = [[FooterView alloc] initWithScrollView:classZoneTableView];
        footerView.delegate = self;
    }
    else
    {
        footerView = [[FooterView alloc] initWithScrollView:classZoneTableView];
        footerView.delegate = self;
    }
}

-(BOOL)haveThisTime:(NSString *)timeStr
{
    for (int i=0; i<[tmpArray count]; i++)
    {
        NSDictionary *dict = [tmpArray objectAtIndex:i];
        if ([[dict objectForKey:@"date"] isEqualToString:timeStr])
        {
            return YES;
        }
    }
    return NO;
}

-(BOOL)isInAccessTime
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"students"])
    {
        NSDate *date = [NSDate date];
        NSDateFormatter *fromatter = [[NSDateFormatter alloc] init];
        [fromatter setTimeStyle:NSDateFormatterShortStyle];
        NSString *timeStr = [fromatter stringFromDate:date];
        DDLOG(@"timeStr==%@",timeStr);
        NSString *hourStr;
        NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
        NSRange containsA = [formatStringForHours rangeOfString:@"a"];
        BOOL hasAMPM = containsA.location != NSNotFound;
        
        if (hasAMPM)
        {
            //12
            [fromatter setDateFormat:@"KK"];
            hourStr = [fromatter stringFromDate:date];
            if ([timeStr rangeOfString:@"下午"].length > 0 || [timeStr rangeOfString:@"PM"].length > 0)
            {
                NSString *timeLimit = [[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:StudentVisiteTime];
                if ([timeLimit integerValue] ==2)
                {
                    if ([hourStr integerValue] < 7)
                    {
                        [Tools showAlertView:[NSString stringWithFormat:@"空间访问时间为晚上7点以后"] delegateViewController:nil];
                        return NO;
                    }
                }
                else if ([timeLimit integerValue] ==0)
                {
                    if ([hourStr integerValue] < 5)
                    {
                        [Tools showAlertView:[NSString stringWithFormat:@"空间访问时间为晚上5点以后"] delegateViewController:nil];
                        return NO;
                    }
                }
                else
                {
                    return YES;
                }
            }
            else
            {
                NSString *timeLimit = [[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:StudentVisiteTime];
                if ([timeLimit integerValue] ==2)
                {
                    if ([hourStr integerValue] < 7+12)
                    {
                        [Tools showAlertView:[NSString stringWithFormat:@"空间访问时间为晚上7点以后"] delegateViewController:nil];
                        return NO;
                    }
                }
                else if ([timeLimit integerValue] ==0)
                {
                    if ([hourStr integerValue] < 5+12)
                    {
                        [Tools showAlertView:[NSString stringWithFormat:@"空间访问时间为晚上5点以后"] delegateViewController:nil];
                        return NO;
                    }
                }
                else
                {
                    return YES;
                }
            }
        }
        else
        {
            //24
            [fromatter setDateFormat:@"HH"];
            hourStr = [fromatter stringFromDate:date];
            
            NSString *timeLimit = [[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:StudentVisiteTime];
            if ([timeLimit integerValue] ==2)
            {
                if ([hourStr integerValue] < 19)
                {
                    [Tools showAlertView:[NSString stringWithFormat:@"空间访问时间为晚上19点以后"] delegateViewController:nil];
                    return NO;
                }
            }
            else if ([timeLimit integerValue] ==0)
            {
                if ([hourStr integerValue] < 17)
                {
                    [Tools showAlertView:[NSString stringWithFormat:@"空间访问时间为晚上17点以后"] delegateViewController:nil];
                    return NO;
                }
            }
            else
            {
                return YES;
            }
        }
    }
    else if(([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"visitor"]) &&
            [[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] isKindOfClass:[NSDictionary class]] &&
            ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:VisitorAccess] integerValue] == 0))
    {
        [Tools showAlertView:@"游客不可以查看班级空间！" delegateViewController:nil];
        return NO;
    }
    if(([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"visitor"]) &&
       [[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] isKindOfClass:[NSDictionary class]] &&
       ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:VisitorAccess] integerValue] == 1))
    {
        return YES;
    }
    return YES;
}

-(BOOL)canSendDiary
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"parents"] &&
        [[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] isKindOfClass:[NSDictionary class]] &&
        [[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:ParentSendDiary] integerValue] == 1)
    {
        return YES;
    }
    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"students"] &&
             [[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] isKindOfClass:[NSDictionary class]] &&
             [[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:StudentSendDiary] integerValue] == 1)
    {
        return YES;
    }
    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"teachers"])
    {
        return YES;
    }
    return NO;
}

-(void)getCacheData
{
    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",GETDIARIESLIST,[Tools user_id],classID];
    NSString *key = [requestUrlStr MD5Hash];
    DDLOG(@"classzone cache key %@",key);
    NSData *cacheData = [FTWCache objectForKey:key];
    if ([cacheData length] > 0)
    {
        NSString *responseString = [[NSString alloc] initWithData:cacheData encoding:NSUTF8StringEncoding];
        NSDictionary *responseDict = [Tools JSonFromString:responseString];
        if ([[responseDict objectForKey:@"code"] intValue]== 1)
        {
            if ([[[responseDict objectForKey:@"data"] objectForKey:@"posts"] count] > 0)
            {
                [tmpArray removeAllObjects];
                classZoneTableView.hidden = NO;
                NSArray *array = [[responseDict objectForKey:@"data"] objectForKey:@"posts"];
                [self groupByTime:array];
            }
            else
            {
                noneDongTaiLabel.hidden = NO;
            }
        }
    }
}
@end

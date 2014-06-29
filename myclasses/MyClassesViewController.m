//
//  MyClassesViewController.m
//  School
//
//  Created by TeekerZW on 1/14/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "MyClassesViewController.h"
#import "XDContentViewController+JDSideMenu.h"
#import "JDSideMenu.h"
#import "Header.h"
#import "ClassZoneViewController.h"
#import "ClassMemberViewController.h"
#import "NotificationViewController.h"
#import "ClassInfoViewController.h"
#import "ChooseSchoolViewController.h"
#import "ClassCell.h"
#import "EGORefreshTableHeaderView.h"
#import "AppDelegate.h"
#import "KKNavigationController.h"
#import "KKNavigationController+JDSideMenu.h"
#import "UINavigationController+JDSideMenu.h"
#import "SearchSchoolViewController.h"
#import "MoreViewController.h"
#import "CreateClassViewController.h"

#import "SearchClassViewController.h"

#import "XDTabViewController.h"

#define DEFAULTSCHOOLNAME  @"未指定学校的班级"
#define DEFAULTSCHOOLID    @"123"
#define DEFAULTSCHOOLLEVEL  @"1"

#define ADDACTIONSHEETTAG   3000

@interface MyClassesViewController ()<UITableViewDataSource,
UITableViewDelegate,
EGORefreshTableHeaderDelegate,
ChatDelegate,
MsgDelegate,
ReadNoticeDelegate,
FreshClassZone,
UIActionSheetDelegate>
{
    BOOL moreOpen;
    UITableView *classTableView;
    NSMutableArray *tmpArray;
    
    UILabel *haveNoClassLabel;
    
    EGORefreshTableHeaderView *pullRefreshView;
    BOOL _reloading;
    
    OperatDB *db;
    
    NSArray *schoolLevelArray;
    
    BOOL inThisPage;
    
//    UIView *headerView;
//    UILabel *headerLabel;
}
@end

@implementation MyClassesViewController
@synthesize headerIcon;
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
    
//    [self getcities];
    
    self.titleLabel.text = @"我的班级";
    self.titleLabel.font = [UIFont systemFontOfSize:19];
    [self.backButton setHidden:YES];
    self.returnImageView .hidden = YES;
    
    db = [[OperatDB alloc] init];
    
    schoolLevelArray = [NSArray arrayWithObjects:@"幼儿园",@"小学",@"中学",@"中专技校",@"培训机构",@"其他", nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeClassInfo) name:@"changeClassInfo" object:nil];
    
    [[self.bgView layer] setShadowOffset:CGSizeMake(-5.0f, 5.0f)];
    [[self.bgView layer] setShadowColor:[UIColor darkGrayColor].CGColor];
    [[self.bgView layer] setShadowOpacity:1.0f];
    [[self.bgView layer] setShadowRadius:3.0f];
    
    tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(5, 4, 42, 34);
    [moreButton setImage:[UIImage imageNamed:@"icon_list"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreOpen) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:moreButton];
    
//    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"navbtn"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setTitle:@"添加" forState:UIControlStateNormal];
    addButton.backgroundColor = [UIColor clearColor];
    [addButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    addButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [addButton addTarget:self action:@selector(addButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:addButton];
    
    haveNoClassLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, UI_NAVIGATION_BAR_HEIGHT+101, SCREEN_WIDTH-60, 60)];
    haveNoClassLabel.font = [UIFont systemFontOfSize:17];
    haveNoClassLabel.backgroundColor = [UIColor clearColor];
    haveNoClassLabel.numberOfLines = 3;
    haveNoClassLabel.textAlignment = NSTextAlignmentCenter;
    haveNoClassLabel.lineBreakMode = NSLineBreakByWordWrapping;
    haveNoClassLabel.textColor = UIColorFromRGB(0x727171);
    haveNoClassLabel.text = @"您还没有加入任何班级，快去加入或创建一个您的班级吧!";
    haveNoClassLabel.hidden = YES;
    [self.bgView addSubview:haveNoClassLabel];
    
    classTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    classTableView.delegate = self;
    classTableView.dataSource = self;
    classTableView.backgroundColor = self.bgView.backgroundColor;
    classTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    classTableView.showsVerticalScrollIndicator = NO;
    [self.bgView addSubview:classTableView];
    
    _reloading = NO;
    pullRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:classTableView orientation:EGOPullOrientationDown];
    pullRefreshView.delegate = self;
    
    
    [self getCacheData];
    
    if ([Tools NetworkReachable])
    {
        [self getClassesByUser];
    }
}
-(void)changeClassInfo
{
    [self getClassesByUser];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageOne"];
    inThisPage = YES;
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).ChatDelegate = self;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = self;
    
    [self dealNewChatMsg:nil];
    [self dealNewMsg:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
}
-(void)dealloc
{
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = self;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = self;
}

#pragma mark - chatdelegate
-(void)dealNewChatMsg:(NSDictionary *)dict
{
    db = [[OperatDB alloc] init];
    NSMutableArray *array = [db findSetWithDictionary:@{@"userid":[Tools user_id],@"readed":@"0"} andTableName:@"chatMsg"];
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
#pragma mark - moredelegate
-(void)signOutClass:(BOOL)signOut
{
    if (signOut)
    {
        [self egoRefreshTableHeaderDidTriggerRefresh:pullRefreshView];
    }
}

#pragma mark - newMsg

-(void)dealNewMsg:(NSDictionary *)dict
{
    if ([[dict objectForKey:@"type"] isEqualToString:@"c_apply"] ||
        [[dict objectForKey:@"type"] isEqualToString:@"notice"] ||
        [[dict objectForKey:@"type"] isEqualToString:@"c_allow"]||
        [[[NSUserDefaults standardUserDefaults] objectForKey:NewClassNum] integerValue]>0)
    {
        [self getClassesByUser];
    }
    else if([[dict objectForKey:@"type"]isEqualToString:@"f_apply"])
    {
        if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"checked":@"0"} andTableName:FRIENDSTABLE] count] > 0)
        {
            self.unReadLabel.hidden = NO;
        }
    }
}
-(void)countOfNewMsgWithType:(NSString *)msgType andTag:(NSString *)tagStr
{
    db = [[OperatDB alloc] init];
    NSMutableArray *array = [db findSetWithDictionary:@{@"uid":[Tools user_id],@"tag":tagStr} andTableName:@"notice"];
    DDLOG(@"new %@==%d",msgType,[array count]);
}

-(void)getCacheData
{
    NSString *requestUrlStr = [NSString stringWithFormat:@"%@==%@",GETCLASSESBYUSER,[Tools user_id]];
    NSString *key = [requestUrlStr MD5Hash];
    NSData *cacheData = [FTWCache objectForKey:key];
    if ([cacheData length] > 0)
    {
        NSString *responseString = [[NSString alloc] initWithData:cacheData encoding:NSUTF8StringEncoding];
        NSDictionary *responseDict = [Tools JSonFromString:responseString];
        DDLOG(@"classlist %@",responseDict);
        if ([[responseDict objectForKey:@"code"] intValue]== 1)
        {
            [tmpArray removeAllObjects];
            NSDictionary *dict1 = [responseDict objectForKey:@"data"];
            if (![dict1 isEqual:[NSNull null]])
            {
                haveNoClassLabel.hidden = YES;
                classTableView.hidden = NO;
                NSArray *array = [dict1 objectForKey:@"classes"];
                for (int i=0; i<[array count]; ++i)
                {
                    NSDictionary *dict2 = [array objectAtIndex:i];
                    NSString *s_id = [dict2 objectForKey:@"s_id"];
                    if ([s_id isEqual:[NSNull null]])
                    {
                        s_id = DEFAULTSCHOOLID;
                    }
                    if (![self isExistInTmpArray:s_id])
                    {
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
                        NSString *schoolID = s_id;
                        if ([schoolID length] > 0)
                        {
                            [dict setObject:schoolID forKey:@"s_id"];
                        }
                        
                        NSString *schoolName = [dict2 objectForKey:@"s_name"];
                        if ([schoolName isEqual:[NSNull null]])
                        {
                            schoolName = DEFAULTSCHOOLNAME;
                        }
                        if ([schoolName length] > 0)
                        {
                            [dict setObject:schoolName forKey:@"s_name"];
                        }
                        
                        NSString *s_level = [dict2 objectForKey:@"s_level"];
                        if ([s_level isEqual:[NSNull null]])
                        {
                            s_level = DEFAULTSCHOOLLEVEL;
                        }
                        
                        if ([dict2 objectForKey:@"s_level"])
                        {
                            NSString *schoolLevel = [NSString stringWithFormat:@"%d",[s_level integerValue]];
                            if ([schoolLevel length] > 0)
                            {
                                [dict setObject:schoolLevel forKey:@"s_level"];
                            }
                        }
                        NSMutableArray *array2 = [[NSMutableArray alloc] initWithCapacity:0];
                        for (int m=0; m<[array count]; ++m)
                        {
                            NSString *schoolID2 = [[array objectAtIndex:m] objectForKey:@"s_id"];
                            if ([schoolID2 isEqual:[NSNull null]])
                            {
                                schoolID2 = DEFAULTSCHOOLID;
                            }
                            if ([schoolID2 isEqualToString:schoolID])
                            {
                                [array2 addObject:[array objectAtIndex:m]];
                            }
                        }
                        [dict setObject:array2 forKey:@"classes"];
                        [tmpArray addObject:dict];
                    }
                }
                if ([tmpArray count] <= 0)
                {
                    haveNoClassLabel.hidden = NO;
                    classTableView.hidden = YES;
                    [self getClassesByUser];
                }
                else
                {
                    haveNoClassLabel.hidden = YES;
                    classTableView.hidden = NO;
                    [classTableView reloadData];
                }
            }
        }
    }
    else
    {
        [self getClassesByUser];
    }
}

#pragma mark - egodelegate
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self getClassesByUser];
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
    [pullRefreshView egoRefreshScrollViewDidScroll:classTableView];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pullRefreshView egoRefreshScrollViewDidEndDragging:classTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getClassesByUser
{
    if ([Tools NetworkReachable])
    {
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-25, UI_NAVIGATION_BAR_HEIGHT + 10, 50, 50)];
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token]
                                                                      } API:GETCLASSESBYUSER];
        
        [request setCompletionBlock:^{
            [indicatorView stopAnimating];
            [indicatorView removeFromSuperview];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"classesByUser responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                int ucfriendNum = [[[responseDict objectForKey:@"data"] objectForKey:@"ucfriendsnum"] intValue];
                if (ucfriendNum > 0)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",ucfriendNum] forKey:UCFRIENDSUM];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    self.unReadLabel.hidden = NO;
                }
                
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:NewClassNum] integerValue] > 0)
                {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:NewClassNum];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                [tmpArray removeAllObjects];
                NSDictionary *dict1 = [responseDict objectForKey:@"data"];
                if (![dict1 isEqual:[NSNull null]])
                {
                    haveNoClassLabel.hidden = YES;
                    classTableView.hidden = NO;
                    NSArray *array = [dict1 objectForKey:@"classes"];
                    for (int i=0; i<[array count]; ++i)
                    {
                        NSDictionary *dict2 = [array objectAtIndex:i];
                        NSString *s_id = [dict2 objectForKey:@"s_id"];
                        if ([s_id isEqual:[NSNull null]])
                        {
                            s_id = DEFAULTSCHOOLID;
                        }
                        if (![self isExistInTmpArray:s_id])
                        {
                            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
                            NSString *schoolID = s_id;
                            if ([schoolID length] > 0)
                            {
                                [dict setObject:schoolID forKey:@"s_id"];
                            }
                            
                            NSString *schoolName = [dict2 objectForKey:@"s_name"];
                            if ([schoolName isEqual:[NSNull null]])
                            {
                                schoolName = DEFAULTSCHOOLNAME;
                            }
                            if ([schoolName length] > 0)
                            {
                                [dict setObject:schoolName forKey:@"s_name"];
                            }
                            
                            NSString *s_level = [dict2 objectForKey:@"s_level"];
                            if ([s_level isEqual:[NSNull null]])
                            {
                                s_level = DEFAULTSCHOOLLEVEL;
                            }
                            else if ([dict2 objectForKey:@"s_level"])
                            {
                                NSString *schoolLevel = [NSString stringWithFormat:@"%d",[[dict2 objectForKey:@"s_level"] integerValue]];
                                if ([schoolLevel length] > 0)
                                {
                                    [dict setObject:schoolLevel forKey:@"s_level"];
                                }
                            }
                            
                            
                            NSMutableArray *array2 = [[NSMutableArray alloc] initWithCapacity:0];
                            for (int m=0; m<[array count]; ++m)
                            {
                                NSString *schoolID2 = [[array objectAtIndex:m] objectForKey:@"s_id"];
                                if ([schoolID2 isEqual:[NSNull null]])
                                {
                                    schoolID2 = DEFAULTSCHOOLID;
                                }
                                if ([schoolID2 isEqualToString:schoolID])
                                {
                                    [array2 addObject:[array objectAtIndex:m]];
                                }
                            }
                            [dict setObject:array2 forKey:@"classes"];
                            [tmpArray addObject:dict];
                        }
                    }
                    NSString *requestUrlStr = [NSString stringWithFormat:@"%@==%@",GETCLASSESBYUSER,[Tools user_id]];
                    NSString *key = [requestUrlStr MD5Hash];
                    [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
                    if ([tmpArray count] <= 0)
                    {
                        haveNoClassLabel.hidden = NO;
                        classTableView.hidden = YES;
                    }
                    else
                    {
                        haveNoClassLabel.hidden = YES;
                        classTableView.hidden = NO;
                    }
                    [classTableView reloadData];
                    _reloading = NO;
                    [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:classTableView];
                }
                else
                {
                    classTableView.hidden = YES;
                    haveNoClassLabel.hidden = NO;
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
            [indicatorView stopAnimating];
            [indicatorView removeFromSuperview];
            [Tools showAlertView:@"连接错误" delegateViewController:nil];
            _reloading = NO;
            [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:classTableView];
        }];
        [indicatorView startAnimating];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
        _reloading = NO;
        [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:classTableView];
    }
}


-(BOOL)isExistInTmpArray:(NSString *)schoolID
{
    for (int i=0; i<[tmpArray count]; ++i)
    {
        if ([schoolID isEqualToString:[[tmpArray objectAtIndex:i] objectForKey:@"s_id"]])
        {
            return YES;
        }
    }
    return NO;
}


#pragma mark - tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tmpArray count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[tmpArray objectAtIndex:section] objectForKey:@"classes"] count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 83;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    
//    headerView.backgroundColor = UIColorFromRGB(0xf1f0ec);
    if (section % 2 == 0)
    {
        headerView.backgroundColor = RGB(64, 196, 110, 1);
    }
    else
    {
        headerView.backgroundColor = RGB(65, 196, 182, 1);
    }
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, 30)];
    headerLabel.backgroundColor = [UIColor clearColor];
//    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont boldSystemFontOfSize:16];
    headerLabel.textColor = [UIColor whiteColor];
    NSDictionary *tmpdict = [tmpArray objectAtIndex:section];
    if ([[tmpdict objectForKey:@"s_name"] isEqualToString:DEFAULTSCHOOLNAME])
    {
         headerLabel.text = [NSString stringWithFormat:@"   %@",[tmpdict objectForKey:@"s_name"]];
    }
    else
    {
         headerLabel.text = [NSString stringWithFormat:@"   %@(%@)",[tmpdict objectForKey:@"s_name"],[schoolLevelArray objectAtIndex:[[tmpdict objectForKey:@"s_level"] integerValue]]];
    }
   
    [headerView addSubview:headerLabel];
    return headerView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *classname = @"classname";
    ClassCell *cell = [tableView dequeueReusableCellWithIdentifier:classname];
    if (cell == nil)
    {
        cell = [[ClassCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:classname];
    }
    NSDictionary *dict = [tmpArray objectAtIndex:indexPath.section];
    NSArray *array = [dict objectForKey:@"classes"];
    NSDictionary *classDict = [array objectAtIndex:indexPath.row];
    cell.headerImageView.frame = CGRectMake(10, 10, 50, 50);
    cell.headerImageView.layer.cornerRadius = 3;
    cell.headerImageView.clipsToBounds =YES;
    if (![[classDict objectForKey:@"img_icon"] isEqual:[NSNull null]] && [[classDict objectForKey:@"img_icon"] length] > 10)
    {
        [Tools fillImageView:cell.headerImageView withImageFromURL:[classDict objectForKey:@"img_icon"] andDefault:@"3100"];
    }
    else
    {
        [cell.headerImageView setImage:[UIImage imageNamed:@"headpic.jpg"]];
    }
    cell.nameLabel.frame = CGRectMake(70, 10, SCREEN_WIDTH-95, 30);
    cell.nameLabel.text = [classDict objectForKey:@"name"];
    int num = 0;
    
    if ([[classDict objectForKey:@"notice"] integerValue] > 0)
    {
        num+=[[classDict objectForKey:@"notice"] integerValue];
    }
    
    OperatDB *_db = [[OperatDB alloc] init];
    if ([classDict objectForKey:UCMEMBER])
    {
        num+=[[classDict objectForKey:UCMEMBER] integerValue];
        if ([[classDict objectForKey:UCMEMBER] integerValue] > 0)
        {
            [_db deleteRecordWithDict:@{@"classid":[classDict objectForKey:@"_id"],@"checked":@"0"} andTableName:CLASSMEMBERTABLE];
            for (int i=0; i<[[classDict objectForKey:UCMEMBER] integerValue]; ++i)
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
                [dict setObject:@"" forKey:@"name"];
                [dict setObject:[classDict objectForKey:@"_id"] forKey:@"classid"];
                [dict setObject:@"" forKey:@"img_icon"];
                [dict setObject:@"0" forKey:@"checked"];
                [dict setObject:@"" forKey:@"phone"];
                [dict setObject:@"" forKey:@"re_name"];
                [dict setObject:@"" forKey:@"re_id"];
                [dict setObject:@"" forKey:@"re_type"];
                [dict setObject:@"" forKey:@"title"];
                if ([_db insertRecord:dict andTableName:CLASSMEMBERTABLE])
                {
                    DDLOG(@"insert new apply in myclassesVC success!");
                }
            }
        }
    }
    
    cell.contentLable.backgroundColor = [UIColor redColor];
    cell.contentLable.textColor = [UIColor whiteColor];
    cell.contentLable.textAlignment = NSTextAlignmentCenter;
    cell.contentLable.font = [UIFont systemFontOfSize:10];
    if (num >0)
    {
        cell.contentLable.frame = CGRectMake(SCREEN_WIDTH-70 , 25, 20, 20);
        cell.contentLable.layer.cornerRadius = 10;
        cell.contentLable.clipsToBounds = YES;
        cell.contentLable.hidden = NO;
        cell.contentLable.text = [NSString stringWithFormat:@"%d",num];
    }
    else if([classDict objectForKey:UCDIARY] || [classDict objectForKey:DIARY])
    {
        cell.contentLable.frame = CGRectMake(SCREEN_WIDTH-60, 30, 10, 10);
        cell.contentLable.layer.cornerRadius = 5;
        cell.contentLable.clipsToBounds = YES;
        cell.contentLable.hidden = NO;
    }
    else
    {
        cell.contentLable.hidden = YES;
    }
    
    
    int studentNum = 0;
    if(![[classDict objectForKey:@"students_num"] isEqual:[NSNull null]])
    {
        studentNum = [[classDict objectForKey:@"students_num"] integerValue];
    }
    int parentNum = 0;
    if(![[classDict objectForKey:@"parents_num"] isEqual:[NSNull null]])
    {
        parentNum = [[classDict objectForKey:@"parents_num"] integerValue];
    }
    cell.timeLabel.frame = CGRectMake(cell.nameLabel.frame.origin.x, cell.nameLabel.frame.origin.y+cell.nameLabel.frame.size.height, 180, 20);
    cell.timeLabel.textColor = TIMECOLOR;
    cell.timeLabel.text = [NSString stringWithFormat:@"%d名学生  %d名家长",studentNum,parentNum];
    
    
    cell.bgView.frame = CGRectMake(10, 6.5, SCREEN_WIDTH-20, 70);
    cell.bgView.backgroundColor = [UIColor whiteColor];
    cell.bgView.layer.cornerRadius = 5;
    cell.bgView.clipsToBounds = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.backgroundColor = self.bgView.backgroundColor;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [tmpArray objectAtIndex:indexPath.section];
    DDLOG(@"class %@",dict);
    NSDictionary *classDict = [[dict objectForKey:@"classes"] objectAtIndex:indexPath.row];
    NSString *classID = [classDict objectForKey:@"_id"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",[[classDict objectForKey:@"notice"] integerValue]] forKey:[NSString  stringWithFormat:@"%@-notice",classID]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    XDTabViewController *tabViewController = [XDTabViewController sharedTabViewController];
    
    ClassZoneViewController *classZone = [[ClassZoneViewController alloc] init];
    classZone.fromClasses = NO;
    classZone.fromMsg = NO;
    classZone.refreshDel = self;
    
    NotificationViewController *notification = [[NotificationViewController alloc] init];
    notification.readNoticedel = self;
    
    ClassMemberViewController *classMember = [[ClassMemberViewController alloc] init];
    classMember.fromMsg = NO;
    
    ClassInfoViewController *classInfoViewController = [[ClassInfoViewController alloc] init];
//    MoreViewController *moreVC = [[MoreViewController alloc] init];
    
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    [ud setObject:FROMCLASS forKey:FROMWHERE];
    [ud setObject:classID forKey:@"classid"];
    [ud setObject:[classDict objectForKey:@"name"] forKey:@"classname"];
    NSString *s_id = [classDict objectForKey:@"s_id"];
    if ([s_id isEqual:[NSNull null]])
    {
        s_id = @"未设置学校";
    }
    [ud setObject:s_id forKey:@"schoolid"];
    NSString *s_name = [classDict objectForKey:@"s_name"];
    if ([s_name isEqual:[NSNull null]])
    {
        s_name = @"未设置学校";
    }
    [ud setObject:s_name forKey:@"schoolname"];
    
    NSString *s_level = [classDict objectForKey:@"s_level"];
    if ([s_level isEqual:[NSNull null]])
    {
        s_level = @"未设置学校";
    }
    [ud setObject:s_level forKey:@"schoollevel"];
    
    if (![[classDict objectForKey:@"img_kb"] isEqual:[NSNull null]] && [[classDict objectForKey:@"img_kb"] length] > 10)
    {
        [ud setObject:[classDict objectForKey:@"img_kb"] forKey:@"classkbimage"];
    }
    else
    {
        [ud setObject:@"" forKey:@"classkbimage"];
    }
    
    if (![[classDict objectForKey:@"img_icon"] isEqual:[NSNull null]] && [[classDict objectForKey:@"img_icon"] length] > 10)
    {
        [ud setObject:[classDict objectForKey:@"img_icon"] forKey:@"classiconimage"];
    }
    else
    {
        [ud setObject:@"" forKey:@"classiconimage"];
    }

    [ud synchronize];
    
    KKNavigationController *nav1 = [[KKNavigationController alloc] initWithRootViewController:classZone];
    KKNavigationController *nav2 = [[KKNavigationController alloc] initWithRootViewController:notification];
    KKNavigationController *nav3 = [[KKNavigationController alloc] initWithRootViewController:classMember];
    KKNavigationController *nav4 = [[KKNavigationController alloc] initWithRootViewController:classInfoViewController];
    
    NSArray *viewControllerArray = @[nav1,nav2,nav3,nav4];
    [tabViewController setTabBarContents:viewControllerArray];
    [tabViewController selectItemAtIndex:0];
    
    KKNavigationController *tabBarNav = [[KKNavigationController alloc] initWithRootViewController:tabViewController];
    [self.navigationController presentViewController:tabBarNav animated:YES completion:^{

    }];
    [self.sideMenuController hideMenuAnimated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    inThisPage = NO;
}

-(void)reFreshClassZone:(BOOL)refresh
{
    if (refresh)
    {
        [self getClassesByUser];
    }
}
-(void)readNotice:(BOOL)read
{
    if (read)
    {
        [self getClassesByUser];
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

-(void)addButtonClick
{
    if ([Tools phone_num])
    {
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"创建班级",@"加入班级", nil];
        ac.tag = ADDACTIONSHEETTAG;
        [ac showInView:classTableView];
        
        //        SearchSchoolViewController *searchSchoolViewController = [[SearchSchoolViewController alloc] init];
//        [self.navigationController pushViewController:searchSchoolViewController animated:YES];
//        ChooseSchoolViewController *chooseViewController = [[ChooseSchoolViewController alloc] init];
//        [chooseViewController.schoolArray addObjectsFromArray:tmpArray];
//        [self.navigationController pushViewController:chooseViewController animated:YES];
        
//        CreateClassViewController *createClassViewController = [[CreateClassViewController alloc] init];
//        [self.navigationController pushViewController:createClassViewController animated:YES];
    }
    else
    {
        [Tools showAlertView:@"请先到个人信息里绑定手机号" delegateViewController:nil];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == ADDACTIONSHEETTAG)
    {
        if (buttonIndex == 0)
        {
            CreateClassViewController *createClass = [[CreateClassViewController alloc] init];
            [self.navigationController pushViewController:createClass animated:YES];
        }
        else if(buttonIndex == 1)
        {
            SearchClassViewController *searchclassVC = [[SearchClassViewController alloc] init];
            [self.navigationController pushViewController:searchclassVC animated:YES];
        }
    }
}

-(void)getcities
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token]
                                                                      } API:GETCITIES];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"get cities responsedict %@",responseDict);
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

@end
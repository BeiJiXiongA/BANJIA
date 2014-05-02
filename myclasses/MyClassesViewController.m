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
#import "MoreViewController.h"
#import "ChooseSchoolViewController.h"
#import "ClassCell.h"
#import "EGORefreshTableHeaderView.h"
#import "AppDelegate.h"
#import "KKNavigationController.h"

@interface MyClassesViewController ()<UITableViewDataSource,
UITableViewDelegate,
EGORefreshTableHeaderDelegate,
ChatDelegate,
MsgDelegate>
{
    BOOL moreOpen;
    UITableView *classTableView;
    NSMutableArray *tmpArray;
    
    UILabel *haveNoClassLabel;
    
    EGORefreshTableHeaderView *pullRefreshView;
    BOOL _reloading;
    OperatDB *db;
    
//    UIView *headerView;
//    UILabel *headerLabel;
}
@end

@implementation MyClassesViewController

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
    
    self.titleLabel.text = @"我的班级";
    self.titleLabel.font = [UIFont systemFontOfSize:19];
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    [self.backButton setHidden:YES];
    self.returnImageView .hidden = YES;
    db = [OperatDB alloc];
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).ChatDelegate = self;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = self;
    
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
//    [addButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    addButton.backgroundColor = [UIColor clearColor];
    [addButton setBackgroundImage:[UIImage imageNamed:@"navbtn"] forState:UIControlStateNormal];
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
    
    classTableView = [[UITableView alloc] initWithFrame:CGRectMake(4, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH-8, SCREEN_HEIGHT - UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    classTableView.delegate = self;
    classTableView.dataSource = self;
    classTableView.backgroundColor = UIColorFromRGB(0xf1f0ec);
    classTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    classTableView.showsVerticalScrollIndicator = NO;
    [self.bgView addSubview:classTableView];
    
    _reloading = NO;
    pullRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:classTableView orientation:EGOPullOrientationDown];
    pullRefreshView.delegate = self;
    
    
    [self getClassesByUser];
//    [self getCacheData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

#pragma mark - chatdelegate
-(void)dealNewChatMsg:(NSDictionary *)dict
{
    NSMutableArray *array = [db findSetWithDictionary:@{} andTableName:@"chatMsg"];
    DDLOG(@"new chat==%d",[array count]);
    if ([array count] > 0)
    {
        self.unReadLabel.hidden = NO;
    }
}
#pragma mark - newMsg

-(void)dealNewMsg:(NSDictionary *)dict
{
    [classTableView reloadData];
}
-(void)countOfNewMsgWithType:(NSString *)msgType andTag:(NSString *)tagStr
{
    NSMutableArray *array = [db findSetWithDictionary:@{} andTableName:@"notice"];
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
                    if (![self isExistInTmpArray:[dict2 objectForKey:@"s_id"]])
                    {
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
                        NSString *schoolID = [dict2 objectForKey:@"s_id"];
                        if ([schoolID length] > 0)
                        {
                            [dict setObject:schoolID forKey:@"s_id"];
                        }
                        
                        NSString *schoolName = [dict2 objectForKey:@"s_name"];
                        if ([schoolName length] > 0)
                        {
                            [dict setObject:schoolName forKey:@"s_name"];
                        }
                        
                        NSMutableArray *array2 = [[NSMutableArray alloc] initWithCapacity:0];
                        for (int m=0; m<[array count]; ++m)
                        {
                            NSString *schoolID2 = [[array objectAtIndex:m] objectForKey:@"s_id"];
                            
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
                
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"count"] intValue] >0 ||
                    [[[responseDict objectForKey:@"data"] objectForKey:@"ucfriendsnum"] intValue] > 0)
                {
                    self.unReadLabel.hidden = NO;
                }
                else
                {
                    self.unReadLabel.hidden = YES;
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
                        if (![self isExistInTmpArray:[dict2 objectForKey:@"s_id"]])
                        {
                            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
                            NSString *schoolID = [dict2 objectForKey:@"s_id"];
                            if ([schoolID length] > 0)
                            {
                                [dict setObject:schoolID forKey:@"s_id"];
                            }
                            
                            NSString *schoolName = [dict2 objectForKey:@"s_name"];
                            if ([schoolName length] > 0)
                            {
                                [dict setObject:schoolName forKey:@"s_name"];
                            }
                            
                            NSMutableArray *array2 = [[NSMutableArray alloc] initWithCapacity:0];
                            for (int m=0; m<[array count]; ++m)
                            {
                                NSString *schoolID2 = [[array objectAtIndex:m] objectForKey:@"s_id"];
                                
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
                        [self setBaiduTags];
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
                [Tools dealRequestError:responseDict fromViewController:(XDContentViewController *)self.sideMenuController];
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

-(void)setBaiduTags
{
    NSMutableString *tagsString = [[NSMutableString alloc] initWithCapacity:0];
    for (int i=0; i<[tmpArray count]; ++i)
    {
        NSDictionary *dict = [tmpArray objectAtIndex:i];
        NSArray *classArray = [dict objectForKey:@"classes"];
        for (int j=0; j<[classArray count]; ++j)
        {
            NSDictionary *classDict = [classArray objectAtIndex:j];
            NSString *classID = [classDict objectForKey:@"_id"];
            [BPush setTag:classID];
            [tagsString insertString:[NSString stringWithFormat:@"%@,",classID] atIndex:[tagsString length]];
        }
    }
    if ([tmpArray count] > 0)
    {
        NSString *key = [TAGSARRAYKEY MD5Hash];
        [FTWCache setObject:[tagsString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
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
    DDLOG(@"====%@",tmpArray);
    return [tmpArray count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[tmpArray objectAtIndex:section] objectForKey:@"classes"] count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 26.5;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 26.5)];
    
//    headerView.backgroundColor = UIColorFromRGB(0xf1f0ec);
    headerView.backgroundColor = RGB(234, 234, 234, 1);
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1.5, headerView.frame.size.width, 26.5)];
//    headerLabel.backgroundColor = UIColorFromRGB(0x4abcc2);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont systemFontOfSize:17];
    headerLabel.textColor = TITLE_COLOR;
    headerLabel.text = [[tmpArray objectAtIndex:section] objectForKey:@"s_name"];
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
    cell.headerImageView.frame = CGRectMake(16, 7.5, 36, 36);
    cell.headerImageView.layer.cornerRadius = 10;
    cell.headerImageView.clipsToBounds =YES;
    [Tools fillImageView:cell.headerImageView withImageFromURL:@"" andDefault:@"headpic"];
    cell.nameLabel.frame = CGRectMake(80, 10, SCREEN_WIDTH-95, 30);
    cell.nameLabel.text = [classDict objectForKey:@"name"];
    int num = 0;
    if ([classDict objectForKey:NOTICE])
    {
        num+=[[classDict objectForKey:NOTICE] integerValue];
    }
    if ([classDict objectForKey:UCMEMBER])
    {
        num+=[[classDict objectForKey:UCMEMBER] integerValue];
    }
    
    [self countOfNewMsgWithType:@"notice" andTag:[classDict objectForKey:@"_id"]];
    [self countOfNewMsgWithType:@"c_apply" andTag:[classDict objectForKey:@"_id"]];
    
    cell.contentLable.backgroundColor = [UIColor redColor];
    cell.contentLable.textColor = [UIColor whiteColor];
    cell.contentLable.textAlignment = NSTextAlignmentCenter;
    cell.contentLable.font = [UIFont systemFontOfSize:10];
    if (num >0)
    {
        cell.contentLable.frame = CGRectMake(cell.headerImageView.frame.size.width+cell.headerImageView.frame.origin.x-5, cell.headerImageView.frame.origin.y-5, 15, 15);
        cell.contentLable.layer.cornerRadius = 7.5;
        cell.contentLable.clipsToBounds = YES;
        cell.contentLable.text = [NSString stringWithFormat:@"%d",num];
    }
    else if([classDict objectForKey:UCDIARY] || [classDict objectForKey:DIARY])
    {
        cell.contentLable.frame = CGRectMake(cell.headerImageView.frame.size.width+cell.headerImageView.frame.origin.x-3, cell.headerImageView.frame.origin.y-3, 6, 6);
        cell.contentLable.layer.cornerRadius = 3;
        cell.contentLable.clipsToBounds = YES;
    }
    else
    {
        cell.contentLable.hidden = YES;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    UIImageView *bgImageBG = [[UIImageView alloc] init];
    bgImageBG.image = [UIImage imageNamed:@"cell_bg"];
    bgImageBG.backgroundColor = [UIColor clearColor];
    cell.backgroundView = bgImageBG;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [tmpArray objectAtIndex:indexPath.section];
    NSDictionary *classDict = [[dict objectForKey:@"classes"] objectAtIndex:indexPath.row];
    NSString *classID = [classDict objectForKey:@"_id"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([classDict objectForKey:NOTICE])
    {
        [ud setObject:[classDict objectForKey:NOTICE] forKey:NOTICE];
    }
    else
    {
        [ud setObject:@"0" forKey:NOTICE];
    }
    if ([classDict objectForKey:UCMEMBER])
    {
        [ud setObject:[classDict objectForKey:UCMEMBER] forKey:UCMEMBER];
    }
    else
    {
        [ud setObject:@"0" forKey:UCMEMBER];
    }
    if ([classDict objectForKey:UCDIARY] || [classDict objectForKey:DIARY])
    {
        [ud setObject:@"2" forKey:DIARY];
    }
    else
    {
        [ud setObject:@"0" forKey:DIARY];
    }
    [ud synchronize];
    
    ClassZoneViewController *classZone = [[ClassZoneViewController alloc] init];
    classZone.classID = classID;
    classZone.fromClasses = NO;
    classZone.fromMsg = NO;
    
    NotificationViewController *notification = [[NotificationViewController alloc] init];
    notification.classID = classID;
    
    ClassMemberViewController *classMember = [[ClassMemberViewController alloc] init];
    classMember.classID = classID;
    classMember.fromMsg = NO;
    
    MoreViewController *more = [[MoreViewController alloc] init];
    more.classID = classID;
    
    XDTabViewController *tabViewController = [XDTabViewController sharedTabViewController];
    NSArray *viewControllerArray = @[classZone,notification,classMember,more];
    [tabViewController setTabBarContents:viewControllerArray];
    [tabViewController selectItemAtIndex:0];
    [tabViewController showSelfViewController:self];
    [self.sideMenuController hideMenuAnimated:YES];
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

-(void)addButtonClick
{
    ChooseSchoolViewController *chooseViewController = [[ChooseSchoolViewController alloc] init];
    [chooseViewController showSelfViewController:self];
}

@end

//-(void)getMsgList
//{
//    if ([Tools NetworkReachable])
//    {
//        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],@"token":[Tools client_token]} API:MSGLIST];
//        
//        [request setCompletionBlock:^{
//            [Tools hideProgress:self.bgView];
//            NSString *responseString = [request responseString];
//            NSDictionary *responseDict = [Tools JSonFromString:responseString];
//            DDLOG(@"msglist responsedict %@",responseDict);
//            if ([[responseDict objectForKey:@"code"] intValue]== 1)
//            {
//                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//                [ud setObject:[[responseDict objectForKey:@"data"] objectForKey:@"count"] forKey:@"count"];
//                [ud setObject:[[responseDict objectForKey:@"data"] objectForKey:UCMEMBER] forKey:UCFRIENDSUM];
//                [ud synchronize];
//                
//                if ([[[responseDict objectForKey:@"data"] objectForKey:@"count"] integerValue] > 0 || [[[responseDict objectForKey:@"data"] objectForKey:UCFRIENDSUM] integerValue] > 0)
//                {
//                    self.unReadLabel.hidden = NO;
//                }
//            }
//            else
//            {
//                [Tools dealRequestError:responseDict fromViewController:self];
//            }
//            
//        }];
//        
//        [request setFailedBlock:^{
//            NSError *error = [request error];
//            DDLOG(@"error %@",error);
//            [Tools hideProgress:self.bgView];
//        }];
//        [Tools showProgress:self.bgView];
//        [request startAsynchronous];
//    }
//    else
//    {
//        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
//    }
//    
//}

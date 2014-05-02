//
//  ClassMemberViewController.m
//  School
//
//  Created by TeekerZW on 14-1-17.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "ClassMemberViewController.h"
#import "XDTabViewController.h"
#import "MemberCell.h"
#import "StudentDetailViewController.h"
#import "ParentsDetailViewController.h"
#import "MemberDetailViewController.h"
#import "SubGroupViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "OperatDB.h"

#define tableviewTag  3000
#define MemTableViewTag  4000
#define SearchTableViewTag 5000

@interface ClassMemberViewController ()<UIScrollViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
EGORefreshTableHeaderDelegate,
UISearchBarDelegate,
SubGroupDelegate,
MemberDetailDelegate,
PareberDetailDelegate,
StuDetailDelegate>
{
    OperatDB *_db;
    
    UITableView *memberTableView;
    
    NSMutableArray *allMembersArray;
    
    NSMutableArray *newAppleArray;
    NSMutableArray *classLeadersArray;
    NSMutableArray *membersArray;
    NSMutableArray *studentArray;
    NSMutableArray *teachersArray;
    NSMutableArray *adminArray;
    NSMutableArray *parentsArray;
    NSMutableArray *withoutParentStuArray;
    NSMutableArray *adminIDArray;
    
    NSArray *buttonNamesArray;
    UIView *selectView;
    UIScrollView *bgScrollView;
    
    NSString *updateGroup;
    
    EGORefreshTableHeaderView *pullRefreshView;
    BOOL _reloading;
    
    UISearchBar *mySearchBar;
    NSMutableArray *searchResultArray;
    UITableView *searchTableView;
    UIView *searchView;
}
@end

@implementation ClassMemberViewController
@synthesize classID,fromMsg;
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
    self.titleLabel.text = @"班级成员";
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    updateGroup = @"";
    
    _db = [[OperatDB alloc] init];
    
    newAppleArray = [[NSMutableArray alloc] initWithCapacity:0];
    membersArray = [[NSMutableArray alloc] initWithCapacity:0];
    teachersArray = [[NSMutableArray alloc] initWithCapacity:0];
    classLeadersArray = [[NSMutableArray alloc] initWithCapacity:0];
    adminArray = [[NSMutableArray alloc] initWithCapacity:0];
    parentsArray = [[NSMutableArray alloc] initWithCapacity:0];
    studentArray = [[NSMutableArray alloc] initWithCapacity:0];
    withoutParentStuArray = [[NSMutableArray alloc] initWithCapacity:0];
    adminIDArray = [[NSMutableArray alloc] initWithCapacity:0];
    allMembersArray = [[NSMutableArray alloc] initWithCapacity:0];
    searchResultArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (fromMsg)
    {
        [self.backButton addTarget:self action:@selector(mybackClick) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [self.backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setTitle:@"邀请" forState:UIControlStateNormal];
    [inviteButton setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
    [inviteButton setBackgroundColor:[UIColor clearColor]];
    inviteButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [inviteButton addTarget:self action:@selector(inviteClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:inviteButton];
    
    mySearchBar = [[UISearchBar alloc] initWithFrame:
                   CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH-0, 40)];
    mySearchBar.delegate = self;
    mySearchBar.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:mySearchBar];
    
    memberTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT+40, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-UI_TAB_BAR_HEIGHT-40) style:UITableViewStylePlain];
    if (fromMsg)
    {
        memberTableView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT+40, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-40);
    }
    else
    {
        memberTableView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT+40, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-UI_TAB_BAR_HEIGHT-40);
    }
    memberTableView.delegate = self;
    memberTableView.dataSource = self;
    memberTableView.backgroundColor = self.bgView.backgroundColor;
    memberTableView.tag = MemTableViewTag;
    [self.bgView addSubview:memberTableView];
    
    pullRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:memberTableView orientation:EGOPullOrientationDown];
    pullRefreshView.delegate = self;
    
    
    searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT-40-UI_TAB_BAR_HEIGHT-20)];
    searchView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.bgView addSubview:searchView];
    [self.bgView sendSubviewToBack:searchView];
    
    UITextField* searchField = nil;
    for (UIView* subview in mySearchBar.subviews)
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            searchField = (UITextField*)subview;
            searchField.leftView=nil;
            searchField.placeholder = @"输入学生姓名";
            [searchField setBackground:nil];
            searchField.background = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
            [searchField setBackgroundColor:[UIColor whiteColor]];
            [searchField setBorderStyle:UITextBorderStyleNone];
            break;
        }
    }
    
    for (UIView *subview in mySearchBar.subviews)
    {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
//            subview.backgroundColor = [UIColor whiteColor];
            [subview removeFromSuperview];
            break;
        }
    }
    
    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 3, 20, 2)];
    
    UIImageView *inputImageView = [[UIImageView alloc] initWithFrame:mySearchBar.frame];
    inputImageView.image = inputImage;
    [self.bgView insertSubview:inputImageView belowSubview:mySearchBar];
    
    searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0) style:UITableViewStylePlain];
    searchTableView.delegate = self;
    searchTableView.dataSource = self;
    searchTableView.tag = SearchTableViewTag;
    [searchView addSubview:searchTableView];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([[ud objectForKey:UCMEMBER] integerValue] > 0)
    {
        [self getAdmins];
    }
    else
    {
         [self getAdminCache];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self getMembersByClass:@"all"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)mybackClick
{
    [self unShowSelfViewController];
}

#pragma mark - subGroupdelegate
-(void)subGroupUpdate:(BOOL)update
{
    if (update)
    {
        [self getMembersByClass:@"all"];
        
    }
}
#pragma mark - memdel
-(void)updateListWith:(BOOL)update
{
    if (update)
    {
        [self getMembersByClass:@"all"];
    }
}

#pragma mark - searchbardelegate
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.2 animations:^{
        [self.bgView bringSubviewToFront:searchView];
        mySearchBar.frame = CGRectMake(0, 0, SCREEN_WIDTH-0, 40);
        searchTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
        memberTableView.hidden = YES;
    }];
    searchBar.showsCancelButton = YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchWithText:searchText];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchResultArray removeAllObjects];
    searchBar.text = nil;
//    [searchResultTableView reloadData];
    [UIView animateWithDuration:0.2 animations:^{
        [self.bgView sendSubviewToBack:searchView];
        mySearchBar.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH-0, 40);
        memberTableView.hidden = NO;
        searchTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    }];
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchContent = [searchBar text];
    [self searchWithText:searchContent];
}

-(void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    DDLOG_CURRENT_METHOD;
}
-(void)searchWithText:(NSString *)searchContent
{
    [searchResultArray removeAllObjects];
    for (int i=0; i<[allMembersArray count]; ++i)
    {
        NSDictionary *dict = [allMembersArray objectAtIndex:i];
        NSString *name = [dict objectForKey:@"name"];
        if ([name rangeOfString:searchContent].length > 0)
        {
            [searchResultArray addObject:dict];
        }
    }
    [searchTableView reloadData];
    DDLOG(@"result count ==%d",[searchResultArray count]);
    
}

#pragma mark - egodelegate
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self getAdmins];
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
    if (scrollView.tag == MemTableViewTag)
    {
        [UIView animateWithDuration:0.2 animations:^{
            if (scrollView.contentOffset.y>50)
            {
                memberTableView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-UI_TAB_BAR_HEIGHT);
                mySearchBar.hidden = YES;
            }
            else if(scrollView.contentOffset.y <50)
            {
                memberTableView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT+40, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-UI_TAB_BAR_HEIGHT-40);
                mySearchBar.hidden = NO;
            }
        }];
    }
    [pullRefreshView egoRefreshScrollViewDidScroll:memberTableView];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pullRefreshView egoRefreshScrollViewDidEndDragging:memberTableView];
}


-(void)backClick
{
//    [[XDTabViewController sharedTabViewController] dismissViewControllerAnimated:YES completion:nil];
    [[XDTabViewController sharedTabViewController] unShowSelfViewController];
}

-(void)inviteClick
{
    InviteViewController *inviteViewController = [[InviteViewController alloc] init];
    [inviteViewController showSelfViewController:self];
}
#pragma mark - getNetData

-(void)getAdminCache
{
    NSString *urlStr = [NSString stringWithFormat:@"%@=%@=%@",[Tools user_id],classID,MB_ADMINLIST];
    NSString *key = [urlStr MD5Hash];
    NSData *adminListData = [FTWCache objectForKey:key];
    if ([adminListData length])
    {
        NSString *responseString = [[NSString alloc] initWithData:adminListData encoding:NSUTF8StringEncoding];
        NSDictionary *responseDict = [Tools JSonFromString:responseString];
        if ([[responseDict objectForKey:@"code"] intValue]== 1)
        {
            [adminIDArray removeAllObjects];
            
            if ([[responseDict objectForKey:@"data"] count] > 0)
            {
                NSArray *array = [[responseDict objectForKey:@"data"] allKeys];
                [adminIDArray addObjectsFromArray:array];
                [self getMemberListCache];
            }
            else
            {
                
            }

        }
        else
        {
            [Tools dealRequestError:responseDict fromViewController:self];
        }
    }
    else
    {
        [self getAdmins];
    }
}
-(void)getMemberListCache
{
    NSString *urlStr = [NSString stringWithFormat:@"%@=%@=%@",[Tools user_id],classID,GETUSERSBYCLASS];
    NSString *key = [urlStr MD5Hash];
    NSData *memberListData = [FTWCache objectForKey:key];
    if ([memberListData length] > 0)
    {
        NSString *responseString = [[NSString alloc] initWithData:memberListData encoding:NSUTF8StringEncoding];
        NSDictionary *responseDict = [Tools JSonFromString:responseString];
        
        [allMembersArray addObjectsFromArray:[[responseDict objectForKey:@"data"] allValues]];
        self.titleLabel.text = [NSString stringWithFormat:@"班级成员(%d)",[allMembersArray count]];
        
        NSDictionary *memberDict = [responseDict objectForKey:@"data"];
    
        for (int i=0; i<[adminIDArray count]; ++i)
        {
            DDLOG(@"admin =%@",[adminIDArray objectAtIndex:i]);
            if ([memberDict objectForKey:[adminIDArray objectAtIndex:i]])
            {
                [adminArray addObject:[memberDict objectForKey:[adminIDArray objectAtIndex:i]]];
            }
        }
        
        NSMutableArray *tmpMemArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (int i=0; i<[allMembersArray count]; ++i)
        {
            NSDictionary *dict = [allMembersArray objectAtIndex:i];
            if ([[dict objectForKey:@"checked"] integerValue] == 0)
            {
                [newAppleArray addObject:dict];
            }
            else if([[dict objectForKey:@"role"] isEqualToString:@"teachers"])
            {
                [teachersArray addObject:dict];
            }
            else if(([[dict objectForKey:@"role"] isEqualToString:@"students"]) && ([[dict objectForKey:@"title"] length]>0))
            {
                [classLeadersArray addObject:dict];
//                [studentArray addObject:dict];
            }
            else if([[dict objectForKey:@"role"] isEqualToString:@"students"])
            {
                [studentArray addObject:dict];
                [tmpMemArray addObject:dict];
            }
            else if([[dict objectForKey:@"role"] isEqualToString:@"parents"])
            {
                [parentsArray addObject:dict];
                [tmpMemArray addObject:dict];
            }
            else
            {
                [tmpMemArray addObject:dict];
            }
        }
        for (int i=0; i<[studentArray count]; ++i)
        {
            NSDictionary *dict = [studentArray objectAtIndex:i];
            if (![self haveParentsOfStudent:[dict objectForKey:@"_id"]])
            {
                [withoutParentStuArray addObject:dict];
            }
        }
        [membersArray addObjectsFromArray:[Tools getSpellSortArrayFromChineseArray:studentArray andKey:@"name"]];
        [memberTableView reloadData];
    }
    else
    {
//        [self getAdmins];
    }
}

-(void)getAdmins
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      } API:MB_ADMINLIST];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"adminslist responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
                NSString *urlStr = [NSString stringWithFormat:@"%@=%@=%@",[Tools user_id],classID,MB_ADMINLIST];
                NSString *key = [urlStr MD5Hash];
                [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
                
                [adminIDArray removeAllObjects];
                
                if ([[responseDict objectForKey:@"data"] count] > 0)
                {
                    NSArray *array = [[responseDict objectForKey:@"data"] allKeys];
                    [adminIDArray addObjectsFromArray:array];
                    [self getMembersByClass:@"all"];
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
            [Tools showAlertView:@"连接错误" delegateViewController:nil];
            _reloading = NO;
            [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:memberTableView];
        }];
        [request startAsynchronous];
    }
}
-(void)getMembersByClass:(NSString *)role
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      @"role":role
                                                                      } API:GETUSERSBYCLASS];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"memberByClass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [allMembersArray removeAllObjects];
                [teachersArray removeAllObjects];
                [newAppleArray removeAllObjects];
                [adminArray removeAllObjects];
                [membersArray removeAllObjects];
                [newAppleArray removeAllObjects];;
                [teachersArray removeAllObjects];
                [classLeadersArray removeAllObjects];
                [parentsArray removeAllObjects];
                [studentArray removeAllObjects];
                [withoutParentStuArray removeAllObjects];
                
                NSString *urlStr = [NSString stringWithFormat:@"%@=%@=%@",[Tools user_id],classID,GETUSERSBYCLASS];
                NSString *key = [urlStr MD5Hash];
                [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
                
                [allMembersArray addObjectsFromArray:[[responseDict objectForKey:@"data"] allValues]];
                
                DDLOG(@"almen==%@",[allMembersArray firstObject]);
                for(int i=0;i<[allMembersArray count];i++)
                {
                    NSDictionary *dict = [allMembersArray objectAtIndex:i];
                    NSString *userid = [dict objectForKey:@"_id"];
                    if ([[_db findSetWithDictionary:@{@"uid":userid} andTableName:@"userinfo"] count] > 0)
                    {
                        [_db updeteKey:@"ficon" toValue:[dict objectForKey:@"img_icon"] withParaDict:@{@"uid":userid} andTableName:@"userinfo"];
                        [_db updeteKey:@"fname" toValue:[dict objectForKey:@"name"] withParaDict:@{@"uid":userid} andTableName:@"userinfo"];
                        NSString *reid = @"";
                        if ([dict objectForKey:@"re_id"])
                        {
                            reid = [dict objectForKey:@"re_id"];
                        }
                        [_db updeteKey:@"re_id" toValue:reid withParaDict:@{@"uid":userid} andTableName:@"userinfo"];
                    }
                    else
                    {
                        NSString *reid = @"";
                        if ([dict objectForKey:@"re_id"])
                        {
                            reid = [dict objectForKey:@"re_id"];
                        }
                        [_db insertRecord:@{@"uid":[dict objectForKey:@"_id"],
                                            @"fname":[dict objectForKey:@"name"],
                                            @"ficon":[dict objectForKey:@"img_icon"],
                                            @"phone":@"",
                                            @"re_id":reid}
                             andTableName:@"userinfo"];
                    }
                }
                
                self.titleLabel.text = [NSString stringWithFormat:@"班级成员(%d)",[allMembersArray count]];
                NSDictionary *memberDict = [responseDict objectForKey:@"data"];
                for (int i=0; i<[adminIDArray count]; ++i)
                {
                    if ([memberDict objectForKey:[adminIDArray objectAtIndex:i]])
                    {
                        [adminArray addObject:[memberDict objectForKey:[adminIDArray objectAtIndex:i]]];
                    }
                }
                
                NSMutableArray *tmpMemArray = [[NSMutableArray alloc] initWithCapacity:0];
                
                for (int i=0; i<[allMembersArray count]; ++i)
                {
                    NSDictionary *dict = [allMembersArray objectAtIndex:i];
                    if ([[dict objectForKey:@"checked"] integerValue] == 0)
                    {
                        [newAppleArray addObject:dict];
                    }
                    else if([[dict objectForKey:@"role"] isEqualToString:@"teachers"])
                    {
                        [teachersArray addObject:dict];
                    }
                    else if(([[dict objectForKey:@"role"] isEqualToString:@"students"]) && ([[dict objectForKey:@"title"] length]>0))
                    {
                        [classLeadersArray addObject:dict];
//                        [studentArray addObject:dict];
                    }
                    else if([[dict objectForKey:@"role"] isEqualToString:@"students"])
                    {
                        [studentArray addObject:dict];
                        [tmpMemArray addObject:dict];
                    }
                    else if([[dict objectForKey:@"role"] isEqualToString:@"parents"])
                    {
                        [parentsArray addObject:dict];
                        [tmpMemArray addObject:dict];
                    }
                    else
                    {
                        [tmpMemArray addObject:dict];
                    }
                }
                for (int i=0; i<[studentArray count]; ++i)
                {
                    NSDictionary *dict = [studentArray objectAtIndex:i];
                    if (![self haveParentsOfStudent:[dict objectForKey:@"_id"]])
                    {
                        [withoutParentStuArray addObject:dict];
                    }
                }
                [membersArray addObjectsFromArray:[Tools getSpellSortArrayFromChineseArray:studentArray andKey:@"name"]];
                [memberTableView reloadData];
                _reloading = NO;
                [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:memberTableView];
                
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                [ud setObject:[NSString stringWithFormat:@"%d",[newAppleArray count]] forKey:UCMEMBER];
                [ud synchronize];
                
                [[XDTabViewController sharedTabViewController] viewDidLoad];
                [[XDTabViewController sharedTabViewController]selectItemAtIndex:2];
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
        [request startAsynchronous];
    }
    else
    {
        _reloading = NO;
        [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:memberTableView];
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

-(BOOL)haveParentsOfStudent:(NSString *)studentID
{
    for (int i=0; i<[parentsArray count]; ++i)
    {
        NSDictionary *dict = [parentsArray objectAtIndex:i];
        NSString *s_id = [dict objectForKey:@"re_id"];
        if ([s_id isEqualToString:studentID])
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark - tableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == MemTableViewTag)
    {
        return 2+[membersArray count];
    }
    else if(tableView.tag == SearchTableViewTag)
    {
        return 1;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == MemTableViewTag)
    {
        if (section ==0)
        {
            return 4;
        }
        else if(section == 1)
        {
            return [classLeadersArray count];
        }
        else
        {
            return [[[membersArray objectAtIndex:section-2] objectForKey:@"count"] integerValue];
        }
    }
    else if (tableView.tag == SearchTableViewTag)
    {
        CGFloat hei = [searchResultArray count]>8?240:[searchResultArray count]*40;
        [UIView animateWithDuration:0.2 animations:^{
            searchTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, hei);
        }];
        return [searchResultArray count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == MemTableViewTag)
    {
        if (indexPath.section == 0)
        {
            if (indexPath.row == 0)
            {
                if ([newAppleArray count] == 0)
                {
                    return 0;
                }
            }
        }
        return 60.0f;
    }
    else if(tableView.tag == SearchTableViewTag)
    {
        return 40;
    }
    return 0.0f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == MemTableViewTag)
    {
        if (section == 1)
        {
            if ([classLeadersArray count]==0)
            {
                return 0;
            }
            return 27;
        }
        else if(section == 0)
        {
            return 0;
        }
        return 27;
    }
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == MemTableViewTag)
    {
        if (section == 1)
        {
            UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-15, 27)];
            headerLabel.text = @"    班干部";
            headerLabel.backgroundColor = [UIColor lightGrayColor];
            headerLabel.font = [UIFont boldSystemFontOfSize:16];
//            headerLabel.textAlignment = NSTextAlignmentCenter;
            headerLabel.textColor = [UIColor whiteColor];
            return headerLabel;
        }
        else
        {
            UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-15, 27)];
            headerLabel.text = [NSString stringWithFormat:@"    %@",[[membersArray objectAtIndex:section-2] objectForKey:@"key"]];
//            headerLabel.textAlignment = NSTextAlignmentCenter;
            headerLabel.textColor = [UIColor whiteColor];
            headerLabel.backgroundColor = [UIColor lightGrayColor];
            return headerLabel;
        }
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == MemTableViewTag)
    {
        if (indexPath.section == 0)
        {
            static NSString *studentCell = @"newapply";
            MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:studentCell];
            if (cell == nil)
            {
                cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:studentCell];
            }
            cell.headerImageView.hidden = YES;
            cell.headerImageView.layer.cornerRadius = 5;
            cell.headerImageView.clipsToBounds = YES;
            cell.remarkLabel.hidden = NO;
            cell.memNameLabel.text = nil;
            cell.remarkLabel.text = nil;
            cell.memNameLabel.frame = CGRectMake(10, 15, 150, 30);
            if (indexPath.row == 0)
            {
                if ([newAppleArray count])
                {
                    UIImage *image = [Tools getImageFromImage:[UIImage imageNamed:@"bg_bor_green"] andInsets:UIEdgeInsetsMake(0.2, 0, 0.2, 0)];
                    
                    cell.markView.hidden = NO;
                    cell.markView.frame = CGRectMake(1.5, 0.5, image.size.width, 59);
                    [cell.markView setImage:image];
                    cell.memNameLabel.text = @"新的成员申请";
                    cell.remarkLabel.text = [NSString stringWithFormat:@"%d人",[newAppleArray count]];
                }
            }
            else if (indexPath.row == 1)
            {
                UIImage *image = [Tools getImageFromImage:[UIImage imageNamed:@"bg_bor_green"] andInsets:UIEdgeInsetsMake(0.2, 0, 0.2, 0)];
                cell.markView.hidden = NO;
                cell.markView.frame = CGRectMake(1.5, 0.5, image.size.width, 59);
                [cell.markView setImage:image];
                cell.memNameLabel.text = @"老师";
                cell.remarkLabel.text = [NSString stringWithFormat:@"%d人",[teachersArray count]];
            }
            else if(indexPath.row == 2)
            {
                UIImage *image = [Tools getImageFromImage:[UIImage imageNamed:@"bg_bor_orang"] andInsets:UIEdgeInsetsMake(0.2, 0, 0.2, 0)];
                cell.markView.hidden = NO;
                cell.markView.frame = CGRectMake(1.5, 0.5, image.size.width, 59);
                [cell.markView setImage:image];
                cell.memNameLabel.text = @"班级管理员";
                cell.remarkLabel.text = [NSString stringWithFormat:@"%d人",[adminArray count]];
            }
            else if(indexPath.row == 3)
            {
                UIImage *image = [Tools getImageFromImage:[UIImage imageNamed:@"bg_bor_red"] andInsets:UIEdgeInsetsMake(0.2, 0, 0.2, 0)];
                cell.markView.hidden = NO;
                cell.markView.frame = CGRectMake(1.5, 0.5, image.size.width, 59);
                [cell.markView setImage:image];
                cell.memNameLabel.text = @"应添加家长的学生";
                cell.remarkLabel.text = [NSString stringWithFormat:@"%d人",[withoutParentStuArray count]];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            return cell;
        }
        else if(indexPath.section == 1)
        {
            static NSString *studentCell = @"classLeaderCell";
            MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:studentCell];
            if (cell == nil)
            {
                cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:studentCell];
            }
            NSDictionary *dict = [classLeadersArray objectAtIndex:indexPath.row];
            cell.memNameLabel.text = [dict objectForKey:@"name"];
            [Tools fillImageView:cell.headerImageView withImageFromURL:[dict objectForKey:@"img_icon"] andDefault:HEADERDEFAULT];
            cell.headerImageView.layer.cornerRadius = 5;
            cell.headerImageView.clipsToBounds = YES;
            cell.remarkLabel.frame = CGRectMake(SCREEN_WIDTH - 130, 15, 100, 30);
            cell.remarkLabel.hidden = NO;
            cell.remarkLabel.font = [UIFont systemFontOfSize:16];
            cell.remarkLabel.text = [dict objectForKey:@"title"];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_angle"]];
            [cell.accessoryView setFrame:CGRectMake(SCREEN_WIDTH-20, 20, 10, 16)];
            return cell;
            
        }
        else
        {
            static NSString *studentCell = @"memberCell";
            MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:studentCell];
            if (cell == nil)
            {
                cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:studentCell];
            }
            DDLOG(@"%@+++%d==%d",membersArray,indexPath.section-2,indexPath.row);
            NSDictionary *dict = [[[membersArray objectAtIndex:indexPath.section-2] objectForKey:@"array"] objectAtIndex:indexPath.row];
            cell.headerImageView.layer.cornerRadius = 5;
            cell.headerImageView.clipsToBounds = YES;
            cell.button2.hidden = YES;
            cell.memNameLabel.text = [dict objectForKey:@"name"];
            cell.remarkLabel.hidden = NO;
            cell.remarkLabel.text = [dict objectForKey:@"title"];
            [Tools fillImageView:cell.headerImageView withImageFromURL:[dict objectForKey:@"img_icon"] andDefault:HEADERDEFAULT];
            cell.button2.hidden = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            return cell;
        }
    }
    else if(tableView.tag == SearchTableViewTag)
    {
        static NSString *searchCell = @"searchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCell];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCell];
        }
        NSDictionary *dict = [searchResultArray objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.text = [dict objectForKey:@"name"];
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == MemTableViewTag)
    {
        if (indexPath.section == 0)
        {
            
            if(indexPath.row == 0)
            {
                SubGroupViewController *subGroup = [[SubGroupViewController alloc] init];
                subGroup.tmpArray = newAppleArray;
                subGroup.classID = classID;
                subGroup.subGroupDel = self;
                subGroup.admin = NO;
                if (fromMsg)
                {
                    [subGroup showSelfViewController:self];
                }
                else
                {
                    [subGroup showSelfViewController:[XDTabViewController sharedTabViewController]];
                }
            }
            else if (indexPath.row == 1)
            {
                SubGroupViewController *subGroup = [[SubGroupViewController alloc] init];
                subGroup.tmpArray = teachersArray;
                subGroup.classID = classID;
                subGroup.admin = NO;
                subGroup.subGroupDel = self;
                if (fromMsg)
                {
                    [subGroup showSelfViewController:self];
                }
                else
                {
                    [subGroup showSelfViewController:[XDTabViewController sharedTabViewController]];
                }
            }
            else if(indexPath.row == 2)
            {
                SubGroupViewController *subGroup = [[SubGroupViewController alloc] init];
                subGroup.tmpArray = adminArray;
                subGroup.classID = classID;
                subGroup.admin = YES;
                subGroup.subGroupDel = self;
                if (fromMsg)
                {
                    [subGroup showSelfViewController:self];
                }
                else
                {
                    [subGroup showSelfViewController:[XDTabViewController sharedTabViewController]];
                }
            }
            else if(indexPath.row == 3)
            {
                SubGroupViewController *subGroup = [[SubGroupViewController alloc] init];
                subGroup.tmpArray = withoutParentStuArray;
                subGroup.classID = classID;
                subGroup.admin = NO;
                subGroup.subGroupDel = self;
                if (fromMsg)
                {
                    [subGroup showSelfViewController:self];
                }
                else
                {
                    [subGroup showSelfViewController:[XDTabViewController sharedTabViewController]];
                }
            }
        }
        else if(indexPath.section == 1)
        {
            NSDictionary *dict = [classLeadersArray objectAtIndex:indexPath.row];
            StudentDetailViewController *studentDetail = [[StudentDetailViewController alloc] init];
            studentDetail.classID = classID;
            studentDetail.admin = NO;
            studentDetail.memDel = self;
            studentDetail.studentID = [dict objectForKey:@"_id"];
            studentDetail.studentName = [dict objectForKey:@"name"];
            studentDetail.title = [dict objectForKey:@"title"];
            studentDetail.headerImg = [dict objectForKey:@"img_icon"];
            studentDetail.role = [dict objectForKey:@"role"];
            if (fromMsg)
            {
                [studentDetail showSelfViewController:self];
            }
            else
            {
                [studentDetail showSelfViewController:[XDTabViewController sharedTabViewController]];
            }
        }
        else
        {
            NSDictionary *dict = [[[membersArray objectAtIndex:indexPath.section-2] objectForKey:@"array"] objectAtIndex:indexPath.row];
            DDLOG(@"detail%@",dict);
            if ([[dict objectForKey:@"role"] isEqualToString:@"students"])
            {
                StudentDetailViewController *studentDetail = [[StudentDetailViewController alloc] init];
                studentDetail.classID = classID;
                studentDetail.studentID = [dict objectForKey:@"_id"];
                studentDetail.studentName = [dict objectForKey:@"name"];
                studentDetail.title = [dict objectForKey:@"title"];
                studentDetail.headerImg = [dict objectForKey:@"img_icon"];
                studentDetail.memDel = self;
                studentDetail.role = [dict objectForKey:@"role"];
                if (fromMsg)
                {
                    [studentDetail showSelfViewController:self];
                }
                else
                {
                    [studentDetail showSelfViewController:[XDTabViewController sharedTabViewController]];
                }
            }
            else if([[dict objectForKey:@"role"] isEqualToString:@"parents"])
            {
                ParentsDetailViewController *parentDetail = [[ParentsDetailViewController alloc] init];
                parentDetail.parentID = [dict objectForKey:@"_id"];
                parentDetail.parentName = [dict objectForKey:@"name"];
                parentDetail.title = [dict objectForKey:@"title"];
                parentDetail.headerImg = [dict objectForKey:@"img_icon"];
                parentDetail.admin = NO;
                parentDetail.memDel = self;
                parentDetail.classID = classID;
                parentDetail.role = [dict objectForKey:@"role"];
                if (fromMsg)
                {
                    [parentDetail showSelfViewController:self];
                }
                else
                {
                    [parentDetail showSelfViewController:[XDTabViewController sharedTabViewController]];
                }
            }
        }
    }
    else if(tableView.tag == SearchTableViewTag)
    {
        NSDictionary *dict = [searchResultArray objectAtIndex:indexPath.row];
        if ([[dict objectForKey:@"role"] isEqualToString:@"students"])
        {
            StudentDetailViewController *studentDetail = [[StudentDetailViewController alloc] init];
            studentDetail.classID = classID;
            studentDetail.studentID = [dict objectForKey:@"_id"];
            studentDetail.studentName = [dict objectForKey:@"name"];
            studentDetail.title = [dict objectForKey:@"title"];
            studentDetail.headerImg = [dict objectForKey:@"img_icon"];
            studentDetail.role = [dict objectForKey:@"role"];
            studentDetail.memDel = self;
            if (fromMsg)
            {
                [studentDetail showSelfViewController:self];
            }
            else
            {
                [studentDetail showSelfViewController:[XDTabViewController sharedTabViewController]];
            }
            [studentDetail showSelfViewController:[XDTabViewController sharedTabViewController]];
        }
        else if([[dict objectForKey:@"role"] isEqualToString:@"parents"])
        {
            ParentsDetailViewController *parentDetail = [[ParentsDetailViewController alloc] init];
            parentDetail.parentID = [dict objectForKey:@"_id"];
            parentDetail.parentName = [dict objectForKey:@"name"];
            parentDetail.title = [dict objectForKey:@"title"];
            parentDetail.headerImg = [dict objectForKey:@"img_icon"];
            parentDetail.admin = NO;
            parentDetail.memDel = self;
            parentDetail.classID = classID;
            parentDetail.role = [dict objectForKey:@"role"];
            if (fromMsg)
            {
                [parentDetail showSelfViewController:self];
            }
            else
            {
                [parentDetail showSelfViewController:[XDTabViewController sharedTabViewController]];
            }
        }
        else if([[dict objectForKey:@"role"] isEqualToString:@"teachers"])
        {
            MemberDetailViewController *memDetail = [[MemberDetailViewController alloc] init];
            memDetail.teacherID = [dict objectForKey:@"_id"];
            memDetail.teacherName = [dict objectForKey:@"name"];
            memDetail.memDel = self;
            memDetail.classID = classID;
            if (fromMsg)
            {
                [memDetail showSelfViewController:self];
            }
            else
            {
                [memDetail showSelfViewController:[XDTabViewController sharedTabViewController]];
            }
        }
        [self searchBarCancelButtonClicked:mySearchBar];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
@end
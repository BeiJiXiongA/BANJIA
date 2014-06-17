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
#import "InviteViewController.h"

@class AppDelegate;

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
StuDetailDelegate,
ChatDelegate,
MsgDelegate>
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
    NSMutableDictionary *adminIDDict;
    
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
    
    UITapGestureRecognizer *tapTgr;
    NSString *classID;
}
@end

@implementation ClassMemberViewController
@synthesize classID,fromMsg,schoolName,className;
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
    
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    updateGroup = @"";
    
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    
    _db = [[OperatDB alloc] init];
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).ChatDelegate = self;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = self;
    
    newAppleArray = [[NSMutableArray alloc] initWithCapacity:0];
    membersArray = [[NSMutableArray alloc] initWithCapacity:0];
    teachersArray = [[NSMutableArray alloc] initWithCapacity:0];
    classLeadersArray = [[NSMutableArray alloc] initWithCapacity:0];
    adminArray = [[NSMutableArray alloc] initWithCapacity:0];
    parentsArray = [[NSMutableArray alloc] initWithCapacity:0];
    studentArray = [[NSMutableArray alloc] initWithCapacity:0];
    withoutParentStuArray = [[NSMutableArray alloc] initWithCapacity:0];
    adminIDDict = [[NSMutableDictionary alloc] initWithCapacity:0];
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
    [inviteButton setBackgroundColor:[UIColor clearColor]];
    [inviteButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    inviteButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [inviteButton addTarget:self action:@selector(inviteClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:inviteButton];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"parents"] && [[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:ParentInviteMem] integerValue] == 0)
    {
        inviteButton.hidden = YES;
    }
    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"students"] && [[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:StudentInviteMem] integerValue] == 0)
    {
        inviteButton.hidden = YES;
    }
    
    mySearchBar = [[UISearchBar alloc] initWithFrame:
                   CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH-0, 40)];
    mySearchBar.delegate = self;
    mySearchBar.placeholder = @"输入成员姓名";
    mySearchBar.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:mySearchBar];
    
    memberTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT+40, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-UI_TAB_BAR_HEIGHT-40) style:UITableViewStylePlain];
    memberTableView.delegate = self;
    memberTableView.dataSource = self;
    memberTableView.backgroundColor = self.bgView.backgroundColor;
    memberTableView.tag = MemTableViewTag;
    memberTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:memberTableView];
    
    pullRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:memberTableView orientation:EGOPullOrientationDown];
    pullRefreshView.delegate = self;
    
    
    searchView = [[UIView alloc] initWithFrame:CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT+40, SCREEN_WIDTH-20, SCREEN_HEIGHT-40-UI_TAB_BAR_HEIGHT-43)];
    searchView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [self.bgView addSubview:searchView];
    [self.bgView sendSubviewToBack:searchView];
    
    tapTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSearch)];
    searchView.userInteractionEnabled = YES;
    [searchView addGestureRecognizer:tapTgr];
    
    UITextField* searchField = nil;
    for (UIView* subview in mySearchBar.subviews)
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            searchField = (UITextField*)subview;
            searchField.leftView=nil;
            [searchField setBackground:nil];
            [searchField setBackgroundColor:[UIColor whiteColor]];
            searchField.background = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
            break;
        }
    }
    
    for (UIView *subview in mySearchBar.subviews)
    {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            subview.backgroundColor = [UIColor clearColor];
            [subview removeFromSuperview];
            break;
        }
    }
    
    searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, 0) style:UITableViewStylePlain];
    searchTableView.delegate = self;
    searchTableView.dataSource = self;
    searchTableView.backgroundColor = [UIColor whiteColor];
    searchTableView.tag = SearchTableViewTag;
    [searchView addSubview:searchTableView];
    
    if (SYSVERSION >= 7.0)
    {
        searchTableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    }
    
    searchTableView.contentOffset = CGPointZero;

    if ([searchTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [searchTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([Tools NetworkReachable])
    {
//        NSArray *newApplyArray = [_db findSetWithDictionary:@{@"classid":classID,@"checked":@"0"} andTableName:CLASSMEMBERTABLE];
//        if ([newApplyArray count] > 0)
//        {
//            [self getAdminCache];
//            [self getAdmins];
//        }
//        else
        {
            [self getAdminCache];
            [self getAdmins];
        }
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

-(void)viewWillDisappear:(BOOL)animated
{
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - chatDel
-(void)dealNewChatMsg:(NSDictionary *)dict
{
    
}

#pragma mark - msgDel
-(void)dealNewMsg:(NSDictionary *)dict
{
    [self manageClassMember];
    [[XDTabViewController sharedTabViewController] viewWillAppear:NO];
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
        [[XDTabViewController sharedTabViewController] viewWillAppear:NO];
    }
}

#pragma mark - searchbardelegate

-(void)cancelSearch
{
    [searchResultArray removeAllObjects];
    mySearchBar.text = nil;
    //    [searchResultTableView reloadData];
    [UIView animateWithDuration:0.2 animations:^{
        [self.bgView sendSubviewToBack:searchView];
        memberTableView.hidden = NO;
        searchTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
        mySearchBar.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, 40);
        mySearchBar.showsCancelButton = NO;
        searchView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    }];
   
    [mySearchBar resignFirstResponder];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.2 animations:^{
        [searchView addGestureRecognizer:tapTgr];
        mySearchBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
        [self.bgView bringSubviewToFront:searchView];
        searchTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
        searchView.frame = CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT);
        memberTableView.hidden = YES;
        searchView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        searchBar.showsCancelButton = YES;
    }];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchWithText:searchText];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self cancelSearch];
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
    NSArray *classMemberArray = [_db findSetWithDictionary:@{@"classid":classID} andTableName:CLASSMEMBERTABLE];
    for (int i=0; i<[classMemberArray count]; ++i)
    {
        NSDictionary *dict = [classMemberArray objectAtIndex:i];
        NSString *name = [dict objectForKey:@"name"];
        if ([name rangeOfString:searchContent].length > 0)
        {
            [searchResultArray addObject:dict];
        }
    }
    [searchTableView reloadData];
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
    [pullRefreshView egoRefreshScrollViewDidScroll:memberTableView];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pullRefreshView egoRefreshScrollViewDidEndDragging:memberTableView];
}


-(void)backClick
{
    [[XDTabViewController sharedTabViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)inviteClick
{
    InviteViewController *inviteViewController = [[InviteViewController alloc] init];
    inviteViewController.fromClass = YES;
    [[XDTabViewController sharedTabViewController].navigationController pushViewController:inviteViewController animated:YES];
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
            [adminIDDict removeAllObjects];
            
            if ([[responseDict objectForKey:@"data"] count] > 0)
            {
                [adminIDDict setDictionary:[responseDict objectForKey:@"data"]];
                [self manageClassMember];
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
                
                [adminIDDict removeAllObjects];
                
                if ([[responseDict objectForKey:@"data"] count] > 0)
                {
                    [adminIDDict setDictionary:[responseDict objectForKey:@"data"]];
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

-(BOOL)haveThisStu:(NSString *)stuID
{
    for (int i=0; i<[parentsArray count]; ++i)
    {
        NSDictionary *parentDict = [parentsArray objectAtIndex:i];
        if (![stuID isEqual:[NSNull null]]) {
            if ([stuID isEqualToString:[parentDict objectForKey:@"re_id"]])
            {
                return YES;
            }

        }
    }
    return NO;
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
                
                NSString *urlStr = [NSString stringWithFormat:@"%@=%@=%@",[Tools user_id],classID,GETUSERSBYCLASS];
                NSString *key = [urlStr MD5Hash];
                [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
                
                [allMembersArray addObjectsFromArray:[[responseDict objectForKey:@"data"] allValues]];
                
                [_db deleteRecordWithDict:@{@"classid":classID} andTableName:CLASSMEMBERTABLE];
                
                for(int i = 0;i < [allMembersArray count];i++)
                {
                    
                    //classid VARCHAR(30),name VARCHAR(20),uid VARCHAR(30),img_icon VARCHAR(30),re_id VARCHAR(30),re_name VARCHAR(30),checked VARCHAR(5),phone VARCHAR(15)
                    NSMutableDictionary *memDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                    NSDictionary *dict = [allMembersArray objectAtIndex:i];
                    [memDict setObject:[dict objectForKey:@"_id"] forKey:@"uid"];
                    [memDict setObject:[dict objectForKey:@"name"] forKey:@"name"];
                    [memDict setObject:classID forKey:@"classid"];
                    [memDict setObject:[NSString stringWithFormat:@"%d",[[dict objectForKey:@"checked"] integerValue]] forKey:@"checked"];
                    
                    if ([[adminIDDict objectForKey:[dict objectForKey:@"_id"]] intValue] > 0)
                    {
                        [memDict setObject:[NSString stringWithFormat:@"%d",[[adminIDDict objectForKey:[dict objectForKey:@"_id"]] integerValue]] forKey:@"admin"];
                    }
                    else
                    {
                        [memDict setObject:@"0" forKey:@"admin"];
                    }
                    
                    if ([dict objectForKey:@"re_id"])
                    {
                        [memDict setObject:[dict objectForKey:@"re_id"] forKey:@"re_id"];
                    }
                    else
                    {
                        [memDict setObject:@"" forKey:@"re_id"];
                    }
                    if ([dict objectForKey:@"re_name"])
                    {
                        [memDict setObject:[dict objectForKey:@"re_name"] forKey:@"re_name"];
                    }
                    else
                    {
                        [memDict setObject:@"" forKey:@"re_name"];
                    }
                    if ([dict objectForKey:@"re_type"])
                    {
                        [memDict setObject:[dict objectForKey:@"re_type"] forKey:@"re_type"];
                    }
                    if ([dict objectForKey:@"img_icon"])
                    {
                        [memDict setObject:[dict objectForKey:@"img_icon"] forKey:@"img_icon"];
                    }
                    if ([dict objectForKey:@"phone"])
                    {
                        [memDict setObject:[dict objectForKey:@"phone"] forKey:@"phone"];
                    }
                    if ([dict objectForKey:@"title"])
                    {
                        [memDict setObject:[dict objectForKey:@"title"] forKey:@"title"];
                    }
                    if ([dict objectForKey:@"role"])
                    {
                        [memDict setObject:[dict objectForKey:@"role"] forKey:@"role"];
                    }
                    else
                    {
                        [memDict setObject:@"" forKey:@"role"];
                    }
                    
                    if ([dict objectForKey:@"re_name"])
                    {
                        if ([[_db findSetWithDictionary:@{@"classid":classID,@"role":@"students",@"name":[dict objectForKey:@"re_name"]} andTableName:CLASSMEMBERTABLE] count] == 0)
                        {
                            NSDictionary *tmpDict = @{@"name":[dict objectForKey:@"re_name"],@"classid":classID,@"role":@"students",@"checked":@"1"};
                            if ([_db insertRecord:tmpDict andTableName:CLASSMEMBERTABLE])
                            {
                                DDLOG(@"insert stu of parent without stu success!");
                            }
                        }
                        [memDict setObject:[dict objectForKey:@"re_name"] forKey:@"re_name"];
                    }
                    if ([[_db findSetWithDictionary:@{@"classid":classID,@"name":[memDict objectForKey:@"name"],@"role":@"students"} andTableName:CLASSMEMBERTABLE] count] > 0)
                    {
                        if ([[memDict objectForKey:@"uid"] length] > 0)
                        {
                            [_db deleteRecordWithDict:@{@"classid":classID,@"name":[memDict objectForKey:@"name"],@"role":@"students"} andTableName:CLASSMEMBERTABLE];
                            if ([_db insertRecord:memDict andTableName:CLASSMEMBERTABLE])
                            {
                                DDLOG(@"insert mem success!");
                            }
                        }
                    }
                    else
                    {
                        if ([_db insertRecord:memDict andTableName:CLASSMEMBERTABLE])
                        {
                            DDLOG(@"insert mem success!");
                        }
                    }
                }
                [self manageClassMember];
                _reloading = NO;
                [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:memberTableView];
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

-(void)manageClassMember
{
    [allMembersArray removeAllObjects];
    [teachersArray removeAllObjects];
    [newAppleArray removeAllObjects];
    [adminArray removeAllObjects];
    [membersArray removeAllObjects];
    [newAppleArray removeAllObjects];
    [classLeadersArray removeAllObjects];
    [parentsArray removeAllObjects];
    [studentArray removeAllObjects];
    [withoutParentStuArray removeAllObjects];
    
    [allMembersArray addObjectsFromArray:[_db findSetWithDictionary:@{@"classid":classID,@"checked":@"1"} andTableName:CLASSMEMBERTABLE]];
    
    [teachersArray addObjectsFromArray:[_db findSetWithDictionary:@{@"classid":classID,@"role":@"teachers"} andTableName:CLASSMEMBERTABLE]];
    
    [newAppleArray addObjectsFromArray:[_db findSetWithDictionary:@{@"classid":classID,@"checked":@"0"} andTableName:CLASSMEMBERTABLE]];
    
    [adminArray addObjectsFromArray:[_db findSetWithDictionary:@{@"classid":classID,@"admin":@"1"} andTableName:CLASSMEMBERTABLE]];
    [adminArray addObjectsFromArray:[_db findSetWithDictionary:@{@"classid":classID,@"admin":@"2"} andTableName:CLASSMEMBERTABLE]];
    
    [parentsArray addObjectsFromArray:[_db findSetWithDictionary:@{@"classid":classID,@"role":@"parents"} andTableName:CLASSMEMBERTABLE]];
    studentArray = [_db findSetWithDictionary:@{@"classid":classID,@"role":@"students"} andTableName:CLASSMEMBERTABLE];
    
    for (int i=0; i<[studentArray count]; ++i)
    {
        NSDictionary *stuDict = [studentArray objectAtIndex:i];
        DDLOG(@"sudict=%@",stuDict);
        NSArray *parentarray = [_db findSetWithDictionary:@{@"classid":classID,@"role":@"parents",@"re_name":[stuDict objectForKey:@"name"]} andTableName:CLASSMEMBERTABLE];
        if([parentarray count] == 0)
        {
            [withoutParentStuArray addObject:[studentArray objectAtIndex:i]];
        }
        if (![[stuDict objectForKey:@"title"] isEqual:[NSNull null]])
        {
            if ([[stuDict objectForKey:@"title"] length] > 0)
            {
                [classLeadersArray addObject:stuDict];
            }
        }
    }
    
    for (int i=0; i<[newAppleArray count]; ++i)
    {
        if ([studentArray containsObject:[newAppleArray objectAtIndex:i]])
        {
            [studentArray removeObject:[newAppleArray objectAtIndex:i]];
        }
    }

    self.titleLabel.text = [NSString stringWithFormat:@"班级成员(%d)",[teachersArray count]+[studentArray count]];
    
    [membersArray addObjectsFromArray:[Tools getSpellSortArrayFromChineseArray:studentArray andKey:@"name"]];
    [memberTableView reloadData];
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
        CGFloat hei = [searchResultArray count]>6?264:([searchResultArray count]*44);
        
        [UIView animateWithDuration:0.2 animations:^{
            searchTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, hei);
//            if (SYSVERSION >= 7.0)
//            {
//                searchTableView.contentSize = CGSizeMake(SCREEN_WIDTH, hei);
//            }
        }];
        if ([searchResultArray count] > 0)
        {
            [searchView removeGestureRecognizer:tapTgr];
        }
        else
        {
            [searchView addGestureRecognizer:tapTgr];
        }
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
        return 44;
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
            headerLabel.backgroundColor = RGB(234, 234, 234, 1);
            headerLabel.font = [UIFont boldSystemFontOfSize:16];
            headerLabel.textColor = TITLE_COLOR;
            return headerLabel;
        }
        else
        {
            UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-15, 27)];
            headerLabel.text = [NSString stringWithFormat:@"    %@",[[membersArray objectAtIndex:section-2] objectForKey:@"key"]];
            headerLabel.textColor = TITLE_COLOR;
            headerLabel.backgroundColor = RGB(234, 234, 234, 1);
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
            cell.headerImageView.layer.cornerRadius = 3;
            cell.headerImageView.clipsToBounds = YES;
            cell.remarkLabel.hidden = NO;
            cell.memNameLabel.text = nil;
            cell.remarkLabel.text = nil;
            cell.memNameLabel.frame = CGRectMake(60, 15, 150, 30);
            
            cell.markView.frame = CGRectMake(10, 10, 40, 40);
            cell.markView.layer.cornerRadius = 3;
            cell.markView.clipsToBounds = YES;
            
            if (indexPath.row == 0)
            {
                if ([newAppleArray count] > 0)
                {
                    UIImage *image = [Tools getImageFromImage:[UIImage imageNamed:@"bg_bor_green"] andInsets:UIEdgeInsetsMake(0.2, 0, 0.2, 0)];
                    
                    cell.markView.hidden = NO;
                    cell.markView.frame = CGRectMake(1.5, 0.5, image.size.width, 59);
                    [cell.markView setImage:image];
                    cell.memNameLabel.text = @"新的成员申请";
                    cell.remarkLabel.textColor = [UIColor redColor];
                    cell.remarkLabel.text = [NSString stringWithFormat:@"%d人",[newAppleArray count]];
                }
            }
            else if (indexPath.row == 1)
            {
                UIImage *image = [Tools getImageFromImage:[UIImage imageNamed:@"bg_bor_green"] andInsets:UIEdgeInsetsMake(0.2, 0, 0.2, 0)];
                cell.markView.hidden = NO;
                [cell.markView setImage:image];
                cell.memNameLabel.text = @"老师";
                cell.remarkLabel.text = [NSString stringWithFormat:@"%d人",[teachersArray count]];
            }
            else if(indexPath.row == 2)
            {
                UIImage *image = [Tools getImageFromImage:[UIImage imageNamed:@"bg_bor_orang"] andInsets:UIEdgeInsetsMake(0.2, 0, 0.2, 0)];
                cell.markView.hidden = NO;
                [cell.markView setImage:image];
                cell.memNameLabel.text = @"班级管理员";
                cell.remarkLabel.text = [NSString stringWithFormat:@"%d人",[adminArray count]];
            }
            else if(indexPath.row == 3)
            {
                UIImage *image = [Tools getImageFromImage:[UIImage imageNamed:@"bg_bor_red"] andInsets:UIEdgeInsetsMake(0.2, 0, 0.2, 0)];
                cell.markView.hidden = NO;
                [cell.markView setImage:image];
                cell.memNameLabel.text = @"应添加家长的学生";
                cell.remarkLabel.text = [NSString stringWithFormat:@"%d人",[withoutParentStuArray count]];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            UIImageView *bgImageBG = [[UIImageView alloc] init];
            bgImageBG.image = [UIImage imageNamed:@"line3"];
            bgImageBG.backgroundColor = [UIColor clearColor];
            cell.backgroundView = bgImageBG;
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
            cell.memNameLabel.frame = CGRectMake(60, 15, 150, 30);
            cell.memNameLabel.text = [dict objectForKey:@"name"];
            [Tools fillImageView:cell.headerImageView withImageFromURL:[dict objectForKey:@"img_icon"] andDefault:HEADERBG];
            cell.headerImageView.layer.cornerRadius = 3;
            cell.headerImageView.clipsToBounds = YES;
            cell.remarkLabel.frame = CGRectMake(SCREEN_WIDTH - 130, 15, 100, 30);
            cell.remarkLabel.hidden = NO;
            cell.remarkLabel.font = [UIFont systemFontOfSize:16];
            if (![[dict objectForKey:@"title"] isEqual:[NSNull null]])
            {
                cell.remarkLabel.text = [dict objectForKey:@"title"];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_angle"]];
            [cell.accessoryView setFrame:CGRectMake(SCREEN_WIDTH-20, 20, 10, 16)];
            UIImageView *bgImageBG = [[UIImageView alloc] init];
            bgImageBG.image = [UIImage imageNamed:@"line3"];
            bgImageBG.backgroundColor = [UIColor clearColor];
            cell.backgroundView = bgImageBG;
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
            NSDictionary *dict = [[[membersArray objectAtIndex:indexPath.section-2] objectForKey:@"array"] objectAtIndex:indexPath.row];
            cell.memNameLabel.frame = CGRectMake(60, 15, 150, 30);
            cell.headerImageView.layer.cornerRadius = 3;
            cell.headerImageView.clipsToBounds = YES;
            cell.button2.hidden = YES;
            cell.memNameLabel.text = [dict objectForKey:@"name"];
            cell.remarkLabel.hidden = NO;
            if (![[dict objectForKey:@"title"] isEqual:[NSNull null]])
            {
                cell.remarkLabel.text = [dict objectForKey:@"title"];
            }
            [Tools fillImageView:cell.headerImageView withImageFromURL:[dict objectForKey:@"img_icon"] andDefault:HEADERBG];
            cell.button2.hidden = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            UIImageView *bgImageBG = [[UIImageView alloc] init];
            bgImageBG.image = [UIImage imageNamed:@"line3"];
            bgImageBG.backgroundColor = [UIColor clearColor];
            cell.backgroundView = bgImageBG;

            return cell;
        }
    }
    else if(tableView.tag == SearchTableViewTag)
    {
        static NSString *searchCell = @"searchmemCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCell];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCell];
        }
        NSDictionary *dict = [searchResultArray objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.text = [dict objectForKey:@"name"];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLOG(@"tableview tag= %d",tableView.tag);
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
                subGroup.titleString = @"新申请";
                [[XDTabViewController sharedTabViewController].navigationController pushViewController:subGroup animated:YES];
            }
            else if (indexPath.row == 1)
            {
                SubGroupViewController *subGroup = [[SubGroupViewController alloc] init];
                subGroup.tmpArray = teachersArray;
                subGroup.classID = classID;
                subGroup.admin = NO;
                subGroup.subGroupDel = self;
                subGroup.titleString = @"老师";
                [[XDTabViewController sharedTabViewController].navigationController pushViewController:subGroup animated:YES];
            }
            else if(indexPath.row == 2)
            {
                SubGroupViewController *subGroup = [[SubGroupViewController alloc] init];
                subGroup.tmpArray = adminArray;
                subGroup.classID = classID;
                subGroup.admin = YES;
                subGroup.subGroupDel = self;
                subGroup.titleString = @"管理员";
                [[XDTabViewController sharedTabViewController].navigationController pushViewController:subGroup animated:YES];
            }
            else if(indexPath.row == 3)
            {
                SubGroupViewController *subGroup = [[SubGroupViewController alloc] init];
                subGroup.tmpArray = withoutParentStuArray;
                subGroup.classID = classID;
                subGroup.admin = NO;
                subGroup.subGroupDel = self;
                subGroup.titleString = @"应添加家长学生";
                [[XDTabViewController sharedTabViewController].navigationController pushViewController:subGroup animated:YES];
            }
        }
        else if(indexPath.section == 1)
        {
            NSDictionary *dict = [classLeadersArray objectAtIndex:indexPath.row];
            StudentDetailViewController *studentDetail = [[StudentDetailViewController alloc] init];
            studentDetail.admin = NO;
            studentDetail.memDel = self;
            studentDetail.studentID = [dict objectForKey:@"uid"];
            studentDetail.studentName = [dict objectForKey:@"name"];
            studentDetail.title = [dict objectForKey:@"title"];
            studentDetail.headerImg = [dict objectForKey:@"img_icon"];
            studentDetail.role = [dict objectForKey:@"role"];
            [[XDTabViewController sharedTabViewController].navigationController pushViewController:studentDetail animated:YES];
        }
        else
        {
            NSDictionary *dict = [[[membersArray objectAtIndex:indexPath.section-2] objectForKey:@"array"] objectAtIndex:indexPath.row];
            StudentDetailViewController *studentDetail = [[StudentDetailViewController alloc] init];
            if (![[dict objectForKey:@"uid"] isEqual:[NSNull null]])
            {
                studentDetail.studentID = [dict objectForKey:@"uid"];
            }
            if (![[dict objectForKey:@"title"] isEqual:[NSNull null]])
            {
                studentDetail.title = [dict objectForKey:@"title"];
            }
            studentDetail.studentName = [dict objectForKey:@"name"];
            if (![[dict objectForKey:@"title"] isEqual:[NSNull null]])
            {
                studentDetail.title = [dict objectForKey:@"title"];
            }
            
            studentDetail.headerImg = [dict objectForKey:@"img_icon"];
            studentDetail.memDel = self;
            studentDetail.role = [dict objectForKey:@"role"];
            [[XDTabViewController sharedTabViewController].navigationController pushViewController:studentDetail animated:YES];
        }
    }
    else if(tableView.tag == SearchTableViewTag)
    {
        NSDictionary *dict = [searchResultArray objectAtIndex:indexPath.row];
        if ([[dict objectForKey:@"role"] isEqualToString:@"students"])
        {
            StudentDetailViewController *studentDetail = [[StudentDetailViewController alloc] init];
            if (![[dict objectForKey:@"uid"] isEqual:[NSNull null]])
            {
                studentDetail.studentID = [dict objectForKey:@"uid"];
            }
            if (![[dict objectForKey:@"title"] isEqual:[NSNull null]])
            {
                studentDetail.title = [dict objectForKey:@"title"];
            }
            studentDetail.studentName = [dict objectForKey:@"name"];
            if (![[dict objectForKey:@"title"] isEqual:[NSNull null]])
            {
                studentDetail.title = [dict objectForKey:@"title"];
            }
            
            studentDetail.headerImg = [dict objectForKey:@"img_icon"];
            studentDetail.memDel = self;
            studentDetail.role = [dict objectForKey:@"role"];
            [[XDTabViewController sharedTabViewController].navigationController pushViewController:studentDetail animated:YES];

        }
        else if([[dict objectForKey:@"role"] isEqualToString:@"parents"])
        {
            ParentsDetailViewController *parentDetail = [[ParentsDetailViewController alloc] init];
            parentDetail.parentID = [dict objectForKey:@"uid"];
            parentDetail.parentName = [dict objectForKey:@"name"];
            parentDetail.title = [dict objectForKey:@"title"];
            parentDetail.headerImg = [dict objectForKey:@"img_icon"];
            parentDetail.admin = NO;
            parentDetail.memDel = self;
            parentDetail.role = [dict objectForKey:@"role"];
            [[XDTabViewController sharedTabViewController].navigationController pushViewController:parentDetail animated:YES];
        }
        else if([[dict objectForKey:@"role"] isEqualToString:@"teachers"])
        {
            MemberDetailViewController *memDetail = [[MemberDetailViewController alloc] init];
            memDetail.teacherID = [dict objectForKey:@"uid"];
            memDetail.teacherName = [dict objectForKey:@"name"];
            memDetail.memDel = self;
            [[XDTabViewController sharedTabViewController].navigationController pushViewController:memDetail animated:YES];
        }
        [self cancelSearch];
        [self searchBarCancelButtonClicked:mySearchBar];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
@end
//
//  SelectChatMemberViewController.m
//  BANJIA
//
//  Created by TeekerZW on 7/22/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "SelectChatMemberViewController.h"
#import "MemberCell.h"
#import "SSCheckBoxView.h"
#import "SubmitGroupChatViewController.h"
#import "ChineseToPinyin.h"

#define MemTableViewTag  4000
#define SearchTableViewTag 5000
#define SectionTag  33333333
#define RowTag    7777
#define CheckBoxTag  5555

#define ALLSTUDENTS  1111
#define ALLPARENTS   2222
#define ALLTEACHERS  3333

@interface SelectChatMemberViewController ()<
UITableViewDataSource,
UITableViewDelegate,
UISearchBarDelegate>

{
    NSString *role;
    NSString *classID;
    
    NSMutableArray *memberArray;
    NSMutableArray *selectedArray;
    
    UISearchBar *mySearchBar;
    NSMutableArray *searchResultArray;
    UITableView *searchTableView;
    UIView *searchView;
    UITapGestureRecognizer *tapTgr;
    
    OperatDB *db;
    
    UITableView *memberTableView;
    
    UIView *buttomView;
    UIScrollView *chatMemberScrollView;
    UIButton *submitButton;
    
    CGFloat tableViewY;
    CGFloat chedkViewH;
    CGFloat buttomH;
    CGFloat keyBoardHeight;
    
    UIView *checkView;
    
    BOOL haveStudent;
    BOOL haveParent;
    BOOL haveTeacher;
}

@end

@implementation SelectChatMemberViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = @"创建群聊";
    
    db = [[OperatDB alloc] init];
    
    memberArray = [[NSMutableArray alloc] initWithCapacity:0];
    selectedArray = [[NSMutableArray alloc] initWithCapacity:0];
    searchResultArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    role = [[NSUserDefaults standardUserDefaults] objectForKey:@"role"];
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    
    haveStudent = NO;
    haveParent = NO;
    haveTeacher = NO;
    
    tableViewY = UI_NAVIGATION_BAR_HEIGHT+45;
    chedkViewH = 0;
    buttomH = 50;
    
    if ([role isEqualToString:@"teachers"])
    {
        tableViewY = UI_NAVIGATION_BAR_HEIGHT + 50;
        chedkViewH = 50;
        
        checkView = [[UIView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, 50)];
        checkView.backgroundColor = [UIColor whiteColor];
        [self.bgView addSubview:checkView];
    }
    
    
    if ([[db findSetWithDictionary:@{@"classid":classID} andTableName:CLASSMEMBERTABLE] count] > 0)
    {
        [self dealClassMembers];
    }
    else
    {
        [self getMembersByClass];
    }

    
    mySearchBar = [[UISearchBar alloc] initWithFrame:
                   CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT + chedkViewH, SCREEN_WIDTH-0, 40)];
    mySearchBar.delegate = self;
    mySearchBar.placeholder = @"输入成员姓名";
    mySearchBar.contentMode = UIControlContentHorizontalAlignmentLeft;
    mySearchBar.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:mySearchBar];

    
    searchView = [[UIView alloc] initWithFrame:CGRectMake(10, tableViewY-50, SCREEN_WIDTH-20, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-50)];
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
    
    searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, mySearchBar.frame.size.height+mySearchBar.frame.origin.y, SCREEN_WIDTH, 0) style:UITableViewStylePlain];
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
    
    memberTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, mySearchBar.frame.size.height+mySearchBar.frame.origin.y, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-chedkViewH-mySearchBar.frame.size.height) style:UITableViewStylePlain];
    memberTableView.delegate = self;
    memberTableView.dataSource = self;
    memberTableView.tag = MemTableViewTag;
    memberTableView.backgroundColor = self.bgView.backgroundColor;
    memberTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:memberTableView];
    
    buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-0, SCREEN_WIDTH, 0)];
    buttomView.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:buttomView];
    
    chatMemberScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 5, SCREEN_WIDTH-80, 50)];
    chatMemberScrollView.backgroundColor = [UIColor whiteColor];
    [buttomView addSubview:chatMemberScrollView];
    
    submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitButton setBackgroundImage:[ImageTools createImageWithColor:RGB(57, 188, 173, 1)] forState:UIControlStateNormal];
    submitButton.layer.cornerRadius = 5;
    submitButton.clipsToBounds = YES;
    submitButton.frame = CGRectMake(SCREEN_WIDTH-65, 13, 60, 34);
    submitButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [submitButton addTarget:self action:@selector(submitChat) forControlEvents:UIControlEventTouchUpInside];
    [buttomView addSubview:submitButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealClassMembers
{
    NSMutableArray *allArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    if ([role isEqualToString:@"teachers"])
    {
        NSArray *tmpArray = [db findSetWithDictionary:@{@"classid":classID} andTableName:CLASSMEMBERTABLE];
        for (int i=0; i < [tmpArray count]; i++)
        {
            NSDictionary *dict  =[tmpArray objectAtIndex:i];
            if(![[dict objectForKey:@"role"] isEqual:[NSNull null]] && ![[dict objectForKey:@"role"] isEqualToString:@"unin_students"] && ![[dict objectForKey:@"uid"] isEqualToString:[Tools user_id]])
            {
                if ([[dict objectForKey:@"role"] isEqualToString:@"students"])
                {
                    haveStudent = YES;
                }
                if ([[dict objectForKey:@"role"] isEqualToString:@"teachers"])
                {
                    haveTeacher = YES;
                }
                if ([[dict objectForKey:@"role"] isEqualToString:@"parents"])
                {
                    haveParent = YES;
                }
                [allArray addObject:dict];
            }
        }
    }
    else
    {
        NSArray *tmpArray = [db findSetWithDictionary:@{@"classid":classID,@"role":@"students"} andTableName:CLASSMEMBERTABLE];
        for (int i=0; i < [tmpArray count]; i++)
        {
            NSDictionary *dict  =[tmpArray objectAtIndex:i];
            if(![[dict objectForKey:@"role"] isEqualToString:@"unin_students"] &&
               ![[dict objectForKey:@"uid"] isEqual:[NSNull null]] &&
               ![[dict objectForKey:@"uid"] isEqualToString:[Tools user_id]])
            {
                haveStudent = YES;
                [allArray addObject:dict];
            }
        }
        tmpArray = [db findSetWithDictionary:@{@"classid":classID,@"role":@"parents"} andTableName:CLASSMEMBERTABLE];
        for (int i=0; i < [tmpArray count]; i++)
        {
            NSDictionary *dict  =[tmpArray objectAtIndex:i];
            if(![[dict objectForKey:@"role"] isEqualToString:@"unin_students"] && ![[dict objectForKey:@"uid"] isEqualToString:[Tools user_id]])
            {
                haveParent = YES;
                [allArray addObject:dict];
            }
        }
    }
    
    NSMutableArray *nameArray = [[NSMutableArray alloc] initWithCapacity:0];
    if (haveTeacher)
    {
        [nameArray addObject:@"全体老师"];
    }
    if (haveParent)
    {
        [nameArray addObject:@"全体家长"];
    }
    if (haveStudent)
    {
        [nameArray addObject:@"全体学生"];
    }
    SSCheckBoxView *checkBox = nil;
    for (int i=0; i<[nameArray count]; i++)
    {
        SSCheckBoxViewStyle style = kSSCheckBoxViewStyleBox;
        checkBox = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3*i, 5, SCREEN_WIDTH/3, 40)style:style checked:NO];
        [checkBox setText:[nameArray objectAtIndex:i]];
        [checkView addSubview:checkBox];
        [checkBox setStateChangedTarget:self selector:@selector(checkBoxStateChange)];
        if ([[nameArray objectAtIndex:i] isEqualToString:@"全体老师"])
        {
            checkBox.tag = ALLTEACHERS;
        }
        else if([[nameArray objectAtIndex:i] isEqualToString:@"全体家长"])
        {
            checkBox.tag = ALLPARENTS;
        }
        else if([[nameArray objectAtIndex:i] isEqualToString:@"全体学生"])
        {
            checkBox.tag = ALLSTUDENTS;
        }
    }
    
    [memberArray addObjectsFromArray:[Tools getSpellSortArrayFromChineseArray:allArray andKey:@"name"]];
    [memberTableView reloadData];
}

-(void)submitChat
{
    if ([selectedArray count] < 2)
    {
        [Tools showAlertView:@"群聊至少需要选择两个成员！" delegateViewController:nil];
        return ;
    }
    SubmitGroupChatViewController *submitVC = [[SubmitGroupChatViewController alloc] init];
    submitVC.selectArray = selectedArray;
    [self.navigationController pushViewController:submitVC animated:YES];
}

-(BOOL)containAllStudent
{
    NSMutableArray *studentArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *tmpArray = [db findSetWithDictionary:@{@"classid":classID,@"role":@"students"} andTableName:CLASSMEMBERTABLE];
    for (int i=0; i < [tmpArray count]; i++)
    {
        NSDictionary *dict  =[tmpArray objectAtIndex:i];
        if([[dict objectForKey:@"role"] isEqualToString:@"students"] &&
            ![[dict objectForKey:@"uid"] isEqualToString:[Tools user_id]])
        {
            [studentArray addObject:dict];
        }
    }
    if ([studentArray count] == 0)
    {
        return NO;
    }
    for (NSDictionary *dict in studentArray)
    {
        if (![selectedArray containsObject:dict])
        {
            return NO;
        }
    }
    return YES;
}
-(BOOL)containAllTeacher
{
    NSMutableArray *teachersArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *tmpArray = [db findSetWithDictionary:@{@"classid":classID,@"role":@"teachers"} andTableName:CLASSMEMBERTABLE];
    for (int i=0; i < [tmpArray count]; i++)
    {
        NSDictionary *dict  =[tmpArray objectAtIndex:i];
        if([[dict objectForKey:@"role"] isEqualToString:@"teachers"] && ![[dict objectForKey:@"uid"] isEqualToString:[Tools user_id]])
        {
            [teachersArray addObject:dict];
        }
    }
    if ([teachersArray count] == 0)
    {
        return NO;
    }
    for (NSDictionary *dict in teachersArray)
    {
        if (![selectedArray containsObject:dict])
        {
            return NO;
        }
    }
    return YES;
}
-(BOOL)containAllParents
{
    NSMutableArray *parentsArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *tmpArray = [db findSetWithDictionary:@{@"classid":classID,@"role":@"parents"} andTableName:CLASSMEMBERTABLE];
    for (int i=0; i < [tmpArray count]; i++)
    {
        NSDictionary *dict  =[tmpArray objectAtIndex:i];
        if([[dict objectForKey:@"role"] isEqualToString:@"parents"] && ![[dict objectForKey:@"uid"] isEqualToString:[Tools user_id]])
        {
            [parentsArray addObject:dict];
        }
    }
    if ([parentsArray count] == 0)
    {
        return  NO;
    }
    for (NSDictionary *dict in parentsArray)
    {
        if (![selectedArray containsObject:dict])
        {
            return NO;
        }
    }
    return YES;
}

#pragma mark - getclassmeme
-(void)getMembersByClass
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      @"role":@"all"
                                                                      } API:GETUSERSBYCLASS];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"memberByClass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSArray *allMembersArray = [[responseDict objectForKey:@"data"] allValues];
                
                [db deleteRecordWithDict:@{@"classid":classID} andTableName:CLASSMEMBERTABLE];
                
                for(int i = 0;i < [allMembersArray count];i++)
                {
                    
                    //classid VARCHAR(30),name VARCHAR(20),uid VARCHAR(30),img_icon VARCHAR(30),re_id VARCHAR(30),re_name VARCHAR(30),checked VARCHAR(5),phone VARCHAR(15)
                    NSMutableDictionary *memDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                    NSDictionary *dict = [allMembersArray objectAtIndex:i];
                    if ([[dict objectForKey:@"role"] isEqualToString:@"unin_students"])
                    {
                        continue ;
                    }
                    
                    [memDict setObject:[dict objectForKey:@"_id"] forKey:@"uid"];
                    NSString *name = [dict objectForKey:@"name"];
                    [memDict setObject:name forKey:@"name"];
                    if (![[dict objectForKey:@"title"] isEqual:[NSNull null]])
                    {
                        [memDict setObject:[dict objectForKey:@"title"] forKey:@"title"];
                    }
                    
                    [memDict setObject:[ChineseToPinyin jianPinFromChiniseString:name] forKey:@"jianpin"];
                    [memDict setObject:[ChineseToPinyin pinyinFromChiniseString:name] forKey:@"quanpin"];
                    
                    if ([[db findSetWithDictionary:@{@"uid":[dict objectForKey:@"_id"],@"uicon":[dict objectForKey:@"img_icon"],@"username":[dict objectForKey:@"name"]} andTableName:USERICONTABLE] count] == 0)
                    {
                        [db insertRecord:@{@"uid":[dict objectForKey:@"_id"],
                                            @"uicon":[dict objectForKey:@"img_icon"],
                                            @"username":[dict objectForKey:@"name"]}
                             andTableName:USERICONTABLE];
                    }
                    
                    [memDict setObject:classID forKey:@"classid"];
                    [memDict setObject:[NSString stringWithFormat:@"%ld",(long)[[dict objectForKey:@"checked"] integerValue]] forKey:@"checked"];
                    
                    [memDict setObject:@"0" forKey:@"admin"];
                    
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
                        NSString *checked;
                        if ([[dict objectForKey:@"checked"] integerValue] == 0)
                        {
                            checked = @"0";
                        }
                        else
                        {
                            checked = @"1";
                        }
                        if ([[db findSetWithDictionary:@{@"classid":classID,@"role":@"students",@"name":[dict objectForKey:@"re_name"],@"checked":checked} andTableName:CLASSMEMBERTABLE] count] == 0)
                        {
                            NSDictionary *tmpDict = @{@"name":[dict objectForKey:@"re_name"],@"classid":classID,@"role":@"students",@"checked":checked};
                            if ([db insertRecord:tmpDict andTableName:CLASSMEMBERTABLE])
                            {
                                DDLOG(@"insert stu of parent without stu success!");
                            }
                        }
                        [memDict setObject:[dict objectForKey:@"re_name"] forKey:@"re_name"];
                    }
                    if ([[memDict objectForKey:@"role"] isEqualToString:@"students"])
                    {
                        if ([[db findSetWithDictionary:@{@"name":[memDict objectForKey:@"name"],@"classid":classID,@"role":@"students"} andTableName:CLASSMEMBERTABLE] count] == 0)
                        {
                            if ([db insertRecord:memDict andTableName:CLASSMEMBERTABLE])
                            {
                                DDLOG(@"insert mem success!");
                            }
                        }
                        else
                        {
                            if ([[memDict objectForKey:@"checked"] integerValue] == 0)
                            {
                                if ([db insertRecord:memDict andTableName:CLASSMEMBERTABLE])
                                {
                                    DDLOG(@"insert mem success!");
                                }
                            }
                            else if([[memDict objectForKey:@"checked"] integerValue] == 1)
                            {
                                if ([db deleteRecordWithDict:@{@"name":[memDict objectForKey:@"name"],@"classid":classID,@"role":@"students"} andTableName:CLASSMEMBERTABLE])
                                {
                                    if ([db insertRecord:memDict andTableName:CLASSMEMBERTABLE])
                                    {
                                        DDLOG(@"insert student success!");
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        if ([db insertRecord:memDict andTableName:CLASSMEMBERTABLE])
                        {
                            ;
                        }
                    }
                }
                [self dealClassMembers];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        [request setFailedBlock:^{
            
        }];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

-(void)checkBoxStateChange
{
    [selectedArray removeAllObjects];
    if ([((SSCheckBoxView *)[checkView viewWithTag:ALLTEACHERS]) checked])
    {
        //全体老师
        NSArray *tmpArray = [db findSetWithDictionary:@{@"classid":classID,@"role":@"teachers"} andTableName:CLASSMEMBERTABLE];
        for (int i=0; i < [tmpArray count]; i++)
        {
            NSDictionary *dict  =[tmpArray objectAtIndex:i];
            if([dict objectForKey:@"uid"] && [[dict objectForKey:@"uid"] isKindOfClass:[NSString class]] && [[dict objectForKey:@"uid"] length] > 10 && ![[dict objectForKey:@"uid"] isEqualToString:[Tools user_id]])
            {
                [selectedArray addObject:dict];
            }
        }
    }
    if ([((SSCheckBoxView *)[checkView viewWithTag:ALLPARENTS]) checked])
    {
        //全体家长
        NSArray *tmpArray = [db findSetWithDictionary:@{@"classid":classID,@"role":@"parents"} andTableName:CLASSMEMBERTABLE];
        for (int i=0; i < [tmpArray count]; i++)
        {
            NSDictionary *dict  =[tmpArray objectAtIndex:i];
            if([dict objectForKey:@"uid"] && [[dict objectForKey:@"uid"] isKindOfClass:[NSString class]] && [[dict objectForKey:@"uid"] length] > 10 && ![[dict objectForKey:@"uid"] isEqualToString:[Tools user_id]])
            {
                [selectedArray addObject:dict];
            }
        }
    }
    if ([((SSCheckBoxView *)[checkView viewWithTag:ALLSTUDENTS]) checked])
    {
        //全体学生
        NSArray *tmpArray = [db findSetWithDictionary:@{@"classid":classID,@"role":@"students"} andTableName:CLASSMEMBERTABLE];
        for (int i=0; i < [tmpArray count]; i++)
        {
            NSDictionary *dict  =[tmpArray objectAtIndex:i];
            if([dict objectForKey:@"uid"] && [[dict objectForKey:@"uid"] isKindOfClass:[NSString class]] && [[dict objectForKey:@"uid"] length] > 10 && ![[dict objectForKey:@"uid"] isEqualToString:[Tools user_id]])
            {
                [selectedArray addObject:dict];
            }
        }
    }
    [self updateSelect:nil];
}

#pragma mark - searchbar
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.2 animations:^{
        [searchView addGestureRecognizer:tapTgr];
        mySearchBar.frame = CGRectMake(0, YSTART, SCREEN_WIDTH, 40);
        [self.bgView insertSubview:searchView belowSubview:buttomView];
        searchTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
        searchView.frame = CGRectMake(0, 40+YSTART, SCREEN_WIDTH, SCREEN_HEIGHT);
        memberTableView.hidden = YES;
        checkView.hidden = YES;
        searchView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        mySearchBar.showsCancelButton = YES;
    }];
    
}

-(void)cancelSearch
{
    [searchResultArray removeAllObjects];
    mySearchBar.text = nil;
    //    [searchResultTableView reloadData];
    [UIView animateWithDuration:0.2 animations:^{
        [searchView removeFromSuperview];
        memberTableView.hidden = NO;
        checkView.hidden = NO;
        searchTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
        mySearchBar.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT+chedkViewH, SCREEN_WIDTH, 40);
        searchView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        mySearchBar.showsCancelButton = NO;
    }];
    [self updateSelect:nil];
    [mySearchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self cancelSearch];
    [self updateSelect:nil];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchBar.text length] > 0)
    {
        [self searchWithText:searchText];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchContent = [searchBar text];
    [self searchWithText:searchContent];
}

-(void)searchWithText:(NSString *)searchContent
{
    [searchResultArray removeAllObjects];
    
    if ([role isEqualToString:@"teachers"])
    {
        [searchResultArray addObjectsFromArray:[db fuzzyfindSetWithDictionary:@{@"classid":classID,
                                                                                @"role":@"students"}
                                                                 andTableName:CLASSMEMBERTABLE
                                                           andFuzzyDictionary:@{@"name":mySearchBar.text,
                                                                                @"jianpin":mySearchBar.text,
                                                                                @"quanpin":mySearchBar.text}]];
        [searchResultArray addObjectsFromArray:[db fuzzyfindSetWithDictionary:@{@"classid":classID,
                                                                                @"role":@"parents"}
                                                                 andTableName:CLASSMEMBERTABLE
                                                           andFuzzyDictionary:@{@"name":mySearchBar.text,
                                                                                @"jianpin":mySearchBar.text,
                                                                                @"quanpin":mySearchBar.text}]];
        [searchResultArray addObjectsFromArray:[db fuzzyfindSetWithDictionary:@{@"classid":classID,
                                                                                @"role":@"teachers"}
                                                                 andTableName:CLASSMEMBERTABLE
                                                           andFuzzyDictionary:@{@"name":mySearchBar.text,
                                                                                @"jianpin":mySearchBar.text,
                                                                                @"quanpin":mySearchBar.text}]];
    }
    else
    {
        [searchResultArray addObjectsFromArray:[db fuzzyfindSetWithDictionary:@{@"classid":classID,
                                                                                @"role":@"students"}
                                                                 andTableName:CLASSMEMBERTABLE
                                                           andFuzzyDictionary:@{@"name":mySearchBar.text,
                                                                                @"jianpin":mySearchBar.text,
                                                                                @"quanpin":mySearchBar.text}]];
        [searchResultArray addObjectsFromArray:[db fuzzyfindSetWithDictionary:@{@"classid":classID,
                                                                                @"role":@"parents"}
                                                                 andTableName:CLASSMEMBERTABLE
                                                           andFuzzyDictionary:@{@"name":mySearchBar.text,
                                                                                @"jianpin":mySearchBar.text,
                                                                                @"quanpin":mySearchBar.text}]];
    }
    
//    NSMutableArray *waitingRemoveArray = [[NSMutableArray alloc] initWithCapacity:0];
//    for (int i=0; i<[searchResultArray count]; ++i)
//    {
//        NSDictionary *dict = [searchResultArray objectAtIndex:i];
//        if (!([dict objectForKey:@"uid"] && [[dict objectForKey:@"uid"] isKindOfClass:[NSString class]] && [[dict objectForKey:@"uid"] length] > 10))
//        {
//            [waitingRemoveArray addObject:dict];
//        }
//        else if([[dict objectForKey:@"uid"] isEqualToString:[Tools user_id]])
//        {
//            [waitingRemoveArray addObject:dict];
//        }
//        if([selectedArray containsObject:dict])
//        {
//            [waitingRemoveArray addObject:dict];
//        }
//    }
//    for(NSDictionary *dict in waitingRemoveArray)
//    {
//        [searchResultArray removeObject:dict];
//    }
    DDLOG(@"search result count %lu",(unsigned long)[searchResultArray count]);
    [self updateSelect:nil];
    [searchTableView reloadData];
}

#pragma mark - tableview

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [mySearchBar resignFirstResponder];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == MemTableViewTag)
    {
        return [memberArray count];
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
        NSDictionary *groupDict = [memberArray objectAtIndex:section];
        return [[groupDict objectForKey:@"array"] count];
    }
    else if(tableView.tag == SearchTableViewTag)
    {
        [UIView animateWithDuration:0.2 animations:^{
            if ([searchResultArray count] *44 > SCREEN_HEIGHT-mySearchBar.frame.origin.y-mySearchBar.frame.size.height-buttomH)
            {
                searchTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-mySearchBar.frame.origin.y-mySearchBar.frame.size.height-buttomH);
            }
            else
            {
                searchTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, [searchResultArray count] * 44);
            }
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == MemTableViewTag)
    {
        return 27;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == MemTableViewTag)
    {
        return 60;
    }
    else if(tableView.tag == SearchTableViewTag)
    {
        return 44;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == MemTableViewTag)
    {
        NSDictionary *groupDict = [memberArray objectAtIndex:section];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-15, 27)];
        headerLabel.text = [NSString stringWithFormat:@"    %@",[groupDict objectForKey:@"key"]];
        headerLabel.backgroundColor = self.bgView.backgroundColor;
        headerLabel.font = [UIFont systemFontOfSize:16];
        headerLabel.textColor = TITLE_COLOR;
        return headerLabel;
    }
    return nil;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == SearchTableViewTag)
    {
        static NSString *searchCell = @"searchmemCell";
        MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCell];
        if (cell == nil)
        {
            cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCell];
        }
        NSDictionary *dict = [searchResultArray objectAtIndex:indexPath.row];
        
        [Tools fillImageView:cell.headerImageView withImageFromURL:[dict objectForKey:@"img_icon"] andDefault:HEADERICON];
        cell.headerImageView.frame = CGRectMake(5, 4, 35, 35);
        cell.headerImageView.layer.cornerRadius = 5;
        cell.headerImageView.clipsToBounds = YES;
        
        cell.memNameLabel.frame = CGRectMake(cell.headerImageView.frame.size.width+cell.headerImageView.frame.origin.x+5, 12, 220, 20);
        cell.memNameLabel.text = [dict objectForKey:@"name"];
        
        if (![[dict objectForKey:@"title"] isEqual:[NSNull null]] && [[dict objectForKey:@"title"] length] > 0)
        {
            cell.memNameLabel.text = [NSString stringWithFormat:@"%@(%@)",[dict objectForKey:@"name"],[dict objectForKey:@"title"]];
        }
        else
        {
            cell.memNameLabel.text = [dict objectForKey:@"name"];
        }
        
        cell.button1.hidden = NO;
        cell.button1.frame = CGRectMake(SCREEN_WIDTH-40, 11, 20, 20);
        if ([selectedArray containsObject:dict])
        {
            [cell.button1 setImage:[UIImage imageNamed:@"icon_checked"] forState:UIControlStateNormal];
        }
        else
        {
            [cell.button1 setImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
        }
        
        CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
        UIImageView *lineImageView = [[UIImageView alloc] init];
        lineImageView.frame = CGRectMake(70, cellHeight-0.5, cell.frame.size.width, 0.5);
        lineImageView.backgroundColor = LineBackGroudColor;
        [cell.contentView addSubview:lineImageView];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }
    else if(tableView.tag == MemTableViewTag)
    {
        static NSString *studentCell = @"chatMemberCell";
        MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:studentCell];
        if (cell == nil)
        {
            cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:studentCell];
        }
        NSDictionary *groupDict = [memberArray objectAtIndex:indexPath.section];
        NSArray *groupArray = [groupDict objectForKey:@"array"];
        NSDictionary *dict = [groupArray objectAtIndex:indexPath.row];
        DDLOG(@"dict %@",dict);
        
        CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
        UIImageView *lineImageView = [[UIImageView alloc] init];
        lineImageView.frame = CGRectMake(60, cellHeight-0.5, cell.frame.size.width, 0.5);
        lineImageView.backgroundColor = LineBackGroudColor;
        [cell.contentView addSubview:lineImageView];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        cell.memNameLabel.frame = CGRectMake(60, 15, 220, 30);
        if (![[dict objectForKey:@"title"] isEqual:[NSNull null]] && [[dict objectForKey:@"title"] length] > 0)
        {
            cell.memNameLabel.text = [NSString stringWithFormat:@"%@(%@)",[dict objectForKey:@"name"],[dict objectForKey:@"title"]];
        }
        else
        {
            cell.memNameLabel.text = [dict objectForKey:@"name"];
        }
        
        [Tools fillImageView:cell.headerImageView withImageFromURL:[dict objectForKey:@"img_icon"] andDefault:HEADERICON];
        cell.headerImageView.layer.cornerRadius = 3;
        cell.headerImageView.clipsToBounds = YES;
        cell.remarkLabel.hidden = NO;
       
        cell.button1.hidden = NO;
        cell.button1.frame = CGRectMake(SCREEN_WIDTH-60, 20, 20, 20);
        
        if ([selectedArray containsObject:dict])
        {
            [cell.button1 setImage:[UIImage imageNamed:@"icon_checked"] forState:UIControlStateNormal];
        }
        else
        {
            [cell.button1 setImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
        }
        
        cell.button1.tag = indexPath.section * SectionTag + indexPath.row+ 4433;
        
        [cell.button1 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *bgImageBG = [[UIImageView alloc] init];
        bgImageBG.image = [UIImage imageNamed:@"line3"];
        bgImageBG.backgroundColor = [UIColor clearColor];
        cell.backgroundView = bgImageBG;
        return cell;
    }
    return nil;
}

-(void)buttonClicked:(UIButton *)button
{
    int sectionIndex = (int)(button.tag-4433)/(int)SectionTag;
    int rowIndex = (button.tag - 4433) % SectionTag;
    NSDictionary *groupDict = [memberArray objectAtIndex:sectionIndex];
    NSArray *groupArray = [groupDict objectForKey:@"array"];
    NSDictionary *dict = [groupArray objectAtIndex:rowIndex];
    [self updateSelect:dict];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict;
    if (tableView.tag == SearchTableViewTag)
    {
        dict = [searchResultArray objectAtIndex:indexPath.row];
        [self updateSelect:dict];
        [searchTableView reloadData];
    }
    else if(tableView.tag == MemTableViewTag)
    {
        NSDictionary *groupDict = [memberArray objectAtIndex:indexPath.section];
        NSArray *groupArray = [groupDict objectForKey:@"array"];
        dict = [groupArray objectAtIndex:indexPath.row];
        [self updateSelect:dict];
    }
}

-(void)updateSelect:(NSDictionary *)dict
{
    if (dict)
    {
        if([dict objectForKey:@"uid"] && [[dict objectForKey:@"uid"] isKindOfClass:[NSString class]] && [[dict objectForKey:@"uid"] length] > 10 && ![[dict objectForKey:@"uid"] isEqualToString:[Tools user_id]])
        {
            if ([selectedArray containsObject:dict])
            {
                [selectedArray removeObject:dict];
            }
            else
            {
                [selectedArray addObject:dict];
            }
        }
    }
    
    if ([selectedArray count] > 0)
    {
        for(UIView *v in chatMemberScrollView.subviews)
        {
            [v removeFromSuperview];
        }
        buttomH = 50;
        for (int i=0; i<[selectedArray count]; i++)
        {
            NSDictionary *dict = [selectedArray objectAtIndex:i];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [Tools fillButtonView:button withImageFromURL:[dict objectForKey:@"img_icon"] andDefault:HEADERICON];
            [button addTarget:self action:@selector(buttomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            button.layer.cornerRadius = 5;
            button.clipsToBounds = YES;
            button.tag = i;
            button.frame = CGRectMake(5+50*i, 0, 40, 40);
            [chatMemberScrollView addSubview:button];
            
//            UILabel *nameLabel = [[UILabel alloc] init];
//            nameLabel.frame = CGRectMake(button.frame.origin.x-3, button.frame.size.height+button.frame.origin.y, button.frame.size.width+6, 10);
//            nameLabel.textAlignment = NSTextAlignmentCenter;
//            nameLabel.font = [UIFont systemFontOfSize:10];
//            nameLabel.textColor = COMMENTCOLOR;
////            NSDictionary *userDict = []
//            
//            nameLabel.text = [dict objectForKey:@"name"];
//            [chatMemberScrollView addSubview:nameLabel];
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            buttomView.frame = CGRectMake(0, SCREEN_HEIGHT-buttomH-keyBoardHeight, SCREEN_WIDTH, buttomH);
            [submitButton setTitle:[NSString stringWithFormat:@"提交(%lu)",(unsigned long)[selectedArray count]] forState:UIControlStateNormal];
            memberTableView.frame = CGRectMake(0, mySearchBar.frame.size.height+mySearchBar.frame.origin.y, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-buttomH-chedkViewH-mySearchBar.frame.size.height);
            chatMemberScrollView.contentSize = CGSizeMake([selectedArray count] * 50, 50);
            if (chatMemberScrollView.contentSize.width > chatMemberScrollView.frame.size.width)
            {
                chatMemberScrollView.contentOffset = CGPointMake(chatMemberScrollView.contentSize.width-chatMemberScrollView.frame.size.width, 0);
            }
        }];
    }
    else
    {
        buttomH = 0;
        [UIView animateWithDuration:0.2 animations:^{
            buttomView.frame = CGRectMake(0, SCREEN_HEIGHT-0, SCREEN_WIDTH, 0);
            memberTableView.frame = CGRectMake(0, mySearchBar.frame.size.height+mySearchBar.frame.origin.y, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-chedkViewH-mySearchBar.frame.size.height);
        }];
    }
    
    if ([role isEqualToString:@"teachers"])
    {
        [((SSCheckBoxView *)[checkView viewWithTag:ALLTEACHERS]) setChecked:[self containAllTeacher]];
        [((SSCheckBoxView *)[checkView viewWithTag:ALLPARENTS]) setChecked:[self containAllParents]];
        [((SSCheckBoxView *)[checkView viewWithTag:ALLSTUDENTS]) setChecked:[self containAllStudent]];
    }
    
    [memberTableView reloadData];
}

-(void)buttomButtonClick:(UIButton *)button
{
    NSDictionary *dict = [selectedArray objectAtIndex:button.tag];
    [self updateSelect:dict];
    if (![searchResultArray containsObject:dict])
    {
        [searchResultArray addObject:dict];
        [searchTableView reloadData];
    }
}

- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        if ([selectedArray count] > 0)
        {
            [UIView animateWithDuration:0.2 animations:^{
                buttomView.frame = CGRectMake(0, SCREEN_HEIGHT-buttomH, SCREEN_WIDTH, buttomH);
                if ([searchResultArray count] *44 > SCREEN_HEIGHT-mySearchBar.frame.origin.y-mySearchBar.frame.size.height-buttomH)
                {
                    searchTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-mySearchBar.frame.origin.y-mySearchBar.frame.size.height-buttomH);
                }
                else
                {
                    searchTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, [searchResultArray count] *44);
                }
            }];
        }
        else
        {
            buttomView.frame = CGRectMake(0, SCREEN_HEIGHT-0, SCREEN_WIDTH, 0);
        }
        keyBoardHeight = 0;
    }completion:^(BOOL finished) {
    }];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
//获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyBoardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:0.2 animations:^{
        if ([selectedArray count] > 0)
        {
            buttomView.frame = CGRectMake(0, SCREEN_HEIGHT-keyBoardHeight-buttomH, SCREEN_WIDTH, buttomH);
        }
    }];
    
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
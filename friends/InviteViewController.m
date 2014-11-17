//
//  InviteViewController.m
//  School
//
//  Created by TeekerZW on 14-1-20.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "InviteViewController.h"
#import "Header.h"
#import "FriendsCell.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "WeiboSDK.h"
#import "WeiboApi.h"
#import "WXApi.h"

#define tableViewTagBase   77777777

#define BanJiaFriendsTableViewTag tableViewTagBase

#define ContactTableViewTag  (tableViewTagBase+1)

#define TencentTableViewTag     (tableViewTagBase+2)
#define WeiXinTag             (tableViewTagBase+3)
#define SearchTableViewTag (tableViewTagBase+4)

#define TIPSLABEL_TAG 10086

#define BUFFER_SIZE 1024 * 100

@class AppDelegate;

@interface InviteViewController ()<UITableViewDataSource,
UITableViewDelegate,
MFMessageComposeViewControllerDelegate,
UIAlertViewDelegate,
UISearchBarDelegate>
{
    UIScrollView *bgScrollView;
    
    
    //腾讯微博
    NSMutableArray *tencentFriendsArray;
    UITableView *tencentTableView;
    NSMutableArray *tencentInviteArray;
    UIButton *inviteTencentButton;
    
    //手机联系人
    NSMutableArray *contactArray;
    UITableView *contactTableView;
    NSMutableArray *contactInviteArray;
    NSMutableArray *groupContactArray;
    
    NSMutableArray *addedContactArray;
    
    NSMutableArray *allContacts;
    
    //班家好友
    NSMutableArray *thisClassFriednsArray;
    NSMutableArray *friendsArry;
    UITableView *friendsTableView;
    NSMutableArray *alreadyInviteFriendsArray;
    
    UIView *phoneBgView;
    NSString *_userName;

    NSMutableArray *alreadyUsers;
    
    NSInteger pageNum;
    NSInteger pageSize;
    
    NSString *weiboToken;
    
    UIButton *inviteButton;
    
    OperatDB *db;
    
    NSString *schoolName;
    NSString *className;
    NSString *classID;
    
    NSMutableArray *iconOnArray;
    NSMutableArray *iconArray;
    
    
    UIScrollView *buttonScrollView;
    
    NSMutableArray *selectedUsers;
    
    UISearchBar *mySearchBar;
    
    UIView *searchView;
    NSMutableArray *searchResultArray;
    UITableView *searchTableView;
    
    UITapGestureRecognizer *tapTgr;
    
    UIView *selectView;
    UIScrollView *selectScrollView;
    UIButton *selectButton;
    
    int fromClassTableViewIndex;
    
    NSString *sendMsg;
}
@end

@implementation InviteViewController
@synthesize fromClass;
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
    
    self.titleLabel.text = @"好友";
        
    schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
    if ([schoolName isEqualToString:@"未指定学校"] ||
        [schoolName isEqualToString:@"未设置学校"])
    {
        schoolName = @"";
    }
    className = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    
    if (![schoolName isEqualToString:@"未设置学校"] && [schoolName length] > 0)
    {
         sendMsg = [NSString stringWithFormat:@"{\"t\":\"c_i\",\"c_id\":\"%@\"}$!#我是%@,我在[%@—%@],你也一起加入吧！",classID,[Tools user_name],schoolName,className];
    }
    else
    {
        sendMsg = [NSString stringWithFormat:@"{\"t\":\"c_i\",\"c_id\":\"%@\"}$!#我是%@,我在[%@],你也一起加入吧！",classID,[Tools user_name],className];
    }
    
   
    
    pageNum = 0;
    pageSize = 100;
    weiboToken = @"";
    
    db = [[OperatDB alloc] init];
    
    //班家好友
    thisClassFriednsArray = [[NSMutableArray alloc] initWithCapacity:0];
    friendsArry = [[NSMutableArray alloc] initWithCapacity:0];
    
    alreadyInviteFriendsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    //手机联系人
    contactArray = [[NSMutableArray alloc]initWithCapacity:0];
    //已经选择的手机号数组 
    contactInviteArray  = [[NSMutableArray alloc] initWithCapacity:0];
    //已注册班家的联系人
    alreadyUsers = [[NSMutableArray alloc] initWithCapacity:0];
    //按字母排序后的数据
    groupContactArray = [[NSMutableArray alloc] initWithCapacity:0];
    //
    allContacts = [[NSMutableArray alloc] initWithCapacity:0];
    //已经邀请或是加好友的已注册联系人
    selectedUsers = [[NSMutableArray alloc] initWithCapacity:0];
    //搜索到的联系人
    searchResultArray = [[NSMutableArray alloc] initWithCapacity:0];
    //已经选择的联系人
    addedContactArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    tapTgr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelSearch)];
    
    fromClassTableViewIndex = 1;
    
    if (fromClass)
    {
        fromClassTableViewIndex = 0;
    }
    
    inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setTitle:@"邀请" forState:UIControlStateNormal];
    [inviteButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    inviteButton.frame = CGRectMake(SCREEN_WIDTH - 80, self.backButton.frame.origin.y, 70, NAV_RIGHT_BUTTON_HEIGHT);
    [inviteButton addTarget:self action:@selector(inviteClick) forControlEvents:UIControlEventTouchUpInside];
    if (fromClass)
    {
        inviteButton.hidden = YES;
    }
    [self.navigationBarView addSubview:inviteButton];
    
    buttonScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, 70)];
    buttonScrollView.backgroundColor = UIColorFromRGB(0xf0f1ec);
    buttonScrollView.showsHorizontalScrollIndicator = NO;
    [self.bgView addSubview:buttonScrollView];
    
    iconArray = [[NSMutableArray alloc] initWithCapacity:0];
    iconOnArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (fromClass)
    {
        [iconOnArray addObjectsFromArray:@[@"Invite_banjia_friend_on",@"invite_phone_on"]];
        [iconArray addObjectsFromArray:@[@"Invite_banjia_friend",@"invite_phone"]];
    }
    else
    {
        [iconOnArray addObjectsFromArray:@[@"invite_phone_on"]];
        [iconArray addObjectsFromArray:@[@"invite_phone"]];
    }
    
    if ([QQApi isQQInstalled])
    {
        [iconArray addObject:@"invite_QQ"];
        [iconOnArray addObject:@"invite_QQ_on"];
    }
    
    if ([WXApi isWXAppInstalled])
    {
        [iconArray addObject:@"invite_weichat"];
        [iconOnArray addObject:@"invite_weichat_on"];
    }
    
    
    for (int i=0; i<[iconOnArray count]; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(35+103*i, 10, 50, 50);
        button.backgroundColor = [UIColor clearColor];
        button.tag = tableViewTagBase+i;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0)
        {
            [button setImage:[UIImage imageNamed:[iconOnArray objectAtIndex:i]] forState:UIControlStateNormal];
        }
        else
        {
            [button setImage:[UIImage imageNamed:[iconArray objectAtIndex:i]] forState:UIControlStateNormal];
        }
        [buttonScrollView addSubview:button];
    }
    
    buttonScrollView.contentSize = CGSizeMake(35+103*[iconArray count], 70);
    
    bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, buttonScrollView.frame.size.height+buttonScrollView.frame.origin.y, SCREEN_WIDTH, SCREEN_HEIGHT - buttonScrollView.frame.origin.y-buttonScrollView.frame.size.height)];
    bgScrollView.tag = 5000;
    bgScrollView.backgroundColor = [UIColor whiteColor];
    bgScrollView.delegate = self;
    bgScrollView.pagingEnabled = YES;
    bgScrollView.showsHorizontalScrollIndicator = NO;
    bgScrollView.scrollEnabled = NO;
    bgScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*([iconArray count]), bgScrollView.frame.size.height);
    [self.bgView addSubview:bgScrollView];
    
    
    if (fromClass)
    {
        friendsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, bgScrollView.frame.size.height) style:UITableViewStylePlain];
        friendsTableView.delegate = self;
        friendsTableView.dataSource = self;
        friendsTableView.tag = BanJiaFriendsTableViewTag;
        friendsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [bgScrollView addSubview:friendsTableView];
    }
    
    
    
    mySearchBar = [[UISearchBar alloc] initWithFrame:
                   CGRectMake(((ContactTableViewTag-fromClassTableViewIndex)%tableViewTagBase)*SCREEN_WIDTH, 0, SCREEN_WIDTH-0, 40)];
    mySearchBar.delegate = self;
    mySearchBar.placeholder = @"输入联系人姓名";
    
    UIImage *searchBarBgImage = [Tools getImageFromImage:[UIImage imageNamed:@"searchBG"] andInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [mySearchBar setBackgroundImage:searchBarBgImage];
    
    mySearchBar.contentMode = UIControlContentHorizontalAlignmentLeft;
//    mySearchBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"searchBG"]];
    mySearchBar.backgroundColor = UIColorFromRGB(0xcbc7cc);
    [bgScrollView addSubview:mySearchBar];
    
    if (SYSVERSION < 7.0)
    {
        UITextField* searchField = nil;
        for (UIView* subview in mySearchBar.subviews)
        {
            if ([subview isKindOfClass:[UITextField class]])
            {
                searchField = (UITextField*)subview;
                searchField.leftView=nil;
                [searchField setBackground:nil];
                [searchField setBackgroundColor:[UIColor whiteColor]];
                searchField.layer.cornerRadius = 5;
                searchField.clipsToBounds = YES;
                break;
            }
        }
        
        for (UIView *subview in mySearchBar.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                [subview setBackgroundColor:UIColorFromRGB(0xcbc7cc)];
                [subview removeFromSuperview];
                break;
            }
        }
    }

    
    searchView = [[UIView alloc] init];
    searchView.frame = CGRectMake(mySearchBar.frame.origin.x, mySearchBar.frame.size.height+mySearchBar.frame.origin.y, SCREEN_WIDTH, SCREEN_HEIGHT-YSTART-mySearchBar.frame.size.height);
    searchView.alpha = 0;
    searchView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [bgScrollView addSubview:searchView];
    
    searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(mySearchBar.frame.origin.x, 0, mySearchBar.frame.size.width, 0) style:UITableViewStylePlain];
    searchTableView.delegate = self;
    searchTableView.dataSource = self;
    searchTableView.tag = SearchTableViewTag;
    [searchView addSubview:searchTableView];
    
    contactTableView = [[UITableView alloc]initWithFrame:CGRectMake(((ContactTableViewTag-fromClassTableViewIndex)%tableViewTagBase)*SCREEN_WIDTH, 40, bgScrollView.frame.size.width, bgScrollView.frame.size.height-mySearchBar.frame.size.height) style:UITableViewStylePlain];
    contactTableView.delegate = self;
    contactTableView.dataSource = self;
    contactTableView.tag = ContactTableViewTag;
    contactTableView.sectionIndexTrackingBackgroundColor=[UIColor grayColor];
    if (SYSVERSION>=7)
    {
        contactTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    contactTableView.backgroundColor = self.bgView.backgroundColor;
    contactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [bgScrollView addSubview:contactTableView];
    
    selectView = [[UIView alloc] init];
    selectView.backgroundColor = self.bgView.backgroundColor;
    selectView.frame = CGRectMake(0, bgScrollView.frame.size.height, SCREEN_WIDTH, 50);
    [bgScrollView addSubview:selectView];
    
    selectScrollView = [[UIScrollView alloc] init];
    selectScrollView.backgroundColor = self.bgView.backgroundColor;
    selectScrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH-80, 50);
    [selectView addSubview:selectScrollView];
    
    selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    selectButton.frame = CGRectMake(SCREEN_WIDTH-75, 5, 70, 40);
    [selectButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    selectButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [selectButton addTarget:self action:@selector(inviteClick) forControlEvents:UIControlEventTouchUpInside];
    [selectView addSubview:selectButton];
    
    
    inviteTencentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteTencentButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    inviteTencentButton.frame = CGRectMake(CENTER_POINT.x-80+SCREEN_WIDTH*((TencentTableViewTag-fromClassTableViewIndex)%tableViewTagBase), bgScrollView.frame.size.height/2-35, 160, 42);
    [inviteTencentButton setTitle:@"邀请QQ好友" forState:UIControlStateNormal];
    [inviteTencentButton addTarget:self action:@selector(shareToQQFriendClickHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *inviteWeiXinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteWeiXinButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    inviteWeiXinButton.frame = CGRectMake(CENTER_POINT.x-80+SCREEN_WIDTH*((WeiXinTag-fromClassTableViewIndex)%tableViewTagBase), bgScrollView.frame.size.height/2-35, 160, 42);
    [inviteWeiXinButton setTitle:@"邀请微信好友" forState:UIControlStateNormal];
    [inviteWeiXinButton addTarget:self action:@selector(inviteWeiXin) forControlEvents:UIControlEventTouchUpInside];
    
    if([QQApi isQQInstalled])
    {
        [bgScrollView addSubview:inviteTencentButton];
    }
    else
    {
        inviteWeiXinButton.frame = CGRectMake(CENTER_POINT.x-80+SCREEN_WIDTH*((WeiXinTag-fromClassTableViewIndex-1)%tableViewTagBase), bgScrollView.frame.size.height/2-35, 160, 42);
    }
    
    if ([WXApi isWXAppInstalled])
    {
        [bgScrollView addSubview:inviteWeiXinButton];
    }
    
    
    
    if (fromClass)
    {
        [self getFriendList];
    }
    [self getLocalContacts];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - searchbardelegate

-(void)cancelSearch
{
    [searchResultArray removeAllObjects];
    [searchTableView reloadData];
    mySearchBar.text = nil;
    [UIView animateWithDuration:0.2 animations:^{
        [bgScrollView sendSubviewToBack:searchView];
        contactTableView.hidden = NO;
        [searchView removeGestureRecognizer:tapTgr];
        mySearchBar.showsCancelButton = NO;
        bgScrollView.frame = CGRectMake(0, buttonScrollView.frame.size.height+buttonScrollView.frame.origin.y, SCREEN_WIDTH, SCREEN_HEIGHT - buttonScrollView.frame.origin.y-buttonScrollView.frame.size.height);
        if ([addedContactArray count] > 0)
        {
            selectView.frame = CGRectMake(((ContactTableViewTag-fromClassTableViewIndex)%tableViewTagBase)*SCREEN_WIDTH, bgScrollView.frame.size.height-50, SCREEN_WIDTH, 50);
        }
        else
        {
            selectView.frame = CGRectMake(((ContactTableViewTag-fromClassTableViewIndex)%tableViewTagBase)*SCREEN_WIDTH, bgScrollView.frame.size.height, SCREEN_WIDTH, 0);
        }
    }];
    
    [mySearchBar resignFirstResponder];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.2 animations:^{
        
        searchBar.showsCancelButton = YES;
        for(id cc in [searchBar subviews])
        {
            if([cc isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)cc;
                [btn setTitle:@"完成"  forState:UIControlStateNormal];
                [btn setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:16];
                [btn setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"searchbarbg1"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"searchbarbg1"] forState:UIControlStateHighlighted];
            }
        }
        
        [searchView addGestureRecognizer:tapTgr];
        bgScrollView.frame = CGRectMake(0, YSTART, SCREEN_WIDTH, SCREEN_HEIGHT-YSTART);
        mySearchBar.frame = CGRectMake(((ContactTableViewTag-fromClassTableViewIndex)%tableViewTagBase)*SCREEN_WIDTH, 0, SCREEN_WIDTH, 40);
        searchView.alpha = 1;
        [bgScrollView bringSubviewToFront:searchView];
//        searchTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
        searchView.frame = CGRectMake(((ContactTableViewTag-fromClassTableViewIndex)%tableViewTagBase)*SCREEN_WIDTH, 40, SCREEN_WIDTH, SCREEN_HEIGHT-40-YSTART);
        contactTableView.hidden = YES;
    }];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchBar.text length] > 0)
    {
        [self searchWithText:searchText];
    }
    else
    {
        [searchResultArray removeAllObjects];
        [searchTableView reloadData];
    }
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
    for(NSDictionary *dict in contactArray)
    {
        if ([[dict objectForKey:@"name"] rangeOfString:searchContent].length > 0)
        {
            [searchResultArray addObject:dict];
        }
    }
    [searchTableView reloadData];
    
}


#pragma mark - tableview

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (scrollView.tag == 1001)
    {
        if (scrollView.contentOffset.y>scrollView.contentSize.height-scrollView.frame.size.height+30)
        {
//            pageNum++;
//            DDLOG(@"pagenum == %d",pageNum);
//            [self getSinaFriends:sinaAuthOptions andPageNumber:pageNum];
        }
    }
    else if(scrollView.tag == SearchTableViewTag)
    {
        [mySearchBar resignFirstResponder];
    }
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView.tag == ContactTableViewTag)
    {
        if ([contactArray count] > 10)
        {
            NSMutableArray *sectionArray = [[NSMutableArray alloc] initWithCapacity:0];
            NSArray *letters = [NSArray arrayWithObjects:@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z", nil];
            if ([alreadyUsers count] > 0)
            {
                [sectionArray addObject:@"*"];
            }
            for (int i=0; i<[letters count]; ++i)
            {
                NSString *letter = [letters objectAtIndex:i];
                for (int j=0; j<[groupContactArray count]; ++j)
                {
                    NSString *first = [[groupContactArray objectAtIndex:j] objectForKey:@"key"];
                    if ([letter isEqualToString:first])
                    {
                        if (![sectionArray containsObject:letter])
                        {
                            [sectionArray addObject:letter];
                        }
                    }
                }
            }
            [sectionArray addObject:@"#"];
            return sectionArray;
        }
    }
    return nil;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == BanJiaFriendsTableViewTag)
    {
        return 2;
    }
    else if (tableView.tag == ContactTableViewTag)
    {
        return [groupContactArray count]+1;
    }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == BanJiaFriendsTableViewTag)
    {
        if (section == 0)
        {
            return [friendsArry count];
        }
        else if(section == 1)
        {
            return [thisClassFriednsArray count];
        }
    }
    else if(tableView.tag == ContactTableViewTag)
    {
        for(UIView *v in selectScrollView.subviews)
        {
            [v removeFromSuperview];
        }
        if ([addedContactArray count] > 0)
        {
//            [UIView animateWithDuration:0.2 animations:^{
                contactTableView.frame = CGRectMake(((ContactTableViewTag-fromClassTableViewIndex)%tableViewTagBase)*SCREEN_WIDTH, mySearchBar.frame.size.height, SCREEN_WIDTH,bgScrollView.frame.size.height-mySearchBar.frame.size.height-50);
                selectView.frame = CGRectMake(((ContactTableViewTag-fromClassTableViewIndex)%tableViewTagBase)*SCREEN_WIDTH, bgScrollView.frame.size.height-50, SCREEN_WIDTH, 50);
//            }];
            for(int i = 0 ; i< [addedContactArray count] ; i++)
            {
                NSDictionary *dict = [addedContactArray objectAtIndex:i];
                NSString *name = [dict objectForKey:@"name"];
                UIButton *nameLabel = [UIButton buttonWithType:UIButtonTypeCustom];
                nameLabel.frame = CGRectMake(5+40*i, 7.5, 35, 35);
                nameLabel.layer.cornerRadius = 17.5;
                nameLabel.tag = i;
                [nameLabel addTarget:self action:@selector(delSelectContact:) forControlEvents:UIControlEventTouchUpInside];
                nameLabel.backgroundColor = LIGHT_BLUE_COLOR;
                [nameLabel setTitle:[name substringFromIndex:[name length] -1] forState:UIControlStateNormal];
                [selectScrollView addSubview:nameLabel];
            }
            selectScrollView.contentSize = CGSizeMake(10+40*[addedContactArray count], 50);
            if ((10+40*[addedContactArray count]) > SCREEN_WIDTH-80)
            {
                selectScrollView.contentOffset = CGPointMake((10+40*[addedContactArray count])-SCREEN_WIDTH+80, 0);
            }
            
            [selectButton setTitle:[NSString stringWithFormat:@"邀请(%d)",[addedContactArray count]] forState:UIControlStateNormal];
            [inviteButton setTitle:[NSString stringWithFormat:@"邀请(%d)",[addedContactArray count]] forState:UIControlStateNormal];
        }
        else
        {
//            [UIView animateWithDuration:0.2 animations:^{
                contactTableView.frame = CGRectMake(((ContactTableViewTag-fromClassTableViewIndex)%tableViewTagBase)*SCREEN_WIDTH, mySearchBar.frame.size.height, SCREEN_WIDTH,bgScrollView.frame.size.height-mySearchBar.frame.size.height);
                selectView.frame = CGRectMake(((ContactTableViewTag-fromClassTableViewIndex)%tableViewTagBase)*SCREEN_WIDTH, bgScrollView.frame.size.height, SCREEN_WIDTH, 50);
                
//            }];
            [inviteButton setTitle:@"邀请" forState:UIControlStateNormal];
        }
        if ([groupContactArray count] > 0 || [alreadyUsers count] > 0)
        {
            contactTableView.hidden = NO;
        }
        if (section == 0)
        {
            return [alreadyUsers count];
        }
        else
        {
            if ([groupContactArray count] > 0)
            {
                NSDictionary *groupDict = [groupContactArray objectAtIndex:section-1];
                NSArray *array = [groupDict objectForKey:@"array"];
                return [array count];
            }
        }
    }
    else if(tableView.tag == SearchTableViewTag)
    {
        
        if ([searchResultArray count] > 0)
        {
            [searchView removeGestureRecognizer:tapTgr];
        }
        else
        {
            [UIView animateWithDuration:0.2 animations:^{
                searchTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - YSTART-mySearchBar.frame.size.height);
                [searchView addGestureRecognizer:tapTgr];
            }];
            
        }
        return [searchResultArray count];
    }
    
    return 0;
}

-(void)delSelectContact:(UIButton *)button
{
    NSDictionary *dict = [addedContactArray objectAtIndex:button.tag];
    if ([addedContactArray containsObject:dict])
    {
        [addedContactArray removeObject:dict];
        NSArray *homePhoneArray = [self getPhoneArrayFromContactDict:dict];
        for (int i=0; i<[homePhoneArray count]; ++i)
        {
            if ([self haveThisPhone:[homePhoneArray objectAtIndex:i]])
            {
                [contactInviteArray removeObject:[homePhoneArray objectAtIndex:i]];
            }
            else
            {
                [contactInviteArray addObject:[homePhoneArray objectAtIndex:i]];
            }
        }
        [contactTableView reloadData];
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == BanJiaFriendsTableViewTag)
    {
        if (section == 0 && [friendsArry count] > 0)
        {
            return 30;
        }
        else if(section == 1 && [thisClassFriednsArray count] > 0)
        {
            return 30;
        }
    }
    if (tableView.tag == ContactTableViewTag)
    {
        if(section == 0)
        {
            if ([alreadyUsers count] > 0)
            {
                return 30;
            }
            return 0;
        }
        return 30;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == BanJiaFriendsTableViewTag)
    {
        if (section == 0 && [friendsArry count] > 0)
        {
            UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-15, 27)];
            headerLabel.text = @"    未加入班级的好友";
            headerLabel.backgroundColor = UIColorFromRGB(0x3dc46e);
            headerLabel.font = [UIFont systemFontOfSize:14];
            headerLabel.textColor = [UIColor whiteColor];
            return headerLabel;
        }
        else if(section == 1 && [thisClassFriednsArray count])
        {
            UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-15, 27)];
            headerLabel.text = @"    已加入班级的好友";
            headerLabel.backgroundColor = UIColorFromRGB(0xf0f1ec);
            headerLabel.font = [UIFont systemFontOfSize:14];
            headerLabel.textColor = COMMENTCOLOR;
            return headerLabel;
        }
    }
    else if (tableView.tag == ContactTableViewTag)
    {
        if (section == 0)
        {
            if ([alreadyUsers count] > 0)
            {
                
                UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-15, 27)];
                headerLabel.text = @"    已注册班家的联系人";
                headerLabel.backgroundColor = UIColorFromRGB(0x3dc46e);
                headerLabel.font = [UIFont systemFontOfSize:14];
                headerLabel.textColor = [UIColor whiteColor];
                return headerLabel;
            }
        }
        else if(section > 0)
        {
            if ([groupContactArray count] > 0)
            {
                NSDictionary *groupDict = [groupContactArray objectAtIndex:section-1];
                UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-15, 27)];
                headerLabel.text = [NSString stringWithFormat:@"   %@",[groupDict objectForKey:@"key"]];
                headerLabel.backgroundColor = UIColorFromRGB(0xf0f1ec);
                headerLabel.font = [UIFont systemFontOfSize:14];
                headerLabel.textColor = COMMENTCOLOR;
                return headerLabel;
            }
        }
    }
    return nil;
}

-(BOOL)haveThisFriend:(NSString *)fid
{
    NSArray *array = [db findSetWithDictionary:@{@"uid":[Tools user_id]} andTableName:FRIENDSTABLE];
    for (int i=0; i<[array count]; ++i)
    {
        NSDictionary *friendDict = [array objectAtIndex:i];
        if ([fid isEqualToString:[friendDict objectForKey:@"fid"]])
        {
            if ([[friendDict objectForKey:@"checked"]integerValue] == 1)
            {
                return YES;
            }
            return NO;
        }
    }
    return NO;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == BanJiaFriendsTableViewTag)
    {
        static NSString *inviteFriend = @"inviteFriend";
        FriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:inviteFriend];
        if (cell == nil)
        {
            cell = [[FriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:inviteFriend];
        }
        NSDictionary *friendDict;
        if (indexPath.section == 0)
        {
            friendDict = [friendsArry objectAtIndex:indexPath.row];
        }
        else if(indexPath.section == 1)
        {
            friendDict = [thisClassFriednsArray objectAtIndex:indexPath.row];
        }
        cell.nameLabel.frame = CGRectMake(45, 10, SCREEN_WIDTH - 80, 30);
        cell.nameLabel.font = [UIFont systemFontOfSize:16];
        cell.nameLabel.text = [friendDict objectForKey:@"name"];
        
        cell.headerImageView.frame = CGRectMake(5, 7.5, 34, 34);
        cell.headerImageView.layer.cornerRadius = 5;
        cell.headerImageView.clipsToBounds = YES;
        [Tools fillImageView:cell.headerImageView withImageFromURL:[friendDict objectForKey:@"img_icon"] andDefault:HEADERICON];
        
        if (indexPath.section == 0)
        {
            cell.inviteButton.hidden = NO;
            cell.inviteButton.frame = CGRectMake(SCREEN_WIDTH-50, 12.5, 25, 25);
            if ([alreadyInviteFriendsArray containsObject:friendDict])
            {
                [cell.inviteButton setTitle:@"已邀请" forState:UIControlStateNormal];
                [cell.inviteButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                cell.inviteButton.enabled = NO;
                cell.inviteButton.frame = CGRectMake(SCREEN_WIDTH-80, 12.5, 60, 25);
                cell.inviteButton.titleLabel.font = [UIFont systemFontOfSize:14];
                [cell.inviteButton setTitleColor:UIColorFromRGB(0x676768) forState:UIControlStateNormal];
            }
            else
            {
                [cell.inviteButton setTitle:@"" forState:UIControlStateNormal];
                [cell.inviteButton setImage:[UIImage imageNamed:@"roundadd"] forState:UIControlStateNormal];
                cell.inviteButton.tag = indexPath.row;
                [cell.inviteButton addTarget:self action:@selector(inviteFriendJoinClass:) forControlEvents:UIControlEventTouchUpInside];
                cell.inviteButton.enabled = YES;
            }
        }
        else if(indexPath.section == 1)
        {
            cell.inviteButton.hidden = YES;
        }
        
        CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
        UIImageView *lineImageView = [[UIImageView alloc] init];
        if ((indexPath.section == 0 && indexPath.row == [friendsArry count]-1) ||
            (indexPath.section == 1 && indexPath.row == [thisClassFriednsArray count]-1))
        {
            lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
        }
        else
        {
            lineImageView.frame = CGRectMake(45, cellHeight-0.5, cell.frame.size.width, 0.5);
        }
        lineImageView.backgroundColor = LineBackGroudColor;
        [cell.contentView addSubview:lineImageView];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        return cell;
    }
    else if (tableView.tag == ContactTableViewTag)
    {
        if (indexPath.section == 0)
        {
            static NSString *cellName = @"alreadyContactcell";
            FriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil)
            {
                cell = [[FriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            }
            
            CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
            UIImageView *lineImageView = [[UIImageView alloc] init];
            lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
            lineImageView.backgroundColor = LineBackGroudColor;
            
            [cell.contentView addSubview:lineImageView];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            if (indexPath.row < [tableView numberOfRowsInSection:indexPath.section]-1)
            {
                lineImageView.frame = CGRectMake( 45, cellHeight-0.5, cell.frame.size.width, 0.5);
            }
            
            cell.nameLabel.frame = CGRectMake(45, 10, SCREEN_WIDTH - 80, 30);
            cell.nameLabel.font = [UIFont systemFontOfSize:16];
            
            NSDictionary *dict = [alreadyUsers objectAtIndex:indexPath.row];
            
            cell.headerImageView.frame = CGRectMake(5, 7.5, 34, 34);
            cell.headerImageView.layer.cornerRadius = 5;
            cell.headerImageView.clipsToBounds = YES;
            [Tools fillImageView:cell.headerImageView withImageFromURL:[dict objectForKey:@"img_icon"] andDefault:HEADERICON];
            
            
            NSString *name = [self nameInContacts:[dict objectForKey:@"phone"]];
            if ([name length] > 0)
            {
                cell.nameLabel.text = [NSString stringWithFormat:@"%@(%@)",[dict objectForKey:@"r_name"],name];
            }
            else
            {
                cell.nameLabel.text = [dict objectForKey:@"r_name"];
            }
            cell.inviteButton.hidden = NO;
            cell.inviteButton.frame = CGRectMake(SCREEN_WIDTH-50, 12.5, 25, 25);
            if ([selectedUsers containsObject:dict])
            {
                cell.inviteButton.frame = CGRectMake(SCREEN_WIDTH-80, 12.5, 60, 25);
                cell.inviteButton.titleLabel.font = [UIFont systemFontOfSize:14];
                if (fromClass)
                {
                    [cell.inviteButton setTitle:@"已邀请" forState:UIControlStateNormal];
                }
                else
                {
                    [cell.inviteButton setTitle:@"已申请" forState:UIControlStateNormal];
                }
                [cell.inviteButton setTitleColor:UIColorFromRGB(0x676768) forState:UIControlStateNormal];
                [cell.inviteButton setImage:nil forState:UIControlStateNormal];
            }
            else
            {
                [cell.inviteButton setTitle:@"" forState:UIControlStateNormal];
                [cell.inviteButton setImage:[UIImage imageNamed:@"roundadd"] forState:UIControlStateNormal];
            }
            
            
            cell.inviteButton.enabled = YES;
            
            cell.inviteButton.tag = ContactTableViewTag+3333+indexPath.row;
            
            if (fromClass)
            {
                [cell.inviteButton addTarget:self action:@selector(inviteFriend:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                [cell.inviteButton addTarget:self action:@selector(addFriendWithID:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            return cell;
        }
        else if(indexPath.section > 0)
        {
            static NSString *cellName = @"contactcell";
            FriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil)
            {
                cell = [[FriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            }
            DDLOG(@"current section %d",indexPath.section);
            if ([groupContactArray count] > 0)
            {
                NSDictionary *groupDict = [groupContactArray objectAtIndex:indexPath.section-1];
                NSArray *tmpArray = [groupDict objectForKey:@"array"];
                
                cell.nameLabel.frame = CGRectMake(10, 10, SCREEN_WIDTH - 80, 30);
                cell.nameLabel.font = [UIFont systemFontOfSize:16];
                
                NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
                cell.nameLabel.text = [dict objectForKey:@"name"];
                cell.inviteButton.frame = CGRectMake(SCREEN_WIDTH-50, 12.5, 27, 27);
                cell.inviteButton.backgroundColor = [UIColor clearColor];
                [cell.inviteButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
                cell.inviteButton.tag = indexPath.row+(ContactTableViewTag%tableViewTagBase)*tableViewTagBase+(indexPath.section-1)*10000;
                NSArray *array = [self getPhoneArrayFromContactDict:dict];
                for (int i=0; i<[array count]; ++i)
                {
                    if ([self haveThisPhone:[array objectAtIndex:i]])
                    {
                        [cell.inviteButton setImage:[UIImage imageNamed:@"selectBtn"] forState:UIControlStateNormal];
                    }
                    else
                    {
                        [cell.inviteButton setImage:[UIImage imageNamed:@"unselectBtn"] forState:UIControlStateNormal];
                    }
                }
                [cell.inviteButton addTarget:self action:@selector(inviteButtonCLick:) forControlEvents:UIControlEventTouchUpInside];
                CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
                UIImageView *lineImageView = [[UIImageView alloc] init];
                lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
                lineImageView.backgroundColor = LineBackGroudColor;
                [cell.contentView addSubview:lineImageView];
                cell.contentView.backgroundColor = [UIColor whiteColor];
            }
            return cell;
        }
    }
    else if(tableView.tag == SearchTableViewTag)
    {
        static NSString *cellName = @"searchcell";
        FriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil)
        {
            cell = [[FriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        DDLOG(@"current section %d",indexPath.section);
        cell.nameLabel.frame = CGRectMake(10, 10, SCREEN_WIDTH - 80, 30);
        cell.nameLabel.font = [UIFont systemFontOfSize:16];
            
        NSDictionary *dict = [searchResultArray objectAtIndex:indexPath.row];
        cell.nameLabel.text = [dict objectForKey:@"name"];
        cell.inviteButton.frame = CGRectMake(SCREEN_WIDTH-50, 12.5, 25, 25);
        cell.inviteButton.backgroundColor = [UIColor clearColor];
        [cell.inviteButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
        cell.inviteButton.tag = indexPath.row;
        NSArray *array = [self getPhoneArrayFromContactDict:dict];
        for (int i=0; i<[array count]; ++i)
        {
            if ([self haveThisPhone:[array objectAtIndex:i]])
            {
                [cell.inviteButton setImage:[UIImage imageNamed:@"selectBtn"] forState:UIControlStateNormal];
            }
            else
            {
                [cell.inviteButton setImage:[UIImage imageNamed:@"unselectBtn"] forState:UIControlStateNormal];
            }
        }
        [cell.inviteButton addTarget:self action:@selector(inviteSearchButtonCLick:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
        UIImageView *lineImageView = [[UIImageView alloc] init];
        lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
        [cell.contentView addSubview:lineImageView];
        lineImageView.backgroundColor = LineBackGroudColor;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        return cell;
    }
    return nil;
}

-(void)inviteFriendJoinClass:(UIButton *)button
{
    NSDictionary *dict = [friendsArry objectAtIndex:button.tag];
    if (fromClass)
    {
        [self sendMsgWithString:sendMsg andUserID:[dict objectForKey:@"_id"] andUserInfo:dict userType:@"friend"];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLOG(@"table view tag %d== %d",ContactTableViewTag-fromClassTableViewIndex,tableView.tag);
    if (tableView.tag == BanJiaFriendsTableViewTag)
    {
        if (indexPath.section == 0)
        {
            NSDictionary *dict = [friendsArry objectAtIndex:indexPath.row];
            if (![alreadyInviteFriendsArray containsObject:dict])
            {
                if (fromClass)
                {
                    [self sendMsgWithString:sendMsg andUserID:[dict objectForKey:@"_id"] andUserInfo:dict userType:@"friend"];
                }
            }
        }
    }
    else if (tableView.tag == ContactTableViewTag)
    {
        if (indexPath.section > 0)
        {
            NSDictionary *groupDict = [groupContactArray objectAtIndex:indexPath.section-1];
            NSArray *tmpArray = [groupDict objectForKey:@"array"];
            NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
            NSArray *homePhoneArray = [self getPhoneArrayFromContactDict:dict];
            for (int i=0; i<[homePhoneArray count]; ++i)
            {
                if ([self haveThisPhone:[homePhoneArray objectAtIndex:i]])
                {
                    [contactInviteArray removeObject:[homePhoneArray objectAtIndex:i]];
                }
                else
                {
                    [contactInviteArray addObject:[homePhoneArray objectAtIndex:i]];
                }
            }
            
            if ([addedContactArray containsObject:dict])
            {
                [addedContactArray removeObject:dict];
            }
            else
            {
                [addedContactArray addObject:dict];
            }
            [contactTableView reloadData];
        }
        else
        {
            NSDictionary *dict = [alreadyUsers objectAtIndex:indexPath.row];
            if (![selectedUsers containsObject:dict])
            {
                if (fromClass)
                {
                    [self sendMsgWithString:sendMsg andUserID:[dict objectForKey:@"_id"] andUserInfo:dict userType:@"contact"];
                }
                else
                {
                    [self addFriendWith:[dict objectForKey:@"_id"] andUserInfo:dict];
                }
                [selectedUsers addObject:dict];
                [contactTableView reloadData];
            }
        }
    }
    else if (tableView.tag == SearchTableViewTag)
    {
        NSDictionary *dict = [searchResultArray objectAtIndex:indexPath.row];
        NSArray *homePhoneArray = [self getPhoneArrayFromContactDict:dict];
        for (int i=0; i<[homePhoneArray count]; ++i)
        {
            if ([self haveThisPhone:[homePhoneArray objectAtIndex:i]])
            {
                [contactInviteArray removeObject:[homePhoneArray objectAtIndex:i]];
            }
            else
            {
                [contactInviteArray addObject:[homePhoneArray objectAtIndex:i]];
            }
        }
        
        if ([addedContactArray containsObject:dict])
        {
            [addedContactArray removeObject:dict];
        }
        else
        {
            [addedContactArray addObject:dict];
        }

        [contactTableView reloadData];
        [self cancelSearch];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSString *)nameInContacts:(NSString *)phoneNum
{
    for(NSDictionary *dict in allContacts)
    {
        if ([[Tools getPhoneNumFromString:[dict objectForKey:@"home_phone"]] rangeOfString:phoneNum].length > 0)
        {
            return [dict objectForKey:@"name"];
        }
    }
    return @"";
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!fromClass)
    {
        inviteButton.hidden = NO;
    }
    
    if (!fromClass)
    {
        if (scrollView.tag == 5000)
        {
            [UIView animateWithDuration:0.2 animations:^{
                
                if(scrollView.contentOffset.x/SCREEN_WIDTH == ContactTableViewTag%tableViewTagBase)
                {
                    inviteButton.hidden = NO;
                    [self getLocalContacts];
                }
                else if(scrollView.contentOffset.x/SCREEN_WIDTH == WeiXinTag%tableViewTagBase)
                {
                    inviteButton.hidden = YES;
                }
                
            }];
        }
    }
}

-(void)inviteSearchButtonCLick:(UIButton *)button
{
    NSDictionary *dict = [searchResultArray objectAtIndex:button.tag];
    NSArray *homePhoneArray = [self getPhoneArrayFromContactDict:dict];
    for (int i=0; i<[homePhoneArray count]; ++i)
    {
        if ([self haveThisPhone:[homePhoneArray objectAtIndex:i]])
        {
            [contactInviteArray removeObject:[homePhoneArray objectAtIndex:i]];
        }
        else
        {
            [contactInviteArray addObject:[homePhoneArray objectAtIndex:i]];
        }
    }
    if ([addedContactArray containsObject:dict])
    {
        [addedContactArray removeObject:dict];
    }
    else
    {
        [addedContactArray addObject:dict];
    }
    [searchTableView reloadData];
}


-(void)inviteButtonCLick:(UIButton *)button
{
   if(button.tag/tableViewTagBase == (ContactTableViewTag%tableViewTagBase))
    {
        NSDictionary *groupDict = [groupContactArray objectAtIndex:(button.tag -(ContactTableViewTag%tableViewTagBase)*tableViewTagBase)/10000];
        NSArray *tmpArray = [groupDict objectForKey:@"array"];
        NSDictionary *dict = [tmpArray objectAtIndex:(button.tag -(ContactTableViewTag%tableViewTagBase)*tableViewTagBase)%10000];
        NSArray *homePhoneArray = [self getPhoneArrayFromContactDict:dict];
        for (int i=0; i<[homePhoneArray count]; ++i)
        {
            if ([self haveThisPhone:[homePhoneArray objectAtIndex:i]])
            {
                [contactInviteArray removeObject:[homePhoneArray objectAtIndex:i]];
            }
            else
            {
                [contactInviteArray addObject:[homePhoneArray objectAtIndex:i]];
            }
        }
        
        if ([addedContactArray containsObject:dict])
        {
            [addedContactArray removeObject:dict];
        }
        else
        {
            [addedContactArray addObject:dict];
        }
        [contactTableView reloadData];
    }
}

-(NSArray *)getPhoneArrayFromContactDict:(NSDictionary *)dict
{
    NSMutableString *phonesStr = [[NSMutableString alloc] initWithCapacity:0];
    [phonesStr insertString:[dict objectForKey:@"home_phone"] atIndex:[phonesStr length]];
    
    NSArray *charArray = @[@"(",@")",@"-",@" "];
    
    for (int i=0; i<[charArray count]; ++i)
    {
        NSRange range1 = [phonesStr rangeOfString:[charArray objectAtIndex:i]];
        while (range1.location != NSNotFound)
        {
            [phonesStr deleteCharactersInRange:range1];
            range1 = [phonesStr rangeOfString:[charArray objectAtIndex:i]];
        }
        
    }
    NSArray *homePhoneArray = [phonesStr componentsSeparatedByString:@","];
    return homePhoneArray;
}

-(BOOL)haveThisPhone:(NSString *)phoneStr
{
    if ([contactInviteArray containsObject:phoneStr])
        return YES;
    else
        return NO;
}



-(void)buttonClick:(UIButton *)button
{
    [UIView animateWithDuration:0.2 animations:^{
        
    }];
    for (int i = 0; i < [iconArray count]; i++)
    {
        if (i == button.tag - tableViewTagBase)
        {
            [((UIButton *)[buttonScrollView viewWithTag:i+tableViewTagBase]) setImage:[UIImage imageNamed:[iconOnArray objectAtIndex:i]] forState:UIControlStateNormal];
        }
        else
        {
            [((UIButton *)[buttonScrollView viewWithTag:i+tableViewTagBase]) setImage:[UIImage imageNamed:[iconArray objectAtIndex:i]] forState:UIControlStateNormal];
        }
    }
    
    [contactInviteArray removeAllObjects];
    if(button.tag == ContactTableViewTag-fromClassTableViewIndex)
    {
        inviteButton.hidden = NO;
        if (!([contactArray count] > 0 || [alreadyUsers count] >0))
        {
            [self getLocalContacts];
        }
    }
    else
    {
        inviteButton.hidden = YES;
    }
    [UIView animateWithDuration:0.2 animations:^{
        if (fromClass)
        {
            if (button.tag == tableViewTagBase+1)
            {
                buttonScrollView.contentOffset = CGPointMake(0, 0);
            }
            else if(button.tag == tableViewTagBase + 2)
            {
                buttonScrollView.contentOffset = CGPointMake(100, 0);
            }
        }
        bgScrollView.contentOffset = CGPointMake((button.tag%tableViewTagBase)*SCREEN_WIDTH, 0);
    }];
    
}

#pragma mark - 获取本地通讯录
-(void)getLocalContacts
{
    
    //获取通讯录权限
    ABAddressBookRef tmpAddressBook = NULL;
    // ABAddressBookCreateWithOptions is iOS 6 and up.
    if (&ABAddressBookCreateWithOptions)
    {
        CFErrorRef error = nil;
        tmpAddressBook = ABAddressBookCreateWithOptions(NULL, &error);
        
        if (error)
        {
            NSLog(@"%@", error);
        }
    }
    if (tmpAddressBook == NULL)
    {
        tmpAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"允许访问通讯录" message:@"请到 手机设置->隐私->通讯录中，允许班家访问你的通讯录" delegate:nil cancelButtonTitle:@"好的，明白了" otherButtonTitles: nil];
        [al show];
        return ;
    }
    if (tmpAddressBook)
    {
        [Tools showProgress:contactTableView];
        // ABAddressBookRequestAccessWithCompletion is iOS 6 and up. 适配IOS6以上版本
        if (&ABAddressBookRequestAccessWithCompletion)
        {
            ABAddressBookRequestAccessWithCompletion(tmpAddressBook,
                                                     ^(bool granted, CFErrorRef error)
            {
                                                         if (granted)
                                                         {
                                                             
                                                             // constructInThread: will CFRelease ab.
                                                             [NSThread detachNewThreadSelector:@selector(constructInThread:)
                                                                                      toTarget:self
                                                                                    withObject:CFBridgingRelease(tmpAddressBook)];
                                                         }
                                                         else
                                                         {
                                                             //                                                             CFRelease(ab);
                                                             // Ignore the error
                                                         }
                                                        });
        }
        else
        {
            // constructInThread: will CFRelease ab.
            [NSThread detachNewThreadSelector:@selector(constructInThread:)
                                     toTarget:self
                                   withObject:CFBridgingRelease(tmpAddressBook)];
        }
    }
}
-(void)constructInThread:(ABAddressBookRef) ab
{
    [contactArray removeAllObjects];
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(ab);
    for(int i = 0; i < CFArrayGetCount(results); i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        NSString *firstName = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastname = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        //读取电话多值
        NSString* phoneString1 = @"";
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            //获取該Label下的电话值
            NSString * personPhone = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(phone, k));
            phoneString1 = [phoneString1 stringByAppendingFormat:@",%@",personPhone];
            personPhone = nil;
        }
        CFRelease(phone);
        
        NSString *phoneString = [phoneString1 length]>0?[phoneString1 substringFromIndex:1]:@"";
        //构造字典
        NSDictionary* dic = @{@"name":[NSString stringWithFormat:@"%@%@",lastname?lastname:@"", firstName?firstName:@"" ],
                              @"home_phone": phoneString?phoneString:[NSNull null],
                              };
        [contactArray addObject:dic];
    }
    NSArray *tmpArray = [Tools getSpellSortArrayFromChineseArray:contactArray andKey:@"name"];
    [groupContactArray addObjectsFromArray:tmpArray];
    [contactTableView reloadData];
    if ([Tools NetworkReachable])
    {
        [self checkContacts:contactArray];
    }
    else
    {
        [Tools hideProgress:contactTableView];
    }
    
    CFRelease(results);
}

-(NSString *)getPhonesString:(NSString *)phonesString
{
    NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *phoneArray = [phonesString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\","]];
    for(NSString *phoneStr in phoneArray)
    {
        NSMutableString *num = [[NSMutableString alloc] initWithString:phoneStr];
        [num replaceOccurrencesOfString:@" " withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [num length])];
        [num replaceOccurrencesOfString:@"-" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [num length])];
        if ([num rangeOfString:@"("].length > 0)
        {
            [num deleteCharactersInRange:[num rangeOfString:@"("]];
        }
        if ([num rangeOfString:@")"].length > 0)
        {
            [num deleteCharactersInRange:[num rangeOfString:@")"]];
        }
        // && ![num isEqualToString:[[Tools myNumber] substringFromIndex:3]]
        if ([Tools isPhoneNumber:num])
        {
            [tmpArray addObject:num];
        }
    }
    return [NSString stringWithFormat:@"%@",tmpArray];
}

-(void)checkContacts:(NSArray *)array
{
    [allContacts addObjectsFromArray:array];
    if ([array count] == 0)
    {
        [Tools showTips:@"没有任何联系人信息" toView:contactTableView];
        return ;
    }
    if ([Tools NetworkReachable])
    {
        NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i=0; i<[array count]; ++i)
        {
            NSString *home_phone = [[array objectAtIndex:i] objectForKey:@"home_phone"];
            NSArray *phoneArray = [home_phone componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\","]];
            for(NSString *phoneStr in phoneArray)
            {
                NSMutableString *num = [[NSMutableString alloc] initWithString:phoneStr];
                [num replaceOccurrencesOfString:@" " withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [num length])];
                [num replaceOccurrencesOfString:@"-" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [num length])];
                if ([num rangeOfString:@"("].length > 0)
                {
                    [num deleteCharactersInRange:[num rangeOfString:@"("]];
                }
                if ([num rangeOfString:@")"].length > 0)
                {
                    [num deleteCharactersInRange:[num rangeOfString:@")"]];
                }
                if ([num rangeOfString:@" "].length > 0)
                {
                    [num replaceOccurrencesOfString:@" " withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [num length])];
                }
                if ([Tools isPhoneNumber:num])
                {
                    [tmpArray addObject:num];
                }
            }
        }
        NSMutableString *tmpStr = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@",tmpArray]];
        [tmpStr replaceOccurrencesOfString:@"\"" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [tmpStr length])];
        [tmpStr replaceOccurrencesOfString:@"{" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [tmpStr length])];
        [tmpStr replaceOccurrencesOfString:@"}" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [tmpStr length])];
        [tmpStr replaceOccurrencesOfString:@" " withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [tmpStr length])];
        [tmpStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [tmpStr length])];
        DDLOG(@"tmpstr length=%d",[tmpStr length]);
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"contacts":[tmpStr substringWithRange:NSMakeRange(1, [tmpStr length]-2)]
                                                                      } API:CHECKCONTACTS];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"checkcontact responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [groupContactArray removeAllObjects];
                [alreadyUsers addObjectsFromArray:[[responseDict objectForKey:@"data"] allObjects]];
                
                for (int i = 0; i < [alreadyUsers count]; ++i)
                {
                    NSDictionary *alreadyDict = [alreadyUsers objectAtIndex:i];
                    NSString *alreadyPhone = [alreadyDict objectForKey:@"phone"];
                    for (int j=0; j<[contactArray count]; j++)
                    {
                        NSDictionary *contactDict = [contactArray objectAtIndex:j];
                        NSString *contactPhone = [Tools getPhoneNumFromString:[contactDict objectForKey:@"home_phone"]];
                        if ([contactPhone rangeOfString:alreadyPhone].length > 0)
                        {
                            [contactArray removeObjectAtIndex:j];
                        }
                    }
                }
                
                if (fromClass)
                {
                    DDLOG(@"uid %@",[Tools user_id]);
                    
                    NSMutableArray *waitRemoveArray = [[NSMutableArray alloc] initWithCapacity:0];
                    
                    for (int i=0; i<[alreadyUsers count]; i++)
                    {
                        NSDictionary *alreadyDict = [alreadyUsers objectAtIndex:i];
                        if ([[db findSetWithDictionary:@{@"classid":classID,@"uid":[alreadyDict objectForKey:@"_id"]} andTableName:CLASSMEMBERTABLE] count] > 0)
                        {
                            [waitRemoveArray addObject:alreadyDict];
                        }
                    }
                    
                    for (int i=0; i<[waitRemoveArray count]; i++)
                    {
                        NSDictionary *alreadyDict = [waitRemoveArray objectAtIndex:i];
                        [alreadyUsers removeObject:alreadyDict];
                    }
                }
                else
                {
                    NSMutableArray *waitRemoveArray = [[NSMutableArray alloc] initWithCapacity:0];
                    
                    for (int i=0; i<[alreadyUsers count]; i++)
                    {
                        NSDictionary *alreadyDict = [alreadyUsers objectAtIndex:i];
                        if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"fid":[alreadyDict objectForKey:@"_id"]} andTableName:FRIENDSTABLE] count] > 0)
                        {
                            [waitRemoveArray addObject:alreadyDict];
                        }
                        else if([[alreadyDict objectForKey:@"_id"] isKindOfClass:[NSString class]] && [[alreadyDict objectForKey:@"_id"] isEqualToString:[Tools user_id]])
                        {
                            [waitRemoveArray addObject:alreadyDict];
                        }
                    }
                    
                    for (int i=0; i<[waitRemoveArray count]; i++)
                    {
                        NSDictionary *alreadyDict = [waitRemoveArray objectAtIndex:i];
                        [alreadyUsers removeObject:alreadyDict];
                    }
                }
                
                NSArray *tmpArray = [Tools getSpellSortArrayFromChineseArray:contactArray andKey:@"name"];
                [groupContactArray addObjectsFromArray:tmpArray];
                [contactTableView reloadData];
                [Tools hideProgress:contactTableView];
                
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            [Tools hideProgress:contactTableView];
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools hideProgress:contactTableView];
        }];
        [request startAsynchronous];
    }
}

-(NSString *)getNameWithPhone:(NSString *)phoneStr
{
    for (int i=0; i<[contactArray count]; i++)
    {
        NSString *tmpPhoneStr = [[contactArray objectAtIndex:i] objectForKey:@"home_phone"];
        if ([[self getPhonesString:tmpPhoneStr] rangeOfString:phoneStr].length > 0)
        {
            return  [[contactArray objectAtIndex:i] objectForKey:@"name"];
        }
    }
    return @"";
}

#pragma mark - inviteQQFriends
/**
 *	@brief	分享给QQ好友
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToQQFriendClickHandler:(UIButton *)sender
{
    //创建分享内容
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    
    NSString *msgBody;
    if (fromClass)
    {
        NSMutableString *inviteBody = [[NSMutableString alloc] initWithString:InviteClassMember];
        
        NSString *classNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"classnum"];
        [inviteBody replaceOccurrencesOfString:@"#school-" withString:[schoolName length] > 0?[NSString stringWithFormat:@"%@-",schoolName]:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
        if ([classNum length] > 0)
        {
            [inviteBody replaceOccurrencesOfString:@"#class" withString:[NSString stringWithFormat:@"%@(班号:%@)",className,classNum] options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
        }
        else
        {
            [inviteBody replaceOccurrencesOfString:@"#class" withString:className options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
        }

        
        msgBody = inviteBody;
    }
    else
    {
        msgBody = ShareContent;
    }
    
    id<ISSContent> publishContent = [ShareSDK content:msgBody
                                       defaultContent:@""
                                                image:[ShareSDK jpegImageWithImage:[UIImage imageNamed:@"logo120"] quality:1]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:nil
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
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     [DealJiFen dealJiFenWithID:QQBASE64];
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                 }
                             }];
}


#pragma mark - inviteWeiXin
- (void)inviteWeiXin
{
    // 发送内容给微信
    Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
    memset(pBuffer, 0, BUFFER_SIZE);
    NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
    free(pBuffer);
    
    
    
    NSMutableString *inviteBody;
    if (fromClass)
    {
        inviteBody = [[NSMutableString alloc] initWithString:InviteClassMember];
        [inviteBody replaceOccurrencesOfString:@"#school-" withString:[schoolName length] > 0?[NSString stringWithFormat:@"%@-",schoolName]:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
        NSString *classNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"classnum"];
        if ([classNum length] > 0)
        {
            [inviteBody replaceOccurrencesOfString:@"#class" withString:[NSString stringWithFormat:@"%@(班号:%@)",className,classNum] options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
        }
        else
        {
            [inviteBody replaceOccurrencesOfString:@"#class" withString:className options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
        }
        
    }
    else
    {
        inviteBody = ShareContent;
    }
    
    id<ISSContent> content = [ShareSDK content:inviteBody
                                defaultContent:inviteBody
                                         image:[ShareSDK jpegImageWithImage:[UIImage imageNamed:@"logo120"] quality:1]
                                         title:NSLocalizedString(@"班家", @"这是App消息")
                                           url:ShareUrl
                                   description:inviteBody
                                     mediaType:SSPublishContentMediaTypeNews];
    [content addWeixinSessionUnitWithType:INHERIT_VALUE
                                  content:inviteBody
                                    title:INHERIT_VALUE
                                      url:INHERIT_VALUE
                                    image:INHERIT_VALUE
                             musicFileUrl:nil
                                  extInfo:@""
                                 fileData:data
                             emoticonData:nil];
    
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
    
    [ShareSDK shareContent:content
                      type:ShareTypeWeixiSession
               authOptions:authOptions
             statusBarTips:YES
                    result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                        
                        if (state == SSPublishContentStateSuccess)
                        {
                            [DealJiFen dealJiFenWithID:WXBASE64];
                        }
                        else if (state == SSPublishContentStateFail)
                        {
                            if ([error errorCode] == -22003)
                            {
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TEXT_TIPS", @"提示")
                                                                                    message:[error errorDescription]
                                                                                   delegate:nil
                                                                          cancelButtonTitle:NSLocalizedString(@"TEXT_KNOW", @"知道了")
                                                                          otherButtonTitles:nil];
                                [alertView show];
                            }
                        }
                    }];
}

//-(void) onCancelText
//{
//    [self.parentController dismissModalViewControllerAnimated:YES];
//}

#pragma  mark - showmsg
-(void)showMessageView
{
    if( [MFMessageComposeViewController canSendText] ){
        
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init]; //autorelease];
        
        controller.recipients = contactInviteArray;
        
        NSString *msgBody;
        if (fromClass)
        {
            NSMutableString *inviteBody = [[NSMutableString alloc] initWithString:InviteClassMember];
            
            DDLOG(@"InviteClassMember==%@",inviteBody);
            NSString *classNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"classnum"];
            
            [inviteBody replaceOccurrencesOfString:@"#school-" withString:[schoolName length] > 0?[NSString stringWithFormat:@"%@-",schoolName]:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
            if ([classNum length] > 0)
            {
                [inviteBody replaceOccurrencesOfString:@"#class" withString:[NSString stringWithFormat:@"%@(班号:%@)",className,classNum] options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
            }
            else
            {
                [inviteBody replaceOccurrencesOfString:@"#class" withString:className options:NSRegularExpressionSearch range:NSMakeRange(0, [inviteBody length])];
            }
            
            msgBody = inviteBody;
        }
        else
        {
            msgBody = ShareContent;
        }
        controller.body = msgBody;
        controller.messageComposeDelegate = self;
        
        [self presentViewController:controller animated:YES completion:nil];
        
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:@"测试短信"];//修改短信界面标题
    }else{
        [self alertWithTitle:@"提示信息" msg:@"设备没有短信功能"];
    }
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    [controller dismissViewControllerAnimated:NO completion:nil];
    
    switch ( result ) {
            
        case MessageComposeResultCancelled:
            
            [self alertWithTitle:@"提示信息" msg:@"发送取消"];
            break;
        case MessageComposeResultFailed:// send failed
            [self alertWithTitle:@"提示信息" msg:@"发送失败"];
            break;
        case MessageComposeResultSent:
        {
            [self alertWithTitle:@"提示信息" msg:@"发送成功"];
            [DealJiFen dealJiFenWithPhones:contactInviteArray];
            break;
        }
        default:
            break;
    }
}

- (void) alertWithTitle:(NSString *)title msg:(NSString *)msg {
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定", nil];
    
    [alert show];
    
}

#pragma mark - inviteClick
-(void)inviteClick
{
    if (bgScrollView.contentOffset.x/SCREEN_WIDTH == (ContactTableViewTag-fromClassTableViewIndex)%tableViewTagBase)
    {
        [self showMessageView];
    }
}

#pragma mark - addFriend
-(void)inviteFriend:(UIButton *)button
{
    NSDictionary *dict = [alreadyUsers objectAtIndex:button.tag-ContactTableViewTag-3333];
    if (![selectedUsers containsObject:dict])
    {
        [self sendMsgWithString:sendMsg andUserID:[dict objectForKey:@"_id"] andUserInfo:dict userType:@"contact"];
        [selectedUsers addObject:dict];
        [contactTableView reloadData];
    }
}


#pragma mark - sendmsg
-(void)sendMsgWithString:(NSString *)msgContent andUserID:(NSString *)uid andUserInfo:(NSDictionary *)userInfo userType:(NSString *)userType
{
    if ([Tools NetworkReachable])
    {
        
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"t_id":uid,
                                                                      @"content":msgContent
                                                                      } API:CREATE_CHAT_MSG];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"chat responsedict %@",responseString);
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
                [chatDict setObject:uid forKey:@"tid"];
                [chatDict setObject:@"1" forKey:@"readed"];
                if ([[db findSetWithKey:@"mid" andValue:messageID andTableName:@"chatMsg"] count] <= 0)
                {
                    [db insertRecord:chatDict andTableName:@"chatMsg"];
                }
                
                
                if ([userType isEqualToString:@"friend"])
                {
                    [Tools showAlertView:[NSString stringWithFormat:@"您已经成功邀请%@",[userInfo objectForKey:@"name"]] delegateViewController:nil];
                    [alreadyInviteFriendsArray addObject:userInfo];
                    [friendsTableView reloadData];
                }
                else
                {
                    [Tools showAlertView:[NSString stringWithFormat:@"您已经成功邀请%@",[userInfo objectForKey:@"r_name"]] delegateViewController:nil];
                    [alreadyInviteFriendsArray addObject:userInfo];
                    [contactTableView reloadData];
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



-(void)addFriendWithID:(UIButton *)button
{
    NSDictionary *dict = [alreadyUsers objectAtIndex:button.tag-ContactTableViewTag-3333];
    if (![selectedUsers containsObject:dict])
    {
        [self addFriendWith:[dict objectForKey:@"_id"] andUserInfo:dict];
        [selectedUsers addObject:dict];
        [contactTableView reloadData];
    }
}
-(void)addFriendWith:(NSString *)uid andUserInfo:(NSDictionary *)userInfo
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"f_id":uid
                                                                      } API:MB_APPLY_FRIEND];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"memberByClass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showAlertView:@"请求已申请，请等待对方答复！" delegateViewController:self];
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

#pragma mark - getFriendList
-(void)getFriendList
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token]                                                                     } API:MB_FRIENDLIST];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"friendsList responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if (![[responseDict objectForKey:@"data"] isEqual:[NSNull null]])
                {
                    if (fromClass)
                    {
                        NSArray *tmpArray = [responseDict objectForKey:@"data"];
                        for (NSDictionary *dict in tmpArray)
                        {
                            if ([[dict objectForKey:@"cgroup"] intValue] == 0)
                            {
                                if ([[db findSetWithDictionary:@{@"classid":classID,@"uid":[dict objectForKey:@"_id"]} andTableName:CLASSMEMBERTABLE] count] > 0)
                                {
                                    [thisClassFriednsArray addObject:dict];
                                }
                                else
                                {
                                    if (![[dict objectForKey:@"_id"] isEqualToString:OurTeamID] && ![[dict objectForKey:@"_id"] isEqualToString:AssistantID])
                                    {
                                        [friendsArry addObject:dict];
                                    }
                                }
                            }
                        }
                        [friendsTableView reloadData];
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
        }];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}
@end
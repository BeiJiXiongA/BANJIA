//
//  PersonalSettingViewController.m
//  School
//
//  Created by TeekerZW on 1/14/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "PersonalSettingViewController.h"
#import "XDContentViewController+JDSideMenu.h"
#import "Header.h"
#include "WelcomeViewController.h"
#import "PersonalSettingCell.h"
#import "AuthCell.h"
#import "PersonInfoSettingViewController.h"
#import "AuthViewController.h"
#import "RelatedCell.h"
#import "LogOutCell.h"
#import "AppDelegate.h"
#import "SettingViewController.h"
#import "ChangePhoneViewController.h"
#import "UINavigationController+JDSideMenu.h"
#import "ClassPlusAccountViewController.h"
#import "ResetPwdViewController.h"


@interface PersonalSettingViewController ()<UITableViewDataSource,
UITableViewDelegate,
ChatDelegate,
MsgDelegate,
UITextFieldDelegate,
ChangePhoneNum,
UIAlertViewDelegate,
UIActionSheetDelegate,
AuthImageDone,
ShareContentDelegate>
{
    UITableView *personalSettiongTableView;
    BOOL isAuth;
    NSMutableDictionary *userInfoDict;
    NSArray *tmpArray;
    BOOL authenticated;
    
    NSDictionary *accountDict;
    
    NSString *qqNickName;
    NSString *sinaNickName;
    NSString *rrNickName;
    NSString *wxNickName;
    
    int gf;
    NSString *banjiaNumber;
    NSString *reg_method;
}
@end

@implementation PersonalSettingViewController

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
    
    isAuth = YES;
    
    qqNickName = @"";
    rrNickName = @"";
    sinaNickName = @"";
    wxNickName = @"";
    
    gf = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeIcon) name:@"changeicon" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillAppear:) name:RELOAD_MENU_BUTTON object:nil];
    
    userInfoDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    self.titleLabel.text = @"个人信息";
    [[self.bgView layer] setShadowOffset:CGSizeMake(-5.0f, 0.0f)];
    [[self.bgView layer] setShadowColor:[UIColor darkGrayColor].CGColor];
    [[self.bgView layer] setShadowOpacity:1.0f];
    [[self.bgView layer] setShadowRadius:3.0f];
    self.returnImageView.hidden = YES;
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = self;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = self;
    
    UIButton *setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [setButton setTitle:@"设置" forState:UIControlStateNormal];
    [setButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    setButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [setButton addTarget:self action:@selector(settingClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationBarView addSubview:setButton];
    
    [self.backButton setHidden:YES];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(5, self.backButton.frame.origin.y, 42, NAV_RIGHT_BUTTON_HEIGHT);;
    [moreButton setImage:[UIImage imageNamed:@"icon_list"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreOpen) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:moreButton];
    
    UIView *tableViewBg = [[UIView alloc] initWithFrame:self.bgView.frame];
    [tableViewBg setBackgroundColor:UIColorFromRGB(0xf1f0ec)];
    
    personalSettiongTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    personalSettiongTableView.delegate = self;
    personalSettiongTableView.backgroundView = tableViewBg;
    personalSettiongTableView.backgroundColor = [UIColor whiteColor];
    personalSettiongTableView.dataSource = self;
    personalSettiongTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if ([personalSettiongTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [personalSettiongTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    [self.bgView addSubview:personalSettiongTableView];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [shareButton setTitle:@"分享" forState:UIControlStateNormal];
    [shareButton setTitleColor:RightCornerTitleColor forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareAPP:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:shareButton];
    
    [self getData];
}

-(void)getData
{
    [self getAccount];
    [self getUserInfo];
}

-(void)changeIcon
{
    [personalSettiongTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self haveNewMsg] || [self haveNewNotice])
    {
        self.unReadLabel.hidden = NO;
    }
    else
    {
        self.unReadLabel.hidden = YES;
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RELOAD_MENU_BUTTON object:nil];
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = nil;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).msgDelegate = nil;
}


#pragma mark - chatdelegate
-(void)dealNewChatMsg:(NSDictionary *)dict
{
    if ([[Tools user_id] length] == 0)
    {
        return ;
    }
    if ([self haveNewMsg] || [self haveNewNotice])
    {
        self.unReadLabel.hidden = NO;
    }
    else
    {
        self.unReadLabel.hidden = YES;
    }
}

-(void)dealNewMsg:(NSDictionary *)dict
{
    if ([[Tools user_id] length] == 0)
    {
        return ;
    }
    if ([self haveNewMsg] || [self haveNewNotice])
    {
        self.unReadLabel.hidden = NO;
    }
    else
    {
        self.unReadLabel.hidden = YES;
    }
}

-(BOOL)haveNewMsg
{
    OperatDB *db = [[OperatDB alloc] init];
    NSArray *msgArray = [db findSetWithDictionary:@{@"readed":@"0",@"userid":[Tools user_id]} andTableName:CHATTABLE];
    NSArray *friendsArray  =[db findSetWithDictionary:@{@"checked":@"0",@"uid":[Tools user_id]} andTableName:FRIENDSTABLE];
    if ([msgArray count] > 0 || [friendsArray count] > 0 ||
        [[[NSUserDefaults standardUserDefaults] objectForKey:NewChatMsgNum] integerValue]>0 ||
        [[[NSUserDefaults standardUserDefaults] objectForKey:NewClassNum] integerValue]>0 ||
        [[[NSUserDefaults standardUserDefaults] objectForKey:UCFRIENDSUM] integerValue] > 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    return NO;
}
-(BOOL)haveNewNotice
{
    OperatDB *db = [[OperatDB alloc] init];
    NSMutableArray *array = [db findSetWithDictionary:@{@"readed":@"0",@"uid":[Tools user_id],@"type":@"f_apply"} andTableName:@"notice"];
    if ([array count] > 0)
    {
        return YES;
    }
    return NO;
}

-(void)settingClick
{
    SettingViewController *setting = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:setting animated:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - tableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH, 10)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont systemFontOfSize:16];
    headerLabel.backgroundColor = [UIColor clearColor];
    return headerLabel;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1 || section == 2)
    {
        return 25;
    }
    else if(section == 0)
    {
        return 20;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else if(section == 1)
    {
        return 4;
    }
    else if (section == 2)
    {
        return 3;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 90;
    }
    else if(indexPath.section == 1)
    {
        return 60;
    }
    else if (indexPath.section == 2)
    {
        if (isAuth)
        {
            if (indexPath.row == 1)
            {
                return 0;
            }
        }
        if (indexPath.row == 0 && [[Tools phone_num] length] == 0)
        {
            return 0;
        }
        return 47;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            static NSString *firstCell = @"firstCell";
            PersonalSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:firstCell];
            if (cell == nil)
            {
                cell = [[PersonalSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:firstCell];
            }
            NSString *userName = [Tools user_name];
            CGFloat nameLength = ([userName length]*18>(SCREEN_WIDTH-130))?(SCREEN_WIDTH-130):([userName length]*18);
            cell.nameLabel.frame = CGRectMake(85, 25, nameLength, 20);
            cell.nameLabel.text = userName;
            cell.nameLabel.font = [UIFont systemFontOfSize:18];
            cell.nameLabel.textColor = USER_NAME_COLOR;
            
            cell.objectsLabel.frame = CGRectMake(85, 50, 200, 20);
            cell.objectsLabel.textColor = TITLE_COLOR;
            cell.objectsLabel.font = [UIFont systemFontOfSize:15];
            cell.objectsLabel.text = [NSString stringWithFormat:@"用户ID:%@",[Tools banjia_num]];
        
            cell.headerImageView.layer.cornerRadius = 5;
            cell.headerImageView.clipsToBounds = YES;
            cell.headerImageView.frame = CGRectMake(15, 15, 60, 60);
            
            [Tools fillImageView:cell.headerImageView withImageFromURL:[Tools header_image] andDefault:HEADERICON];
            
            cell.authenticationSign.frame = CGRectMake(cell.nameLabel.frame.origin.x+cell.nameLabel.frame.size.width+3, cell.nameLabel.frame.origin.y-7, 15, 15);
            
            if ([accountDict objectForKey:@"t_checked"])
            {
                [cell.authenticationSign setImage:[UIImage imageNamed:@"auth"]];
            }
            
            cell.arrowImageView.hidden = NO;
            [cell.arrowImageView setFrame:CGRectMake(SCREEN_WIDTH-20, 37.5, 10, 15)];
            [cell.arrowImageView setImage:[UIImage imageNamed:@"menu_arrow_right"]];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.backgroundColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
            UIImageView *lineImageView = [[UIImageView alloc] init];
            lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
            lineImageView.backgroundColor = LineBackGroudColor;
            [cell.contentView addSubview:lineImageView];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            return cell;
        }
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            static NSString *authcell = @"section0";
            PersonalSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:authcell];
            if (cell == nil)
            {
                cell = [[PersonalSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:authcell];
            }
            cell.nameLabel.font = [UIFont systemFontOfSize:18];
            cell.nameLabel.textAlignment = NSTextAlignmentLeft;
            cell.nameLabel.frame = CGRectMake(60, 15, 100, 30);
            cell.nameLabel.textColor = CONTENTCOLOR;
            
            cell.headerImageView.frame = CGRectMake(10, 10, 40, 40);
            cell.headerImageView.layer.cornerRadius = 3;
            cell.headerImageView.clipsToBounds = YES;
            [cell.headerImageView setImage:[UIImage imageNamed:@"invite_phone_on"]];
            
            if ([Tools phone_num])
            {
                cell.nameLabel.text = [NSString stringWithFormat:@"手机账号"];
            }
            else
            {
                cell.nameLabel.text = [NSString stringWithFormat:@"绑定手机"];
                cell.textLabel.textColor = TITLE_COLOR;
            }
            
            if ([[Tools phone_num] length] > 0)
            {
                cell.objectsLabel.frame = CGRectMake(SCREEN_WIDTH-130, 15, 134, 30);
                cell.objectsLabel.text = [Tools phone_num];
                cell.objectsLabel.font = [UIFont systemFontOfSize:18];
                cell.arrowImageView.hidden = YES;
            }
            else
            {
                cell.objectsLabel.frame = CGRectMake(SCREEN_WIDTH-96, 15, 80, 30);
                cell.objectsLabel.text = @"绑定手机";
                cell.objectsLabel.font = [UIFont systemFontOfSize:16];
                cell.arrowImageView.hidden = NO;
                [cell.arrowImageView setFrame:CGRectMake(SCREEN_WIDTH-20, 22.5, 10, 15)];
                [cell.arrowImageView setImage:[UIImage imageNamed:@"menu_arrow_right"]];
            }
            
            cell.objectsLabel.textColor = TITLE_COLOR;
            
            
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.backgroundColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
            UIImageView *lineImageView = [[UIImageView alloc] init];
            lineImageView.frame = CGRectMake(60, cellHeight-0.5, cell.frame.size.width, 0.5);
            lineImageView.backgroundColor = LineBackGroudColor;
            [cell.contentView addSubview:lineImageView];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            return cell;
        }
        else
        {
            static NSString *relateCell = @"relateCell";
            RelatedCell *cell = [tableView dequeueReusableCellWithIdentifier:relateCell];
            if (cell == nil)
            {
                cell = [[RelatedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:relateCell];
            }
            cell.relateButton.tag = indexPath.row+1000;
            cell.relateButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            cell.relateButton.frame = CGRectMake(SCREEN_WIDTH-85, 17, 60, 26);
            cell.nametf.frame = CGRectMake(60, 15, 170, 30);
            cell.relateButton.titleLabel.font = [UIFont systemFontOfSize:16];
            [cell.relateButton setTitle:@"" forState:UIControlStateNormal];
            [cell.relateButton setTitleColor:COMMENTCOLOR forState:UIControlStateNormal];
            cell.nametf.frame = CGRectMake(SCREEN_WIDTH-150, 17, 120, 26);
    
            cell.arrowImageView.hidden = NO;
            [cell.arrowImageView setFrame:CGRectMake(SCREEN_WIDTH-20, 22.5, 10, 15)];
            [cell.arrowImageView setImage:[UIImage imageNamed:@"menu_arrow_right"]];
            
            CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
            UIImageView *lineImageView = [[UIImageView alloc] init];
            lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
            lineImageView.backgroundColor = LineBackGroudColor;
            [cell.contentView addSubview:lineImageView];
            
            if (indexPath.row == 3)
            {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:QQNICKNAME] length] >0)
                {
                    cell.contentLabel.text = [NSString stringWithFormat:@"QQ账号(%@)",[[NSUserDefaults standardUserDefaults] objectForKey:QQNICKNAME]];
                    cell.nametf.frame = CGRectMake(SCREEN_WIDTH - 150, 17, 120, 26);
                    cell.nametf.text = @"";
                    [cell.relateButton removeTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton setTitle:@"解绑" forState:UIControlStateNormal];
                    [cell.relateButton addTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                }
                else
                {
                    cell.contentLabel.text = [NSString stringWithFormat:@"QQ账号"];
                    [cell.relateButton removeTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton setTitle:@"绑定" forState:UIControlStateNormal];
                }
                lineImageView.frame = CGRectMake(60, cellHeight-0.5, cell.frame.size.width, 0.5);
                [cell.iconImageView setImage:[UIImage imageNamed:@"QQicon"]];
            }
            else if(indexPath.row == 2)
            {
                
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:SINANICKNAME] length] >0)
                {
                    cell.contentLabel.text = [NSString stringWithFormat:@"新浪账号(%@)",[[NSUserDefaults standardUserDefaults] objectForKey:SINANICKNAME]];
                    cell.nametf.frame = CGRectMake(SCREEN_WIDTH - 150, 17, 120, 26);
                    cell.nametf.text = @"";
                    [cell.relateButton removeTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton setTitle:@"解绑" forState:UIControlStateNormal];
                    [cell.relateButton addTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                }
                else
                {
                    cell.contentLabel.text = [NSString stringWithFormat:@"新浪账号"];
                    [cell.relateButton removeTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton setTitle:@"绑定" forState:UIControlStateNormal];
                }
                lineImageView.frame = CGRectMake(60, cellHeight-0.5, cell.frame.size.width, 0.5);
                [cell.iconImageView setImage:[UIImage imageNamed:@"sinaicon"]];
            }
            else if(indexPath.row == 1)
            {
                
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:WXNICKNAME] length] >0)
                {
                    cell.contentLabel.text = [NSString stringWithFormat:@"微信账号(%@)",[[NSUserDefaults standardUserDefaults] objectForKey:WXNICKNAME]];
                    cell.nametf.frame = CGRectMake(SCREEN_WIDTH - 150, 17, 120, 26);
                    cell.nametf.text = @"";
                    [cell.relateButton removeTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton setTitle:@"解绑" forState:UIControlStateNormal];
                    [cell.relateButton addTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                }
                else
                {
                    cell.contentLabel.text = [NSString stringWithFormat:@"微信账号"];
                    [cell.relateButton removeTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton setTitle:@"绑定" forState:UIControlStateNormal];
                }
                
                [cell.iconImageView setImage:[UIImage imageNamed:@"invite_weichat_on"]];
            }
            else if(indexPath.row == 4)
            {
                
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:RRNICKNAME] length] >0)
                {
                    cell.contentLabel.text = [NSString stringWithFormat:@"人人账号(%@)",[[NSUserDefaults standardUserDefaults] objectForKey:RRNICKNAME]];
                    cell.nametf.frame = CGRectMake(SCREEN_WIDTH - 150, 17, 120, 26);
                    cell.nametf.text = @"";
                    [cell.relateButton removeTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton setTitle:@"解绑" forState:UIControlStateNormal];
                    [cell.relateButton addTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                }
                else
                {
                    cell.contentLabel.text = [NSString stringWithFormat:@"人人账号"];
                    [cell.relateButton removeTarget:self action:@selector(cancelAccount:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.relateButton setTitle:@"绑定" forState:UIControlStateNormal];
                }
                
                [cell.iconImageView setImage:[UIImage imageNamed:@"icon_rr"]];
            }
            cell.nametf.tag = indexPath.row+333;
            cell.nametf.font = [UIFont systemFontOfSize:16];
            cell.nametf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            cell.nametf.enabled = NO;
            cell.contentLabel.frame = CGRectMake(cell.iconImageView.frame.size.width+cell.iconImageView.frame.origin.x+10, cell.iconImageView.frame.origin.y+4, 150, 30);
            cell.contentLabel.font = [UIFont systemFontOfSize:18];
            cell.nametf.returnKeyType = UIReturnKeyDone;
            
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.backgroundColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.accessoryView.backgroundColor = [UIColor whiteColor];
            return cell;
        }
    }
    else if(indexPath.section == 2)
    {
        if (indexPath.row == 1)
        {
            static NSString *authcell = @"section0";
            PersonalSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:authcell];
            if (cell == nil)
            {
                cell = [[PersonalSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:authcell];
            }
            cell.nameLabel.font = [UIFont systemFontOfSize:18];
            cell.nameLabel.textAlignment = NSTextAlignmentLeft;
            cell.headerImageView.hidden = YES;
            
            if (!isAuth)
            {
                cell.nameLabel.hidden = NO;
                cell.nameLabel.text = @"您尚未进行教师认证";
                cell.nameLabel.textColor = USER_NAME_COLOR;
                cell.nameLabel.frame = CGRectMake(20, 13, 200, 20);
                if (!([Tools phone_num] && [[Tools phone_num] length] > 0))
                {
                    cell.objectsLabel.frame = CGRectMake(SCREEN_WIDTH-120, 13, 110, 20);
                    cell.objectsLabel.text = @"请绑定手机号";
                    cell.objectsLabel.font = [UIFont systemFontOfSize:14];
                }
                else if ([accountDict objectForKey:@"t_checked"])
                {
                    if ([[accountDict objectForKey:@"t_checked"] integerValue] == 0)
                    {
                        cell.objectsLabel.frame = CGRectMake(SCREEN_WIDTH-100, 13, 80, 20);
                        cell.objectsLabel.text = @"审核被拒绝";
                        cell.objectsLabel.font = [UIFont systemFontOfSize:14];
                    }
                }
                else if ([accountDict objectForKey:@"img_tcard"])
                {
                    if ([[accountDict objectForKey:@"img_tcard"] length] > 10)
                    {
                        cell.objectsLabel.frame = CGRectMake(SCREEN_WIDTH-100, 13, 80, 20);
                        cell.objectsLabel.text = @"正在审核";
                        cell.objectsLabel.font = [UIFont systemFontOfSize:14];
                    }
                }
                else
                {
                    cell.objectsLabel.text = @"";
                }
                cell.arrowImageView.frame = CGRectMake(SCREEN_WIDTH-20, 16, 10, 15);
                [cell.arrowImageView setImage:[UIImage imageNamed:@"menu_arrow_right"]];
                cell.arrowImageView.backgroundColor = [UIColor whiteColor];
                cell.arrowImageView.hidden = NO;
            }
            else
            {
                cell.nameLabel.hidden = YES;
                cell.arrowImageView.hidden = YES;
            }
            
            
            CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
            UIImageView *lineImageView = [[UIImageView alloc] init];
            lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
            lineImageView.backgroundColor = LineBackGroudColor;
            [cell.contentView addSubview:lineImageView];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.contentView.backgroundColor = [UIColor whiteColor];
            return cell;
        }
        else if (indexPath.row == 2)
        {
            static NSString *authcell = @"section2";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:authcell];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:authcell];
            }
            cell.textLabel.font = [UIFont systemFontOfSize:18];
            cell.textLabel.text = @" 系统设置";
            cell.textLabel.textColor = USER_NAME_COLOR;
            
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
            UIImageView *lineImageView = [[UIImageView alloc] init];
            lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
            lineImageView.backgroundColor = LineBackGroudColor;
            [cell.contentView addSubview:lineImageView];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            UIImageView *arrowImageView = [[UIImageView alloc] init];
            arrowImageView.frame = CGRectMake(SCREEN_WIDTH-20, 16, 10, 15);
            [arrowImageView setImage:[UIImage imageNamed:@"menu_arrow_right"]];
            arrowImageView.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:arrowImageView];
            
            return cell;
        }
        else if (indexPath.row == 0)
        {
            static NSString *authcell = @"changepw";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:authcell];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:authcell];
            }
            if ([[Tools phone_num] length] > 0)
            {
                cell.textLabel.font = [UIFont systemFontOfSize:18];
                cell.textLabel.text = @" 修改密码";
                cell.textLabel.textColor = USER_NAME_COLOR;
                
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.contentView.backgroundColor = [UIColor whiteColor];
                
                CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
                UIImageView *lineImageView = [[UIImageView alloc] init];
                lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
                lineImageView.backgroundColor = LineBackGroudColor;
                [cell.contentView addSubview:lineImageView];
                cell.contentView.backgroundColor = [UIColor whiteColor];
                
                UIImageView *arrowImageView = [[UIImageView alloc] init];
                arrowImageView.frame = CGRectMake(SCREEN_WIDTH-20, 16, 10, 15);
                [arrowImageView setImage:[UIImage imageNamed:@"menu_arrow_right"]];
                arrowImageView.backgroundColor = [UIColor whiteColor];
                [cell.contentView addSubview:arrowImageView];
            }
            
            return cell;
        }

    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
    {
        PersonInfoSettingViewController *personInfoSettiongViewController = [[PersonInfoSettingViewController alloc] init];
        [self.navigationController pushViewController:personInfoSettiongViewController animated:YES];
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            if ([[Tools phone_num] length] == 0)
            {
                ChangePhoneViewController *changePhoneNumVC = [[ChangePhoneViewController alloc] init];
                changePhoneNumVC.changePhoneDel = self;
                [self.navigationController pushViewController:changePhoneNumVC animated:YES];
            }
            else
            {
//                ClassPlusAccountViewController *classPlusViewController = [[ClassPlusAccountViewController alloc] init];
//                classPlusViewController.banjia_number = banjiaNumber;
//                classPlusViewController.reg_method = reg_method;
//                [self.navigationController pushViewController:classPlusViewController animated:YES];
            }
        }
        else
        {
            if (indexPath.row == 3)
            {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:QQNICKNAME] length] <= 0)
                {
                    [self bindThirdAccountWithIndex:indexPath.row];
                }
            }
            else if(indexPath.row == 2)
            {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:SINANICKNAME] length] <= 0)
                {
                    [self bindThirdAccountWithIndex:indexPath.row];
                }
            }
            else if(indexPath.row == 1)
            {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:WXNICKNAME] length] <= 0)
                {
                    [self bindThirdAccountWithIndex:indexPath.row];
                }
            }
            
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 1)
        {
            if (!([Tools phone_num] && [[Tools phone_num] length] > 0))
            {
                [Tools showAlertView:@"请先绑定手机号" delegateViewController:nil];
                return ;
            }
            
            AuthViewController *authViewController = [[AuthViewController alloc] init];
            authViewController.authImageDoneDel = self;
            if ([accountDict objectForKey:@"img_id"])
            {
                authViewController.img_id = [accountDict objectForKey:@"img_id"];
            }
            else
            {
                authViewController.img_id = @"";
            }
            if ([accountDict objectForKey:@"img_tcard"])
            {
                authViewController.img_tcard = [accountDict objectForKey:@"img_tcard"];
            }
            else
            {
                authViewController.img_tcard = @"";
            }
            [self.navigationController pushViewController:authViewController animated:YES];
        }
        else if (indexPath.row == 2)
        {
            [self settingClick];
        }
        else if (indexPath.row == 0)
        {
            ResetPwdViewController *resetPwdViewController = [[ResetPwdViewController alloc] init];
            [self.navigationController pushViewController:resetPwdViewController animated:YES];
        }
    }
}
-(void)authImageDone
{
    [self getAccount];
}

#pragma mark - loginAccount
static int loginID;
- (void)clickedThirdLoginButton:(UIButton *)button
{
    [self bindThirdAccountWithIndex:button.tag-1000];
}

-(void)bindThirdAccountWithIndex:(NSInteger)index
{
    switch (index)
    {
        case 3:
            loginID = ShareTypeQQSpace;
            
            break;
        case 2:
            loginID = ShareTypeSinaWeibo;
            
            break;
        case 4:
            loginID = ShareTypeRenren;
            break;
        case 1:
            loginID = ShareTypeWeixiTimeline;
            
            break;
            
        default:
            break;
   ; }
    
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
    
    [ShareSDK getUserInfoWithType:loginID
                      authOptions:authOptions
                           result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error)
     {
         if (result)
         {
             DDLOG(@"success=%@==%@",[userInfo uid],[userInfo nickname]);
             if (loginID == ShareTypeSinaWeibo)
             {
                 //sina
                 sinaNickName = [userInfo nickname];
                 [self relateAccount:[userInfo uid] accountType:@"sw" andName:sinaNickName];
                 
             }
             else if(loginID == ShareTypeQQSpace)
             {
                 //qq
                 qqNickName = [userInfo nickname];
                 [self relateAccount:[userInfo uid] accountType:@"qq" andName:qqNickName];
                 
             }
             else if(loginID == ShareTypeRenren)
             {
                 //ren ren
                 rrNickName = [userInfo nickname];
                 [self relateAccount:[userInfo uid] accountType:@"rr" andName:rrNickName];
                 
             }
             else if(loginID == ShareTypeWeixiTimeline)
             {
                 //ren ren
                 wxNickName = [userInfo nickname];
                 [self relateAccount:[userInfo uid] accountType:@"wx" andName:wxNickName];
                 
             }
         }
         else
         {
             NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
             [ShareSDK cancelAuthWithType:loginID];
         }
     }];
}

-(void)cancelAccount:(UIButton *)button
{
    
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要解除绑定吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"解除", nil];
    al.tag = button.tag;
    [al show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *acctype = @"";
    if (buttonIndex == 1)
    {
        switch (alertView.tag-1000)
        {
            case 3:
            {
                loginID = ShareTypeQQSpace;
                acctype = @"qq";
                
                break;
            }
            case 2:
            {
                loginID = ShareTypeSinaWeibo;
                acctype = @"sw";
                
                break;
            }
            case 4:
            {
                loginID = ShareTypeRenren;
                acctype = @"rr";
                break;
            }
            case 1:
            {
                loginID = ShareTypeWeixiTimeline;
                acctype = @"wx";
                break;
            }
            default:
                break;
        }
    
        [self unBindAccount:acctype];
    }
}

-(void)unBindAccount:(NSString *)accountType
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"a_type":accountType,
                                                                      } API:UNBINDACCOUNT];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"bind responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showTips:@"成功解绑" toView:self.bgView];
                if (loginID == ShareTypeRenren)
                {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:RRNICKNAME];
                }
                else if(loginID == ShareTypeSinaWeibo)
                {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SINANICKNAME];
                }
                else if(loginID == ShareTypeQQSpace)
                {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:QQNICKNAME];
                }
                else if(loginID == ShareTypeWeixiTimeline)
                {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WXNICKNAME];
                }
                [[NSUserDefaults standardUserDefaults] synchronize];
                [ShareSDK cancelAuthWithType:loginID];
                
                [personalSettiongTableView reloadData];
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

-(void)relateAccount:(NSString *)account accountType:(NSString *)accountType andName:(NSString *)name
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"a_id":account,
                                                                      @"a_type":accountType,
                                                                      @"n_name":name
                                                                      } API:BINDACCOUNT];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"bind responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showTips:@"成功绑定" toView:self.bgView];
                if ([accountType isEqualToString:@"sw"])
                {
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:sinaNickName forKey:SINANICKNAME];
                    [ud synchronize];
                }
                else if([accountType isEqualToString:@"qq"])
                {
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:qqNickName forKey:QQNICKNAME];
                    [ud synchronize];
                }
                else if([accountType isEqualToString:@"rr"])
                {
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:rrNickName forKey:RRNICKNAME];
                    [ud synchronize];
                }
                else if([accountType isEqualToString:@"wx"])
                {
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:wxNickName forKey:WXNICKNAME];
                    [ud synchronize];
                }
                [personalSettiongTableView reloadData];
            }
            else
            {
                if ([accountType isEqualToString:@"sw"])
                {
                    [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
                }
                else if([accountType isEqualToString:@"qq"])
                {
                    [ShareSDK cancelAuthWithType:ShareTypeQQSpace];
                }
                else if([accountType isEqualToString:@"rr"])
                {
                    [ShareSDK cancelAuthWithType:ShareTypeRenren];
                }
                else if([accountType isEqualToString:@"wx"])
                {
                    [ShareSDK cancelAuthWithType:ShareTypeWeixiTimeline];
                }
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

#pragma mark - changePhoneNum
-(void)changePhoneNum:(BOOL)changed
{
    if (changed)
    {
        [personalSettiongTableView reloadData];
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

#pragma mark - getUserInfo
-(void)getAccount
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token]
                                                                      } API:GETACCOUNTLIST];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"accountlist responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                accountDict = [responseDict objectForKey:@"data"];
                if ([accountDict objectForKey:@"t_checked"])
                {
                    if ([[accountDict objectForKey:@"t_checked"] integerValue] == 1)
                    {
                        isAuth = YES;
                    }
                    else
                    {
                        isAuth = NO;
                    }
                }
                else
                {
                    isAuth = NO;
                }
                
                if (![[accountDict objectForKey:@"qq"]isEqual:[NSNull null]] && [[accountDict objectForKey:@"qq"] length] > 0)
                {
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:[accountDict objectForKey:@"qq"] forKey:QQNICKNAME];
                    [ud synchronize];
                }
                if (![[accountDict objectForKey:@"rr"]isEqual:[NSNull null]] && [[accountDict objectForKey:@"rr"] length] > 0)
                {
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:[accountDict objectForKey:@"rr"] forKey:RRNICKNAME];
                    [ud synchronize];
                }
                if (![[accountDict objectForKey:@"sw"] isEqual:[NSNull null]] && [[accountDict objectForKey:@"sw"] length] > 0)
                {
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:[accountDict objectForKey:@"sw"] forKey:SINANICKNAME];
                    [ud synchronize];
                }
                if (![[accountDict objectForKey:@"wx"] isEqual:[NSNull null]] && [[accountDict objectForKey:@"wx"] length] > 0)
                {
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:[accountDict objectForKey:@"wx"] forKey:WXNICKNAME];
                    [ud synchronize];
                }
                if (![[accountDict objectForKey:@"phone"]isEqual:[NSNull null]] && [[accountDict objectForKey:@"phone"] length] > 0)
                {
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:[accountDict objectForKey:@"phone"] forKey:PHONENUM];
                    [ud synchronize];
                }
                [personalSettiongTableView reloadData];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error.description);
        }];
        [request startAsynchronous];
    }
}

-(void)getUserInfo
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"other_id":[Tools user_id]
                                                                      } API:MB_GETUSERINFO];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"getuserinfo responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue] == 1)
            {
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"number"] intValue] > 0)
                {
                    banjiaNumber = [NSString stringWithFormat:@"%d",[[[responseDict objectForKey:@"data"] objectForKey:@"number"] intValue]];
                    [[NSUserDefaults standardUserDefaults] setObject:banjiaNumber forKey:BANJIANUM];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                else
                {
                    banjiaNumber = @"";
                }
                if ([[responseDict objectForKey:@"data"] objectForKey:@"reg_method"] && [[[responseDict objectForKey:@"data"] objectForKey:@"reg_method"] length] > 0)
                {
                    reg_method = [[responseDict objectForKey:@"data"] objectForKey:@"reg_method"];
                }
                else
                {
                    reg_method = @"";
                }
                
                gf = [[[responseDict objectForKey:@"data"] objectForKey:@"jf"] intValue];
                [personalSettiongTableView reloadData];
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
    else if (![WXApi isWXAppInstalled] && ![QQApi isQQInstalled])
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"转发到" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"新浪微博",@"腾讯微博",@"人人网", nil];
        [actionSheet showInView:self.bgView];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ShareType shareType;
    if (buttonIndex == [actionSheet numberOfButtons]-1)
    {
        return;
    }
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

    NSString *tmpImagePath = [[NSBundle mainBundle] pathForResource:@"logo120" ofType:@"png"];
    id<ISSCAttachment> attchment = [ShareSDK imageWithPath:tmpImagePath];
    ShareTools *shareTools = [[ShareTools alloc] init];
    shareTools.shareContentDel = self;
    [shareTools shareTo:shareType andShareContent:ShareContent andImage:attchment andMediaType:SSPublishContentMediaTypeNews description:ShareContent andUrl:ShareUrl];
}

-(void)shareSuccess
{
    [Tools showTips:@"分享成功！" toView:self.bgView];
}

- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CGPointMake(CENTER_POINT.x,CENTER_POINT.y);
    }completion:^(BOOL finished) {
    }];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    if (iPhone5)
    {
        self.bgView.center = CGPointMake(CENTER_POINT.x,CENTER_POINT.y-height+150);
    }
    else
    {
        self.bgView.center = CGPointMake(CENTER_POINT.x,CENTER_POINT.y-height);
    }
}

@end
